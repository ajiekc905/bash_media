param="$1"
cliext="${1##*.}"


# settings
if [[ -z $2 ]]; then
longestSide=2048
else
longestSide=$2
fi
size=$longestSide'x'$longestSide'>'
colorspaceForResize='-colorspace LAB'
optional1='-set option:filter:lobes 8'
sigmaContrast1='+sigmoidal-contrast 6.5,50%'
sigmaContrast2='-sigmoidal-contrast 6.5,50%'
resizeType='-filter Lanczos'
sharper='-unsharp 1.5x1+0.7+0.02'
#  Upscaling     "-unsharp 0x0.75+0.75+0.008"
#  Downsampling  "-unsharp 1.5x1+0.7+0.02".
quality='-quality 100'
resizeOperator='-distort resize '"$size"
colorspaceAfterResize='-colorspace sRGB'
jpegQuality=90
cliArray=("$colorspaceForResize" "$optional1" "$sigmaContrast1" "$resizeType" "$resizeOperator" "$colorspaceAfterResize" "$sharper" "$sigmaContrast2" "$quality")
pngQuality=90


# cli utilites
joPath="$(which jpegoptim)"
if [[ -z $joPath ]]; then
  echo jpegoptim is not installed
  brew install jpegoptim
fi
pqPath="$(which pngquant)"
if [[ -z $pqPath ]]; then
  echo pngquant is not installed
  brew install pngquant
fi




resizeJpg() {
  filename="$1"
  outFn="${filename%.*}__$longestSide"'__q'"$jpegQuality"
  convert "$filename" ${cliArray[@]} "$outFn"'.jpg'
  jpegoptim -T 10 -m $jpegQuality -p --strip-none  "$outFn"'.jpg'
};
export -f resizeJpg;
resizePng() {
  filename="$1"
  outFn="${filename%.*}__$longestSide"'__q'"$pngQuality"
  convert "$filename" ${cliArray[@]} "$outFn"'.png'
  pngquant --force --skip-if-larger --quality $quality --speed 1 --nofs "$outFn"'.png'
};
export -f resizePng;



if [ -z "$param"  ]
then
  echo nothing to do
elif [ -d "$param" ]
then
  echo 'directory '"$param"
  jpegs=$(find "$param" -iname '*.jpeg' -or -iname '*.jpg' -or -iname '*.tif' -or -iname '*.tiff')
  pngs=$(find "$param" -iname '*.png')

  while read -r line; do
      resizeJpg "$line"
  done <<< "$jpegs"

  while read -r line; do
      resizePng "$line"
  done <<< "$pngs"

  # -exec bash -c 'resizeJpg "$0"' {} \;

elif [ -f "$param" ]
then
  # echo 'file '$param
  if [ $cliext == 'jpeg' ]
  then
  resizeJpg "$param"
  elif [ $cliext == 'jpg' ]
  then
  resizeJpg "$param"
  elif [ $cliext == 'tif' ]
  then
  resizeJpg "$param"
  elif [ $cliext == 'png' ]
  then
  resizePng "$param"
  fi
else
  echo 'wtf'
fi
