//Ship Functions

declare FUNCTION NOTIFY {
  PARAMETER message, echo is false.
  HUDTEXT(message, 5, 2, 50, YELLOW, echo).
}

function set_runmode // write runmode to probe core part tag
{
  parameter RM, RC.
  set runmode to RM.
  Set RunCode to RC.
  set ship:rootpart:tag to RM:tostring + "," + RC:tostring.
}

// function Staging
// {
//   list engines in eList.
//   for eng in eList
//   {
//     if ship:AvailableThrust < 1 or eng:flameout
//     {
//       WAIT 1.
//       stage.
//       break.
//     }
//     if stage:number < 1 BREAK.
//   }
// }

function Clear_nodes
{
  if HASNODE{until not HASNODE
    {if not HASNODE {BREAK.} remove NEXTNODE.}}
  else RETURN.
}

declare function exec_node
{
  declare parameter nd,autoWarp.
  local tset is 0.
  local done is False.
  local dv0 is nd:deltav.
  local bTime to (nd:ETA - NodeBurnTime(nd:BurnVector:mag)/2).
  IF autoWarp { WARPTO(time:seconds + (bTime-10)). }
  if ship:deltav:CURRENT < nd:deltav:mag {print "Not enough DeltaV to complete.". set done to TRUE.}
  lock STEERING to nd:BurnVector.
  lock throttle to tset.
  until done
  {
    local max_acc to ship:Ship:AvailableThrust / ship:mass.
    local tset to min(nd:deltav:mag / max_acc, 1).
    WAIT UNTIL ((vang(SHIP:FACING:FOREVECTOR, nd:BurnVector) < 2) and (time:seconds + bTime)).
    if vdot(dv0, nd:deltav) < 0
    {
        set throttle to 0.
        break.
    }
    if nd:deltav:mag < 0.5 //original value 0.1
    {
        wait until vdot(dv0, nd:deltav) < 0.5.
        set throttle to 0.
        set done to True.
    }
    lock throttle to tset.
    Staging().
    wait 0.
  }
  unlock steering.
  unlock throttle.
  wait 1.
  remove nd.
  SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}

function AV_switch
{
  list targets in targets.
  for vess in targets
  {
    if vess:distance < 50 set kuniverse:ActiveVessel to vess.
  }
}

declare function R_chutes {
 parameter event.
 for RealChute in ship:modulesNamed("RealChuteModule") {
  RealChute:doevent(event).
 }.
}.
