#! /bin/bash
#
# This script will take the contents of assorted tar files and extract them to
# a squashfs read-only filesystem. The script will be run as the root user.
# The source tar files will be assumed to be located under /INSTALL. Each
# compressed tar file will have a filename format of <partno>-<datetime>.tar.bz2.
# The field partno is a text descriptor of the part that will be installed. It
# will be composed of alphanumeric characters and the hyphen character. It will
# always start with a letter. 
# The field datetime will be a representation of the time the part was created.
# It will be formatted as yyyymmddHHMMSS, following the conventions of the date
# command. There can be more than a single file with the same partno
# identifier, but each will have a unique datetime field. Only the most recent
# part should be copied over to the installation.
# The squashfs file should be named install.squashfs and be created in the
# present working directory. If there is a preexisting install.squashfs file it
# should be moved to be a backup file named install.squashfs.bkup<no> where
# <no> is a counter to uniquely identify the backup file. 
# When created, the squashfs should contain the contents of each tar file
# extracted to the location opt/<partno>, where <partno> corresponds to the
# part name used in the tarfile.  The script should return an error code if any
# of the operations fail. In the case of a failure, it's expected that any
# partially created files will be removed and any filesystems mounted during
# execution will be safely unmounted.

# This script has the following functions:
# sep_partno  - splits the .bz2 filename into a part number and a date.
# make squashfs - makes a squashfs file
# 

for tar_file in /INSTALL/*.bz2; do
  partno=$(sep_partno tar_file)
  

