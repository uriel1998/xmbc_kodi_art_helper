#!/bin/bash

##############################################################################
#
#  copy_all_fanart
#  (c) Steven Saus 2022
#  Licensed under the MIT license
#
#   To get all the fanart from a video directory (e.g. Kodi, Plex, etc) 
#   and copy it to a specified directory.
#
#   copy_all_fanart [--shastore /path/to/file] [--clear] /sourcedir /outdir [PATTERN}
#   
#   No trailing slash on paths. 
#  
#   Cache of checksums persists so you can keep adding to the out directory, 
#   knowing that you arere not duplicating.
#   
#   To specify the SHASTORE (so you can use this with multiple OUT directories)
#
#   --shastore /full/file/path/to/sha_store 
#    It defaults to using ${XDG_DATA_HOME}/fanart_copier_shastore.txt
#  
#   To clear the SHASTORE in use, pass --clear 
#
#   Optionally, use [PATTERN] for the filename pattern before the numbering
#  
##############################################################################


if [ ! -d "${XDG_DATA_HOME}" ];then
    export XDG_DATA_HOME="${HOME}/.local/share"
fi


# mechanism to clear the SHASTORE
if [ "${1}" == "--shastore" ];then
    shift
    SHASTORE="${1}"
    shift
    touch "${SHASTORE}"
    if [ -f "${SHASTORE}" ];then
        echo "Using specified SHASTORE file of ${SHASTORE}"
    else
        echo "Unable to find or create ${SHASTORE}"
        exit 
    fi
fi


# I want this persistent so I can put multiple runs in it.
export SHASTORE="${XDG_DATA_HOME}/fanart_copier_shastore.txt"


# mechanism to clear the SHASTORE
if [ "${1}" == "--clear" ];then
    shift
    truncate -s 0 "${SHASTORE}"
    echo "Cleared ${SHASTORE};"
    echo "If there are files in the output directory they will NOT be checked against."
    exit
fi

BaseDir="$1"
OutDir="$2"
Pattern="$3"

if [ "${Pattern}" == "" ];then
    Pattern="fanart_"
fi

FileCheck=""
if [ -f $(which rg) ];then
    grep_bin=$(which rg)
else
    grep_bin=$(which grep)
fi

check_files () {
    infile="${1}"
    evalstring=$(printf "sha1sum \"%s\" | awk \'{print \$1 }\'" "${infile}")
    file1=$(eval "${evalstring}")
    # file1=$(sha1sum "${1}" | awk '{print $1}')
    isfound=$("${grep_bin}" -c "${file1}" "${SHASTORE}")
    if [ -z "$isfound" ];then isfound=0;fi
    if [ $isfound -gt 0 ];then
        FileCheck="SAME"
    else
        FileCheck=""
        echo "$file1" >> "${SHASTORE}"
    fi
    
}


echo "$BaseDir"
bob=$(find "${BaseDir}" -type f -name "*fanart*") 
OIFS=$IFS
IFS=$'\n'
for line in `echo "$bob"`
    do
        filename=$(basename -- "$line")
        FileExt="${filename##*.}"
        echo "Checking sha1sums of ${line} for duplicates..."
        check_files "${line}" "${OutDir}"
        if [ "$FileCheck" != "SAME" ];then
            Number=0
            DestFileName=$(printf "%s/%s%05d.%s" "${OutDir}" "${Pattern}" "${Number}" "${FileExt}")
            while [ -f "${DestFileName}" ];do
                (( Number++ ))
                DestFileName=$(printf "%s/%s%05d.%s" "${OutDir}" "${Pattern}" "${Number}" "${FileExt}")
            done
            #echo "COPYING TO ${DestFileName}"
            cp "${line}" "${DestFileName}"
            FileCheck=""
        else
            echo "#${line} checksum exists, skipping."
        fi
    done
IFS=$OIFS
rm "${SHASTORE}"
exit



