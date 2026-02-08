#!/usr/bin/env bash

set -e

# ==============================
# DEFAULTS
# ==============================
OUTPUT_DIR="site_backup"
WAIT_TIME=1
RATE_LIMIT="300k"
USER_AGENT="SiteBackupBot/1.0"
LOG_FILE="mirror.log"

# ==============================
# HELP
# ==============================
echo "WormBot 1.0.0"
usage() {
  echo "Usage: site-backup [OPTIONS] <url>"
  echo
  echo "Options:"
  echo "  -o <dir>     Output directory (default: site_backup)"
  echo "  -w <secs>    Wait time between requests (default: 1)"
  echo "  -r <rate>    Rate limit (default: 300k)"
  echo "  -a <agent>   Custom User-Agent"
  echo "  -h           Show this help"
  exit 0
}

# ==============================
# ARGUMENT PARSING
# ==============================
while getopts "o:w:r:a:h" opt; do
  case $opt in
    o) OUTPUT_DIR="$OPTARG" ;;
    w) WAIT_TIME="$OPTARG" ;;
    r) RATE_LIMIT="$OPTARG" ;;
    a) USER_AGENT="$OPTARG" ;;
    h) usage ;;
  esac
done

shift $((OPTIND -1))
TARGET_URL="$1"

# ==============================
# INTERACTIVE FALLBACK
# ==============================
if [[ -z "$TARGET_URL" ]]; then
  read -rp "Enter target URL: " TARGET_URL
fi

if [[ -z "$TARGET_URL" ]]; then
  echo "Error: No URL provided."
  exit 1
fi

# ==============================
# PREP
# ==============================
mkdir -p "$OUTPUT_DIR"

echo "[*] Target: $TARGET_URL"
echo "[*] Output: $OUTPUT_DIR"
echo "[*] User-Agent: $USER_AGENT"
echo "[*] Rate limit: $RATE_LIMIT"
echo "[*] Wait time: $WAIT_TIME sec"
echo "[*] Log: $LOG_FILE"
echo

# ==============================
# MIRROR
# ==============================
wget \
  --mirror \
  --page-requisites \
  --adjust-extension \
  --convert-links \
  --backup-converted \
  --no-parent \
  --wait="$WAIT_TIME" \
  --limit-rate="$RATE_LIMIT" \
  --user-agent="$USER_AGENT" \
  --robots=off \
  --directory-prefix="$OUTPUT_DIR" \
  "$TARGET_URL" \
  -o "$LOG_FILE"

# ==============================
# CLEANUP
# ==============================
find "$OUTPUT_DIR" -type f -name "*.tmp" -delete

echo
echo ""Backup" completed successfully."
