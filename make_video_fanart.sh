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
#   --all
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

if [[ "$@" =~ "--all" ]];then
    Poster=1
    Thumbnail=1
    Fanart=1 
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
    vidbase=$(basename "${vidfullfn}")
    vidbasefilename=${vidbase%.*}
     
    ###########################################################################
    #  Fanart
    ###########################################################################
    if [ -n "$Fanart" ];then
        # You don't have fanart for the Season folders
        # Honestly, you probably do NOT want to use this unless you HAVE to
        # There's SO MUCH good fanart freely accessible out there, but...
        if [[ "${viddir}" != *"Season"* ]];then 
            if [ -f "${vidfullfn}" ];then
                if [ ! -f "${viddir}/fanart.jpg" ]; then  
                    echo "Didn't find $viddir/fanart.jpg"
                    if [ -f "${viddir}/${vidbasefilename}-fanart.jpg" ];then
                        echo "Using individually named fanart file."
                        cp "${viddir}/${vidbasefilename}-fanart.jpg" "${viddir}/fanart.jpg"
                    else
                        echo "Creating thumbnail"
                        # from http://superuser.com/questions/238073/make-thumbnail-from-video
                        # Get the time as h:m:s (non-padded)
                        l=$(ffmpeg -i "$vidfullfn" 2>&1 | grep Duration: | sed -r 's/\..*//;s/.*: //;s/0([0-9])/\1/g')
                        # Convert that into seconds
                        s=$((($(cut -f1 -d: <<< "$l") * 60 + $(cut -f2 -d: <<< "$l")) * 60 + $(cut -f3 -d: <<< "$l")))
                        # Get frame at 25% as the thumbnail
                        ffmpeg -ss $((s / 2)) -y -i "${vidfullfn}" -r 1 -frames 1 "${viddir}/fanart.jpg"
                    fi
                fi
            fi
            #Test for size
            fanartsize=$(identify "${viddir}/fanart.jpg" | awk '{print $3}')
            if [ "$fanartsize" != "1920x1080" ];then
                echo "Resizing fanart in $viddir"
                convert "${viddir}/fanart.jpg" -resize 1920x1080^ -gravity center -extent 1920x1080 "${viddir}/fanart.jpg"
            fi  
            cp "${viddir}/fanart.jpg" "${viddir}/${vidbasefilename}"-fanart.jpg
        fi
    fi


