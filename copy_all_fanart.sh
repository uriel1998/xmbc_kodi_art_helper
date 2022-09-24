#!/bin/bash

########################################################################
#
#   To get all the fanart from a video directory (e.g. Kodi, Plex, etc) 
#   and copy it to a specified directory.
#
#   To do - add checksum for original and copied so it can skip those
#
########################################################################


BaseDir="$1"
OutDir="$2"
FileCheck=""

check_files () {
    file1=$(sha1sum "${1}" | awk '{print $1}')
    dir="${2}"
    
    files_to_check=$(ls -A )
    FileCheck=""
    bob2=$(find "${2}" -type f) 

    for file2 in `echo "$bob2"`
    do
        if [ -f "$file2" ];then 
            file2=$(sha1sum "$file2" | awk '{print $1}')
            if [ "$file1" == "$file2" ];then
                FileCheck="SAME"
            fi
        fi
    done
}

symlink_to_mass_folder (){
    rm -rf /home/steven/documents/static_bkgds_kodi/all_fanart/*

    ln -s -f /home/steven/documents/static_bkgds_kodi/tv/* /home/steven/documents/static_bkgds_kodi/all_fanart/
    ln -s -f /home/steven/documents/static_bkgds_kodi/concerts/* /home/steven/documents/static_bkgds_kodi/all_fanart/
    ln -s -f /home/steven/documents/static_bkgds_kodi/movies/* /home/steven/documents/static_bkgds_kodi/all_fanart/
}

# http://stackoverflow.com/questions/29920839/shell-script-to-copy-and-prepend-folder-name-to-files-from-multiple-subdirectori
# https://stackoverflow.com/questions/9612090/how-to-loop-through-file-names-returned-by-find#9612232

# Currently loops through twice! whoops
echo "$BaseDir"
bob=$(find "$BaseDir" -type f -name "*fanart*") 
for line in `echo "$bob"`
    do
        echo "$line"
        filename=$(basename -- "$line")
        FileExt="${filename##*.}"
        echo "Checking sha1sums for duplicates..."
        check_files "${line}" "${OutDir}"
        if [ "$FileCheck" != "SAME" ];then
            Number=0
            DestFileName=$(printf "%s/fanart_%05d.%s" "${OutDir}" "${Number}" "${FileExt}")
            while [ -f "${DestFileName}" ];do
                (( Number++ ))
                DestFileName=$(printf "%s/fanart_g%05d.%s" "${OutDir}" "${Number}" "${FileExt}")
            done
            echo "COPYING TO ${DestFileName}"
            cp "${line}" "${DestFileName}"
            FileCheck=""
        else
            echo "${line} checksum exists, skipping."
        fi
    done
exit



