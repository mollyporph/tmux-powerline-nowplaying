#!/bin/bash
# Prints now playing from spotify or mocp

run_segment() {
metadata=$(dbus-send --reply-timeout=42 --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' 2>/dev/null)
		if [ "$metadata" ]; then
			state=$(qdbus-qt4 org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player PlaybackStatus)
			if [[ $state == "Playing" ]]; then
				artist=$(echo "$metadata" | grep -PA2 "string\s\"xesam:artist\"" | tail -1 | grep -Po "(?<=\").*(?=\")")
				track=$(echo "$metadata" | grep -PA1 "string\s\"xesam:title\"" | tail -1 | grep -Po "(?<=\").*(?=\")")
				npspot=$(echo "${artist} - ${track}")
			fi
		fi
    if [ "$npspot" ]; then
        echo "♫ - ${npspot}"
    else
        mocp_pid=$(pidof mocp)
        if [ "$mocp_pid" ]; then
            np=$(mocp -i | grep ^Title | sed "s/^Title://")
            mocp_paused=$(mocp -i | grep ^State | sed "s/^State: //")
            if [[ $np ]]; then
                case "$trim_method" in
                    "roll")
                        np=$(roll_text "${np}" ${max_len} ${roll_speed})
                        ;;
                    "trim")
                        np=$(echo "${np}" | cut -c1-"$max_len")
                        ;;
                esac
                if [[ "$mocp_paused" != "STOP" ]]; then
                    echo "♫  - ${np}"
                elif [[ "$mocp_paused" == "STOP" ]]; then
                    echo "♫ || ${np}"
                fi
            fi
        fi
    fi
}

