#!/system/bin/sh
MODDIR=${0%/*}

while true; do
  boot=$(getprop sys.boot_completed)
  if [ "$boot" = 1 ]; then
  
    for zone in thermal_zone0 thermal_zone9 thermal_zone10; do
      echo 999999999 > /sys/class/thermal/$zone/trip_point_0_temp
    done

    find /sys/devices/virtual/thermal -type f -exec chmod 000 {} +

    echo "N" > /sys/module/workqueue/parameters/power_efficient
    echo "N" > /sys/module/workqueue/parameters/disable_numa

    for service in thermal thermald thermal_core thermal_manager vendor.thermal-hal-2-0.mtk \
                 mi_thermald vendor.thermal-engine vendor.thermal-manager vendor.thermal-hal-2-0 \
                 vendor.thermal-symlinks vendor.thermal.link_ready vendor.thermal.symlinks thermal_mnt_hal_service \
                 vendor.thermal-hal thermalloadalgod thermalservice sec-thermal-1-0 \
                 debug_pid.sec-thermal-1-0 thermal-engine vendor.thermal-hal-1-0 \
                 android.thermal-hal vendor-thermal-1-0 thermal-hal android.thermal-hal; do
      stop $service
    done

    for a in $(getprop|grep thermal|cut -f1 -d]|cut -f2 -d[|grep -F init.svc.|sed 's/init.svc.//'); do
      stop $a
      setprop $a stopped
      setprop ${a}_} ""
    done

    exit
  fi
  sleep 1
done
