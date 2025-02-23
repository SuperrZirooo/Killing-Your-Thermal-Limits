ui_print "--------------------------------------"
ui_print "      Void Disable Thermal G99       " 
ui_print "--------------------------------------"
ui_print "      By: SuperrZiroo             "
ui_print "--------------------------------------"
ui_print "      Join : @SzProjectt          "
ui_print "--------------------------------------"
ui_print " "
sleep 1.0
ui_print "------------------------------------"
ui_print "            DEVICE INFO             "
ui_print "------------------------------------"
ui_print "DEVICE : $(getprop ro.build.product) "
ui_print "MODEL : $(getprop ro.product.model) "
ui_print "MANUFACTURE : $(getprop ro.product.system.manufacturer) "
ui_print "PROC : $(getprop ro.product.board) "
ui_print "CPU : $(getprop ro.hardware) "
ui_print "ANDROID : $(getprop ro.build.version.release) "
ui_print "KERNEL : $(uname -r) "
ui_print "RAM : $(free | grep Mem |  awk '{print $2}') "
ui_print " "
sleep 1.0
ui_print "-----------------------------------"
ui_print "          MODULE INFO          "
ui_print "-----------------------------------"
ui_print "Name : Void Disable Thermal G99 "
ui_print "Version : 1.0 "
ui_print "Support Root : Magisk / KernelSU / APatch"
ui_print " "
sleep 1.0
ui_print "-------------------------------------------"
ui_print "  INSTALLING Void Disable Thermal G99  "
ui_print "-------------------------------------------"
ui_print " "
sleep 1.5

# Set permissions
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $MODPATH/vendor 0 0 0755 0755
set_perm_recursive $MODPATH/system 0 0 0755 0755

find /system/vendor/ -name "*thermal*" -type f -print0 | while IFS= read -r -d '' nama;do if [[ "$nama" == *.conf ]];then mkdir -p "$MODPATH/$nama";rmdir "$MODPATH/$nama";touch "$MODPATH/$nama";fi;done >/dev/null 2>&1