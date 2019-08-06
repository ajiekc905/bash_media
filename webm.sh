inputVideo=$1
if [[ -z $2 ]]; then
  bitrate='3000k'
else
  bitrate=$2'k'
fi
preset='placebo'
# preset='veryslow'
# tune='animation'
tune='film'
loglevel='warning'
# loglevel='debug'
lutFile="$3"

seekToSecond=03:19.800
# totalTime=02:27.68
# -ss 00:23:00
# Note that you can use two different time unit formats: sexagesimal 
# (HOURS:MM:SS.MILLISECONDS, as in 01:23:45.678), or in seconds. If a fraction is used, such as 02:30.05, this is interpreted as "5 100ths of a second", 
# not as frame 5. For instance, 02:30.5 would be 2 minutes, 30 seconds, and a half a second, which would be the same as using 150.5 in seconds. 
framesv=5

profile='-profile:v high -level 4.0'
outputVideo="${inputVideo%.*}_b$bitrate.mp4"

start=( '-ss' "$seekToSecond"  )

if [[ -z $3 ]]; then
  # no lut
  filters=('format=pix_fmts=rgb24,scale=-2:720,format=pix_fmts=yuv420p')
  # filters=('format=pix_fmts=yuv420p')
  # filters=('format=pix_fmts=rgb24,scale=-2:720,format=pix_fmts=yuv420p')
  # filters=('mpdecimate,setpts=PTS,format=pix_fmts=rgb24,scale=-2:720,format=pix_fmts=yuv420p')
else
  # lut
  filters=('format=pix_fmts=rgb24,lut3d=file='"$lutFile"',scale=-1:720,format=pix_fmts=yuv420p')
fi
# https://trac.ffmpeg.org/wiki/FilteringGuide
if [[ -z $framesv ]]; then
  additional=( '-t' "$totalTime"  '-movflags' '+faststart' "-preset $preset" "-tune $tune" "$profile" '-c:v' "libx264" '-b:v' "$bitrate")
else
  additional=( '-frames:v' "$framesv" '-movflags' '+faststart' "-preset $preset" "-tune $tune" "$profile" '-c:v' "libx264" '-b:v' "$bitrate")
fi

# additional=( '-ss' "$seekToSecond"  '-movflags' '+faststart' "-preset $preset" "-tune $tune" "$profile" '-c:v' "libx264" '-b:v' "$bitrate")
# additional=( '-ss' "$seekToSecond" '-frames:v' "$framesv" '-movflags' '+faststart' "-preset $preset" "-tune $tune" "$profile" '-c:v' "libx264" '-b:v' "$bitrate")
# additional=( '-ss' "$seekToSecond" '-t' "$totalTime" '-movflags' '+faststart' "-preset $preset" "-tune $tune" "$profile" '-c:v' "libx264" '-b:v' "$bitrate")
spamming=("-hide_banner" "-loglevel $loglevel" '-stats -y')
# afterInput='-preset '"$preset"' -tune '"$tune"' '"$additional"' '"$profile"' -c:v libx264 -b:v '"$bitrate"
# audio=('-c:a libfdk_aac' '-b:a 128k')
audio=('-an')

echo $outputVideo
ffmpeg ${spamming[@]} ${start[@]} -i "$1" ${additional[@]} -vf "[in]${filters[@]}[out]"  -pass 1  -an -f mp4 /dev/null
ffmpeg ${spamming[@]} ${start[@]} -i "$1" ${additional[@]} -vf "[in]${filters[@]}[out]"  -pass 2  ${audio[@]} "$outputVideo"



# Use the mpdecimate filter, whose purpose is to "Drop frames that do not differ greatly from the previous frame in order to reduce frame rate."
#     This will generate a console readout showing which frames the filter thinks are duplicates.
#     ffmpeg -i input.mp4 -vf mpdecimate -loglevel debug -f null -
#     To generate a video with the duplicates removed
#     ffmpeg -i input.mp4 -vf mpdecimate,setpts=N/FRAME_RATE/TB out.mp4
# explanation https://stackoverflow.com/questions/37088517/ffmpeg-remove-sequentially-duplicate-frames
