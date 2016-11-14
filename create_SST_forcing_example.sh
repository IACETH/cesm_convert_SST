#! /bin/bash

########################################################
######### Create SST and Sea Ice forcing files #########
########################################################

# AFTER
# http://www.cesm.ucar.edu/models/cesm1.2/cesm/doc/usersguide/x2306.html
# and the script from Jan Sedlacek

# I would name this script: 
# create_SST_forcing_b.e122.B_RCP8.5_CAM5_CN.f19_g16.io144.580.sh

# ----------------------------------------------------------------------
# Required USER INPUT

casename=b.e122.B_RCP8.5_CAM5_CN.f19_g16.io144.580

# folder with SST data
root=/net/meso/climphys/cesm122/${casename}/archive/
# destination folder
dest=/net/exo/landclim/${USER}/SST_forcing/data/

first=2006
last=2099

# END USER INPUT
# ----------------------------------------------------------------------

# source the create_SST_forcing.sh

. ./generate_SST_forcing.sh
