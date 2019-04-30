#!/bin/sh

if [ $# -eq 0 ]
  then
    echo "scriptname.sh inputVideo outputGif"
fi
if [ $# -eq 1 ]
  then
    echo "scriptname.sh inputVideo outputGif"
fi

seekToSecond=1
totalTime=25 
# palettegen='single'
palettegen='full'
# palettegen='diff'
# dither='sierra2_4a'
# dither='bayer:bayer_scale=2'
# dither='floyd_steinberg'
# dither='sierra2'
dither='none'


# palette="/tmp/palette.png"
palette="palette.png"
log='warning'
# log='debug'
filters="fps=4,scale=480:-1:flags=lanczos"
if [ -z "$seekToSecond" ]; then
ffmpeg -v $log -i "$1" -vf "$filters,palettegen" -y $palette
ffmpeg -v $log -i "$1" -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y "$2"
else
ffmpeg -v $log -ss $seekToSecond -t $totalTime -i "$1"  -vf "$filters,palettegen=stats_mode=$palettegen" -y $palette
ffmpeg -v $log -ss $seekToSecond -t $totalTime -i "$1"  -i $palette  -lavfi "$filters [x]; [x][1:v] paletteuse=dither=$dither" -y "$2"
fi


