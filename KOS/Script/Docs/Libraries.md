# Math Library (Lib_math.ks)
## PhaseAngle
Determines the angle between 2 objects in the Same Sphere of influence. <br>
Used for determining the time offset for a Hohmann Transfer to intercept a target. <br>
**Parameters:** none.

## Circ_Vel
Calculates the Orbital Velocity at a Specified Altitude. <br>
**Parameters:** Altitude in meters above surface. *required*

## GeoSyncAlt
Calculates the Geosynchronous Orbit Altitude around a body. <br>
**Parameters:** none.

## OrbPeratAlt
Calculates to Orbital Period at a Specified Altitude. <br>
**Parameters:** Altitude in meters. *Default is current Apoapsis*

## Dv_Circ_Obt
Δv Required to Circularize at Apoapsis.<br>
**Parameters:** none.

## Hoh_Trans
Hohmann Transfer<br>
**Parameters:** New Apoapsis in meters above surface. *required* <br>
**Returns:** LIST (v1, v2, t1, s1, p1)<br>
V1, Δv to raise/lower current Apoapsis to New Apoapsis<br>
V2, Δv to Circularize at new Apoapsis/Periapsis<br>
T1, Time(seconds) to travel to new Apoapsis/Periapsis *needed to setup Circularization Node*
S1, Angular Speed of Target<br>
P1, ???

## NodeBurnTime
Calculates to time to complete the current Maneuver Node <br>
**Parameters:** Δv of the node *required* (NEXTNODE:BurnVector:mag)<br>
**Returns:** Burntime in seconds.


# Function Library (Lib_Func.ks)
## NOTIFY
Displays a HUD Message in the Center-Top of the screen.<br>
**Parameters:** Message *Required*, Echo *Optional* Defaults to False.

## Set_Runmode
Changes the Runmode and writes the current Runmode to the crafts Rootparts' Part Tag to Resume where the script left off.<br>
**Parameters:** Runmode (scalar) *Required*

## Staging
Auto-Staging if AvailableThrust < 1 or Engine flameout. **Will Not Stage if there is only 1 stage**<br>
**Parameters:** None.

## Clear_nodes
Clears all current Maneuver Nodes<br>
**Parameters:** None.

## Exec_Node
Executes next Maneuver None, will auto-Warp to the correct time and Orient the craft to match the Nodes BurnVector. will also throttle down when the node burn is almost complete.<br>
**Parameters:** Maneuver Node (NEXTNODE), autoWarp (0 or 1) *Both Required*

## MET
<!-- moved to Lib_HUD -->
Formats Time for use in Terminal GUI's.<br>
**Parameters:** Time(seconds)*Required*

## Resonant_Orbit
<!-- moved to Lib_Flightsys -->
A "node-less" solution to putting Satellites into a resonant orbit for the creation of Communication Networks.<br>
Handles: AP raise Burn, Steering, Warp to Periapsis, Warp to Apoapsis<br>
**Parameters:** Target Apoapsis (in meters AGL), Resonant Fraction (number of Satellites being launched -1*as a decimal fraction*) *Both Required*

## AV_switch
Switches to a recently deployed vessel, so that it can run it's own program (See SAT.Boot.ks)<br>
**Parameters:**None.

## CountDown
<!-- moved to Lib_Flightsys -->
What it says on the tin<br>
**Parameters:**None.

## R_chutes
Enables Arming, Deploying & Cutting of RealChute Parachutes.<br>
**Parameters:** Event Name.


# File System Library (Lib_Filesys.ks)
## SleepCores
Toggles Power other KOS Cores.<br>
**Parameters:**None.

## TagCores
Writes the current Ship Name to other KOS Cores on the current craft.<br>
**Parameters:**None.<br>
**Useful for:** Switching back to the "Mothership" automatically when deploying a Satellite Constellation.

## Sat_Update
Used for updating the bootfile on Other KOS cores on the craft without reverting to SPH/VAB<br>
**Parameters:**None.<br>
**Limitations:** currently Hardcoded to only update SAT.Boot.ks.

## update_Sat_name
Finds all craft with a name based on the current Ship Name (i.e Satellites deployed from it.) and renames them with a Numerical Identifier.<br>
**Parameters:**None.

## Format_Core
Deletes all files on the current volume.<br>
**Parameters:**None.<br>
***WARNING*** no protection against "formatting" the archive volume (0:/).

## Copy_Files
Copy Library Files to the local volume. if there is insufficient space on the volume, Run the Library from the Archive. <br>
**Parameters:**None.<br>
**Limitations:** needs a list named *Liblist*

## Launch_Prog
Similar to Copy_Files(), except that it is for the "Main Program". Reads the name of the program from the KOS Core PartTag. Launch Parameters can be separated from the file name with |<br>
**Parameters:**None.<br>

# Docking Library (Lib_Dock.ks)

# Terminal Display Library (Lib_HUD.ks)
Graphical User Interface (GUI)

# Flight Systems Library (Lib_Flightsys.ks)

# Mission Runner (Lib_Mission.ks)
