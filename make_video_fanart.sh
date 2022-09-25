#!/bin/bash

##############################################################################
#
#  make_video_fanart
#  (c) Steven Saus 2022
#  Licensed under the MIT license
#
#   to create thumbnails for videos in media directory. Uses ffmpeg
#   should leave existing thumbnails alone.
#   INDIR is first
#   --thumbnail
#   --fanart
#   --poster
##############################################################################
    
BaseDir="$1"
Poster=""
Fanart=""
Thumbnail=""

if [[ "$@" =~ "--fanart" ]];then
    Fanart=1
fi

if [[ "$@" =~ "--thumbnail" ]];then
    Thumbnail=1
fi
if [[ "$@" =~ "--poster" ]];then
    Poster=1
fi
       
bob=$(find "${BaseDir}" -iname "*.mp4" -or -iname "*.mp4" -or -iname "*.mkv" -or -iname "*.mpeg" -or -iname "*.avi" -or -iname "*.mov" -or -iname "*.mkv" -or -iname "*.webm" -or -iname "*.wmv"  | sort -u )

OIFS=$IFS
IFS=$'\n'
for vidfile in `echo "$bob"`
do  
    vidfullfn=$(realpath "${vidfile}")
    viddirrel=$(echo "${vidfullfn}" | sed -e 's!/[^/]*$!!' -e 's!^\./!!')
    viddir="${viddirrel}"
    # the above is backwards compatability
    echo "$viddir"
    
    read
    vidbase=$(basename "${vidfullfn}")
    vidbasefilename=${vidbase%.*}
     
     
     
    ### TODO : OUTPUT DIRECTORY NOT RIGHT HERE
        
    ###########################################################################
    #  Fanart
    ###########################################################################
    if [ -n "$Fanart" ];then
        # You don't have fanart for the Season folders
        # Honestly, you probably do NOT want to use this unless you HAVE to
        if [[ "${viddir}" != *"Season"* ]];then 
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
    fi

    ###########################################################################
    #  Poster
    ###########################################################################
# Needs shifting of filename for seasons in TV show
    if [ -n "$Poster" ];then    
        # the below line needs to change once I'm done coding it.
        if [[ "${viddir}" == *"Season"* ]];then 
            vid1updir=$(find .. -maxdepth 1 -type d -name '..' -print0 | xargs --null -I {} realpath {})
            # Transforms Season-01 (or some variants) into season01
            diff_dir=$(echo ${viddir#${vid1updir}} | tr -d '\_ /' | tr '[:upper:]' '[:lower:]')
            if [ -f "${vid1updir}"/poster.jpg ];then 
                cp "${vid1updir}"/poster.jpg "${vid1updir}"/"${diff_dir}"-poster.jpg
            else
            
            
            # If it's in a Season folder, then create a season02-fanart
            # season02-poster
            # if there is a series one of either, just copy that shiz
            # get the last part of dir name
            # remove underscore
            # tolower
            # does poster.jpg exist? 
            #   if not, create from video
            # does season01-poster.jpg exist?
            #   if not, and poster.jpg exists, copy poster.jpg
            
        
        fi



        if [ ! -f "$viddir/poster.jpg" ]; then  
            if [ -f "$viddir/$vidbasefilename.nfo" ];then
                title=$(cat "$viddir/$vidbasefilename.nfo"| grep -oPm1 "(?<=<title>)[^<]+")
            else
                title=$vidbasefilename
            fi
            echo "Creating poster for $title"               
            if [ -f "$viddir/fanart.jpg" ]; then
                convert "$viddir/fanart.jpg" -resize 500x750^ -gravity center -extent 500x750 "$viddir/poster.jpg"
            else
                l=$(ffmpeg -i "$vidfullfn" 2>&1 | grep Duration: | sed -r 's/\..*//;s/.*: //;s/0([0-9])/\1/g')
                # Convert that into seconds
                echo "$l"
                read
                s=$((($(cut -f1 -d: <<< "$l") * 60 + $(cut -f2 -d: <<< "$l")) * 60 + $(cut -f3 -d: <<< "$l")))
                ffmpeg -ss $((s / 2)) -y -i "$vidfullfn" -r 1 -frames 1 "$viddir/temp.jpg"
                echo "check $viddir/temp.jpg"
                read
                convert "$viddir/temp.jpg" -resize 500x750^ -gravity center -extent 500x750 "$viddir/poster.jpg"
                rm "$viddir/temp.jpg"
            fi
            convert "$viddir/poster.jpg" -gravity South -pointsize 25 -fill white -annotate +0+30  "$title" "$viddir/poster_title.jpg"; 
            rm "$viddir/poster.jpg"
            cp "$viddir/poster_title.jpg" "$viddir/poster.jpg"
            rm "$viddir/poster_title.jpg"               
        fi
    fi
    
    ###########################################################################
    #  Thumbnail
    ###########################################################################
    
    if [ -n "$Thumbnail" ];then
       if [ ! -f "$viddir/$vidbasefilename-thumb.jpg" ]; then  
            echo "didn't find $viddir/$vidbasefilename-thumb.jpg"
            echo "Creating thumbnail"
            # from http://superuser.com/questions/238073/make-thumbnail-from-video
            # Get the time as h:m:s (non-padded)
            l=$(ffmpeg -i "$vidfullfn" 2>&1 | grep Duration: | sed -r 's/\..*//;s/.*: //;s/0([0-9])/\1/g')
            # Convert that into seconds
            s=$((($(cut -f1 -d: <<< "$l") * 60 + $(cut -f2 -d: <<< "$l")) * 60 + $(cut -f3 -d: <<< "$l")))
            # Get frame at 25% as the thumbnail
            ffmpeg -ss $((s / 3)) -y -i "$vidfullfn" -r 1 -frames 1 "$viddir/$vidbasefilename-thumb.jpg"
        fi
    fi
done

IFS=$OIFS




