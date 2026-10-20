# gnss-assist-fix
Swaps China-only A-GNSS servers (SUPL, XTRA, NTP) for global ones

# Why
Chinese-market ROMs (Xiaomi, Vivo, OPPO, etc.) point GPS assistance at servers that only serve China, like Qianxun (`qxwz.com`). Outside China, the GPS chip gets no assistance data, so it falls back to slow, unassisted fixes.

You notice it most where the sky is partly blocked, like narrow alleys or between tall buildings:
- Slow first fix, or no fix at all
- Position jumping around or drifting away from where you are
- Fix lost after a few seconds indoors or in alleys

Inside China this never shows up, because those servers work there.

# What it changes
| File | Change |
|---|---|
| `gps.conf` (vendor/odm/system) | `SUPL_HOST` → `supl.google.com:7275`, `NTP_SERVER` → `time.android.com`, Qualcomm `XTRA_SERVER_*` → `xtrapath[1-3].izatcloud.net` (keeps the ROM's XTRA file name) |
| `agps_profiles_conf2.xml` (MediaTek) | Qianxun SUPL hosts → `supl.google.com` |
| `gps_debug.conf` (system) | Framework-level SUPL override, works on any chipset |
| `ntp_server` global setting | `time.android.com` |

On every boot, once the network is up, it re-injects time and XTRA/PSDS data.

Original files are never modified. Everything is overlaid through the module and goes away when you remove it.

# Install
1. Flash `gnss_assist_fix-vX.X.zip`
2. Reboot
3. Go outside with a clear sky for 1–2 minutes to get a fresh fix

Cold reset the GPS:
```sh
su -c 'cmd location providers send-extra-command gps delete_aiding_data'
```
Then go outside and wait for a new fix.

# Limitations
- Multipath: In narrow alleys, signals bounce off walls before reaching the phone. Better assistance data helps the phone lock faster and hold the fix, but no software can fully fix reflected signals.
- Network location: If your position still jumps when GPS is weak, the cause is likely the ROM's China network location provider (Wi-Fi/cell positioning). The action button shows which provider you have. Replacing it needs GMS plus an overlay, which this module doesn't do.
- Real-world jamming/spoofing: If someone is actually jamming or spoofing GPS signals in an area, nothing on the phone can fix that.

# Uninstall
Remove the module and reboot. `uninstall.sh` resets the `ntp_server` setting back to the ROM default.
