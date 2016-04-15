# Sasquatch v0.21 #
This library contains necessary classes for reading binary sas files.  Sasquatch is a AS3 library for reading data sets in the .sas7bdat format, commonly used in the SAS statistical software system.

I have included in the downloads section an installer for a application I built using this library.  It is built in Adobe AIR so it should run on all OS that support that.

The majority of the work in this project is derived from Matt Shotwell's [sas7bdat](https://github.com/BioStatMatt/sas7bdat) project, an R-based SAS reader and the SassyReader project from [eobjects.org](http://sassyreader.eobjects.org)

## Current Features ##
  1. Load SAS File ( Created with 32-bit version of SAS )
  1. Read SAS Columns: Names, Labels, DataTypes & Formats
  1. Read All Data for Sas file and returns row data.

## Planned Features ##
  1. ~~Reading SAS Formats from Catalog File ( sas7bcat )~~
  1. Reading SAS Formats from SAS generated Formats XML file
  1. Filtering
  1. Data Visualization
  1. Read files created with 64-bit version of SAS