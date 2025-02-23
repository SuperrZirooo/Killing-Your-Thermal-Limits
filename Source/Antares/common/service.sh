#!/system/bin/sh
MODDIR=${0%/*}

# Wait until boot completion
while [ -z "$(getprop sys.boot_completed)" ]; do
    sleep 1
done


# Function: Lock a value in a file
lock_val() {
    local value="$1"
    shift
    for file in "$@"; do
        if [ -f "$file" ]; then
            chown root:root "$file"
            chmod 644 "$file"
            echo "$value" > "$file"
            chmod 444 "$file"
        fi
    done
}


# Remove thermal limits for specific CPU thermal zones
remove_cpu_thermal_limits() {
    for zone in thermal_zone0 thermal_zone9 thermal_zone10; do
        echo 999999999 > /sys/class/thermal/$zone/trip_point_0_temp
    done
}


# Disable access to thermal configuration files
disable_thermal_config_access() {
    find /sys/devices/virtual/thermal -type f -exec chmod 000 {} +
}


# Disable kernel power optimization features for workqueues
disable_kernel_power_opt() {
    echo "N" > /sys/module/workqueue/parameters/power_efficient
    echo "N" > /sys/module/workqueue/parameters/disable_numa
}


# Stop thermal-related services found in the init directories
list_thermal_services() {
    for rc in $(find /system/etc/init -type f && find /vendor/etc/init -type f && find /odm/etc/init -type f); do
        grep -r "^service" "$rc" | awk '{print $2}'
    done | grep thermal
}

for svc in $(list_thermal_services); do
    echo "Stopped $svc"
    stop $svc
done

for pid in $(pgrep thermal); do
    echo "Stopped $pid"
    kill -9 $pid
done

for prop in $(resetprop | grep 'thermal.*running' | awk -F '[][]' '{print $2}'); do
    resetprop $prop stopped
done


# Disable Mediatek temperature limits (if present)
disable_mediatek_thermal() {
    if [ -f /proc/driver/thermal/tzcpu ]; then
        echo "Disabling Mediatek thermal limits..."
        t_limit="125"
        no_cooler="0 0 no-cooler 0 0 no-cooler 0 0 no-cooler 0 0 no-cooler 0 0 no-cooler 0 0 no-cooler 0 0 no-cooler 0 0 no-cooler"
        lock_val "1 ${t_limit}000 0 mtktscpu-sysrst $no_cooler 200" /proc/driver/thermal/tzcpu
        lock_val "1 ${t_limit}000 0 mtktspmic-sysrst $no_cooler 1000" /proc/driver/thermal/tzpmic
        lock_val "1 ${t_limit}000 0 mtktsbattery-sysrst $no_cooler 1000" /proc/driver/thermal/tzbattery
        lock_val "1 ${t_limit}000 0 mtk-cl-kshutdown00 $no_cooler 2000" /proc/driver/thermal/tzpa
        lock_val "1 ${t_limit}000 0 mtktscharger-sysrst $no_cooler 2000" /proc/driver/thermal/tzcharger
        lock_val "1 ${t_limit}000 0 mtktswmt-sysrst $no_cooler 1000" /proc/driver/thermal/tzwmt
        lock_val "1 ${t_limit}000 0 mtktsAP-sysrst $no_cooler 1000" /proc/driver/thermal/tzbts
        lock_val "1 ${t_limit}000 0 mtk-cl-kshutdown01 $no_cooler 1000" /proc/driver/thermal/tzbtsnrpa
        lock_val "1 ${t_limit}000 0 mtk-cl-kshutdown02 $no_cooler 1000" /proc/driver/thermal/tzbtspa
    fi
}


# Disable thermal mode on all thermal zones
disable_thermal_zones() {
    for zone in /sys/class/thermal/thermal_zone*; do
        lock_val "disabled" "$zone/mode"
    done
}


# Remove Mediatek CPU thermal limits
remove_cpu_limits() {
    if [ -f /sys/devices/virtual/thermal/thermal_message/cpu_limits ]; then
        for i in 0 2 4 6 7; do
            maxfreq=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_max_freq)
            if [ "$maxfreq" -gt "0" ]; then
                lock_val "cpu$i $maxfreq" /sys/devices/virtual/thermal/thermal_message/cpu_limits
            fi
        done
    fi
}


# Disable thermal-related PPM policies
disable_ppm_policies() {
    if [ -d /proc/ppm ]; then
        for idx in $(grep -E 'PWR_THRO|THERMAL' /proc/ppm/policy_status | awk -F'[][]' '{print $2}'); do
            lock_val "$idx 0" /proc/ppm/policy_status
        done
    fi
}


# Remove GPU power limitations
remove_gpu_limits() {
    if [ -f "/proc/gpufreq/gpufreq_power_limited" ]; then
        lock_val "ignore_batt_oc 1" /proc/gpufreq/gpufreq_power_limited
        lock_val "ignore_batt_percent 1" /proc/gpufreq/gpufreq_power_limited
        lock_val "ignore_low_batt 1" /proc/gpufreq/gpufreq_power_limited
        lock_val "ignore_thermal_protect 1" /proc/gpufreq/gpufreq_power_limited
        lock_val "ignore_pbm_limited 1" /proc/gpufreq/gpufreq_power_limited
    fi
}


# Disable thermal control on MSM (Qualcomm) and related throttling
disable_msm_thermal() {
    lock_val 0 /sys/kernel/msm_thermal/enabled
    lock_val "N" /sys/module/msm_thermal/parameters/enabled
    lock_val "0" /sys/module/msm_thermal/core_control/enabled
    lock_val "0" /sys/module/msm_thermal/vdd_restriction/enabled
    lock_val 0 /sys/class/kgsl/kgsl-3d0/throttling
    lock_val "stop 1" /proc/mtk_batoc_throttling/battery_oc_protect_stop
}


# Use thermalservice override if available
override_thermalservice() {
    if command -v thermalservice &> /dev/null; then
        cmd thermalservice override-status 0
    fi
}


# Universal Thermal Disabler and additional features
universal_thermal_disabler() {
    echo 0 > /sys/class/thermal/thermal_zone*/mode
    echo 0 > /proc/sys/kernel/sched_boost
    echo N > /sys/module/msm_thermal/parameters/enabled
    echo 0 > /sys/module/msm_thermal/core_control/enabled
    echo 0 > /sys/kernel/msm_thermal/enabled
}


