#!/bin/sh
#
# Usage: set-timezone [TIMEZONE]
# Example: set-timezone America/New_York
#
# Sets the container's timezone. Lists available timezones if no argument is given.

set -e

TIMEZONE_DIR="/usr/share/zoneinfo"

# If no argument is provided, display usage and current timezone
if [ -z "$1" ]; then
    CURRENT_TZ=$(cat /etc/timezone 2>/dev/null || readlink /etc/localtime | sed "s|.*/zoneinfo/||")
    echo "Current timezone: ${CURRENT_TZ}"
    echo "Usage: $(basename "$0") [TIMEZONE]"
    echo "Example: $(basename "$0") America/New_York"
    echo "To list available timezones, use a command like: find ${TIMEZONE_DIR} -type f | sort"
    exit 0
fi

TARGET_TZ="$1"

# Validate if the timezone exists
if [ ! -f "${TIMEZONE_DIR}/${TARGET_TZ}" ]; then
    echo "Error: Timezone '${TARGET_TZ}' not found in ${TIMEZONE_DIR}."
    echo "Please provide a valid IANA timezone name."
    exit 1
fi

# Set the new timezone
sudo ln -snf "${TIMEZONE_DIR}/${TARGET_TZ}" /etc/localtime
echo "${TARGET_TZ}" | sudo tee /etc/timezone > /dev/null

echo "Container timezone has been set to: ${TARGET_TZ}"

