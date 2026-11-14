#!/bin/bash

bats=(/sys/class/power_supply/BAT*)
BAT_DIR="${bats[0]}"
PREV_TOTAL=0
PREV_IDLE=0

while true; do
    # CPU Usage
    read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
    IDLE=$((idle + iowait))
    TOTAL=$((user + nice + system + IDLE + irq + softirq + steal))
    DIFF_TOTAL=$((TOTAL - PREV_TOTAL))
    DIFF_IDLE=$((IDLE - PREV_IDLE))
    [ "$DIFF_TOTAL" -gt 0 ] && CPU=$(( (100 * (DIFF_TOTAL - DIFF_IDLE)) / DIFF_TOTAL )) || CPU=0
    PREV_TOTAL=$TOTAL
    PREV_IDLE=$IDLE

    # RAM Usage
    while IFS=": " read -r key val _; do
        case "$key" in
            MemTotal) mem_total=$val ;;
            MemAvailable) mem_avail=$val; break ;;
        esac
    done < /proc/meminfo
    RAM=$(( (mem_total - mem_avail) * 100 / mem_total ))

    # Battery Level
    if [ -f "$BAT_DIR/capacity" ]; then
        read -r BAT < "$BAT_DIR/capacity"
        read -r BAT_STAT < "$BAT_DIR/status"
        case "$BAT_STAT" in
            Charging) BAT_IND="+" ;;
            Full)     BAT_IND="=" ;;
            *)        BAT_IND=""  ;;
        esac
    else
        BAT="N/A"
        BAT_IND=""
    fi

    # Network Status
    NET="Offline"
    while read -r iface _; do
        case "$iface" in
            Inter-*|face|lo:) continue ;;
            *:*)
                NET="WiFi"
                break
                ;;
        esac
    done < /proc/net/wireless

    if [ "$NET" = "Offline" ]; then
        for state_file in /sys/class/net/[ew]*/operstate; do
            [ -f "$state_file" ] && read -r state < "$state_file"
            if [ "$state" = "up" ]; then
                NET="Online"
                break
            fi
        done
    fi

    # Volume
    VOL_RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    if [[ "$VOL_RAW" == *"MUTED"* ]]; then
        VOL="Muted"
    else
        VOL_DEC=${VOL_RAW#*Volume: }
        VOL=$(( 10#${VOL_DEC/./} ))%
    fi

    # Power Profile
    if [ -f /etc/tuned/active_profile ]; then
        read -r PWR < /etc/tuned/active_profile
    fi

    # Current Hour:Min 
    printf -v TIME '%(%H:%M)T' -1

    echo "cpu: ${CPU}% | ram: ${RAM}% | connection: ${NET} | volume: ${VOL} | profile: ${PWR} | battery: ${BAT_IND}${BAT}% | ${TIME}"

    sleep 2
done