//Ascent Gudance and Circularization - Vehicle Independent
parameter OrbInc to 0, MaxG to 4.
SAS OFf. RCS OFF. LIGHTS OFF. GEAR OFF.
//Orbit Defaults - Kerbin - AP 120km, Gravity Turn End 60km, Inclination 0
//Libraries
runoncepath("0:/lib/lib_lazcalc.ks").
runoncepath("0:/lib/lib_math.ks").
runoncepath("0:/lib/Lib_Func.ks").
runoncepath("0:/lib/Lib_HUD.ks").
if body:atm:exists
{
  set OrbAlt to body:atm:height + 35000.
  set TurnEnd to body:atm:height * 0.7.
}
else
{
  set OrbAlt to 35000.
  set TurnEnd to OrbAlt * 0.7.
}
set LaunchData to LAZcalc_init(OrbAlt,OrbInc).
set runmode to -1.
set launchcomplete to FALSE.

HUD_init().
HUD_print().
//setup throttle and steering locks.
set tVal to 0.
lock throttle to tVal.
set sVal to Ship:Up.
LOCK Steering to sVal.
//Throttle PID
set kp to 0.1.
set ki to 0.01.
set kd to 0.05.
Set PID to PIDLOOP(kp,ki,kd).
set pid:maxoutput to 0.1.
set pid:minoutput to -0.1.


//Resume Script or Initial Boot
if ship:rootpart:tag <> "" {set_runmode(ship:rootpart:Tag:toscalar).} //Resume Script
Else{CountDown(). set tVal to 1. set sVal to UP. set_runmode(10). Stage.} //Initial Boot.


until launchcomplete
{
  if runmode = 10
  {
    if body:atm:exists {until alt:radar > 1000 or ship:verticalspeed > 100 {HUD_print(). wait 0. }}
    set sVal to heading(LAZcalc(LaunchData),max(round(90 - (90 * ((floor(altitude) * 100) / (TurnEnd)) / 100)),0)).
    set Tval to min((1-ship:q),max(0.5, ship:mass * (MaxG * CONSTANT:g0()) / ship:AvailableThrust)).
    if alt:apoapsis >= orbAlt {set tVal to 0. wait 1. set_runmode(20).}
    staging().
    wait 0.
  }
  else if runmode = 20
  {
    set tVal to 0.
    if alt:radar >= TurnEnd and ship:partsdubbed("PLF"):length >0
    {
      ship:partsdubbed("PLF")[0]:getmodule("ModuleProceduralFairing"):doaction("Deploy",true).
    }
    wait until alt:radar >= body:atm:height.
    panels on.
    if alt:radar >= (body:atm:height + 500)
    {
      warpto(time:seconds + (eta:apoapsis-30)).
      if kuniverse:timewarp:issettled() {set sVal to heading(LAZcalc(LaunchData),0). set_runmode(30).}
    }
  }
  else if runmode = 30
  {
    if eta:apoapsis >=30 {set tVal to 0.}
    Else
    {
      set sVal to prograde.
      set tval to 1.
    }
    staging().
    wait 0.
    if ship:obt:eccentricity <= 0.001 {set tVal to 0. set launchcomplete to true.}
  }
  HUD_print().
}
