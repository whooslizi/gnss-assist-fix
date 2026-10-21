#!/system/bin/sh
MOD=/data/adb/modules/gnss_assist_fix
ROOT=/proc/1/root

cmd location providers send-extra-command gps force_time_injection
cmd location providers send-extra-command gps force_psds_injection
echo "Assistance data re-injected"

echo
echo "== Mounts =="
grep -E "gps|agps" /proc/1/mounts || echo "none"

echo
echo "NTP: $(settings get global ntp_server)"

for f in /vendor/etc/gps.conf /odm/etc/gps.conf /system/etc/gps.conf /system/etc/gps_debug.conf; do
  [ -f "$ROOT$f" ] || continue
  echo
  echo "== $f =="
  grep -E '^(SUPL_HOST|SUPL_PORT|NTP_SERVER|XTRA_SERVER_[0-9])=' "$ROOT$f"
done

echo
echo "== Network provider =="
dumpsys location 2>/dev/null | grep -A1 'network provider:' | head -n 2
