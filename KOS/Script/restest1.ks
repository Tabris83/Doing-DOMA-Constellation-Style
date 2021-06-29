sas off.
runoncepath("0:/lib/Lib_HUD.ks").
clearscreen.
set currPer to obt:period.
set resPer to currPer * 1.33.
warpto(time:seconds + (eta:apoapsis - 30)).
lock steering to prograde.//heading(90,0).
wait 1.
until obt:period >= resPer
{
  set perErr to resPer - obt:period.
  lock throttle to perErr/100.
  print "Current Period: " + MET(obt:period) at (0,1).
  print " Target Period: " + MET(resPer) at (0,2).
  print "         error: " + MET(perErr) at (0,3).
  print "     Throttle: " + throttle at (0,4).
}
lock throttle to 0.