# Stop thermal services
stop_manual_thermal_services() {
    services=(
        logd
        android.thermal-hal
        vendor.thermal-engine
        vendor.thermal_manager
        vendor.thermal-manager
        vendor.thermal-hal-2-0
        vendor.thermal-symlinks
        vendor.thermal.link_ready
        thermal_mnt_hal_service
        thermal
        mi_thermald
        thermald
        thermalloadalgod
        thermalservice
        sec-thermal-1-0
        debug_pid.sec-thermal-1-0
        thermal-engine
        vendor.thermal-hal-1-0
        vendor-thermal-1-0
        thermal-hal
    )
    for svc in "${services[@]}"; do
        stop "$svc"
        sleep 1
    done
}


# Stop thermal services using setprop method
stop_setprop_thermal_services() {
    setprop_list=(
        init.svc.thermal
        init.svc.thermal-managers
        init.svc.thermal_manager
        init.svc.thermal_mnt_hal_service
        init.svc.thermal-engine
        init.svc.mi-thermald
        init.svc.thermalloadalgod
        init.svc.thermalservice
        init.svc.thermal-hal
        init.svc.vendor.thermal-symlinks
        init.svc.android.thermal-hal
        init.svc.vendor.thermal-hal
        init.svc.thermal-manager
        init.svc_debug_pid.vendor.thermal-hal
        init.svc.vendor-thermal-hal-1-0
        init.svc.vendor.thermal-hal-1-0
        init.svc.vendor.thermal-hal-2-0.mtk
        init.svc.vendor.thermal-hal-2-0
    )
    for prop in "${setprop_list[@]}"; do
        setprop "$prop" stopped
    done
}