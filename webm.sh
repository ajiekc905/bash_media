inputVideo=$1
if [[ -z $2 ]]; then
  bitrate='1000k'
else
  bitrate=$2'k'
fi
# preset='placebo'
preset='veryslow'
# tune='animation'
tune='film'
loglevel='warning'
# loglevel='debug'
lutFile="$3"
profile='-profile:v high -level 4.0'
outputVideo="${inputVideo%.*}_b$bitrate.mp4"
if [[ -z $3 ]]; then
  # no lut
  filters=('format=pix_fmts=rgb24,scale=-2:720,format=pix_fmts=yuv420p')
else
  # lut
  filters=('format=pix_fmts=rgb24,lut3d=file='"$lutFile"',scale=-1:720,format=pix_fmts=yuv420p')
fi
# https://trac.ffmpeg.org/wiki/FilteringGuide
additional=('-movflags' '+faststart' "-preset $preset" "-tune $tune" "$profile" '-c:v' "libx264" '-b:v' "$bitrate")
spamming=("-hide_banner" "-loglevel $loglevel" '-stats -y')
# afterInput='-preset '"$preset"' -tune '"$tune"' '"$additional"' '"$profile"' -c:v libx264 -b:v '"$bitrate"
# audio=('-c:a libfdk_aac' '-b:a 128k')
audio=('-an')

echo $outputVideo
ffmpeg ${spamming[@]} -i "$1" ${additional[@]} -vf "[in]${filters[@]}[out]"  -pass 1  -an -f mp4 /dev/null
ffmpeg ${spamming[@]} -i "$1" ${additional[@]} -vf "[in]${filters[@]}[out]"  -pass 2  ${audio[@]} "$outputVideo"