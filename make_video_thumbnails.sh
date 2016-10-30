#!/bin/bash

# to create thumbnails for videos in media directory. Uses ffmpeg
# should leave existing thumbnails alone.


#######
#MAIN
######
	# we need to walk the video directory and find art.
	# http://stackoverflow.com/questions/12873834/list-directories-not-containing-certain-files
	# http://stackoverflow.com/questions/5374239/tab-separated-values-in-awk
	
	find . -iname "*.mp4" -iname "*.mkv" -or -iname "*.mp4" -or -iname "*.mpeg" -or -iname "*.avi" -or -iname "*.mov" -or -iname "*.mkv" -or -iname "*.wmv"  | sort -u | while read vidfile
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
		if [ -f "$vidfullfn" ];then
			echo "OO"
			if [ ! -f "$viddir/$vidbasefilename-thumb.jpg" ]; then	
				echo "didn't find $viddir/$vidbasefilename-thumb.jpg"
				echo "Creating thumbnail"
				# from http://superuser.com/questions/238073/make-thumbnail-from-video
				# Get the time as h:m:s (non-padded)
				l=$(ffmpeg -i "$vidfullfn" 2>&1 | grep Duration: | sed -r 's/\..*//;s/.*: //;s/0([0-9])/\1/g')
				# Convert that into seconds
				s=$((($(cut -f1 -d: <<< $l) * 60 + $(cut -f2 -d: <<< $l)) * 60 + $(cut -f3 -d: <<< $l)))
				# Get frame at 25% as the thumbnail
				ffmpeg -ss $((s / 3)) -y -i "$vidfullfn" -r 1 -updatefirst 1 -frames 1 "$viddir/$vidbasefilename-thumb.jpg"
			else
				echo "found $viddir/$vidbasefilename.jpg"
			fi
		fi
	done






