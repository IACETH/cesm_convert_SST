# Convert the ocean output from a B-type simulation to force an F-type simulation

Convert SST and Sea Ice from POP output do DOCN input

## Sources
* NCAR [description](http://www.cesm.ucar.edu/models/cesm1.2/cesm/doc/usersguide/x2306.html). I adapted it for `CDO` instead of `ncdump`. 
* Jan Sedlacek had his own version of this conversion from which I took the code for `grid_fill.ncl`.

## Warning

#### Linear Interpolation
DOCN uses the monthly mean fields of SST and Sea Ice and linearly interpolates between them. The interpolated then causes the monthly means to not be equal. In the NCAR [description](http://www.cesm.ucar.edu/models/cesm1.2/cesm/doc/usersguide/x2306.html) they mention a way to avoid this, however, the necessary files are not available.

#### Spatial Interpolation
The output of POP is on a rotated grid which we here convert to a regular grid. After reading from the regular grid DOCN regrids this again to the rotated grid. This is of course not very clever, one should instead keep the original grid and tell POP to use this.

#### Discrepancy

When I compare the B and F simulation I get a temperature anomaly in Northern High latitudes, most likely due to a Sea Ice effect (probably due to the linear interpolation). I have not looked in to that.

## Usage

The main script is `create_SST_forcing.sh`. It executes the `CDO` commands and calls the `python` and `ncl` script. You need to change some parameters in `create_SST_forcing.sh` to run the file:

* `casename`: name of the simulation
* `root`: folder where the simulation is stored
* `dest`: folder to write the output to
* `first`: first year to use
* `last`: last year to use

For `first` and `last` I recommend to use all years in the B simulation, even if you don't want to simulate all years in the `F` simulation.

Run `.\create_SST_forcing.sh` and wait...

## Further Hints

Tell CESM to use your input file (must be an F-type simulation):

```bash
# year when your simulation starts (and not the start of your SST dataset!)
start_year=1950
# year when your simulation starts (and not the start of your SST dataset!)
end_year=1950
# name of the B simulation
CONTROL=B...

# set the SST and ICE forcing file
./xmlchange -file env_run.xml -id SSTICE_DATA_FILENAME -val /path/to/file/SST_ICE_${CONTROL}.nc

./xmlchange -file env_run.xml -id SSTICE_YEAR_ALIGN -val ${start_year}
./xmlchange -file env_run.xml -id SSTICE_YEAR_START -val ${start_year}
./xmlchange -file env_run.xml -id SSTICE_YEAR_END -val ${end_year}
```

## Helper Files

##### griddes_1x1.txt
CDO grid description of the usual 1° x 1° ocean input file at `cesm/inputdata/atm/cam/sst`

    cdo griddes sst_HadOIBl_bc_1x1_1850_2012_c130411.nc

##### grid_fill.ncl
Fills the continents with interpolated data. This is important for costal regions if the ocean has another resolution than the inputfile (which it usually does).

##### change_time.py
POP uses `days since 0-01-01 00:00:00` as netCDF time string. However, DOCN can not read this time string, so we use python to shift the time axis to 1850.

## Conversion
* Sea Surface Temperatures
    * extract `TEMP`
    * select the uppermost level
    * rename `TEMP` to `SST_cpl`
    * regrid to 1° x 1°
    * interpolate to continents
* Sea Ice
    * extract `aice`
    * convert from percent to fraction
    * rename `aice` to `ice_cov`
    * regrid to 1° x 1°
    * interpolate to continents
* Concatenate all files
* Merge SST and Sea Ice file

