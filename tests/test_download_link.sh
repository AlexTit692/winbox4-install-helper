#!/usr/bin/env bash

set -euo pipefail

SCRIPT="winbox4_install.sh"
readonly USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"

if [[ ! -f "$SCRIPT" ]]; then
  echo "❌ $SCRIPT not found"
  exit 1
fi

# Extract the grep pattern directly from the script
WINBOX_LINK_REGEX=$(
  grep -oP "WINBOX_LINK_REGEX='\K[^']+" "$SCRIPT"
)

WINBOX_DOWNLOAD_PAGE=$(
  grep -oP 'WINBOX_DOWNLOAD_PAGE="\K[^"]+' "$SCRIPT"
)

if [[ -z "$WINBOX_LINK_REGEX" || -z "$WINBOX_DOWNLOAD_PAGE" ]]; then
  echo "ERROR: Failed to extract download logic from script"
  exit 1
fi

DOWNLOAD_URL=$(
  wget --https-only -qO- --header="User-Agent: $USER_AGENT" "$WINBOX_DOWNLOAD_PAGE" \
  | grep -oP "$WINBOX_LINK_REGEX" \
  | head -n 1
)

if [[ -z "$DOWNLOAD_URL" ]]; then
  echo "ERROR: Failed to extract WinBox Linux download URL"
  exit 1
fi

echo "Extracted URL:"
echo "$DOWNLOAD_URL"

# Sanity checks
if ! [[ "$DOWNLOAD_URL" =~ WinBox_Linux\.zip$ ]]; then
  echo "ERROR: URL does not point to WinBox_Linux.zip"
  exit 1
fi

# Optional: check that file actually exists
wget --spider "$DOWNLOAD_URL" >/dev/null 2>&1 \
  || { echo "ERROR: Download URL not reachable"; exit 1; }

echo "Download URL is valid and reachable"

