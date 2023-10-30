# Monitor Input Toggle Script (ddc_switch.sh)

This bash script enables the dynamic toggling of input sources (HDMI to DP or DP to HDMI) for connected monitors. The script leverages the `ddcutil` utility to manage the input source switch.

## Features

- **Dynamic Monitor Detection:** Detects the number of connected monitors to enable user selection for input switching.
- **Input Switching:** Toggles between HDMI and DisplayPort inputs for the specified monitor.
- **Cache System:** Utilizes a cache system to store and compare the detected number of monitors, improving script efficiency.

## Usage

### Requirements

- **ddcutil:** Ensure `ddcutil` is installed on your system.
- **zenity** is needed for the monitor selection dialog
- **notify-send** to display desktop notification

### Configuration

- **Input Codes:** The script allows for defining HDMI and DP input codes for easy reference.
- **Monitor Detection Configuration:** The `DETECT_MONITORS` variable controls the dynamic generation of monitor numbers. Modify this to suit your preferences.

### Running the Script

1. **Run the Script:** Execute the script in the terminal using `bash ddc_switch.sh` or `./ddc_switch.sh`.
2. **User Input:** Depending on the configuration, the script may prompt you to select the monitor number to switch input sources.
3. **Monitor Input Switch:** The script will identify the current input and switch it to the alternate input source.
4. **Notifications:** If supported, a system notification will indicate the switch between inputs.
5. **i3vm integration** Add the binding similar to the following to your ~/.config/i3/config
   ```
   bindsym $mod+Shift+x exec /usr/local/bin/ddc_switch.sh
   ```

## Customization

- Modify the script variables to suit specific requirements.
- Adapt the script for different input sources or add additional functionalities.

