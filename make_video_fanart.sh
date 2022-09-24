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
    vidbase=$(basename "${vidfullfn}")
    vidbasefilename=${vidbase%.*}
     
     
     
    ### TODO : OUTPUT DIRECTORY NOT RIGHT HERE
        
    ###########################################################################
    #  Fanart
    ###########################################################################
    if [ -n "$Fanart" ];then
        # You don't have fanart IN the Season folders
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
    fi

    ###########################################################################
    #  Poster
    ###########################################################################

    if [ -n "$Poster" ];then    
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
                echo "$s"
                read
                # Get frame at 25% as the thumbnail
                
                #TODO - THIS IS WHERE THE ERROR IS HAPPENING 
                
                ffmpeg -ss $((s / 2)) -y -i "$vidfullfn" -r 1 -frames 1 "$viddir/temp.jpg"
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




