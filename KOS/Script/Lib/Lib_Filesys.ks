//File And Core Fucntions

function SleepCores{ //Is a Toggle, Call to sleep, Call to Wake.
set corelst to list(). list parts in parts.
for p in parts{if p:hasmodule("KOSProcessor") corelst:add(p).}
corelst:remove(corelst:find(core:part)).
for c in corelst{c:getmodule("kosprocessor"):doevent("Toggle Power").}
}

function TagCores{
set corelst to list(). list parts in parts.
for p in parts{if p:hasmodule("KOSProcessor") corelst:add(p).}
corelst:remove(corelst:find(core:part)).
for c in corelst{set c:tag to ship:name.}
}

function Sat_Update
{set sat_Vol to list(). list volumes in volumes. for v in volumes {sat_Vol:add(v).}
  sat_Vol:remove(sat_Vol:find(core:volume)). sat_Vol:remove(0).
  set SV_It to sat_Vol:iterator.
  until Not SV_It:NEXT{deletepath((SV_It:index + 2) + ":/boot"). copypath("0:/boot/sat.boot.ks", (SV_It:index + 2) + ":/boot/sat.boot.ks").}
  runpath("0:/remote_reboot.ks").
}

function update_Sat_name
{list targets in targets. set deployed to list().
  for t in targets{if t:name:contains(ship:name){Deployed:add(t).}}
  set Dep_Itr to Deployed:iterator.
  until not Dep_Itr:NEXT{set Dep_Itr:value:name to shipname + "-" + (Dep_Itr:index +1) + " " + Dep_Itr:value:type.}
}

function Format_Core
{switch to core:volume.  list files in Files.  for f in Files  {Print "Deleting: " + f. deletepath(f).}}

function Copy_Files
{for p in Liblist{copypath("0:/" + p,"1:/" + p). if exists("1:/" + p) {runpath("1:/" + p).} else {runpath("0:/" + p).}}}

function launch_Prog
{
  set ProgRun to core:tag:split("|").
  if ProgRun:length > 1
  {
    copypath("0:/" + ProgRun[0] + ".ks","1:/").
    if exists("1:/"+ProgRun[0]) {runpath("1:/" + ProgRun[0] + ".ks",ProgRun[1]).}
    else {runpath("0:/" + ProgRun[0] + ".ks",ProgRun[1]).}
  }
  else
  {
    copypath("0:/" + ProgRun[0] + ".ks","1:/").
    if exists("1:/"+ProgRun[0]) {runpath("1:/" + ProgRun[0]+ ".ks").}
    else {runpath("0:/" + ProgRun[0]+ ".ks").}
  }
}
