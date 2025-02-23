#!/system/bin/sh
MODDIR=${0%/*}
for prop in \
    ro.boottime.thermald \
    ro.boottime.vendor.thermal-hal \
    ro.boottime.vendor.thermal-hal-2-0.mtk \
    ro.vendor.mtk_thermal_2_0 \
    ro.boottime.thermal_core \
    ro.boottime.vendor.thermal.symlinks; do
  resetprop -n "$prop" 0
done
