#!/system/bin/sh
SUPL_HOST=supl.google.com
SUPL_PORT=7275
NTP=time.android.com
OUT=$MODPATH/files

set_kv() {
  sed -i -E "/^[#[:space:]]*$2[[:space:]]*=/d" "$1"
  echo "$2=$3" >> "$1"
}

stage() {
  dst=$OUT$1
  mkdir -p "${dst%/*}"
  cp -L "$1" "$dst"
  echo "$dst"
}

for src in /vendor/etc/gps.conf /odm/etc/gps.conf /system/etc/gps.conf; do
  [ -f "$src" ] || continue
  ui_print "- Patching $src"
  dst=$(stage "$src")

  set_kv "$dst" SUPL_HOST "$SUPL_HOST"
  set_kv "$dst" SUPL_PORT "$SUPL_PORT"
  set_kv "$dst" NTP_SERVER "$NTP"

  cur=$(grep -E '^XTRA_SERVER_1' "$src" | head -n1 | cut -d= -f2- | tr -d ' "')
  case "$cur" in
    ""|*izatcloud.net*|*xtracloud.net*) ;;
    *)
      bin=${cur##*/}
      case "$bin" in *.bin) ;; *) bin=xtra3grc.bin ;; esac
      for n in 1 2 3; do
        set_kv "$dst" XTRA_SERVER_$n "https://xtrapath$n.izatcloud.net/$bin"
      done
      ;;
  esac
done

for src in /vendor/etc/agps_profiles_conf2.xml /odm/etc/agps_profiles_conf2.xml /system/etc/agps_profiles_conf2.xml; do
  [ -f "$src" ] || continue
  ui_print "- Patching $src"
  dst=$(stage "$src")
  sed -i -E "s/(supl|agnss)\.qxwz\.com/$SUPL_HOST/g" "$dst"
done

if [ -f /system/etc/gps_debug.conf ]; then
  ui_print "- Patching /system/etc/gps_debug.conf"
  dst=$(stage /system/etc/gps_debug.conf)
  set_kv "$dst" SUPL_HOST "$SUPL_HOST"
  set_kv "$dst" SUPL_PORT "$SUPL_PORT"
fi

set_perm_recursive "$MODPATH" 0 0 0755 0644
ui_print "- Done, reboot"
