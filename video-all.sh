#!/usr/bin/env bash
set -x

mkdir -p $(dirname  $0)/output
listFile=$(mktemp)
list=()
while IFS= read -r file;  do
	list+=( "$(realpath $file)" )
done < <(find $(dirname  $0)  -type  f|grep  -v  output|grep -E -e "\\.mp4\$" -e "\\.mov\$")

for  file in  ${list[@]};  do
	outputFile="$(realpath $(dirname $0)/output/$(basename  $file))"
	if [ ! -e "$outputFile" ]; then
		ffmpeg -i  "$(realpath $file)" -vf "fps=30,scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2"  -c:a aac -ar 48000 -ac 2 -c:v libx264 -crf 0 -f mp4 -pix_fmt yuv420p "$outputFile"
		if [ ! $? -eq 0 ]; then
			rm -rf $outputFile
		fi
	fi
	echo "file '$outputFile'" >> $listFile
done
cat $listFile
ffmpeg -f concat -safe 0 -i $listFile -c copy $(dirname $0)/output/output.mp4
rm -rf $listFile