# Why did I not get a poster for the film?

    ###########################################################################
    #  Poster
    ###########################################################################
    if [ -n "$Poster" ];then    
        if [[ "${viddir}" == *"Season"* ]];then
            RunTimeDir=$(echo "${PWD}")
            cd "${viddir}"
            # This trick requires you to be in the referred directory.
            vid1updir=$(find .. -maxdepth 1 -type d -name '..' -print0 | xargs --null -I {} realpath {})
            # Transforms Season-01 (or some variants) into season01
            diff_dir=$(echo ${viddir#${vid1updir}} | tr -d '\_ /' | tr '[:upper:]' '[:lower:]')
            if [ -f "${vid1updir}/poster.jpg" ];then 
                cp "${vid1updir}/poster.jpg" "${vid1updir}/${diff_dir}"-poster.jpg
            else
                # No season OR series poster.
                if [ -f "${vid1updir}"/fanart.jpg ]; then
                    convert "${vid1updir}/fanart.jpg" -resize 500x750^ -gravity center -extent 500x750 "${vid1updir}/poster.jpg"
                    cp "${vid1updir}/poster.jpg" "${vid1updir}/${diff_dir}"-poster.jpg
                else
                # And no fanart either. Le sigh. Creating from video.
                    l=$(ffmpeg -i "$vidfullfn" 2>&1 | grep Duration: | sed -r 's/\..*//;s/.*: //;s/0([0-9])/\1/g')
                    # Convert that into seconds
                    s=$((($(cut -f1 -d: <<< "$l") * 60 + $(cut -f2 -d: <<< "$l")) * 60 + $(cut -f3 -d: <<< "$l")))
                    ffmpeg -ss $((s / 2)) -y -i "${vidfullfn}" -r 1 -frames 1 "${vid1updir}/temp.jpg"
                    convert "${vid1updir}/temp.jpg" -resize 500x750^ -gravity center -extent 500x750 "${vid1updir}/poster.jpg"
                    cp "${vid1updir}/temp.jpg" "${vid1updir}/${diff_dir}-poster.jpg"
                    rm "${vid1updir}/temp.jpg"
                    # If we created the poster, add the TV Show name if it can be found 
                    # in .nfo. Otherwise, do not make a name variant.
                    # Note - this only does this for the SHOW poster, if it was created.
                    if [ -f "${vid1updir}"/tvshow.nfo ];then
                        title=""
                        title=$(cat "${vid1updir}"/tvshow.nfo | grep -oPm1 "(?<=<title>)[^<]+")
                        if [ -n "${title}" ];then 
                            convert "${vid1updir}"/poster.jpg -gravity South -pointsize 25 -fill white -annotate +0+30  "$title" "${vid1updir}"/poster_title.jpg; 
                            rm "${vid1updir}"/poster.jpg
                            cp "${vid1updir}"/poster_title.jpg "${vid1updir}"/poster.jpg
                            rm "${vid1updir}"/poster_title.jpg
                        fi  
                    fi
                fi
                cd "${RunTimeDir}"
            fi
        else
            # No season, which means it's probably a movie.
            # Is there a poster?
            if [ ! -f "${viddir}/${vidbasefilename}-poster.jpg" ];then        
                if [ -f "${viddir}/poster.jpg" ];then
                    cp "${viddir}/poster.jpg" "${viddir}/${vidbasefilename}-poster.jpg"
                else
                    # Fine, no poster.
                    # Creating from fanart,if it exists.
                    if [ -f "${viddir}"/fanart.jpg ]; then
                        convert "${viddir}/fanart.jpg" -resize 500x750^ -gravity center -extent 500x750 "${viddir}/poster.jpg"
                    else
                        # And no fanart either. Le sigh. Creating from video.
                        l=$(ffmpeg -i "${vidfullfn}" 2>&1 | grep Duration: | sed -r 's/\..*//;s/.*: //;s/0([0-9])/\1/g')
                        # Convert that into seconds
                        s=$((($(cut -f1 -d: <<< "$l") * 60 + $(cut -f2 -d: <<< "$l")) * 60 + $(cut -f3 -d: <<< "$l")))
                        ffmpeg -ss $((s / 2)) -y -i "${vidfullfn}" -r 1 -frames 1 "${viddir}/temp.jpg"
                        convert "${viddir}/temp.jpg" -resize 500x750^ -gravity center -extent 500x750 "${viddir}/poster.jpg"
                        rm "${viddir}/temp.jpg"
                        # If we created the poster, add the TV Show name if it can be found 
                        # in .nfo. Otherwise, do not make a name variant.
                        if [ -f "$viddir/$vidbasefilename.nfo" ];then
                            title=""
                            title=$(cat "${viddir}/${vidbasefilename}.nfo"| grep -oPm1 "(?<=<title>)[^<]+")
                            if [ -n "${title}" ];then 
                                convert "${viddir}/poster.jpg" -gravity South -pointsize 25 -fill white -annotate +0+30  "$title" "${viddir}/poster_title.jpg"; 
                                rm "${viddir}/poster.jpg"
                                cp "${viddir}/poster_title.jpg" "${viddir}/${vidbasefilename}-poster.jpg"
                                cp "${viddir}/poster_title.jpg" "$viddir/poster.jpg"
                                rm "${viddir}/poster_title.jpg"               
                            fi  
                        fi
                    fi
                fi
            fi
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




