#!/usr/bin/env bash

set -o nounset
set -o errexit

# Define input codes
HDMI_INPUT=0x11
DP_INPUT=0x0f

DETECT_MONITORS="yes"  ## dynamically generate number of monitors (slows down a script)
#DETECT_MONITORS="no"  ## dynamically generate number of monitors 
DDC_CACHE="${XDG_RUNTIME_DIR}/ddc_monitors"

# Function to check if cache and detected monitors match
check_cache_vs_detected() {
    detected_monitors=$(ddcutil detect --async | grep -c -e "^Display ")
    if [ -f "$DDC_CACHE" ]; then
        cached_monitors=$(<"$DDC_CACHE")
        if [ "$cached_monitors" -eq "$detected_monitors" ]; then
            return 0  # Cache and detected monitors match
        else
            rm "$DDC_CACHE"  # Delete cache if it doesn't match
            return 1
        fi
    else
        echo "$detected_monitors" > "$DDC_CACHE"  # Cache file doesn't exist, create it
        return 0
    fi
}


MONITOR_NUM="${1:-1}"
# Check if DETECT_MOMITORS is set to "yes" or "true"
if [[ "${DETECT_MONITORS,,}" == "yes" || "${DETECT_MONITORS,,}" == "true" ]]; then
	# Read number of monitors cached
	if [ -f "${DDC_CACHE}" ]; then
		MONITOR_NUM_DETECTED="$(<${DDC_CACHE})"
	else
		MONITOR_NUM_DETECTED="$(ddcutil --async detect|grep -c -e "^Display ")"
		umask 077
		echo "${MONITOR_NUM_DETECTED}" > ${DDC_CACHE}
	fi
	MONITOR_NUM="$(zenity --list --text="  Which monitor to toggle input?" --column "Numbers" $(seq 1 ${MONITOR_NUM_DETECTED}))"
else
	MONITOR_NUM="$(zenity --list --text="  Which monitor to toggle input?" --column "Numbers" 1 2)"
fi

if ! [[ "${MONITOR_NUM}" =~ ^[1-9]+$ ]] || ((MONITOR_NUM < 1 || MONITOR_NUM > 9 )); then
    echo "Invalid monitor number. Please enter a valid number between 1 and 9."
    exit 1
fi

# Get current input
current=$(ddcutil --async -d "${MONITOR_NUM}" getvcp 60 | sed -n "s/.*(sl=\(.*\))/\1/p")

# Get the other input
case $current in

    # HDMI -> DP
    $HDMI_INPUT)
        output=$DP_INPUT
	output_name="HDMI"
        ;;

    # DP -> HDMI
    $DP_INPUT)
        output=$HDMI_INPUT
	output_name="DP"
        ;;

    *)
        echo "Unknown input"
        exit 1
        ;;
esac


# Notify and switch input
if command -v notify-send &> /dev/null; then
    notify-send "Switching monitor ${MONITOR_NUM} to ${output_name}" -i /usr/share/icons/Adwaita/16x16/legacy/video-display.png
fi

# Set new input
ddcutil --async -d "${MONITOR_NUM}" setvcp 60 "${output}"

# Check whether cache contains valid numner of monitors and clean cache if not
check_cache_vs_detected
