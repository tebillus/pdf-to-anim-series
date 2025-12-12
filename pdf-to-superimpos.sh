#!/bin/bash

# Usage: ./pdf-to-alpha_mov.sh input.pdf holds.csv background.{jpg, png}
# This script converts a PDF to SVGs (one-indexed), then to a video with frame holds.
# White areas in the original PDF are translated to transparent (alpha) in the output video.
# Video is then superimposed over a background image, JPG or PNG.
# Requires: ImageMagick (convert), potrace, ffmpeg (with prores support for alpha), ffprobe.
# Adjust holds array to match the number of PDF pages and desired timings.

if [ $# -ne 3 ]; then
  echo "Usage: $0 input.pdf holds.csv background.{jpg, png}"
  exit 1
fi

pdf_file="$1"
csv_file="$2"
jpg_png_file="$3"

base="${pdf_file%.pdf}"

holds=($(cat "$csv_file")) # For animation timing (one value per PDF page)

svgs=()

# Convert PDF to JPGs (temporary, zero-indexed)
convert -density 150 "$pdf_file" "temp_${base}-%03d.jpg"

# Get dimensions from the first JPG using ffprobe
first_jpg="temp_${base}-000.jpg"
if [ ! -f "$first_jpg" ]; then
  echo "No JPG files generated. Check if the PDF conversion succeeded."
  exit 1
fi
width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 "$first_jpg")

# Process each JPG, renumber SVGs to one-indexed
i=1
for jpg in "temp_${base}"-*.jpg; do
  if [ ! -f "$jpg" ]; then
    echo "No JPG files generated. Check if the PDF conversion succeeded."
    exit 1
  fi
  pbm="${jpg%.jpg}.pbm"
  svg="${base}-$(printf %03d $i).svg"

  # Convert JPG to PBM with dither and 2 colors (black foreground, white background)
  convert "$jpg" +dither -colors 2 "$pbm"

  # Convert PBM to SVG (potrace traces black; white becomes transparent)
  potrace "$pbm" -s -o "$svg"
  svgs+=("$svg")

  # Clean up intermediates
  rm "$pbm" "$jpg"

  ((i++))
done

# Now convert SVGs to PNG sequence with holds
mkdir -p png_sequence
frame_num=1
out_frame=1

for hold in "${holds[@]}"; do
  # Convert SVG to PNG (transparent background preserved)
  convert -background none "${base}-$(printf %03d $frame_num).svg" "temp.png"
  for ((j = 1; j <= hold; j++)); do
    cp "temp.png" "png_sequence/frame$(printf %05d $out_frame).png"
    ((out_frame++))
  done
  ((frame_num++))
done

rm "temp.png"

# Create video with alpha channel (using ProRes 4444 for transparency support)
ffmpeg -framerate 24 -i "png_sequence/frame%05d.png" -vf scale=${width}:-2 -c:v prores_ks -profile:v 4 -pix_fmt yuva444p10le "${base}_alph.mov"

# Superimpose alpha video over background image
ffmpeg -loop 1 -framerate 24 -i "$jpg_png_file" -i "${base}_alph.mov" -filter_complex "[0:v][1:v]scale2ref[bg][fg];[bg][fg]overlay=0:0:shortest=1" -y "${base}.mp4"

# add a "#" to the lines below if you don't want to remove them
#
rm -r png_sequence
rm "${svgs[@]}"
rm "${base}_alph.mov"
