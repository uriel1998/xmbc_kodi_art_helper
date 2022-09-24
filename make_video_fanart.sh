#!/bin/bash

##############################################################################
#
#  make_video_fanart
#  (c) Steven Saus 2022
#  Licensed under the MIT license
#
#   to create thumbnails for videos in media directory. Uses ffmpeg
#   should leave existing thumbnails alone.
#
##############################################################################

### THIS IS MOSTLY WORKING, AND POORLY DOCUMENTED.

#######
#MAIN
######

    # need to add test to find directories with subdirectories starting with Season to get fanart
    # for entire series
    # if [ $(find /target/directory -type d -name "prefix*" | wc -l ) != "0" ] ; then
    #    echo something was found
    # else
   # echo nope, didn't find anything
    # fi
    # we need to walk the video directory and find art.
    # http://stackoverflow.com/questions/12873834/list-directories-not-containing-certain-files
    # http://stackoverflow.com/questions/5374239/tab-separated-values-in-awk
    
    find . -iname "*.mp4" -or -iname "*.mp4" -or -iname "*.mkv" -or -iname "*.mpeg" -or -iname "*.avi" -or -iname "*.mov" -or -iname "*.mkv" -or -iname "*.wmv"  | sort -u | while read vidfile
    do
        viddirrel=$(echo "$vidfile" | sed -e 's!/[^/]*$!!' -e 's!^\./!!')
        vidbase=`basename "$vidfile"`
        vidbasefilename=${vidbase%.*}
        if [ "$viddirrel" = "." ];then
            viddir="$PWD"
        else
            viddir="$PWD/$viddirrel"
        fi
        vidfullfn="$viddir/$vidbase"
#       echo "$viddir"
        #You don't have fanart INSIDE tv show Season folders.
        if [[ ${viddir} != *"Season"* ]];then 
            if [ -f "$vidfullfn" ];then
                if [ ! -f "$viddir/fanart.jpg" ]; then  
                    echo "Didn't find $viddir/fanart.jpg"
                    echo "Creating thumbnail"
                    # from http://superuser.com/questions/238073/make-thumbnail-from-video
                    # Get the time as h:m:s (non-padded)
                    l=$(ffmpeg -i "$vidfullfn" 2>&1 | grep Duration: | sed -r 's/\..*//;s/.*: //;s/0([0-9])/\1/g')
                    # Convert that into seconds
                    s=$((($(cut -f1 -d: <<< "$l") * 60 + $(cut -f2 -d: <<< "$l")) * 60 + $(cut -f3 -d: <<< "$l")))
                    # Get frame at 25% as the thumbnail
                    ffmpeg -ss $((s / 2)) -y -i "$vidfullfn" -r 1 -frames 1 "$viddir/fanart.jpg"
                fi
            fi
            #Test for size
            fanartsize=$(identify "$viddir"/fanart.jpg | awk '{print $3}')
#           echo "$fanartsize"
#           read
            if [ "$fanartsize" != "1920x1080" ];then
                echo "Resizing fanart in $viddir"
                convert "$viddir/fanart.jpg" -resize 1920x1080^ -gravity center -extent 1920x1080 "$viddir/fanart.jpg"
            fi  
        fi
    done






