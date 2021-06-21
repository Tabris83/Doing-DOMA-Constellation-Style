//Orbital Math Lib
@LAZYGLOBAL OFF.

function PhaseAngle {
	local transferSMA is (target:orbit:semimajoraxis + ship:orbit:semimajoraxis) / 2.
	local transferTime is (2 * constant:pi * sqrt(transferSMA^3 / ship:body:mu)) / 2.
	local transferAng is 180 - ((transferTime / target:orbit:period) * 360).

	local univRef is ship:orbit:lan + ship:orbit:argumentofperiapsis + ship:orbit:trueanomaly.
	local compareAng is target:orbit:lan + target:orbit:argumentofperiapsis + target:orbit:trueanomaly.
	local phaseAng is (compareAng - univRef) - 360 * floor((compareAng - univRef) / 360).

    local DegPerSec is  (360 / ship:orbit:period) - (360 / target:orbit:period).
    local angDiff is transferAng - phaseAng.

    local t is angDiff / DegPerSec.

	return abs(t).
}

declare function circ_vel //Orbital Velocity of Circular Orbit at Specified Altitude
{
  declare parameter salt.
  local talt  to salt + body:radius.
  return sqrt(body:mu/talt).

}

Declare Function GeoSyncAlt //GeoSync Altitude
{
  //R = (G x M x period2/(4 x pi2) )(1/3)
  //LOCAL GM to BODY:MU.
  //LOCAL Rp to body:rotationperiod.
  //LOCAL pi to CONSTANT:PI.
  //LOCAL R to Body:Radius.

  //print (GM * (Rp ^2) / (4 * pi ^2))^(1/3) - R.
  return (BODY:MU * (body:rotationperiod ^2) / (4 * CONSTANT:PI ^2))^(1/3) - Body:Radius.
}

Declare Function OrbPeratAlt //Orbital period at Specified Altitude
{
  declare parameter aalt is SHIP:APOAPSIS.
  return SQRT(((4 * CONSTANT:PI ^2) * ((aalt + Body:Radius)^3))/ BODY:MU).
}

Declare FUNCTION Dv_Circ_Obt //DeltaV Required to Circularize at Apoapsis
{
  //SQRT(μ * (2/r - 1/a) )
  local r1 to SHIP:APOAPSIS + BODY:radius.
  local a1 to SHIP:OBT:SEMIMAJORAXIS.
  local v1 to SQRT(BODY:Mu * (2/r1 - 1/a1)).
  local v2 to SQRT(BODY:Mu * (2/r1 - 1/r1)).
  RETURN v2 - v1.
}

declare FUNCTION Hoh_Trans //Hohmann Transfer
{
  PARAMETER desiredAltitude.
  local mu  TO SHIP:OBT:BODY:MU.
  local r1 TO SHIP:OBT:SEMIMAJORAXIS.
  local r2 TO desiredAltitude + SHIP:OBT:BODY:RADIUS.
  //print mu +"/n"+ r1 +"/n"+ r2.
  // v1 First Burn to raise/lower apoapsis
  local v1 TO SQRT(mu / r1) * (SQRT((2 * r2) / (r1 + r2)) - 1).
  // v2 Second burn to Circularize at new apo/peri
  local v2 TO SQRT(mu / r2) * (1 - SQRT((2 * r1) / (r1 + r2))).
  // Time to travel to new ap
  local t1 to constant:pi * sqrt( (r1+r2)^3/(8*mu) ).
  //Target Angular Speed
  local s1 to constant:pi * sqrt( (1+r1/r2)^3 / 8 ).
  local p1 to 180 - (((t1/2)/OrbPeratAlt(desiredAltitude))*360).
  RETURN LIST(v1, v2, t1, s1, p1).
}

Declare FUNCTION NodeBurnTime
{
  parameter dv.
  LOCAL ens to list().
  LOCAL myengines to list().
  ens:clear.
  LOCAL ens_thrust to 0.
  LOCAL ens_isp to 0.
  list engines in myengines.
  for en in myengines {
    if en:ignition = true and en:flameout = false {
      ens:add(en).
    }
  }
  for en in ens {
    SET ens_thrust to ens_thrust + en:availablethrust.
    SET ens_isp to ens_isp + en:isp.
  }
  if (ens_thrust = 0 or ens_isp = 0)
  {
    //notify("No engines available!").
    return 0.
  }
  else {
    local f is ens_thrust.  				// engine thrust (kg * m/s²)
    local m is ship:mass.        		// starting mass (kg)
    local e is constant():e.      	// base of natural log
    local p is ens_isp/ens:length.	// engine isp (s) support to average different isp values
    local g is constant:g.					// gravitational acceleration constant (m/s²)
    return g * m * p * (1 - e^(-dv/(g*p))) / f.
  }
}
