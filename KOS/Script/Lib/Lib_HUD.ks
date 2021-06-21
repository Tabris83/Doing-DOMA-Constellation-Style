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
  parameter mission.
  //Col1 1, col2 20, col3 34
  //Static information
  print "Ship Name: " + shipname at (1,1). print "MET: " + MET(Missiontime) at (20,1). print mission["runmode"]() at (34,1).
  //Initial Orbital Params
  print "Target Ap: " + round(orbAlt/1000) + "km   " at (1,2).
  print "Current Alt: " + round(alt:radar/1000,2) at (1,3).
  print "Current AP: " + round(alt:apoapsis/1000,2) + "km   " at (1,4).
  print "Current PE: " + round(alt:periapsis/1000,2) + "km   " at (1,5).
}
//Mission HUD Modules
function HUD_SatDep
{
  parameter mission.
  print "Target AP: " + round(TarAP/1000,2) + "km   " at (1,7).
  print "Resonant Fraction: " + resFraction at (1,8).
  print "Target Period: " + MET(OrbPeratAlt(TarAP)) at (25,7).
  Print "Res Period: " + MET(OrbPeratAlt(TarAP)*resFraction) at (25,8).
  print "Sats Left: " + Sats at (1,9).
}

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
