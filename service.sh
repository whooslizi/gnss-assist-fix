#!/system/bin/sh
until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 2; done

settings put global ntp_server time.android.com

i=0
while [ $i -lt 60 ]; do
  ping -c1 -W2 8.8.8.8 >/dev/null 2>&1 && break
  sleep 2
  i=$((i + 1))
done

cmd location providers send-extra-command gps force_time_injection >/dev/null 2>&1
cmd location providers send-extra-command gps force_psds_injection >/dev/null 2>&1
