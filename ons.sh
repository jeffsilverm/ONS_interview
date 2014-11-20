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

# bash is a terrible language for implementing such a complicated problem, it
# would be much simpler in perl or python

# This script has the following functions:
# sep_partno  - splits the .bz2 filename into a part number and a date.
# make_squashfs - makes a squashfs file.  Saves an existing squash file
#
LOGFILE="~/ons_logfile.txt"

function make_squashfs() {
# This function creates a new squashfs file, install.squashfs.  If a squashfs
# file already exists then rename it to install_squashfs.bkup_NUM
if [ -e install.squashfs ]; then
  if [ -e install.squashfs.bkup* ]; then
# We have to pick the latest numbered backup file.  I make the simplifying
# assumption that the chronologically last file is also the lexigraphically
# last file.  The -r switch to sed tells it to use extended regular expressions.
# I have to use sed to convert multiple spaces to single tab characters for cut
    lastfile=(ls -1 -ort | tail -1 | sed -r 's/ +/\t/g' | cut -f 8)
    echo "last install.squashfs.bkup file is ${lastfile}">> $LOGFILE
# pickup the number by spliting the filename on the _ delimiter
    arr=$($(echo $lastline | tr "_" "\n")
# From https://www.silviogutierrez.com/blog/getting-last-element-bash-array/
    LENGTH=${#arr[@]} # Get the length.                                          
    LAST_POSITION=$((LENGTH - 1)) # Subtract 1 from the length.                   
    number=${arr[${LAST_POSITION}]} # Get the last position.
    new_number=$((number+1))
    echo "Moving install.squashfs.bkup to install.squashfs.bkup_${new_number}" \
		 >> $LOGFILE
    mv install.squashfs.bkup install.squashfs.bkup_${new_number}
  else
# no backup file exists, but a copy of install.squashfs exists, so rename it.
# The requirements do not say how many copies of the backup file might exist,
# hopefully 10000 will be enough.  TODO - put in code that throws an error if
# this assumption is wrong
    mv install.squashfs.bkup install.squashfs.bkup_0001
else
  echo "No install.squashfs exists" >> $LOGFILE
fi
}

function sep_partno() {
# This function, when given a string of the form
# abcd-efgh-gijk-yyyymmddHHMMSS.tar.bz2
# The partno is the abcd-efgh-gijk part.  There will be zero to many -.
# Implementation detail: the last (rightmost) hyphen always separates the date
# from the partno.
  string=$1
  arr=$($(echo $string | tr "-" "\n")
  LENGTH=${#arr[@]} # Get the length.                                          
  LAST_POSITION=$((LENGTH - 1)) # Subtract 1 from the length.                   
  date_stamp=${arr[${LAST_POSITION}]} # Get the date stamp
  echo "The date_stamp of ${string} is ${date_stamp}" >> $LOGFILE

  

}


for tar_file in /INSTALL/*.bz2; do
  partno=$(sep_partno tar_file $tar_file)
  

