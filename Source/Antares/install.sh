SKIPMOUNT=false

PROPFILE=true

POSTFSDATA=true

LATESTARTSERVICE=true

REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"


REPLACE="
"
print_modname() {
ui_print "------------------------------------"
ui_print "      Killing Your Thermal Limits    " 
ui_print "------------------------------------"
ui_print "      By: SuperrZiroo             "
ui_print "------------------------------------"
ui_print "      Join : @SzProjectt          "
ui_print "------------------------------------"
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
ui_print "-------------------------------------"
ui_print "            MODULE INFO             "
ui_print "-------------------------------------"
ui_print "Name : Killing Your Thermal Limits"
ui_print "Version : 1"
ui_print "CodeName: Antares"
ui_print "Support Root : Magisk / KernelSU / APatch"
ui_print " "
sleep 1.0
ui_print "-------------------------------------------"
ui_print "   INSTALLING Killing Your Thermal Limits   "
ui_print "-------------------------------------------"
ui_print " "
sleep 1.5
}

# Copy/extract your module files into $MODPATH in on_install.

on_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm $MODPATH/system/bin/P0 0 0 0755 0755
  set_perm $MODPATH/system/bin/P1 0 0 0755 0755

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# You can add more functions to assist your custom script code
