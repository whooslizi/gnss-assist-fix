#!/system/bin/sh
cmd location providers send-extra-command gps force_time_injection
cmd location providers send-extra-command gps force_psds_injection
echo "Assistance data re-injected"

echo
echo "NTP: $(settings get global ntp_server)"

for f in /vendor/etc/gps.conf /odm/etc/gps.conf /system/etc/gps.conf /system/etc/gps_debug.conf; do
  [ -f "$f" ] || continue
  echo
  echo "$f"
  grep -E '^(SUPL_HOST|SUPL_PORT|NTP_SERVER|XTRA_SERVER_[0-9])=' "$f"
done

echo
dumpsys location 2>/dev/null | grep -iA2 'network provider' | head -n 6
