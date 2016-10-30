#!/bin/bash
# http://stackoverflow.com/questions/29920839/shell-script-to-copy-and-prepend-folder-name-to-files-from-multiple-subdirectori

    if [ ! -d "$2" ]; then 
		mkdir "$2"
	fi
	echo "$1"/*
    for folder in "$1"/*; do
    if [[ -d $folder ]]; then
		echo "$folder"
        foldername="${folder##*/}"
        filepath="$folder"/fanart.jpg
        echo "$filepath"
        if [[ -f "$filepath" ]]; then
            newfilename="$foldername"_fanart.jpg
           cp "$filepath" "$2"/"$newfilename"
        fi
    fi
    done
