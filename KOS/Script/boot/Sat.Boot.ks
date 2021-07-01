//Satellite Boot Script - Auto Circularize at periapsis
Print "Waiting until Released".
wait until ship:modulesnamed("kOSProcessor"):length = 1 and kuniverse:ActiveVessel:name = ship:name.
runoncepath("0:/lib/Lib_HUD.ks").
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SAS OFF. RCS OFF. GEAR OFF. LIGHTS OFF.  CLEARVECDRAWS().
clearscreen. set tv to 0. lock throttle to tv. set TarPe to alt:periapsis.
function thS
{
  set PeErr to ((TarPe - alt:apoapsis)/100)*-1.
  RETURN PeErr.
}

Function OrbPeratAlt
{
  return SQRT(((4 * CONSTANT:PI ^2) * ((SHIP:periapsis + Body:Radius)^3))/ BODY:MU).
}

if eta:periapsis > 180 warpto(time:seconds + (ETA:periapsis - 60)). wait 3.
ship:modulesnamed("moduleEnginesFX")[0]:doevent("Activate Engine"). set TarP to OrbPeratAlt().
until obt:period <= TarP
{
  lock steering to retrograde.
  set tv to thS().
  print MET(obt:period - TarP) at (0,0).
  print MET(OrbPeratAlt()) at (0,1).
  print ths at (0,3).
}
set ship:control:pilotmainthrottle to 0.
panels on.
list parts in parts.
for p in parts
{
  if p:hasmodule("ModuleDeployableAntenna")
  p:GETMODULE("ModuleDeployableAntenna"):doaction("Toggle Antenna",true).
}
ship:modulesnamed("moduleEnginesFX")[0]:doevent("Shutdown Engine"). wait 2.
set kuniverse:ActiveVessel to VESSEL("""" + core:tag + """").
