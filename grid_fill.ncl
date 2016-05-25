
;**********************************
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"  
;************************************************

begin


; CHECK INPUT

if (.not. isvar("ifile") .or. .not. isvar("ofile") .or. .not. isvar("varname")) then
    print("Please give ifile ofile and per command line argument like so:")
    ;print("ncl 'ifile=''ifile.nc''' 'ofile=''ofile.nc'' 'varname=''TEMP''' grid_fill.ncl")
end if


; from Jan Sedlacek
nscan = 200              ; usually *much* fewer
eps   = 0.001            ; variable depended
gtype = False            ; "gendat" does not generate cyclic fields
guess = 0                ; use zonal means
relc  = 0.6              ; standard relaxation coef
opt   = 0

; load in data
in = addfiles(ifile, "r")
var = in[:]->$varname$
time_bnds = in[:]->time_bnds
; need to get rid of the z dimension
; this is not elegant
if (dimsizes(dimsizes(var)) .eq. 4) then
    delete(var)
    var = in[:]->$varname$(:, 0, :, :)
end if


; fill the continents with reasonably sensible data
poisson_grid_fill(var, gtype, guess, nscan, eps, relc, opt)


fout = addfile(ofile,"c")

fout->$varname$=var
fout->time_bnds=time_bnds
end




