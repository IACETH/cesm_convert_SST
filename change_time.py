#!/usr/bin/env python
# -*- coding: utf-8 -*-

#Author: Mathias Hauser
#Date: 

import netCDF4 as nc
import sys


def main(filename):
    """
    change the calendar of the SSTs and Ice cover data

    """

    with nc.Dataset(filename, 'a') as ncf:

        # check if the units are right
        units = ncf.variables['time'].units
        if units != "days since 0-01-01 00:00:00" and units != "days since 0-1-1 00:00:00":
            raise RuntimeError("units is not 'days since 0-01-01 00:00:00'")

        # check if the calendar is right
        calendar = ncf.variables['time'].calendar
        if calendar != "365_day":
            raise RuntimeError("calendar is not '365_day'")


        # we want a more current calendar
        new_units = "days since 1850-01-01 00:00:00"

        # need to subtract days
        time_offset = 365 * 1850

        # adjust 
        ncf.variables['time_bnds'][:] -= time_offset
        # we want the time in the middle of the month
        ncf.variables['time'][:] = ncf.variables['time_bnds'][:].mean(axis=1)
        # adjust the units
        ncf.variables['time'].units = new_units


if __name__ == '__main__':


    if len(sys.argv) < 2:
        raise ValueError("command line argument needed")
    
    filename = sys.argv[1]


    main(filename)


