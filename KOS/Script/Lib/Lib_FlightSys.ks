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
  parameter mission.
  HUD_init().
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
  mission["next"]().
}

function doStaging
{
  parameter mission.
  list engines in eList.
  for eng in eList
  {
    if ship:AvailableThrust < 1 or eng:flameout
    {
      WAIT 1.
      stage.
      break.
    }
    if stage:number < 1 BREAK.
  }
}

FUNCTION doAscent
{
  parameter mission.
  if body:atm:exists {until alt:radar > 1000 or ship:verticalspeed > 100 {wait 0. }}
  set sVal to heading(LAZcalc(LaunchData),max(round(90 - (90 * ((floor(altitude) * 100) / (TurnEnd)) / 100)),0)).
  set Tval to min((1-ship:q),max(0.5, ship:mass * (MaxG * CONSTANT:g0()) / ship:AvailableThrust)).
  if alt:apoapsis >= orbAlt {set tVal to 0. wait 1. mission["next"]().}
}

function doCoast
{
  parameter mission.
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
    if kuniverse:timewarp:issettled() {set sVal to heading(LAZcalc(LaunchData),0). mission["next"]().}
  }
}

function doCircularize
{
  parameter mission.
  if eta:apoapsis >=30 {set tVal to 0.}
  Else
  {
    set sVal to prograde.
    set tval to 1.
  }
  if ship:obt:eccentricity <= 0.001 {set tVal to 0. unlock all. mission["next"]().}
}
//Mission Functions
function doResonantOrbit //Params Target AP, Resonant Fraction (Decimal)
{
  parameter mission.
  set tarOrbit to createorbit(0,0,body:radius+TarAP,0,0,0,0,ship:body).
  set resOrbPer to OrbPeratAlt(TarAP)*resFraction.
  wait 2.
  warpto(time:seconds + (ETA:periapsis-90)).
  wait until kuniverse:timewarp:issettled.
  lock steering to prograde.
  WAIT UNTIL vang(SHIP:FACING:FOREVECTOR, prograde:vector) < 2.
  until ship:apoapsis >= tarOrbit:apoapsis
  {
    set tVal to 0.75.
  }
  Set tVal to 0.
  wait 2.
  warpto(time:seconds + (eta:apoapsis-90)).
  wait until kuniverse:timewarp:issettled.
  lock steering to prograde.
  WAIT UNTIL vang(SHIP:FACING:FOREVECTOR, prograde:vector) < 2.
  until ship:obt:period >= resOrbPer
  {
    set tVal to 0.75.
  }
  Set tVal to 0.
  mission["next"]().
}

function doDeploy
{
  parameter mission.
  local srel is 0.
  until ship:partstagged("SAT"):length = 0
  {
    set sVal to prograde.
    if eta:apoapsis <= 55 and not Srel
    {
      set p to ship:partstagged("SAT")[0].
      p:getmodule("moduleDecouple"):DOEVENT("Decouple").
      set p:tag to "deployed".
      set srel to 1.
      KUniverse:QUICKSAVE().
      AV_switch().
    }
    else if eta:apoapsis > 180
    {
      warpto(time:seconds + (ETA:apoapsis-60)).
    }
    if ETA:apoapsis > ETA:periapsis set Srel to 0.
  }
  if ship:partstagged("SAT"):length = 0 and not Srel {mission["next"]().}
}

function doRendevous //Params Target.
{

}

function doDocking
{

}

function doDeOrbit
{
  parameter mission.
  set sVal to -prograde.
  until alt:periapsis <= 0 set tVal to 1.
  mission["terminate"]().
}
