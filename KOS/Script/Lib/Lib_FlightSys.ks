//Flight Operations Systems
// Launch Operations
//   CountDown
//   Ascent
//   Coast
//   Circularize
//
// Mission
//   Resonant Orbit
//   Rendevous
//   Docking
//
// Post Mission
//   De-Orbit
//
// Utilities
//   Staging


//Launch Operations
function doCountDown
{
  //HUD_init().
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
}

FUNCTION doAscent
{
  // if body:atm:exists {until alt:radar > 1000 or ship:verticalspeed > 100 {wait 0. }}
  set sVal to heading(LAZcalc(LaunchData),max(round(90 - (90 * ((floor(altitude) * 100) / (TurnEnd)) / 100)),0)).
  set Tval to min((1-ship:q),max(0.5, ship:mass * (MaxG * CONSTANT:g0()) / ship:AvailableThrust)).
  if alt:apoapsis >= orbAlt {set tVal to 0. wait 1. }
  wait 0.
}

function doCoast
{
  set tVal to 0.
  wait until alt:radar >= body:atm:height.
  panels on.
  if alt:radar >= (body:atm:height + 500) {warpto(time:seconds + (eta:apoapsis-30)).}
  if kuniverse:timewarp:issettled() {set sVal to heading(LAZcalc(LaunchData),0). }
  wait 0.
}

function doCircularize
{

  until ship:obt:eccentricity <= 0.001
  {
    if eta:apoapsis >=45 {set tVal to 0.}
    else
    {
      set circErr to (orbAlt - alt:periapsis)/100.
      set sVal to prograde.
      set tVal to circErr.
    }
  }
  set tVal to 0. wait 1.
  wait 0.
}

//Mission Functions
function doResonantOrbit1 //Params Target AP, Resonant Fraction (Decimal)
{

  LOCK Steering to sVal.
  //Raise AP to Target AP
  set sVal to prograde.
  wait 0.
  warpto(time:seconds + (eta:periapsis -45)).
  set sVal to prograde.
  wait until vang(SHIP:FACING:FOREVECTOR, prograde:vector) < 2.
  until alt:apoapsis >= TarAP
  {
    set ApErr to TarAP - alt:apoapsis.
    set tVal to ApErr/100.
  }
  set tVal to 0.
  wait 1.
  wait 0.
}
function doResonantOrbit2
{

  LOCK Steering to sVal.
  set sVal to prograde.
  //Increase Orbital Period to Resonant Period
  warpto(time:seconds + (eta:apoapsis -45)).
  set sVal to prograde.
  set resPer to OrbPeratAlt(TarAP)*resFraction.
  wait until vang(SHIP:FACING:FOREVECTOR, prograde:vector) < 2.
  until obt:period >= resPer
  {
    set resErr to resPer - obt:period.
    set tVal to resErr/100.
  }
  set tVal to 0.
  wait 0.

}

function doDeploy
{

  local srel is 0.
  until ship:partstagged("SAT"):length = 0
  {
    set sVal to prograde.
    if eta:periapsis <= 55 and not Srel
    {
      set p to ship:partstagged("SAT")[0].
      p:getmodule("moduleDecouple"):DOEVENT("Decouple").
      set p:tag to "deployed".
      set srel to 1.
      KUniverse:QUICKSAVE().
      AV_switch().
    }
    else if eta:periapsis > 180
    {
      warpto(time:seconds + (ETA:periapsis-60)).
    }
    if ETA:periapsis > ETA:apoapsis set Srel to 0.
  }
  if ship:partstagged("SAT"):length = 0 and not Srel {}
  wait 0.
}


function doRendevous //Params Target.
{

}

function doDocking
{

}

//post Mission
function doDeOrbit
{

  set sVal to retrograde.
  until alt:periapsis <= 0 set tVal to 1.

}

//Utilities
function doStaging
{

  list engines in eList.
  for eng in eList
  {
    if ship:AvailableThrust < 1 or (eng:flameout and eng:ignition)
    {
      WAIT 1.
      stage.
      break.
    }
    if stage:number < 1 BREAK.
  }
}

function doFaringDeploy
{

  if (alt:radar >= orbAlt*0.9 OR alt:radar >= body:atm:height) and ship:partsdubbed("PLF"):length >0
  {
    ship:partsdubbed("PLF")[0]:getmodule("ModuleProceduralFairing"):doaction("Deploy",true).
  }
}
