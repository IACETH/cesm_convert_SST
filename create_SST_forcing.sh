#! /bin/bash



# AFTER
# http://www.cesm.ucar.edu/models/cesm1.2/cesm/doc/usersguide/x2306.html
# and the script from Jan Sedlacek

# ----------------------------------------------------------------------
# USER INPUT

casename=b.e122.B_RCP8.5_CAM5_CN.f19_g16.io144.580

# folder with SST data
root=/net/meso/climphys/cesm122/${casename}/archive/
# destination folder
dest=/net/exo/landclim/mathause/SST_forcing/data/

first=2006
last=2099


# END USER INPUT
# ----------------------------------------------------------------------

# we need ncl
module load ncl

root_ocn=${root}ocn/hist/
root_ice=${root}ice/hist/

file_root_ocn=${casename}.pop.h.
file_root_ice=${casename}.cice.h.


year=$first; monthi=01
# create weight for interpolation (is faster)
if [ ! -f weight_ocn.nc ]; then
	file_ocn=${file_root_ocn}${year}-${monthi}.nc
	ifile=${root_ocn}${file_ocn}
	cdo genbil,griddes_1x1.txt -selvar,TEMP ${ifile} weight_ocn.nc
fi

# ice can not be bilinearly interpolated
if [ ! -f weight_ice.nc ]; then
	file_ice=${file_root_ice}${year}-${monthi}.nc
	ifile=${root_ice}${file_ice}
	cdo gencon,griddes_1x1.txt ${ifile} weight_ice.nc
fi

for year in $(seq $first $last)
do

	echo ${year}
	for month in {1..12}
	do
		monthi=`printf "%02d" $month`

		echo ${month}


		# =====================================================================
		# PREPARE OCEAN
		# =====================================================================		

		file_ocn=${file_root_ocn}${year}-${monthi}.nc
		
		ifile=${root_ocn}${file_ocn}
		ofile=${dest}reggrid_${file_ocn}
		
		if [ ! -f ${ofile} ]; then
			cdo remap,griddes_1x1.txt,weight_ocn.nc `# regrid to 1x1 deg`\
				-chname,TEMP,SST_cpl `# rename`\
			    -sellevel,500 `# sel topmost level`\
			    -selname,TEMP `# we need TEMP`\
			    ${ifile} ${ofile}
		fi

		ifile=${ofile}
		ofile=${dest}gridfill_${file_ocn}

		if [ ! -f ${ofile} ]; then
			# fill the continents
			s1=ifile=\"${ifile}\"
			s2=ofile=\"${ofile}\"
			s3=varname=\"SST_cpl\"

			# rm ${ofile}
			ncl $s1 $s2 $s3 grid_fill.ncl >&/dev/null

		fi


		# =====================================================================
		# PREPARE SEA ICE
		# =====================================================================

		file_ice=${file_root_ice}${year}-${monthi}.nc

		ifile=${root_ice}${file_ice}
		ofile=${dest}reggrid_${file_ice}



		if [ ! -f ${ofile} ]; then
			cdo remap,griddes_1x1.txt,weight_ice.nc `# regrid to 1x1 deg`\
			    -chname,aice,ice_cov `# rename`\
			    -divc,100 `# convert from percent to fraction`\
			    -selname,aice `# we need aice`\
			    ${ifile} ${ofile}
		fi

		ifile=${ofile}
		ofile=${dest}gridfill_${file_ice}

		# fill the continents
		if [ ! -f ${ofile} ]; then

			s1=ifile=\"${ifile}\"
			s2=ofile=\"${ofile}\"
			s3=varname=\"ice_cov\"

			ncl $s1 $s2 $s3 grid_fill.ncl >&/dev/null

		fi
	done
done


year=????
monthi=??

# =====================================================================
# Concatenate OCEAN
# =====================================================================

file_ocn=${file_root_ocn}${year}-${monthi}.nc
ifiles=${dest}gridfill_${file_ocn}
cdo cat ${ifiles} ${dest}SST_cpl.nc

# =====================================================================
# Concatenate Sea Ice
# =====================================================================

file_ice=${file_root_ice}${year}-${monthi}.nc
ifiles=${dest}gridfill_${file_ice}
cdo cat ${ifiles} ${dest}ice_cov.nc

# =====================================================================
# Merge Ocean and Sea Ice
# =====================================================================
cdo merge ${dest}SST_cpl.nc ${dest}ice_cov.nc ${dest}SST_ICE_${casename}.nc


# =====================================================================
# Change Time
# =====================================================================
python change_time.py ${dest}SST_ICE_${casename}.nc
