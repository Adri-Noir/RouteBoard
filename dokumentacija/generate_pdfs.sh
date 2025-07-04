#!/usr/bin/env zsh
set -euo pipefail

SOURCE_PDF=${1:-zavrsni.pdf}

if [[ ! -f "$SOURCE_PDF" ]]; then
  echo "Error: '$SOURCE_PDF' not found." >&2
  exit 1
fi

base_name="${SOURCE_PDF:r}"  # filename without extension

echo "Creating printer-quality version…"
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer \
   -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile="${base_name}_printer.pdf" "$SOURCE_PDF"

echo "Creating medium-quality version (≈200 dpi, JPEG 85 %)…"
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer \
   -dColorImageResolution=200 -dGrayImageResolution=200 -dMonoImageResolution=600 -dJPEGQ=85 \
   -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile="${base_name}_medium.pdf" "$SOURCE_PDF"

echo "Creating small version (Ghostscript /ebook preset)…"
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
   -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile="${base_name}_small.pdf" "$SOURCE_PDF"

echo "All variants generated successfully." 
