set done to false.
set RunMode to -1.
set RunCode to -1.
set OpCode to -1.

//setup throttle and steering locks.
set tVal to 0.
lock throttle to tVal.
set sVal to "KILL".
LOCK Steering to sVal.

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
clearscreen.

if ship:rootpart:tag <> "" //Resume
{
  set RM to ship:rootpart:tag:split(",")[0]:toscalar.
  set RC to ship:rootpart:tag:split(",")[1]:toscalar.
  HUD_init().
  HUD_print().
  set_runmode(RM,RC).
}
ELSE //Initial Boot
{
  if ship:modulesnamed("kOSProcessor"):length > 1
  {
    TagCores().
    Sat_Update().
    SleepCores().
  }
  set tVal to 1.
  set sVal to heading(90,90).
  HUD_init().
  HUD_print().
  set_runmode(10,0).
}

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

until done
{
  if RunMode = 10 //Launch & Circularization
  {
    set OpCode to "     ".
    set OpCode to "100".
    set_runmode(10,10).
    until RunMode = 20
    {
      if RunCode = 10 //Count
      {
        set OpCode to "101".
        set Count to 10.
        until Count = 0
        {
          notify(Count).
          set Count to Count -1.
          wait 1.
        }
        set tVal to 1.
        set sVal to heading(90,90).
        stage.
        set_runmode(10,20).
      }
      else if RunCode = 20 // Ascent
      {
        set OpCode to "102".
        set sVal to heading(LAZcalc(LaunchData),max(round(90 - (90 * ((floor(altitude) * 100) / (TurnEnd)) / 100)),0)).
        set Tval to min((1-ship:q),max(0.5, ship:mass * (MaxG * CONSTANT:g0()) / ship:AvailableThrust)).
        doStaging().
        if alt:apoapsis >= orbAlt {set tVal to 0. wait 1. set_runmode(10,30).}
      }
      else if RunCode = 30  // Coast
      {
        set OpCode to "103".
        doFaringDeploy().
        set tVal to 0.
        wait until alt:radar >= body:atm:height.
        panels on.
        if alt:radar >= (body:atm:height + 500) {warpto(time:seconds + (eta:apoapsis-30)).}
        if kuniverse:timewarp:issettled() {set sVal to heading(LAZcalc(LaunchData),0). set_runmode(10,40).}
      }
      else if RunCode = 40 // Circularization
      {
        set OpCode to "104".
        until ship:obt:eccentricity <= 0.001
        {
          if eta:apoapsis >=30 {set tVal to 0.}
          else
          {
            set circErr to (orbAlt - alt:periapsis)/100.
            set sVal to prograde.
            set tVal to circErr.
          }
          doStaging().
          HUD_print().
          HUD_Debug().
        }
        set tVal to 0. wait 1. set_runmode(20,0).
      }
      HUD_print().
      doStaging().
      wait 0.
    }
  }
  else if RunMode = 20 // Mission - Resonant Orbit & Sat Deploy.
  {
    set OpCode to "     ".
    set OpCode to "200".
    set_runmode(20,10).
    until RunMode = 30
    {
      if RunCode = 10 //Raise AP to Target Altitude
      {
        set OpCode to "201".
        set sVal to prograde.
        wait 0.
        warpto(time:seconds + (eta:periapsis -30)).
        // wait until vang(SHIP:FACING:FOREVECTOR, prograde:vector) < 2.
        until alt:apoapsis >= TarAP
        {
          set sVal to prograde.
          set ApErr to (TarAP - alt:apoapsis)/100.
          set tVal to ApErr.
          HUD_print().
          HUD_Debug().
        }
        set tVal to 0.
        wait 0.
        set_runmode(20,20).
      }
      else if RunCode = 20 //Warp to AP, raise AP to Resonant Orbit altitude.
      {
        set tVal to 0.
        set OpCode to "202".
        wait 2.
        //Increase Orbital Period to Resonant Period
        warpto(time:seconds + (eta:apoapsis -30)).
        set sVal to prograde.
        set resPer to OrbPeratAlt(TarAP)*resFraction.
        //wait until vang(SHIP:FACING:FOREVECTOR, prograde:vector) < 2.
        until obt:period >= resPer
        {
          set sVal to prograde.
          set resErr to (resPer - obt:period)/100.
          set tVal to resErr.
          HUD_print().
          HUD_Debug().
        }
        set tVal to 0.
        wait 0.
        set_runmode(20,30).
      }
      else if RunCode = 30 // Wake Cores, Deploy Sats
      {
        SleepCores().
        set OpCode to "203".
        local srel is 0.
        until ship:partstagged("SAT"):length = 0
        {
          // set sVal to prograde.
          set sVal to UP. wait 2.
          if eta:periapsis <= 55 and not Srel
          {
            set p to ship:partstagged("SAT")[0].
            p:getmodule("moduleDecouple"):DOEVENT("Decouple").
            set p:tag to "deployed".
            set srel to 1.
            //KUniverse:QUICKSAVEto(shipname + "-SatDeploy").
            AV_switch().
          }
          else if eta:periapsis > 180
          {
            warpto(time:seconds + (ETA:periapsis-60)).
          }
          if ETA:periapsis > ETA:apoapsis set Srel to 0.
          HUD_print().
        }
        wait 0.
        if ship:partstagged("SAT"):length = 0 and not Srel {set RunCode to -1. set RunMode to 30.}
      }
      HUD_print().
      HUD_SatDep().
      doStaging().
      wait 0.
    }
  }
  else if RunMode = 30
  {
    doDeOrbit().
  }
  HUD_print().
}
