#!/bin/bash

# Usage: ./pdf-svg-png.sh input.pdf
# This script converts a PDF (single or multi-page) to SVG(s) and PNG(s) via intermediate JPG and PBM files,
# processing each page separately and cleaning up intermediates.
# Requires: ImageMagick and potrace installed.

if [ $# -ne 1 ]; then
  echo "Usage: $0 input.pdf"
  exit 1
fi

pdf_file="$1"
base="${pdf_file%.pdf}"

# Convert PDF to JPG(s) with density 150
magick -density 150 "$pdf_file" "${base}-%03d.jpg"

# Process each generated JPG
for jpg in "${base}"-*.jpg; do
  if [ ! -f "$jpg" ]; then
    echo "No JPG files generated. Check if the PDF conversion succeeded."
    exit 1
  fi
  pbm="${jpg%.jpg}.pbm"
  svg="${jpg%.jpg}.svg"

  # Convert JPG to PBM with dither and 2 colors
  magick "$jpg" +dither -colors 2 "$pbm"

  # Convert PBM to SVG
  potrace "$pbm" -s -o "$svg"

  # Convert SVG to PNG with no background
  png="${svg%.svg}.png"
  magick -background none "$svg" "$png"

  # Clean up intermediate files
  rm "$pbm" "$jpg" "$svg"
done

echo "Conversion complete. Alpha PNG files generated for each page."
