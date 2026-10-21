#!/system/bin/sh
MODDIR=${0%/*}
FILES=$MODDIR/files

[ -d "$FILES" ] || exit 0

find "$FILES" -type f | while read -r src; do
  target=${src#$FILES}
  [ -f "$target" ] || continue
  ctx=$(ls -Z "$target" | awk '{print $1}')
  [ -n "$ctx" ] && chcon "$ctx" "$src"
  chmod 0644 "$src"
  umount "$target" 2>/dev/null
  mount -o bind "$src" "$target"
done
