declare function Dock_Exec
{
  parameter CportTag, TarVes, TportTag, RCSPower.
  Dock_RCS_Power(1).
  set Cport to Dock_Port(ship:name,CportTag).
  set TarVesName to TarVes.
  Cport:controlfrom().
  if Dock_Port_Check(ship:name,CportTag,TarVes,TportTag) = "continue"
  {
    RCS on.
    set Tport to Dock_Port(TarVes,TportTag).
    //print "Moving to Waypoint 1. " at (5,5).
    Dock_Waypoint(VESSEL(TarVes),Cport,100,5).
    //print "Holding at Waypoint 1." at (5,5).
    Dock_KillVel(Tport).
    //print "Moving to Waypoint 2. " at (5,5).
    Dock_Side(Tport,Cport,100,3).
    Dock_KillVel(Tport).
    Dock_RCS_Power(0.75).
    //print "Moving to Waypoint 3. " at (5,5).
    Dock_Waypoint(VESSEL(TarVes),Cport,25,2).
    //print "Aligning with Port    " at (5,5).
    Dock_Approach(Tport,Cport,5,0.5).
    Dock_RCS_Power(RCSPower).
    //print "Final Approach        " at (5,5).
    wait 5.
    Dock_Approach(Tport,Cport,0,0.5).
  }
}

function Dock_Port_Check
{
  parameter CSname, Cport, TSname, Tport.
  //check if Docking Port is Open.
  set TportOpen to Dock_Port(TSname,Tport).
  set CportOpen to Dock_Port(CSname,Cport).
  set PortHighlight to highlight(TportOpen,white).
  if (TportOpen:STATE <> "READY") or (CportOpen:nodetype <> TportOpen:nodetype)
  {
    set PortHighlight:color to red.
    set PortHighlight:enabled to true.
    //NOTIFY("Port Not Available").
    Dock_KillVel(Dock_Port(TSname,Tport)).
    wait 1.
    set PortHighlight:enabled to false.
    RETURN "abort".
  }
  Else
  {
    set PortHighlight:color to green.
    set PortHighlight:enabled to true.
    wait 1.
    set PortHighlight:enabled to false.
    return "continue".
    //NOTIFY("Port Available and Sizes Match").
  }
}

function Dock_Undock
{
  parameter shipN, port.
  list elements in eList.
  set i to 0.
  for ele in eList
  {
    if eList[i]:NAME = shipN set Cport to eList[i]:dockingPorts[0].
    set i to i+1.
  }
  set Cport to Cport:partsdubbed(port)[0].
  Cport:controlfrom().
  Cport:undock().
  wait 5.
  RCS on.
  Dock_Trans(-Cport:PORTFACING:VECTOR).
  wait 5.
  Dock_Trans(Cport:PORTFACING:VECTOR).
  RCS off.
}

function Dock_Port
{
  PARAMETER sName, pTag is "".
  list targets in tShips.
  tShips:add(ship).
  set tIndex to tShips:find(VESSEL(sName)).
  if pTag <> "" {return tShips[tIndex]:partsdubbed(pTag)[0].}
  else return tShips[tIndex]:name.
}

function Dock_RCS_Power
{
  parameter RCSPower.
  LIST RCS in Rcslist.
  for RCS in Rcslist
  {
    set rcs:thrustlimit to RCSPower*100.
  }
}

FUNCTION Dock_Trans
{
  PARAMETER vector.
  IF vector:MAG > 1 SET vector TO vector:normalized.

  SET SHIP:CONTROL:STARBOARD  TO vector * SHIP:FACING:STARVECTOR.
  SET SHIP:CONTROL:FORE       TO vector * SHIP:FACING:FOREVECTOR.
  SET SHIP:CONTROL:TOP        TO vector * SHIP:FACING:TOPVECTOR.
}

function Dock_KillVel
{
  parameter targetPort.
  lock RelVel to ship:Velocity:orbit - targetPort:ship:Velocity:orbit.
  until RelVel:mag < 0.1
  {
    Dock_Trans(-RelVel).
  }
  Dock_Trans(v(0,0,0)).
}

function Dock_Approach
{
  parameter Tport, Cport, Dist, Vel.

  Cport:controlfrom().

  LOCK DistOffSet to Tport:PORTFACING:VECTOR * Dist.
  LOCK appVec to Tport:NODEPOSITION - Cport:NODEPOSITION + DistOffSet.
  LOCK RelVel to SHIP:VELOCITY:ORBIT - Tport:SHIP:VELOCITY:ORBIT.
  LOCK STEERING to LOOKDIRUP(-Tport:PORTFACING:VECTOR, Tport:PORTFACING:UPVECTOR).
  set target to Tport.

  UNTIL Cport:STATE <> "Ready"
  {
    Dock_Trans((appVec:normalized * Vel) - RelVel).
    LOCAL DistVec is (Tport:NODEPOSITION - Cport:NODEPOSITION).
    if VANG(Cport:PORTFACING:VECTOR, DistVec) > 2 and abs(dist -DistVec:mag) < 0.5
    {
      BREAK.
    }
    WAIT 0.1.
    Dock_Abort().
  }
  Dock_Trans(v(0,0,0)).
}

function Dock_Waypoint
{
  PARAMETER targetVessel, dockingPort, distance, speed.

  LOCK relativePosition TO SHIP:POSITION - targetVessel:POSITION.
  LOCK departVector TO (relativePosition:normalized * distance) - relativePosition.
  LOCK relativeVelocity TO SHIP:VELOCITY:ORBIT - targetVessel:VELOCITY:ORBIT.
  LOCK STEERING TO HEADING(0,0).

  UNTIL FALSE {
    Dock_Trans((departVector:normalized * speed) - relativeVelocity).
    IF departVector:MAG < 0.1 BREAK.
    Dock_Abort().
    WAIT 0.01.
  }
  Dock_Trans(v(0,0,0)).
}

FUNCTION Dock_Side
{
  PARAMETER targetPort, dockingPort, distance, speed.

  dockingPort:CONTROLFROM().

  // Get a direction perpendicular to the docking port
  LOCK sideDirection TO targetPort:SHIP:FACING:STARVECTOR.
  IF abs(sideDirection * targetPort:PORTFACING:VECTOR) = 1 {
    LOCK sideDirection TO targetPort:SHIP:FACING:TOPVECTOR.
  }

  LOCK distanceOffset TO sideDirection * distance.
  // Flip the offset if we're on the other side of the ship
  IF (targetPort:NODEPOSITION - dockingPort:NODEPOSITION + distanceOffset):MAG <
     (targetPort:NODEPOSITION - dockingPort:NODEPOSITION - distanceOffset):MAG {
    LOCK distanceOffset TO (-sideDirection) * distance.
  }

  LOCK approachVector TO targetPort:NODEPOSITION - dockingPort:NODEPOSITION + distanceOffset.
  LOCK relativeVelocity TO SHIP:VELOCITY:ORBIT - targetPort:SHIP:VELOCITY:ORBIT.
  LOCK STEERING TO -1 * targetPort:PORTFACING:VECTOR.

  UNTIL FALSE {
    Dock_Trans((approachVector:normalized * speed) - relativeVelocity).
    IF approachVector:MAG < 0.1 BREAK.
    Dock_Abort().
    WAIT 0.01.
  }

  Dock_Trans(V(0,0,0)).
}

function Dock_Abort
{
  if stage:resourcesLex["Monopropellant"]:amount < (stage:resourcesLex["Monopropellant"]:capacity*0.1)
  {
    NOTIFY("Insuffient Monopropellant Remaining",True).
    RCS OFF.
    wait 0.1.
    reboot.
  }
}
