// LV.Satbus.ks
// Launch Vehicle Satellite Bus Roadmap.
//
// Script 1.
// Launch and Ascent
//    Pre-Launch
//    Ascent
//      Needs to be able to Launch into Inclined Orbit.
//    Circularization to Parking Orbit (Kerbin 120km, 0 Inclination)
//
// Script 2.
// Mission Specific
//  Raise Orbit to Resonant Orbit Period
//  Deploy Satellites at AP
//    Switch to Satellite so it can circularize
//    Switch back to SatBus
//
// Script 3.
// Post Mission
//   Rename Deployed Satellites
//   De-Orbit SatBus
// Script 1 & 3 should be Generic and Vehicle Independant.

runoncepath("0:/lib/lib_lazcalc.ks").
runoncepath("0:/lib/lib_math.ks").
runoncepath("0:/lib/Lib_Func.ks").
runoncepath("0:/lib/Lib_HUD.ks").
runoncepath("0:/lib/Lib_Flightsys.ks").
runoncepath("0:/lib/Lib_mission.ks").
runoncepath("0:/lib/lib_filesys.ks").

parameter Missionparams to core:tag:split("|")[1].
if missionparams <> ""
{
  set TarAP to missionparams:split(",")[0]:toscalar.
  set OrbInc to missionparams:split(",")[1]:toscalar.
  set MaxG to missionparams:split(",")[2]:toscalar.
  set Sats to ship:partstagged("SAT"):length.
  if Sats > 0 {set resFraction to 1 + round(1/Sats,2).} else {set resFraction to 1.}
}

if body:atm:exists{set OrbAlt to body:atm:height + 35000. set TurnEnd to body:atm:height * 0.7.}
else{set OrbAlt to 35000. set TurnEnd to OrbAlt * 0.5.}

set LaunchData to LAZcalc_init(OrbAlt,OrbInc).
set runmode to -1.
//Initial Startup Functions
HUD_init().
HUD_print().
TagCores().
Sat_Update().
//setup throttle and steering locks.
set tVal to 0.
lock throttle to tVal.
set sVal to "KILL".
LOCK Steering to sVal.
set done to false.
// Main Program

// set Main_Seq to List(
//   "Terminal Count  ", doCountDown@,
//   "Ascent          ", doAscent@,
//   "Coast Phase     ", doCoast@,
//   "Circularization ", doCircularize@,
//   "Setting ResOrbit", doResonantOrbit1@,
//   "Setting ResOrbit", doResonantOrbit2@,
//   "Deploying Sats  ", doDeploy@,
//   "De-Orbiting     ", doDeOrbit@
// ).
//
// set events to lex(
//   "Staging", doStaging@,
//   "Faring", doFaringDeploy@,
//   "Hud Print", HUD_print@,
//   //"Debug", HUD_Debug@,
//   "Sat Dep", HUD_SatDep@
// ).
// run_mission(Main_Seq, events).
