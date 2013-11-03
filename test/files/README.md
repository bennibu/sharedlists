Example files to test import filters. Please note that prices and other
information have been changed somewhat randomly.

The files named "*_file_*.{csv,odt,xls}" are picked up by a unit test.
The first part of the filename is the file format (one of the keys of
`FileHelper::file_formats`).

The file with the extension ".yml" is the parsed result.

An optional file with the extension ".opts" is a yaml file with the
options given to the file format parser.
