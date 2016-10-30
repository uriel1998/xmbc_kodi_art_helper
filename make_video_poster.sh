#!/bin/bash

# to create posters for videos in media directory. Uses ffmpeg
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
					s=$((($(cut -f1 -d: <<< $l) * 60 + $(cut -f2 -d: <<< $l)) * 60 + $(cut -f3 -d: <<< $l)))
					# Get frame at 25% as the thumbnail
					ffmpeg -ss $((s / 2)) -y -i "$vidfullfn" -r 1 -updatefirst 1 -frames 1 "$viddir/temp.jpg"
					convert "$viddir/temp.jpg" -resize 500x750^ -gravity center -extent 500x750 "$viddir/poster.jpg"
					rm "$viddir/temp.jpg"
				fi
				convert "$viddir/poster.jpg" -gravity South -pointsize 25 -fill white -annotate +0+30  "$title" "$viddir/poster_title.jpg"; 
				rm "$viddir/poster.jpg"
				cp "$viddir/poster_title.jpg" "$viddir/poster.jpg"
				rm "$viddir/poster_title.jpg"				
			fi
		fi
	done

