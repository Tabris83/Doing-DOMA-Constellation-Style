sas off. //unlock all.

runoncepath("0:/lib/Lib_HUD.ks").
runoncepath("0:/lib/Lib_math.ks").
clearscreen.
set TarAP to 3000000.
set resFraction to 1.33.

set tVal to 0.
lock throttle to tVal.
set sVal to "KILL".
LOCK Steering to sVal.


//Raise AP to Target AP
warpto(time:seconds + (eta:periapsis -30)).
lock sVal to prograde.
wait until vang(SHIP:FACING:FOREVECTOR, prograde:vector) < 2.
until alt:apoapsis >= TarAP
{
  set ApErr to TarAP - alt:apoapsis.
  set tVal to ApErr/100.
}
set tVal to 0.
wait 1.

//Increase Orbital Period to Resonant Period
warpto(time:seconds + (eta:apoapsis -30)).
lock sVal to prograde.
set resPer to OrbPeratAlt(TarAP)*resFraction.
wait until vang(SHIP:FACING:FOREVECTOR, prograde:vector) < 2.
until obt:period >= resPer
{
  set resErr to resPer - obt:period.
  set tVal to resErr/100.
}
set tVal to 0.
