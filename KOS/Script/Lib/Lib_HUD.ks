//GUI Library

function HUD_init
{
  clearscreen.
  CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
  set terminal:width to 51.
  set terminal:height to 25.
  //Col1 1, col2 20, col3 34
  horizontalLine(0,"-").
  verticalLineTo(0,1,9,"|"). verticalLineTo(50,1,9,"|").
  horizontalLine(10,"-").
}

function HUD_print
{
  //Col1 1, col2 20, col3 34
  //Static information
  print "Ship Name: " + shipname at (1,1).
  print "MET: " + MET(Missiontime) at (20,2). print "Mode: " + OpCode at (34,2).
  //Initial Orbital Params
  print "Current Alt: " + round(alt:radar/1000,2) at (1,3).
  print "Current AP: " + round(alt:apoapsis/1000,2) + "km   " at (1,4).
  print "AP ETA: " + MET(eta:apoapsis) + "    " at (25,4).
  print "Current PE: " + round(alt:periapsis/1000,2) + "km   " at (1,5).
  print "PE ETA: " + MET(eta:periapsis) + "    " at (25,5).
  wait 0.
}

//Debug
function HUD_Debug_steering
{
  print "Debug Info" at (0,11).
  print "throttle: " + throttle at (0,12).
  print "Steering Enabled: " + steeringmanager:enabled at (0,13).
  print "Steering: " + steering at (0,14).
  print "Steering Target: " + steeringmanager:target at (0,15).
  print "Steering Variable: " + sVal at (0,16).
  print "prograde " + prograde at (0,17).
  set steeringmanager:showfacingvectors to true.
}

function HUD_Debug
{
  print "Warp to AP: " + MET(time:seconds + (eta:apoapsis-30)) at (0,11).
  print "Warp to PE: " + MET(time:seconds + (eta:periapsis-30)) at (0,12).
  if defined circErr Print "Circularization Throttle: " + circErr at (0,13).
  if defined apErr Print "ResOrb burn1 Throttle: " + apErr at (0,14).
  if defined resErr Print "ResOrb burn2 Throttle: " + resErr at (0,15).
}
//Mission HUD Modules
function HUD_SatDep
{
  print "Target AP: " + round(TarAP/1000,2) + "km   " at (1,7).
  print "Resonant Fraction: " + resFraction at (1,8).
  print "Target Period: " + MET(OrbPeratAlt(TarAP)) at (25,7).
  Print "Res Period: " + MET(OrbPeratAlt(TarAP)*resFraction) at (25,8).
  print "Sats Left: " + ship:partstagged("SAT"):length at (1,9).
  wait 0.
}


//HUD Helper Functions
declare function MET //Time formated
{
  //JNSQ settings
  //43200 sec in 12hr day
  //15768000 sec in kerbin year
  parameter METin.
  local METout to 0.
  if METin < 43200
  {
    set METout to timestamp(METin):clock.
  }
  else if METin > 43200
  {
    set METout to timestamp(METin):day + "d ".
    set METout to METout + timestamp(METin):clock.
  }
  else if Missiontime > 15768000
  {
    set METout to timestamp(METin):full.
  }
  return METout.
}

function horizontalLine //params Line, Char
{
  parameter line,char.
  local i is 0.
  local s is "".
  until i = terminal:width {
    set s to char + s.
    set i to i + 1.
  }
  if line < 0 print s. //print to next line
  else print s at (0,line).
}
function horizontalLineTo //params Line, start Col, End Col, Char
{
  parameter line,colStart,colEnd,char.
  local column is colStart.
  local s is "".
  until column > colEnd {
    set s to char + s.
    set column to column + 1.
  }
  print s at (colStart,line).
}
function verticalLineTo //params Col, Start Line, End Line, Char
{
  parameter column,lineStart,lineEnd,char.
  local line is lineStart.
  until line > lineEnd {
    print char at (column,line).
    set line to line + 1.
  }
}

function clearLine //param Line
{
  parameter line.
  local i is 0.
  local s is "".
  until i = terminal:width {
    set s to " " + s.
    set i to i + 1.
  }
  print s at (0,line).
}
