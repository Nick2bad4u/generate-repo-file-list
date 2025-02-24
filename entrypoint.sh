#!/bin/bash
# entrypoint.sh

# Default values
LOG_LEVEL="INFO"
DIRECTORY="."
REPO_URL="https://github.com/Nick2bad4u/UserStyles"
FALLBACK_REPO_URL="https://github.com/author/repo"
OUTPUT_FORMAT="html"
OUTPUT_FILE="file_list.md"
COLOR_SOURCE="random"
COLOR_LIST="#FF0000 #00FF00 #0000FF #FFFF00 #FF00FF #00FFFF"
COLOR_RANGE_START="#000000"
COLOR_RANGE_END="#FFFFFF"
MAX_ATTEMPTS="1000000"
EXCLUDE_BLACKS_THRESHOLD="#222222"
EXCLUDE_DARK_COLORS="false"
EXCLUDE_BRIGHT_COLORS="false"
EXCLUDE_BLACKS="false"
ENSURE_READABLE_COLORS="false"
REPO_ROOT_HEADER="Repo Root"
HEADER_TEXT="## File List"
INTRO_TEXT="# Here is a list of files included in this repository:"
DARK_COLOR_LUMINANCE_THRESHOLD="128"
BRIGHT_COLOR_LUMINANCE_THRESHOLD="200"
CHUNK_SIZE="40"
VIEWPORT_MOBILE="768"
VIEWPORT_TABLET="1024"
VIEWPORT_SMALL_DESKTOP="1440"
ROOT_MARGIN_LARGE_DESKTOP="0px 0px 400px 0px"
ROOT_MARGIN_SMALL_DESKTOP="0px 0px 300px 0px"
ROOT_MARGIN_TABLET="0px 0px 200px 0px"
ROOT_MARGIN_MOBILE="0px 0px 100px 0px"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --log-level)
      LOG_LEVEL="$2"
      shift 2
      ;;
    --directory)
      DIRECTORY="$2"
      shift 2
      ;;
    --repo-url)
      REPO_URL="$2"
      shift 2
      ;;
    --fallback-repo-url)
      FALLBACK_REPO_URL="$2"
      shift 2
      ;;
    --output-format)
      OUTPUT_FORMAT="$2"
      shift 2
      ;;
    --output-file)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    --color-source)
      COLOR_SOURCE="$2"
      shift 2
      ;;
    --color-list)
      COLOR_LIST="$2"
      shift 2
      ;;
   --color-range)
      COLOR_RANGE_START="$2"
      COLOR_RANGE_END="$3"
      shift 3
      ;;
    --max-attempts)
      MAX_ATTEMPTS="$2"
      shift 2
      ;;
    --exclude-blacks-threshold)
      EXCLUDE_BLACKS_THRESHOLD="$2"
      shift 2
      ;;
    --exclude-dark-colors)
      EXCLUDE_DARK_COLORS="$2"
      shift 2
      ;;
    --exclude-bright-colors)
      EXCLUDE_BRIGHT_COLORS="$2"
      shift 2
      ;;
    --exclude-blacks)
      EXCLUDE_BLACKS="$2"
      shift 2
      ;;
    --ensure-readable-colors)
      ENSURE_READABLE_COLORS="$2"
      shift 2
      ;;
    --repo-root-header)
      REPO_ROOT_HEADER="$2"
      shift 2
      ;;
    --header-text)
      HEADER_TEXT="$2"
      shift 2
      ;;
    --intro-text)
      INTRO_TEXT="$2"
      shift 2
      ;;
    --dark-color-luminance-threshold)
      DARK_COLOR_LUMINANCE_THRESHOLD="$2"
      shift 2
      ;;
    --bright-color-luminance-threshold)
      BRIGHT_COLOR_LUMINANCE_THRESHOLD="$2"
      shift 2
      ;;
    --chunk-size)
      CHUNK_SIZE="$2"
      shift 2
      ;;
    --viewport-mobile)
      VIEWPORT_MOBILE="$2"
      shift 2
      ;;
    --viewport-tablet)
      VIEWPORT_TABLET="$2"
      shift 2
      ;;
    --viewport-small-desktop)
      VIEWPORT_SMALL_DESKTOP="$2"
      shift 2
      ;;
    --root-margin-large-desktop)
      ROOT_MARGIN_LARGE_DESKTOP="$2"
      shift 2
      ;;
    --root-margin-small-desktop)
      ROOT_MARGIN_SMALL_DESKTOP="$2"
      shift 2
      ;;
    --root-margin-tablet)
      ROOT_MARGIN_TABLET="$2"
      shift 2
      ;;
    --root-margin-mobile)
      ROOT_MARGIN_MOBILE="$2"
      shift 2
      ;;
    *)
      echo "Unknown parameter: $1"
      exit 1
      ;;
  esac
done

# Execute the Python script with arguments
python src/generate_file_list.py \
  --log-level "$LOG_LEVEL" \
  --directory "$DIRECTORY" \
  --repo-url "$REPO_URL" \
  --fallback-repo-url "$FALLBACK_REPO_URL" \
  --output-format "$OUTPUT_FORMAT" \
  --output-file "$OUTPUT_FILE" \
  --color-source "$COLOR_SOURCE" \
  --color-list "$COLOR_LIST" \
  --color-range-start "$COLOR_RANGE_START" \
  --color-range-end "$COLOR_RANGE_END" \
  --max-attempts "$MAX_ATTEMPTS" \
  --exclude-blacks-threshold "$EXCLUDE_BLACKS_THRESHOLD" \
  --exclude-dark-colors "$EXCLUDE_DARK_COLORS" \
  --exclude-bright-colors "$EXCLUDE_BRIGHT_COLORS" \
  --exclude-blacks "$EXCLUDE_BLACKS" \
  --ensure-readable-colors "$ENSURE_READABLE_COLORS" \
  --repo-root-header "$REPO_ROOT_HEADER" \
  --header-text "$HEADER_TEXT" \
  --intro-text "$INTRO_TEXT" \
  --dark-color-luminance-threshold "$DARK_COLOR_LUMINANCE_THRESHOLD" \
  --bright-color-luminance-threshold "$BRIGHT_COLOR_LUMINANCE_THRESHOLD" \
  --chunk-size "$CHUNK_SIZE" \
  --viewport-mobile "$VIEWPORT_MOBILE" \
  --viewport-tablet "$VIEWPORT_TABLET" \
  --viewport-small-desktop "$VIEWPORT_SMALL_DESKTOP" \
  --root-margin-large-desktop "$ROOT_MARGIN_LARGE_DESKTOP" \
  --root-margin-small-desktop "$ROOT_MARGIN_SMALL_DESKTOP" \
  --root-margin-tablet "$ROOT_MARGIN_TABLET" \
  --root-margin-mobile "$ROOT_MARGIN_MOBILE"