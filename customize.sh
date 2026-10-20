#!/system/bin/sh
SUPL_HOST=supl.google.com
SUPL_PORT=7275
NTP=time.android.com

set_kv() {
  sed -i -E "/^[#[:space:]]*$2[[:space:]]*=/d" "$1"
  echo "$2=$3" >> "$1"
}

target() {
  if [ "$1" = system ]; then
    echo "$MODPATH/system/etc/$2"
  else
    echo "$MODPATH/system/$1/etc/$2"
  fi
}

for part in vendor odm system; do
  src=/$part/etc/gps.conf
  [ -f "$src" ] || continue
  dst=$(target "$part" gps.conf)
  mkdir -p "${dst%/*}"
  cp -L "$src" "$dst"
  ui_print "- Patching $src"

  set_kv "$dst" SUPL_HOST "$SUPL_HOST"
  set_kv "$dst" SUPL_PORT "$SUPL_PORT"
  set_kv "$dst" NTP_SERVER "$NTP"

  cur=$(grep -E '^XTRA_SERVER_1' "$src" | head -n1 | cut -d= -f2- | tr -d ' "')
  case "$cur" in
    ""|*izatcloud.net*) ;;
    *)
      bin=${cur##*/}
      case "$bin" in *.bin) ;; *) bin=xtra3grc.bin ;; esac
      for n in 1 2 3; do
        set_kv "$dst" XTRA_SERVER_$n "https://xtrapath$n.izatcloud.net/$bin"
      done
      ;;
  esac
done

for part in vendor odm system; do
  src=/$part/etc/agps_profiles_conf2.xml
  [ -f "$src" ] || continue
  dst=$(target "$part" agps_profiles_conf2.xml)
  mkdir -p "${dst%/*}"
  cp -L "$src" "$dst"
  ui_print "- Patching $src"
  sed -i -E "s/(supl|agnss)\.qxwz\.com/$SUPL_HOST/g" "$dst"
done

dbg=$MODPATH/system/etc/gps_debug.conf
mkdir -p "${dbg%/*}"
if [ -f /system/etc/gps_debug.conf ]; then
  cp -L /system/etc/gps_debug.conf "$dbg"
else
  : > "$dbg"
fi
set_kv "$dbg" SUPL_HOST "$SUPL_HOST"
set_kv "$dbg" SUPL_PORT "$SUPL_PORT"

set_perm_recursive "$MODPATH" 0 0 0755 0644
ui_print "- Done, reboot"
