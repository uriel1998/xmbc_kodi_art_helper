# xmbc_kodi_art_helper

Scripts to help with fanart and movie posters for Kodi/XMBC


# Copy All Fanart

**To get all the fanart from a video directory (e.g. Kodi, Plex) and copy it to 
a specified directory.**

This utility allows you to copy all the fanart from one set of directories to
another - without having (exact) duplicates by comparing sha1sums. You will 
end up with a directory full of `fanart_00000.jpg` files (at present). 

The use case here is to have a directory of not (exactly) duplicated fan arts 
for use as backgrounds, screen wallpaper, a source for screensavers, and so on.

The SHA sums are stored in a local file, so you can re-run the program and only 
catch new added files. By default, this is `$XDG_DATA_HOME/fanart_copier_shastore.txt`.

If you need to use this utility with multiple output directories, you can 
specify a *different* SHA sum store with a commandline switch. (For example, 
if you wanted to have one output directory that was *just* TV show fanart and 
another that was TV show fanart *and* movie fanart.

`copy_all_fanart [--shastore /path/to/file] [--clear] /sourcedir /outdir`

Notes: 

* No trailing slash on paths. 

* To specify the SHASTORE (so you can use this with multiple OUT directories) 
have your **FIRST** commandline switch be `--shastore /full/file/path/to/sha_store` 

* To clear the SHASTORE in use, use the `--clear` as the first switch (if you 
are using the default SHASTORE, if you are using a specific one, you must specify 
the SHASTORE first.


# Make Video Fanart

The idea is to both create thumbnails, posters, and fanart for those
videos that don't have one.  Each utility should be run seperately.

