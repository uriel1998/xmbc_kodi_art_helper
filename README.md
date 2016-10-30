# xmbc_kodi_art_helper
Scripts to help with fanart and movie posters for Kodi/XMBC


The idea is to both create thumbnails, posters, and fanart for those
videos that don't have one.  Each utility should be run seperately.

In a semi-working state at the moment....

Also includes a script to copy fanart from movie/TV show directories
into a single directory (e.g. to use for backgrounds, screensavers, etc)

name-fanart.jpg
fanart.jpg
1920/1080

poster.jpg
name-poster.jpg
500/750
882/1377

also copy to folder.jpg!



banner
1000/185



script needs to recognize tv show fanart as 

Being_Human_-_S05E02_-_Sticks_and_Rope-thumb.jpg

so, if SEASON, then no fanart.jpg, just name


is there fanart?
is there a thumbnail for the file?
if path doesn't include SEASON
	is there a poster?
	is there a folder.jpg in the folder? (copy poster)

convert fanart.jpg -resize 1920x1080^ \
> -gravity center -extent 1920x1080 fanart2.jpg

  convert terminal.gif    -resize 64x64^ \
          -gravity center -extent 64x64  fill_crop_terminal.gif


-> identify rose.jpg
rose.jpg JPEG 70x46 70x46+0+0 8-bit sRGB 2.36KB 0.000u 0:00.000


convert houses.jpg -gravity Center -crop "240x300+25+31" houses-center-final.jpg

convert -define jpeg:size=240x180 input.jpg  -thumbnail 120x90^ \
          -gravity center -extent 120x90  cut_to_fit.gif



convert input.jpg -gravity center -crop120x90+0+0 output.jpg