//Generic Launch Vehicle Boot Script

SAS OFF. RCS OFF. GEAR OFF. LIGHTS OFF.  CLEARVECDRAWS().
wait until ship:unpacked.
runoncepath("0:/lib/lib_filesys.ks").
set Liblist to list("lib/lib_func.ks","lib/lib_math.ks","/lib/lib_filesys.ks").
if ship:dockingports:length >0 Liblist:add("lib/Lib_Dock.ks").

if ship:rootpart:tag <> "" and not ship:rootpart:tag = "FORMAT CORE"
{
  Set runmode to ship:rootpart:tag:toscalar.
  wait 1.
  launch_Prog().
}
else if ship:rootpart:tag = ""
{
  Copy_Files().
  launch_Prog().
}
else if ship:rootpart:tag = "FORMAT CORE"
{
  Format_Core().
  wait 1.
  set ship:rootpart:tag to "".
  copypath("0:/boot/boot.ks","1:/boot/boot.ks").
  set core:bootfilename to "/boot/boot.ks".
  reboot.
}
