AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "config.lua" )
include( "shared.lua" )
include( "config.lua" )
util.AddNetworkString( "Spotted" )
util.AddNetworkString( "Hidden" )
util.AddNetworkString( "light_below_limit" )
util.AddNetworkString( "light_above_limit" )
util.AddNetworkString( "Visible" )
util.AddNetworkString( "NotVisible" )


util.PrecacheModel("models/Combine_Soldier.mdl")
util.PrecacheModel("models/Combine_Super_Soldier.mdl")
util.PrecacheModel("models/Police.mdl")

OVERWATCH_TAUNTS = { "I'd get ready if I were you.", "Hope you like bloodbaths.", "Let's get this farce over with.", "I've calculated who will win to a 99.93% certainty, if you're interested. ", "So at least your teammates know what they're doing. ", "Your teammates are doing a really great job. ", "This is probably the most heroic thing anyone's ever done while sitting motionless in their parents' rec room. ", "You were almost helpful this time. ", " It's a good feeling, isn't it? I wouldn't get used to it. ", "Let's be honest: it probably won't help. ", "That's funny, I didn't even see you cheat. ", "That should delay the inevitable slightly. ", "Great teamwork, you vicious thugs. ", "Your entire life has been a mathematical error. A mathematical error I'm about to correct.", "Someone is going to get badly hurt.", "I hate you so much.", "Did anything happen while I was out?", "Just stop it already.", "Are you testing me?" , "You really aren't getting tired of that, are you?" , "I'm done." , "That isn't science." , "Do you need real encouragement? Let's see if this helps." , "Now, you are just wasting my time." , "If you are wondering what that smell is, that is the smell of human fear." }


net.Receive( "light_above_limit", function( length, client )
--client:PrintMessage(HUD_PRINTTALK, "You are visible.")
net.Start( "Visible" )
net.Send(player.GetByID(1))
client:SetNoTarget(false)
end )

net.Receive( "light_below_limit", function( length, client )
local hidden=1
for k, v in pairs(ents.FindByClass("npc_*")) do
if v:IsValid() then
--if v:IsNPC() then
if v:GetClass() == "npc_combine_s" || v:GetClass() == "npc_metropolice" then
if v:Health() > 0 then
if v:GetEnemy() == client then

client:PrintMessage(HUD_PRINTTALK, "You can't hide now. "..v:GetName().." is actively looking for you.")
hidden=0

end
end
end
end
end
if hidden==1 then client:SetNoTarget(true)
--client:PrintMessage(HUD_PRINTTALK, "You are hidden.")
net.Start( "NotVisible" )
net.Send(player.GetByID(1))
end
end)

  
function util.QuickTrace( origin, dir, filter )

	local trace = {}
 
	trace.start = origin
	trace.endpos = origin + dir
	trace.filter = filter

	return util.TraceLine( trace )
end


/*             notes


NPC:SetKeyValue( "model", "models/elite_synth/elite_synth.mdl" )
NPC:SetSkin(1)

Get info from an entity typing this on the console while facing at it
lua_run print(player.GetByID(1):GetEyeTrace().Entity:GetAngles()) print(player.GetByID(1):GetEyeTrace().Entity:GetPos()) print(player.GetByID(1):GetEyeTrace().Entity) print(player.GetByID(1):GetEyeTrace().Entity:GetModel()) print(player.GetByID(1):GetEyeTrace().Entity:GetCollisionGroup())
*/

function GM:Initialize()
RunConsoleCommand( "sk_helicopter_health", "1500") 
RunConsoleCommand( "air_density", "0")
RunConsoleCommand( "g_ragdoll_maxcount", "6")
end



-- WHAT-MAP-ARE-THEY-PLAYING CHECK v
if file.Exists( "gamemodes/thehunt/gamemode/maps/"..game.GetMap()..".lua", "GAME" ) then
include("/maps/"..game.GetMap()..".lua")
win = 1
print("map found")
else
print("map not found")
win = 0
include("/maps/nomap.lua")

end
-- WHAT-MAP-ARE-THEY-PLAYING CHECK ^

-- VARIABLES USED BY THE GAME v
-- Don't touch them. They are edited in-game.

VariedPos = Vector(math.random(-100,100),math.random(-100,100),0)
EnemiesRemainining = 0
combinen = 0
--npcchasing = 0
CombineAssisting = 0
ManuallySpawnedEntity = 0
HeliAangered = 0
CAN_HEAR_BREAK = 1
-- VARIABLES USED BY THE GAME ^

-- UTILITY COMMANDS v

concommand.Add( "h_addonweapons", function(player, command, arguments )
print("Your game has all these weapons installed")
for k,v in pairs( weapons.GetList() ) do 
print( v.ClassName )
end 
print("")
end )

concommand.Add( "h_fixtimers", function(ply)

print("Rebooting: Item Respawn System")
timer.Create( "Item Respawn System", 10, 1, ItemRespawnSystem )

print("Rebooting: CombineIdleSpeech")
timer.Create( "CombineIdleSpeech", math.random(5,15), 0, CombineIdleSpeech ) 

print("Rebooting: CicloUnSegundo")
timer.Create( "CicloUnSegundo", 1, 1, CicloUnSegundo ) 

print("Rebooting: coverzones")
timer.Create( "coverzones", 10, 1, coverzones )

print("Rebooting: wavefinishedchecker")
timer.Create( "wavefinishedchecker", 5, 1, wavefinishedchecker)

print("")

print("Plz report the bug to the Facepunch Thread, the autor itself or the workshop page.")
end)

concommand.Add( "Spotted", function(ply)
if ply:IsAdmin() then
net.Start( "Spotted" )
net.Send(player.GetByID(1))
end
end )

concommand.Add( "RespawnWeapons", function(ply)

if ply:IsAdmin() then
table.foreach(MEDIUMWEAPONS, function(key,value)

for k,v in pairs(ents.FindByClass(value)) do 
	local canrespawn = 1
		for k, player in pairs(ents.FindInSphere(v:GetPos(),20)) do
			if player:IsPlayer() then
			canrespawn = 0
			print("Player has "..v:GetClass()..", wont remove")
			end
		end
	if canrespawn == 1 then
	print("player not found near "..v:GetClass()..", will remove")
	v:Remove()
	end
end

end)
end
end )


concommand.Add( "clnotarget", function(ply)
if ply:IsAdmin() then

ply:SetNoTarget(1)
end
end )

concommand.Add( "cltarget", function(ply)
if ply:IsAdmin() then

ply:SetNoTarget(0)
end
end )

concommand.Add( "h_version", function()
print("TheHunt Version: v0.9-beta-WORKSHOP_UPDATE edition.")
print("Last shit added: Added cs_italy (12/08/2014)")
print("This is the GitHub version.")

end )


concommand.Add( "LaunchCanister", function(ply)
print("Will go to you.")

if ply:IsAdmin() then
SpawnCanister(ply:GetPos())
end

end)


concommand.Add( "SpawnAPC", function(ply)
if ply:IsAdmin() then
print("Experimental shit I didn't implemented yet. If it explodes, is your fault.")
local RocketLauncher = ents.Create( "monster_apc" )
RocketLauncher:SetPos(ply:GetEyeTraceNoCursor().HitPos + Vector(0,0,40))
RocketLauncher:Spawn()
end
end)

concommand.Add( "SpawnRocketLauncher", function(ply)
print("Experimental shit I didn't implemented yet. If it explodes, is your fault.")

if ply:IsAdmin() then

local creating = ents.Create( "path_corner" )
creating:SetPos(ply:GetEyeTraceNoCursor().HitPos + Vector(0,0,500))
creating:SetName("ddd")
creating:Spawn()

local RocketLauncher = ents.Create( "npc_launcher" )
RocketLauncher:SetPos(ply:GetEyeTraceNoCursor().HitPos + Vector(0,0,100))
RocketLauncher:SetKeyValue( "spawnflags", "65536" )

RocketLauncher:SetKeyValue( "PathCornerName", "PATHLEL" )
RocketLauncher:SetKeyValue( "MissileModel", "models/Weapons/W_missile.mdl" )
--RocketLauncher:SetKeyValue( "StartOn", 1)
RocketLauncher:SetKeyValue( "LaunchSmoke ", 1 )
RocketLauncher:SetKeyValue( "SmokeTrail", 1 )
--RocketLauncher:SetKeyValue( "LaunchSound", "weapons/rpg/rocket1.wav" )
RocketLauncher:SetKeyValue( "LaunchDelay", 1 )
RocketLauncher:SetKeyValue( "LaunchSpeed ", 100 )
RocketLauncher:SetKeyValue( "PathCornerName", "ddd" )
RocketLauncher:SetKeyValue( "HomingSpeed", 800 )
RocketLauncher:SetKeyValue( "HomingStrength", 100 )
RocketLauncher:SetKeyValue( "HomingDelay", 1)
RocketLauncher:SetKeyValue( "HomingRampUp", 3 )
RocketLauncher:SetKeyValue( "HomingDuration", 5 )
RocketLauncher:SetKeyValue( "Gravity", 1 )
RocketLauncher:SetKeyValue( "MinRange", 1 )
RocketLauncher:SetKeyValue( "MaxRange", 100 )
RocketLauncher:SetKeyValue( "SpinMagnitude", 100 )
RocketLauncher:SetKeyValue( "SpinSpeed", 100 )
RocketLauncher:SetKeyValue( "Damage", 1 )
RocketLauncher:SetKeyValue( "DamageRadius", 100 )
RocketLauncher:Fire("SetEnemyEntity",ply,0)
RocketLauncher:Spawn()
--RocketLauncher:Activate()
print("RocketLauncher spawned")


RocketLauncher:Fire("TurnOn","",0)
--timer.Simple( 1, function()
RocketLauncher:Fire("FireOnce","",5)

RocketLauncher:Fire("FireOnce","",1)
print("RocketLauncher activated")

 --end )
 end
end )



concommand.Add( "Hidden", function(ply)
if ply:IsAdmin() then

net.Start( "Hidden" )
net.Send(player.GetByID(1))
end
end )

concommand.Add( "NearbyEntities", function(ply)
NearbyEntities()
end )



concommand.Add( "KillCombine", function(ply)
if ply:IsAdmin() then
KillCombine()
print("All the combine soldiers killed.")
end
end)


concommand.Add( "revealzones", function(ply)
if ply:IsAdmin() then
table.foreach(zonescovered, function(key,value)
local sprite = ents.Create( "env_sprite" )
sprite:SetPos(value)
sprite:SetColor( Color( 255, 0, 0 ) )
sprite:SetKeyValue( "model", "sprites/light_glow01.vmt" )
sprite:SetKeyValue( "scale", 0.50 )
sprite:SetKeyValue( "rendermode", 5 )
sprite:SetKeyValue( "renderfx", 7 )
sprite:Spawn()
sprite:Activate()
sprite:SetName("ZoneReveal")
end)
print("Combine Covered Zones Hithlighted.")
end
end)


concommand.Add( "revealweaponspawns", function(ply)
if ply:IsAdmin() then

table.foreach(ITEMPLACES, function(key,value)
local sprite = ents.Create( "env_sprite" )
sprite:SetPos(value)
sprite:SetColor( Color( 247,255,3 ) )
sprite:SetKeyValue( "model", "sprites/light_glow01.vmt" )
sprite:SetKeyValue( "scale", 0.50 )
sprite:SetKeyValue( "rendermode", 5 )
sprite:SetKeyValue( "renderfx", 7 )
sprite:Spawn()
sprite:Activate()
sprite:SetName("ZoneReveal")
end)
print("Weapon Spawn Zones Hithlighted.")
end
end)


concommand.Add( "revealhelipath", function(ply)
if ply:IsAdmin() then

for k, v in pairs(ents.FindByClass("path_track")) do 
sprite = ents.Create( "env_sprite" )
sprite:SetPos(v:GetPos())
sprite:SetColor( Color( 0, 255, 255 ) )
sprite:SetKeyValue( "model", "sprites/light_glow01.vmt" )
sprite:SetKeyValue( "scale", 2 )
sprite:SetKeyValue( "rendermode", 5 )
sprite:SetKeyValue( "renderfx", 7 )
sprite:Spawn()
sprite:Activate()
sprite:SetName("ZoneReveal")
print("Heli Path Hithlighted.")
end
end
end)

concommand.Add( "spawncombinetripmine", function(ply)
if ply:IsAdmin() then
print("Experimental shit I didn't implemented yet. If it explodes, is your fault.")

SpawnItem("combine_tripmine_beam", ply:GetEyeTraceNoCursor().HitPos+Vector(0,0,20), Angle(math.random(-180,180),math.random(-180,180),0))
end
end)



concommand.Add( "revealtargets", function(ply)
if ply:IsAdmin() then
print("Experimental shit I didn't implemented yet. If it explodes, is your fault.")

for k, v in pairs(ents.FindByClass("info_target")) do 
sprite = ents.Create( "env_sprite" )
sprite:SetPos(v:GetPos())
sprite:SetColor( Color( 0, 255, 255 ) )
sprite:SetKeyValue( "model", "sprites/light_glow01.vmt" )
sprite:SetKeyValue( "scale", 2 )
sprite:SetKeyValue( "rendermode", 5 )
sprite:SetKeyValue( "renderfx", 7 )
sprite:Spawn()
sprite:Activate()
sprite:SetName("ZoneReveal")
end
end
end)



concommand.Add( "seesettings", function(ply)
print("Here you go")

print("h_halos: "..GetConVarNumber("h_halos").."")
print("h_autostart: "..GetConVarNumber("h_autostart").."")
print("h_minenemies: "..GetConVarNumber("h_minenemies").."")
print("h_maxhelp: "..GetConVarNumber("h_maxhelp").."")
print("h_npcscaledamage: "..GetConVarNumber("h_npcscaledamage").."")
print("h_playerscaledamage: "..GetConVarNumber("h_playerscaledamage").."")
print("h_lostplayertimeout: "..GetConVarNumber("h_lostplayertimeout").."")
print("h_weaponoffset: "..GetConVarNumber("h_weaponoffset").."")
print("h_autorepeat: "..GetConVarNumber("h_autorepeat").."")
print("h_rpgmax: "..GetConVarNumber("h_rpgmax").."")
print("h_maxgunshotinvestigate: "..GetConVarNumber("h_maxgunshotinvestigate").."")
print("h_max_player_deaths: "..GetConVarNumber("h_max_player_deaths").."")
print("h_punish_deaths_timer: "..GetConVarNumber("h_punish_deaths_timer").."")
print("h_infinite_waves: "..GetConVarNumber("h_infinite_waves").."")
print("h_min_health_help: "..GetConVarNumber("h_min_health_help").."")
print("h_light_stealth: "..GetConVarNumber("h_light_stealth").."")
print("h_time_between_waves: "..GetConVarNumber("h_time_between_waves").."")
print("Friendly fire: "..GetConVarNumber("h_friendlyfire").."")
print("Weapons that The Hunt spawns: ")
PrintTable(MEDIUMWEAPONS)

end)

concommand.Add( "helpme", function(ply)
print("Useful Commands")
print("firstwave: starts the firstwave")
print("h_fixtimers: use it if any feature stops working")
print("infinite wave: starts the infinite wave system")
print("")
print("Facepunch thread: http://facepunch.com/showthread.php?t=1394695")
print("GitHub download: https://github.com/Eddlm/TheHunt <- This version is updated regularly and fully customizable.")
print("Workshop download: http://steamcommunity.com/sharedfiles/filedetails/?id=292275126")
print("Make sure to check these links to read help about how to play this gamemode, and what this gamemode an do.")
print("")

end )
concommand.Add( "hidezones", function(ply)
if ply:IsAdmin() then
hidezones()
print("All sprites removed.")
end
end)

concommand.Add( "assplode", function(ply)
if ply:IsAdmin() then
ent = ents.Create( "env_explosion" )
ent:SetPos(ply:GetEyeTraceNoCursor().HitPos)
ent:Spawn()
ent:SetKeyValue( "iMagnitude", "100" )
print("assploded")
ent:Fire("Explode",0,0)
end
end )

concommand.Add( "assplodeinv", function(ply)
if ply:IsAdmin() then
ent = ents.Create( "env_physexplosion" )
ent:SetPos(ply:GetEyeTraceNoCursor().HitPos)
ent:SetKeyValue( "spawnflags", 1 )
ent:SetKeyValue("radius", 300)
ent:SetKeyValue( "magnitude", 100 )
ent:Spawn()
print("assploded inv")
ent:Fire("Explode",0,0)
end
end )

concommand.Add( "beam", function(ply)
if ply:IsAdmin() then
print("Experimental shit I didn't implemented yet. If it explodes, is your fault.")

local laser = ents.Create( "env_beam" )
	laser:SetPos( ply:GetEyeTraceNoCursor().HitPos)
	laser:SetKeyValue( "StrikeTime", "0.2" )
	laser:SetKeyValue( "spawnflags", "5" )
	laser:SetKeyValue( "rendercolor", "200 200 255" )
	laser:SetKeyValue( "texture", "sprites/laserbeam.spr" )
	laser:SetKeyValue( "TextureScroll", "1" )
	laser:SetKeyValue( "Damage", "20" )
	--laser:SetKeyValue( "renderfx", "6" )
	laser:SetKeyValue( "NoiseAmplitude", ""..math.random(5,2) )
	laser:SetKeyValue( "BoltWidth", "1" )
	laser:SetKeyValue( "TouchType", "0" )
--	laser:SetKeyValue( "LightningStart",  )
--	laser:SetKeyValue( "LightningEnd",  )
	laser:SetKeyValue("Radius", "1000")
	laser:SetKeyValue("life", "0.5")
	laser:Spawn()
	laser:Activate()
	end
end )
concommand.Add( "SpawnMetropolice", function(ply)
if ply:IsAdmin() then
SpawnMetropolice( ply:GetEyeTraceNoCursor().HitPos )
print("Spawned.")
end
end )
concommand.Add( "SpawnMetropoliceStunstick", function(ply)
if ply:IsAdmin() then
SpawnMetropoliceStunstick( ply:GetEyeTraceNoCursor().HitPos )
print("Spawned.")
end
end )


concommand.Add( "SpawnFastZombie", function(ply)
if ply:IsAdmin() then
SpawnFastZombie( ply:GetEyeTraceNoCursor().HitPos + Vector(0,0,20))
print("Spawned.")
end
end )
concommand.Add( "SpawnRebel", function(ply)
if ply:IsAdmin() then
SpawnRebel( ply:GetEyeTraceNoCursor().HitPos + Vector(0,0,20))
print("Spawned.")
end
end )
concommand.Add( "SpawnRollermine", function(ply)
if ply:IsAdmin() then
SpawnRollermine( ply:GetEyeTraceNoCursor().HitPos + Vector(0,0,20))
print("Spawned.")
end
end )
concommand.Add( "spawnSNPC", function(ply)
if ply:IsAdmin() then
spawnSNPC( ply:GetEyeTraceNoCursor().HitPos + Vector(0,0,20))
print("Spawned. LOL")
end
end )
concommand.Add( "SpawnCombineElite1", function(ply)
if ply:IsAdmin() then
SpawnCombineElite1( ply:GetEyeTraceNoCursor().HitPos)
print("Spawned.")
end
end )
concommand.Add( "SpawnCombineElite2", function(ply)
if ply:IsAdmin() then
SpawnCombineElite2( ply:GetEyeTraceNoCursor().HitPos)
print("Spawned.")
end
end )
concommand.Add( "SpawnTurret", function(ply)
if ply:IsAdmin() then
SpawnTurret( ply:GetEyeTraceNoCursor().HitPos + Vector(0,0,5), ply:EyeAngles())
print("Spawned.")
end
end )
concommand.Add( "SpawnCombineS1", function(ply)
if ply:IsAdmin() then
SpawnCombineS1( ply:GetEyeTraceNoCursor().HitPos)
print("Spawned.")
end
end )
concommand.Add( "SpawnCombineS2", function(ply)
if ply:IsAdmin() then
SpawnCombineS2( ply:GetEyeTraceNoCursor().HitPos)
print("Spawned.")
end
end )
concommand.Add( "SpawnScanner", function(ply)
if ply:IsAdmin() then
SpawnScanner( ply:GetEyeTraceNoCursor().HitPos)
print("Spawned.")
end
end )

concommand.Add( "SpawnCombineSFlashlight", function(ply)
print("Experimental shit I didn't implemented yet. If it explodes, is your fault.")

if ply:IsAdmin() then
SpawnCombineSFlashlight( ply:GetEyeTraceNoCursor().HitPos)
print("Spawned.")
end
end )



concommand.Add( "firstwave", function()
if ply:IsAdmin() then

Wave = 1
timer.Create( "firstwave", 2, CombineFirstWave, firstwave )
WAVESPAWN = 1
timer.Simple( 30, function() CanCheck = 1 print("Can check is 1, wave can be defeated now.") end )
timer.Simple( 20, function() WAVESPAWN = 0 print("wavespawn is now 0") end )	
end
end )
concommand.Add( "secondwave", function()
if ply:IsAdmin() then
Wave = 2
timer.Create( "secondwave", 2, CombineSecondWave, secondwave ) 
WAVESPAWN = 1
timer.Simple( 30, function() CanCheck = 1 print("Can check is 1, wave can be defeated now.") end )
timer.Simple( 20, function() WAVESPAWN = 0 print("wavespawn is now 0") end )	
end
end )
concommand.Add( "thirdwave", function()
if ply:IsAdmin() then

Wave = 3
timer.Create( "thirdwave", 2, CombineThirdWave, thirdwave ) 
WAVESPAWN = 1
timer.Simple( 30, function() CanCheck = 1 print("Can check is 1, wave can be defeated now.") end )
timer.Simple( 20, function() WAVESPAWN = 0 print("wavespawn is now 0") end )	
end
end )
concommand.Add( "fourthwave", function()
if ply:IsAdmin() then

Wave = 4
timer.Create( "fourthwave", 2, CombineFourthWave, fourthwave ) 
WAVESPAWN = 1
timer.Simple( 30, function() CanCheck = 1 print("Can check is 1, wave can be defeated now.") end )
timer.Simple( 20, function() WAVESPAWN = 0 print("wavespawn is now 0") end )	
end
end )
concommand.Add( "fifthwave", function()
if ply:IsAdmin() then

Wave = 5
timer.Create( "fifthwave", 2, CombineFifthWave, fifthwave ) 
WAVESPAWN = 1
timer.Simple( 30, function() CanCheck = 1 print("Can check is 1, wave can be defeated now.") end )
timer.Simple( 20, function() WAVESPAWN = 0 print("wavespawn is now 0") end )	
end
end )

concommand.Add( "infinitewave", function()
Wave = 6
infinitewavehandler()
end )

-- UTILITY COMMANDS ^


-- UTILITY FUNCTIONS v (called by the commands or by game hooks)



function NUMPLAYERS()
PLAYERSINMAP=0
for k, v in pairs(ents.FindByClass("player")) do
PLAYERSINMAP=PLAYERSINMAP+1
end
end



function OverwatchAmbientOne()
		table.Random(player.GetAll()):EmitSound(table.Random(OverwatchAmbientSoundsOne), 100, 100)
end

function GM:PlayerDeathThink(ply)

if ply:KeyPressed(IN_ATTACK2) then
ply:UnSpectate()
ply:Spectate(4)
ply:SetMoveType(10)
ply:SpectateEntity(table.Random(player.GetAll()))
end

if ply:KeyPressed(IN_ATTACK) then
if ply.canspawn == 1 then
ply:UnSpectate()
ply:Spawn()
end
end

end


function GM:DoPlayerDeath( ply, attacker, dmginfo )
ply:CreateRagdoll()
ply:AddDeaths(1)
NUMPLAYERS()
ply.canspawn = 0




if attacker:IsNPC() then
attacker:EmitSound(table.Random(CombineKillSounds), 100, 100)
end

-- One npc_sniper can only kill one player, then, it won't shoot players anymore. So I remove it and respawn another when he kills a player.
if attacker:GetClass() == "npc_sniper" then
local pos = attacker:GetPos()
local ang = attacker:GetAngles()
attacker:Remove()
SpawnItem("npc_sniper", pos, ang)
end


table.foreach( ply:GetWeapons(), function(key,value)
if key > 1 then
print(value:GetClass())
SpawnItem(value:GetClass(), ply:GetPos()+Vector(math.random(-30,30),math.random(-30,30),20), Angle(0,0,0))
end
end)



timer.Create( "Delaywhenkilled", 1, 1, function()
ply:Spectate(5)
ply:SetMoveType(10)
ply:SpectateEntity(attacker)

if PLAYERSINMAP > 1 then

if GetConVarNumber("h_max_player_deaths") == ply:Deaths() or ply:Deaths() > GetConVarNumber("h_max_player_deaths")  then
ply:PrintMessage(HUD_PRINTTALK, "You have no lifes left. You will respawn in "..GetConVarNumber("h_punish_deaths_timer").." seconds.")
ply:PrintMessage(HUD_PRINTTALK, "While you wait, think on a better strategy for the next time.")

	timer.Create( "Playernoobspawn", GetConVarNumber("h_punish_deaths_timer"), 1, function()
	ply.canspawn = 1
	ply:SetDeaths(0)
	ply:SetFrags(0)
	ply:PrintMessage(HUD_PRINTTALK, "You can spawn now.")
	end)
 
else
ply:PrintMessage(HUD_PRINTTALK, "You have "..GetConVarNumber("h_max_player_deaths") - ply:Deaths().." lifes left.")
ply.canspawn = 1
end
else

ply.canspawn = 1


end

end)
end

function NearbyEntities()
print("Entities found:")
for k, v in pairs(ents.FindInSphere(player.GetByID(1):GetPos(),256)) do
print(""..v:GetClass()..", "..v:GetName().."")
 end
 print("End of entities")
end


function KillCombine()
for k, v in pairs(ents.FindByClass("npc_combine_s")) do
v:Remove()
 end
end

function autofirstwave()
timer.Create( "firstwave", 2, CombineFirstWave, firstwave )
WAVESPAWN = 1
timer.Simple( 30, function() CanCheck = 1 print("Can check is 1, wave can be defeated now.") end )
timer.Simple( 20, function() WAVESPAWN = 0 print("wavespawn is now 0") end )		
end

function wavefinishedchecker()
timer.Create( "wavefinishedchecker", 10, 1, wavefinishedchecker)
EnemiesRemainining=0

table.foreach(MainEnemies, function(key,enemy)
for k, npc in pairs(ents.FindByClass(enemy)) do
EnemiesRemainining=EnemiesRemainining+1
end
end)

-- if EnemiesRemainining > = GetConVarNumber("h_minenemies") then CanCheck = 1 end

if BossHeliAlive == 0 or BossHeliAlive == nil then
if CanCheck == 1 then 
	if EnemiesRemainining < GetConVarNumber("h_minenemies") then 
	waveend()
	CanCheck = 0
	end
end
end
end

function waveend()
		WAVESPAWN = 1

		OverwatchAmbientOne()
		if Wave < 5 then
			PrintMessage(HUD_PRINTTALK, "[Overwatch]: Squad Nº"..Wave.." proven unable to contain hostiles.")
		end
		
	timer.Simple(GetConVarNumber("h_time_between_waves"), function()
		timer.Simple( 30, function() CanCheck = 1 print("Can check is 1, wave can be defeated now.") end )
		timer.Simple( 20, function() WAVESPAWN = 0 print("wavespawn is now 0") end )		
		if Wave == 1 then timer.Create( "secondwave", 2, CombineSecondWave, secondwave ) 
		PrintMessage(HUD_PRINTTALK, "[Overwatch]: Squad Nº"..(Wave+1).." dispatched.") end
		if Wave == 2 then timer.Create( "thirdwave", 2, CombineThirdWave, thirdwave ) 
		PrintMessage(HUD_PRINTTALK, "[Overwatch]: Squad Nº"..(Wave+1).." dispatched.") end
		if Wave == 3 then timer.Create( "fourthwave", 2, CombineFourthWave, fourthwave ) 
		PrintMessage(HUD_PRINTTALK, "[Overwatch]: Squad Nº"..(Wave+1).." dispatched.") end
		if Wave == 4 then timer.Create( "fifthwave", 2, CombineFifthWave, fifthwave )  
		PrintMessage(HUD_PRINTTALK, "[Overwatch]: Squad Nº"..(Wave+1).." dispatched.") end
	end)
		if Wave == 5 or Wave == 6 then 
				if GetConVarNumber("h_infinite_waves") == 1 then
				infinitewavehandler()
				elseif GetConVarNumber("h_autorepeat") == 1 then
				timer.Simple(5, autofirstwave)
				PrintMessage(HUD_PRINTTALK, "Combine Defeated! Restarting Squads!")
				end

		end
		end
		
function infinitewavehandler()
WAVESPAWN = 1
CanCheck = 0
Wave=6


if INFINITE_ACHIEVED == 1 then
PrintMessage(HUD_PRINTTALK, "[Overwatch]: "..table.Random(OVERWATCH_TAUNTS).."")
end


if INFINITE_ACHIEVED == 0 then
INFINITE_ACHIEVED = 1
PrintMessage(HUD_PRINTTALK, "[Overwatch]: Dude you fucked up.")
end



print(" infinite wave loaded. ")
	timer.Simple(20, function()
	timer.Simple( 20, function() WAVESPAWN = 0 print("wavespawn is now 0") end )		
	timer.Create( "infinitewave", 2, CombineInfiniteWave, infinitewave )
	timer.Simple(20, function() CanCheck = 1 end)
	end)
	
	timer.Create( "launchanisters", 3, 5, function()
	SpawnCanisterWave(table.Random(player.GetAll()):GetPos())
	end	) 


end
function CreateHeliPath(pos)
creating = ents.Create( "path_track" )
creating:SetPos( pos )
creating:Spawn()
end
function restorecombineassistance ()
		if CombineAssisting > 0 then
			CombineAssisting = 0
		end
end
function hidezones()
	for k, v in pairs(ents.FindByName("ZoneReveal") ) do
	v:Remove()
	end
end
function SpawnHeliA( pos,type )
RunConsoleCommand( "sk_helicopter_health", "1500") 
RunConsoleCommand( "g_helicopter_chargetime", "2") 
RunConsoleCommand( "sk_helicopter_burstcount", "12") 
RunConsoleCommand( "sk_helicopter_firingcone", "20") 
RunConsoleCommand( "sk_helicopter_roundsperburst", "5") 
timer.Create( "helibehavior", 1, 1, helibehavior ) 
timer.Create( "helipath", 1, 1, helipath ) 
timer.Create( "usedpaths", 1, 1, usedpaths ) 
HeliIsDead = 0

HeliA = ents.Create( ""..type.."" )
-- HeliA:SetKeyValue( "target", "2" )
HeliA:SetKeyValue( "targetname", "Heli" )
--HeliA:SetKeyValue( "ignoreunseenenemies", 1 )
HeliA:SetKeyValue( "spawnflags", "262144" )
HeliA:SetKeyValue( "patrolspeed", "500" )
HeliA:SetKeyValue("squadname", "heliaforce")
HeliA:SetPos( pos )
if type == "npc_combinegunship" then
RunConsoleCommand( "sk_gunship_health_increments", 8) 
HeliA:Fire("SetPenetrationDepth ","24",0)
HeliA:Fire("BlindfireOn","",0)
end

HeliA:Spawn()
HeliA:Activate()
HeliA:Fire("activate","",0)
-- HeliA:Fire("missileon","",0)
HeliA:Fire("gunon","",0)
if HeliCanSpotlight == 1 then

helispotlight = ents.Create("env_projectedtexture");
helispotlight:SetPos(HeliA:GetPos());
helispotlight:SetAngles(HeliA:GetAngles()+Angle(30,0,0) );
helispotlight:SetParent(HeliA);
helispotlight:SetKeyValue("spawnflags", 2);
helispotlight:SetKeyValue("enableshadows", 1);
helispotlight:SetKeyValue("farz", 2000);
helispotlight:SetKeyValue("target", "");
helispotlight:SetKeyValue("nearz", 400);
helispotlight:SetKeyValue("lightfov", 20);
helispotlight:SetKeyValue("lightcolor", "0 255 255")
helispotlight:SetKeyValue("shadowquality", 1)
helispotlight:SetKeyValue("lightstrength", 5)
-- helispotlight:SetKeyValue("style", 6);
helispotlight:Spawn();
helispotlight:Activate();


HeliAFocus = ents.Create( "point_spotlight" )
HeliAFocus:SetPos(HeliA:GetPos()+(HeliA:GetForward()*150+Vector(0,0,-50)))
HeliAFocus:SetAngles(helispotlight:GetAngles())
HeliAFocus:SetParent(helispotlight)
HeliAFocus:SetKeyValue( "spawnflags", "1" )
HeliAFocus:SetKeyValue( "SpotlightWidth", "50" )
HeliAFocus:SetKeyValue( "SpotlightLength", "200" )
HeliAFocus:SetKeyValue("rendercolor", "100 200 200")
--NPCSpotlight:SetColor(0,0,0,255)
HeliAFocus:Spawn()
HeliAFocus:Activate()
end
end
function SpawnScanner ( pos )
NPC = ents.Create( "npc_cscanner" )
NPC:SetPos( pos )
NPC:SetKeyValue("neverinspectplayers", 1)
NPC:SetKeyValue("SetDistanceOverride", 2)
NPC:Spawn()
NPC:SetName("Scanner")
NPC:Fire("SetFollowTarget","Combine",0)
NPC:Fire("EquipMine","",0)
NPC:Fire("DeployMine","",0)
NPC:Activate()
timer.Create( "Scanner Wander", 1, 1, scannerwander ) 
end
function SpawnCombineSFlashlight ( pos )
NPC = ents.Create( "npc_combine_s" )
NPC:SetKeyValue("NumGrenades", ""..math.random(0,3).."") 
NPC:SetPos( pos )
NPC:SetKeyValue( "ignoreunseenenemies", 0 )
NPC:Spawn()
NPC:Give("ai_weapon_ar2")
combinen = combinen + 1
NPC:SetName("Combine nº"..combinen.."")
NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )
NPC:Fire("StartPatrolling","",0)
NPCSpotlight = ents.Create("env_projectedtexture");
NPCSpotlight:SetPos(NPC:GetShootPos()+(NPC:GetForward()*20)+Vector(0,0,-50))
NPCSpotlight:SetName(""..NPC:GetName().."_flashlight");
NPCSpotlight:SetAngles( Angle(20,0,0) );
NPCSpotlight:SetParent(NPC);
NPCSpotlight:SetKeyValue("spawnflags", 2);
NPCSpotlight:SetKeyValue("enableshadows", 0);
NPCSpotlight:SetKeyValue("farz", 700);
NPCSpotlight:SetKeyValue("target", "");
NPCSpotlight:SetKeyValue("nearz", 15);
NPCSpotlight:SetKeyValue("lightfov", 70);
NPCSpotlight:SetKeyValue("lightcolor", "100 200 200")
NPCSpotlight:SetKeyValue("shadowquality", 1)
NPCSpotlight:SetKeyValue("lightstrength", 2)
for k,NPCWeapon in pairs (ents.FindInSphere(NPC:GetPos(),30)) do
if NPCWeapon:IsWeapon() then
NPCSpotlight:SetAngles(NPCWeapon:GetAngles())
NPCSpotlight:SetParent(NPCWeapon)
end
end

NPCSpotlight = ents.Create( "point_spotlight" )
NPCSpotlight:SetPos(NPC:GetShootPos()+(NPC:GetForward()*20)+Vector(0,0,-50))
-- NPCSpotlight:SetAngles( Angle(20,0,0) )
for k,NPCWeapon in pairs (ents.FindInSphere(NPC:GetPos(),30)) do
if NPCWeapon:IsWeapon() then
NPCSpotlight:SetAngles(NPCWeapon:GetAngles())
NPCSpotlight:SetParent(NPCWeapon)
end
end
--NPCSpotlight:SetParent(NPC);
NPCSpotlight:SetKeyValue( "spawnflags", "1" )
NPCSpotlight:SetKeyValue( "SpotlightWidth", "20" )
NPCSpotlight:SetKeyValue( "SpotlightLength", "200" )
NPCSpotlight:Spawn()
NPCSpotlight:Activate()
end

function SpawnCanister( pos )

traceRes = util.QuickTrace(pos, Vector(0,0,500), player.GetAll())
print(traceRes.Entity)
if traceRes.Entity == NULL then 
print("Place is suitable for canister deployment ")

local canister = ents.Create( "env_headcrabcanister" )

--RocketLauncher:SetKeyValue( "angles", "0 0 90" )
canister:SetAngles(Angle(-70,math.random(180,-180),0))
canister:SetPos(pos + Vector(math.random(200,-200),math.random(200,-200),0))
canister:SetKeyValue( "HeadcrabType", math.random(0,2) )
canister:SetKeyValue( "HeadcrabCount", math.random(3,6) )
canister:SetKeyValue( "FlightSpeed", "9000" )
canister:SetKeyValue( "FlightTime", "3" )
canister:SetKeyValue( "StartingHeight", "0" )
canister:SetKeyValue( "Damage", "20" )
canister:SetKeyValue( "DamageRadius", "5" )
canister:SetKeyValue( "SmokeLifetime", "5" )
canister:SetKeyValue( "MaxSkyboxRefireTime", "5" )
canister:SetKeyValue( "MinSkyboxRefireTime", "1" )
canister:SetKeyValue( "SkyboxCannisterCount", "30" )
canister:Fire("FireCanister","",0.7)
canister:Spawn()

timer.Simple(100, function() canister:Remove() end)
else
print("Place is NOT suitable for canister deployment. Player is under a low ceiling.")

end
end


function util.QuickTrace( origin, dir, filter )

	local trace = {}
 
	trace.start = origin
	trace.endpos = origin + dir
	trace.filter = filter

	return util.TraceLine( trace )
end


function SpawnCanisterWave(pos)

traceRes = util.QuickTrace(pos, Vector(0,0,500), player.GetAll())
print(traceRes.Entity)
if traceRes.Entity == NULL then 
print("Place is suitable for canister deployment.")

local canister = ents.Create( "env_headcrabcanister" )
canister:SetAngles(Angle(-70,math.random(180,-180),0))
canister:SetPos(pos + Vector(math.random(200,-200),math.random(200,-200),0))
canister:SetKeyValue( "HeadcrabType", math.random(0,2) )
canister:SetKeyValue( "HeadcrabCount", math.random(3,8) )
canister:SetKeyValue( "FlightSpeed", "9000" )
canister:SetKeyValue( "FlightTime", "3" )
canister:SetKeyValue( "StartingHeight", "0" )
canister:SetKeyValue( "Damage", "20" )
canister:SetKeyValue( "DamageRadius", "5" )
canister:SetKeyValue( "SmokeLifetime", "5" )
canister:SetKeyValue( "MaxSkyboxRefireTime", "5" )
canister:SetKeyValue( "MinSkyboxRefireTime", "1" )
canister:SetKeyValue( "SkyboxCannisterCount", "30" )
canister:Fire("FireCanister","",0.7)
canister:Spawn()

timer.Simple(100, function() canister:Remove() end)
else
print("Place is NOT suitable for canister deployment. Player is under a low ceiling.")

end
end

function SpawnRebel( pos )
NPC = ents.Create( "npc_citizen" )
NPC:SetPos( pos )
NPC:SetKeyValue("squadname", "Rebels")
NPC:SetKeyValue("citizentype", "3")
NPC:Give("ai_weapon_ar2")
NPC:SetKeyValue("ammosupply", ""..table.Random(RebelsGiveAmmo).."")
NPC:SetKeyValue("spawnflags", "524288")
NPC:Spawn()
NPC:SetHealth("400")
NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )	
NPC:Fire("StartPatrolling","",0)
end
function SpawnFastZombie( pos )
NPC = ents.Create( "npc_fastzombie" )
NPC:SetPos( pos )
NPC:Spawn()
NPC:SetHealth("9000")
end
function spawnSNPC ( pos )
NPC = ents.Create( "npc_megacombine" )
NPC:SetKeyValue("NumGrenades", "0") 
NPC:SetPos( pos )
NPC:SetKeyValue( "ignoreunseenenemies", 1 )
NPC:Spawn()
combinen = combinen + 1
NPC:SetName("Combine nº"..combinen.."")
end
function SpawnCombineS1 ( pos )
NPC = ents.Create( "npc_combine_s" )
NPC:SetKeyValue("NumGrenades", "0") 
NPC:SetPos( pos )
NPC:SetKeyValue( "ignoreunseenenemies", 1 )
NPC:SetKeyValue( "spawnflags", 512 )

NPC:Spawn()
NPC:Give("ai_weapon_ar2")
combinen = combinen + 1
NPC:SetName("Combine nº"..combinen.."")
NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_AVERAGE )
NPC:Fire("StartPatrolling","",0)

end
function SpawnCombineS2 ( pos )
NPC = ents.Create( "npc_combine_s" )
NPC:SetKeyValue("NumGrenades", ""..math.random(1,3).."") 
NPC:SetPos( pos )
NPC:SetKeyValue( "ignoreunseenenemies", 0 )
NPC:SetKeyValue( "spawnflags", 512 )

NPC:Spawn()
NPC:Give("ai_weapon_ar2")
combinen = combinen + 1
NPC:SetName("Combine nº"..combinen.."")
NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )	
NPC:Fire("StartPatrolling","",0)
end

function SpawnCombineShotgunner ( pos )
NPC = ents.Create( "npc_combine_s" )
NPC:SetKeyValue("NumGrenades", "0") 
NPC:SetPos( pos )
NPC:SetKeyValue( "ignoreunseenenemies", 0 )
NPC:SetKeyValue( "spawnflags", 512 )

NPC:SetSkin(1)
NPC:Spawn()
NPC:Give("ai_weapon_shotgun")
combinen = combinen + 1
NPC:SetName("Combine nº"..combinen.."")
NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )	
NPC:Fire("StartPatrolling","",0)
end
function SpawnCombineShotgunnerElite ( pos )
NPC = ents.Create( "npc_combine_s" )
NPC:SetKeyValue("NumGrenades", ""..math.random(2,3).."")
NPC:SetPos( pos )
NPC:SetKeyValue( "ignoreunseenenemies", 0 )
NPC:SetKeyValue( "spawnflags", 512 )

NPC:SetSkin(1)
NPC:Spawn()
NPC:Give("ai_weapon_shotgun")
combinen = combinen + 1
NPC:SetName("Combine nº"..combinen.."")
NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )	
NPC:Fire("StartPatrolling","",0)
end
function SpawnMetropoliceStunstick( pos )
NPC = ents.Create( "npc_metropolice" )
NPC:SetKeyValue("Manhacks", math.random(0,1)) 
NPC:SetKeyValue( "model", "models/Police.mdl" )
NPC:SetPos( pos )
NPC:SetKeyValue( "ignoreunseenenemies", 0 )
NPC:SetKeyValue( "spawnflags", "512" )

NPC:SetKeyValue("squadname", "")
NPC:Spawn()
NPC:Give("ai_weapon_stunstick")
combinen = combinen + 1
NPC:SetName("Combine nº"..combinen.."")
NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_POOR )	
NPC:Fire("StartPatrolling","",0)
NPC:Fire("ActivateBaton","",0)
end
function SpawnMetropolice( pos )
NPC = ents.Create( "npc_metropolice" )
NPC:SetKeyValue("Manhacks", math.random(0,1)) 
NPC:SetKeyValue( "model", "models/Police.mdl" )
NPC:SetPos( pos )
NPC:SetKeyValue( "ignoreunseenenemies", 0 )
NPC:SetKeyValue( "spawnflags", "512" )

NPC:SetKeyValue("squadname", "")
NPC:Spawn()
NPC:Give("ai_weapon_pistol")
combinen = combinen + 1
NPC:SetName("Combine nº"..combinen.."")
NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_POOR )	
NPC:Fire("StartPatrolling","",0)
end
function SpawnMetropoliceHard( pos )
NPC = ents.Create( "npc_metropolice" )
NPC:SetKeyValue("Manhacks", math.random(1,2)) 
NPC:SetKeyValue( "model", "models/Police.mdl" )
NPC:SetPos( pos )
NPC:SetKeyValue( "ignoreunseenenemies", 0 )
-- NPC:SetKeyValue("squadname", "heliaforce")
NPC:SetKeyValue( "spawnflags", 512 )

NPC:Spawn()
NPC:Give("ai_weapon_smg1")
combinen = combinen + 1
NPC:SetName("Combine nº"..combinen.."")
NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )	
NPC:Fire("StartPatrolling","",0)
end
function SpawnRollermine( pos )
NPC = ents.Create( "npc_rollermine" )
NPC:SetPos(pos)
NPC:Spawn()
NPC:SetName("Rollermine")
NPC:SetKeyValue( "spawnflags", "1024" )
end
function SpawnFriendlyRollermine( pos )
NPC = ents.Create( "npc_rollermine" )
NPC:SetPos( pos )
NPC:Spawn()
NPC:SetName("Rollermine")
NPC:AddRelationship("player D_LI 99")
NPC:AddRelationship("npc_combine_s D_HT 99")
NPC:AddRelationship("npc_metropolice D_HT 99")
for k,v in pairs(ents.FindByClass("npc_*")) do
if !v:IsNPC() then return end
if v:GetClass() != NPC:GetClass() then 
       NPC:AddEntityRelationship( v, D_HT, 99 ) 
       v:AddEntityRelationship( NPC, D_HT, 99 ) 
end
end
end
function SpawnCombineElite1( pos )
	NPC = ents.Create( "npc_combine_s" )
	NPC:SetKeyValue("NumGrenades", "0") 
	NPC:SetKeyValue( "model", "models/Combine_Super_Soldier.mdl" )
	NPC:SetPos( pos )
	NPC:SetKeyValue( "spawnflags", 512 )

	NPC:Spawn()
	NPC:Give( "ai_weapon_ar2" )
	combinen = combinen + 1
	NPC:SetName("Combine nº"..combinen.."")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )
	NPC:Fire("StartPatrolling","",0)

end
function SpawnCombineElite2( pos )
	NPC = ents.Create( "npc_combine_s" )
	NPC:SetKeyValue("NumGrenades", ""..math.random(0,1).."") 
	NPC:SetKeyValue( "model", "models/Combine_Super_Soldier.mdl" )
	NPC:SetKeyValue( "spawnflags", "256" )
	NPC:SetPos( pos )
	NPC:SetKeyValue( "spawnflags", 512 )

	NPC:Spawn()
	NPC:Give( "ai_weapon_ar2" )
	combinen = combinen + 1
	NPC:SetName("Combine nº"..combinen.."")
	NPC:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
	NPC:Fire("StartPatrolling","",0)
end


function SpawnAirboat( pos, ang )
spawnairboat = ents.Create("prop_vehicle_airboat")
spawnairboat:SetModel("models/airboat.mdl")
spawnairboat:SetKeyValue("vehiclescript", "scripts/vehicles/airboat.txt")
spawnairboat:SetPos( pos )
spawnairboat:SetAngles( ang ) 
spawnairboat:Spawn()
spawnairboat:Activate()
end


function SpawnCeilingTurretStrong( pos, ang )
NPC = ents.Create( "npc_turret_ceiling" )
NPC:SetPos( pos )
NPC:SetAngles( ang ) 
NPC:SetKeyValue( "spawnflags", "32" )
NPC:Spawn()
NPC:SetHealth(2)
end

function SpawnSuitCharger( pos, ang )
NPC = ents.Create( "item_suitcharger" )
NPC:SetPos( pos )
NPC:SetAngles( ang ) 
NPC:SetKeyValue( "spawnflags", 8192 )
NPC:Spawn()
end

function SpawnDynamicAmmoCrate( pos, ang )
NPC = ents.Create( "item_item_crate" )
NPC:SetPos( pos )
NPC:SetKeyValue( "ItemClass", ""..table.Random(GOODCRATEITEMS).."" )
NPC:SetKeyValue( "ItemCount", math.random(1,2) ) 
NPC:SetAngles( ang ) 
NPC:Spawn()
end

function PropBreak(breaker,prop)
if math.random(1,1) == 1 then
	if prop:IsValid() then
		if prop:GetModel() == "models/props_junk/wood_crate002a.mdl"
		or prop:GetModel() == "models/props_junk/wood_crate001a_damaged.mdl" 
		or prop:GetModel() == "models/props_junk/wood_crate001a_damagedmax.mdl" 
		or prop:GetModel() == "models/props_junk/wood_crate001a_damagedmax.mdl" 
		or prop:GetModel() == "models/props_junk/wood_crate001a.mdl" 
		then
		SpawnItem(""..table.Random(CRATEITEMS).."", prop:GetPos(), Angle(0,0,0))
		end
	end
end


end
hook.Add("PropBreak","OnPropBreak",PropBreak)



function SpawnTurret( pos, ang )
NPC = ents.Create( "npc_turret_floor" )
NPC:SetPos( pos )
NPC:SetAngles( ang ) 
NPC:Spawn()
NPC:SetName("Turret")
end

function SpawnFriendlyTurret( pos, ang )
NPC = ents.Create( "npc_turret_floor" )
NPC:SetPos( pos )
NPC:SetAngles( ang ) 
NPC:SetKeyValue("spawnflags", 512)
NPC:Spawn()
NPC:SetName("Turret")
end
--0.101 -90.000 -0.016
---72.289574 -1476.778076 11.626291

function SpawnMine( pos )
NPC = ents.Create( "combine_mine" )
NPC:SetPos( pos )
NPC:Spawn()
NPC:SetName("Mine")
end

function SpawnFragCrate( pos, ang )
NPC = ents.Create( "item_ammo_crate" )
NPC:SetPos( pos )
NPC:SetName("RPGAMMO")
NPC:SetAngles( ang ) 
NPC:SetKeyValue("AmmoType", 5)
NPC:Spawn()
end

function SpawnAmmoCrate( pos, ang, ammotype )
NPC = ents.Create( "item_ammo_crate" )
NPC:SetPos( pos )
NPC:SetName("RPGAMMO")
NPC:SetAngles( ang ) 
NPC:SetKeyValue("AmmoType", ammotype)
NPC:Spawn()
end

function SpawnMineDisarmed( pos )
NPC = ents.Create( "combine_mine" )
NPC:SetPos( pos )
NPC:SetKeyValue("StartDisarmed", 1)
NPC:Spawn()
NPC:SetName("Mine")
end

function SpawnItem (weapon, pos, ang)
ITEM = ents.Create(weapon)
ITEM:SetPos( pos )
ITEM:SetAngles( ang )
ITEM:Spawn()
end

function SpawnStaticProp( pos, ang, model )
ITEM = ents.Create("prop_physics" )
ITEM:SetPos( pos )
ITEM:SetAngles(ang)
ITEM:SetModel(model)
ITEM:Spawn()
ITEM:Fire("DisableMotion","",0)
ITEM:SetKeyValue("minhealthdmg", 6000)
end
-- UTILITY FUNCTIONS ^


-- v PRE-PLAY THINGS
function GM:PlayerSpawn(ply)

-- MapLoadout() Placeholder
--	ply.safe=yes
    ply:SetCustomCollisionCheck(true)
	ply:StripAmmo()
	ply:StripWeapons()
	ply:Give("weapon_crowbar")
--	ply:Give("weapon_physcannon")
--	ply:Give(table.Random(MEDIUMWEAPONS))
	ply:SetupHands()
	ply:SetWalkSpeed(150)
	ply:SetRunSpeed(250)
	ply:SetCrouchedWalkSpeed(0.3)
	ply:AllowFlashlight(true)
	ply:SetNoCollideWithTeammates(1)
--	ply:SetCollisionGroup(11)
	timer.Simple(1, npcforget)
if math.random(1,2) == 1 then
ply:SetModel(table.Random(playermodelsmale) )
ply.sex="male"
print(""..ply:GetName().." is male")
else
ply:SetModel(table.Random(playermodelsfemale) )
ply.sex="female"
print(""..ply:GetName().." is female")
end
end
-- ^ PRE-PLAY THINGS

-- CYCLES v
function coverzones()
timer.Create( "coverzones", 20, 0, coverzones ) 	
print("Patrol Areas updated:")
for k, v in pairs(ents.FindByClass("npc_combine_s")) do
	if WAVESPAWN == 1 then v:SetCollisionGroup(1) else v:SetCollisionGroup(9) end

	if !v:IsCurrentSchedule(SCHED_FORCED_GO) && !v:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then	
		if v:GetEnemy() then 
			print(""..v:GetName().." is busy, cannot change patrol area")
		else
			v:SetLastPosition(table.Random(zonescovered) + Vector(math.random(-20,20), math.random(-20,20), -30))
			if WAVESPAWN == 1 then
				v:SetSchedule(SCHED_FORCED_GO_RUN)
			else
				v:SetSchedule(SCHED_FORCED_GO)
			end
		print(""..v:GetName().." changed patrol area")
		end
	end
end

for k, v in pairs(ents.FindByClass("npc_metropolice")) do
	if WAVESPAWN == 1 then v:SetCollisionGroup(1) else v:SetCollisionGroup(9) end
		if !v:IsCurrentSchedule(SCHED_FORCED_GO) && !v:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
		if v:GetEnemy() then 
			print(""..v:GetName().." is busy, cannot change patrol area")
		else
			v:SetLastPosition(table.Random(zonescovered) + Vector(math.random(-20,20), math.random(-20,20), -30))
			if WAVESPAWN == 1 then
				v:SetSchedule(SCHED_FORCED_GO_RUN)
			else
				v:SetSchedule(SCHED_FORCED_GO)
			end
		print(""..v:GetName().." changed patrol area")
		end
end
end
end



function GM:ShouldCollide(ent1,ent2)

if ent1:IsPlayer() then
if ent2:GetClass() == "npc_combine_s" then
if ent1:GetPos():Distance(ent2:GetPos()) < 50 then
ent1:SetNoTarget(false)
end
end
end


if ent1:GetClass() == "npc_combine_s" then
if ent2:GetClass():IsPlayer() then
if ent1:GetPos():Distance(ent2:GetPos()) < 50 then
ent1:SetNoTarget(false)
end
end
end

return true

end


function metropolicewander()
for k, v in pairs(ents.FindByClass("npc_metropolice")) do
if !v:GetEnemy() then
if !v:IsCurrentSchedule(SCHED_FORCED_GO) && !v:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
v:SetSchedule(SCHED_IDLE_WANDER)
print(""..v:GetName().." is wandering now")
end
end
end

for k, v in pairs(ents.FindByClass("npc_rollermine")) do
if !v:GetEnemy() then
if v:GetPhysicsObject():GetVelocity():Length() < 20 then
print(""..v:GetName().." is wandering now")

if math.random(1,3)==2 then
v:SetSchedule(SCHED_IDLE_WANDER)

else
v:SetSchedule(SCHED_RUN_RANDOM)

end
end
end
timer.Create( "metropolicewander", 9, 1, metropolicewander ) 
end
end
timer.Create( "metropolicewander", 8, 1, metropolicewander ) 

function CombineIdleSpeech()
local NPCsFound = 0
for _, player in pairs(ents.FindByClass("player")) do
	for k, npc in pairs(ents.FindInSphere(player:GetPos(),900)) do
		if npc:GetClass() == "npc_metropolice" || npc:GetClass() == "npc_combine_s" then
			NPCsFound= NPCsFound+1
			if NPCsFound < 2 && npc:Health() > 0 then
				if npc:GetEnemy() then
					npc:EmitSound(table.Random(CombineCombatSounds), 90,100) else npc:EmitSound(table.Random(CombineIdleSounds), 80,100)
				end
			end
		end
	end
end
end

function npcforget()
print("npcforget APPLIED")
table.foreach(player.GetAll(), function(key,value)
--value:SetNWInt("status", "safe" )
net.Start( "Hidden" )
net.Send(value)
value.spotted = 0
end)
table.foreach(MainEnemies, function(key,enemy)
for k, v in pairs(ents.FindByClass(enemy)) do 
v:SetKeyValue("squadname", "")
if v:GetEnemy() then if v:GetEnemy():IsPlayer() then
--v:GetEnemy():PrintMessage(HUD_PRINTTALK, ""..v:GetName().." lost "..v:GetEnemy():GetName().."")
v:ClearEnemyMemory() 
v:SetEnemy(nil)
v:SetSchedule(SCHED_FORCED_GO_RUN)
end
end
end
end)
end



function GM:InitPostEntity()
INFINITE_ACHIEVED = 0


if GetConVarString("h_autostart") == "1" then
print("H_AUTOSTART is 1")
if win == 1 then
timer.Simple(10, autofirstwave)
end
else
print("H_AUTOSTART is not 1")
end

Wave=0
timer.Create( "Item Respawn System", 10, 1, ItemRespawnSystem )
timer.Create( "CombineIdleSpeech", math.random(5,15), 0, CombineIdleSpeech ) 
timer.Create( "CicloUnSegundo", 1, 1, CicloUnSegundo ) 
timer.Create( "coverzones", 10, 1, coverzones )
timer.Create( "wavefinishedchecker", 5, 1, wavefinishedchecker)
CanCheck = 0
MapSetup()

if REUSE_MAP_PROPS == 1 then
for k, v in pairs(ents.FindByClass("prop_physics")) do
if v:GetModel() == "models/props_c17/furnituredrawer001a.mdl" or v:GetModel() == "models/props_c17/furnitureshelf002a.mdl" or v:GetModel() == "models/props_wasteland/kitchen_shelf001a.mdl" or v:GetModel() == "models/props_interiors/furniture_desk01a.mdl" or v:GetModel() == "models/warby/wan_prop_caffe_table_01.mdl" or v:GetModel() == "models/props_junk/trashdumpster01a.mdl" or v:GetModel() == "models/props_c17/bench01a.mdl" then 


table.insert(ITEMPLACES, v:GetPos()+Vector(0,0,30))
print("found a reusable prop")
end
end
end
end

function GM:GetFallDamage( ply, speed )
nearbycombinecomecasual(ply)

	return ( speed / 60 )
end

function GM:OnEntityCreated(entity)
wavefinishedchecker()
	if entity:IsNPC() && entity:GetClass() != "npc_helicopter" && entity:GetClass() != "npc_combinegunship"  && entity:GetClass() != "npc_combine_s" && entity:GetClass() != "npc_metropolice" && entity:GetName() == "" then
	ManuallySpawnedEntity = ManuallySpawnedEntity + 1
	entity:SetName("NPC nº"..ManuallySpawnedEntity.."")
	print(""..entity:GetName().." created")
	end
end

function CicloUnSegundo()

table.foreach(MainEnemiesCoop, function(key,enemy)
for k, npc in pairs(ents.FindByClass(enemy)) do
if npc:Health() > 0 then

if npc:GetEnemy() then
	if npc:IsCurrentSchedule(SCHED_FORCED_GO) or npc:IsCurrentSchedule(SCHED_IDLE_WANDER) or npc:IsCurrentSchedule(SCHED_FORCED_GO_RUN)	then npc:ClearSchedule() end
	
if npc:GetEnemy():IsPlayer() or npc:GetEnemy():IsNPC() then
npc:SetKeyValue("squadname", "CombineSquad")
if npc:GetEnemy().spotted != 1 then
if npc:GetClass() == "npc_combine_s" || npc:GetClass() == "npc_metropolice" then
npc:EmitSound(table.Random(ContactConfirmed), 100, 100) end

net.Start("Spotted")
net.Send(npc:GetEnemy())
npc:GetEnemy().spotted = 1
end

	if npc:HasCondition(10) then
		if timer.Exists("npcforgettimer") then
		timer.Destroy( "npcforgettimer")
		print("npcforget STOPPED")
		end
		for num, ThisEnt in pairs(ents.FindInSphere(npc:GetPos(),2000)) do 
		if ThisEnt:GetClass() == "npc_combine_s" or ThisEnt:GetClass() == "npc_metropolice" then
				if ThisEnt:GetEnemy() == nil  then 
					if CombineAssisting < GetConVarNumber("h_maxhelp") then
					print(ThisEnt:GetName().." is helping "..npc:GetName().."")
					ThisEnt:SetLastPosition(npc:GetEnemy():GetPos())
					ThisEnt:SetSchedule(SCHED_FORCED_GO_RUN)
					CombineAssisting = CombineAssisting+1
					-- print("Combines helping: "..CombineAssisting.." of "..GetConVarNumber("h_maxhelp").."")
					end
				end
		end
		end
	else
		if !timer.Exists("npcforgettimer") then
		timer.Create( "npcforgettimer", GetConVarNumber("h_lostplayertimeout"), 1, npcforget ) 
		print("npcforget ACTIVE")
		end
	end		
end
end
end
end
end)

timer.Create( "CicloUnSegundo", 1, 1, CicloUnSegundo ) 
end

function helibehavior()
if HeliA then
if HeliIsDead != 1 then
		if HeliA:GetEnemy() then
			--print ("heli has enemy: "..HeliA:GetEnemy():GetName().."")
				if HeliA:GetEnemy():IsNPC() && HeliCanSpotlight == 1 then
					helispotlight:Fire("Target", ""..HeliA:GetEnemy():GetName().."", 0)
					end
				if HeliA:GetEnemy():IsPlayer() && HeliCanSpotlight == 1 then
				HeliA:GetEnemy():SetName(""..tostring(HeliA:GetEnemy():GetName()).."focus")
				helispotlight:Fire("Target", ""..tostring(HeliA:GetEnemy():GetName()).."focus", 0)
				end
if HeliA:HasCondition(10) then
nearbycombinecome(HeliA,HeliA:GetEnemy())
end
		end
end
end
timer.Create( "helibehavior", 1, 1, helibehavior ) 

end
function helipath()
if HeliA:IsValid() && HeliA:GetEnemy() == nil then
	for num, HeliTrack in pairs(ents.FindInSphere(HeliA:GetPos(), 1700)) do
		if HeliCanSpotlight == 1 then helispotlight:Fire("Target", "", 0)	end
			if HeliTrack:IsValid() && HeliTrack:GetClass() == "path_track" && HeliTrack:GetName() != "used" then
			if HeliA:Visible(HeliTrack) then
			--	print("found "..HeliTrack:GetName().."")
				HeliTrack:SetName("going")
				HeliA:Fire("SetTrack","going",0)
				Usada = HeliTrack
			--	print(Usada)
				timer.Create( "GoingToUsed", 0, 1, goingtoused ) 
				timer.Create( "helipath", math.random(3,6), 0, helipath ) 
				timer.Create( "usedpaths", 7, 0, usedpaths ) 
				return false
			end
			end
	end
		
elseif  HeliA:IsValid() && HeliA:GetEnemy() != nil then
	for num, HeliTrack in pairs(ents.FindInSphere(HeliA:GetEnemy():GetPos(), 2000)) do
		if HeliTrack:IsValid() && HeliTrack:GetClass() == "path_track" && HeliTrack:GetName() != "used" then	
			if HeliA:Visible(HeliTrack) && HeliTrack:Visible(HeliA:GetEnemy()) then
			--	print("found "..HeliTrack:GetName().."")
				HeliTrack:SetName("going")
				HeliA:Fire("SetTrack","going",0)
				HeliA:SetVelocity(Vector(2,2,2))
				Usada = HeliTrack
			--	print(Usada)
				timer.Create( "GoingToUsed", 0, 1, goingtoused ) 
				timer.Create( "helipath", math.random(4,8), 0, helipath ) 
				timer.Create( "usedpaths", 9, 0, usedpaths ) 
				return false
			end
		end
	end
end
-- timer.Create( "helipath", math.random(3,6), 0, helipath ) 
end


function goingtoused()
		Usada:SetName("used")
	--	print("Changed to Used")
end

function usedpaths()
if HeliA:IsValid() then
	for num, HeliTrack in pairs(ents.FindInSphere(HeliA:GetPos(), 200560)) do
				if HeliTrack:GetName() == "used" then
					HeliTrack:SetName("empty")
					--print("found used and emptied")
					Usada:SetName("used")
				end
	end
	end
-- timer.Create( "usedpaths", 40, 0, usedpaths ) 
end


function scannerwander()
	for numA, scanner in pairs(ents.GetAll()) do
		if scanner:GetName() == "Scanner" then
			for numB, scannertarget in pairs(ents.FindInSphere(scanner:GetPos(), 25600)) do
				if scannertarget:IsNPC() then
					if scanner:GetEnemy() == nil && scannertarget:GetClass() == "npc_metropolice" || scannertarget:GetClass() == "npc_combine_s" then
					scanner:Fire("SetFollowTarget",""..scannertarget:GetClass().."",0)
					if mines != 1 then
					scanner:Fire("EquipMine","",0)
					scanner:Fire("DeployMine","",2)
					local mines = 1
					end
					end
				end
			end
		end
	end
timer.Create( "Scanner Wander", 30, 1, scannerwander )
mines = 0
end
-- CYCLES ^

-- GM HOOKS v
function GM:OnNPCKilled(victim, killer, weapon)
wavefinishedchecker()

-- Uncomment to for-the-lulz explosion kills
/*
ent = ents.Create( "env_explosion" )
ent:SetPos(victim:GetPos())
ent:Spawn()
ent:SetKeyValue( "iMagnitude", "100" )
print("assploded")
ent:Fire("Explode",0,0)
*/



if victim:GetClass() == "npc_turret_floor" then
print("turret killed")
nearbycombinecome(victim)

/*
for k, v in pairs(ents.FindInSphere(victim:GetPos(),1024)) do
if v:IsPlayer() then
net.Start( "Hidden" )
net.Send(killer)
killer.spotted = 0
print("Player killed it")
end
end

*/
end
if victim:GetClass() == "npc_turret_ceiling" then
nearbycombinecome(killer)
end

if victim:GetClass() == "npc_combinegunship" then
HeliIsDead = 1
timer.Stop( "helipath")
timer.Stop( "usedpaths")
timer.Stop( "helibehavior")
end

if victim:GetClass() == "npc_helicopter" then
timer.Stop( "helipath")
timer.Stop( "usedpaths")
timer.Stop( "helibehavior")
end

if killer:IsNPC() then

if killer:GetClass() == "npc_citizen" then
nearbycombinecome(killer)
end

if killer:Health() > 0 then
	if killer:GetClass() == "npc_combine_s" then
	killer:EmitSound(table.Random(CombineKillSounds), 100, 100)
	end
PrintMessage(HUD_PRINTTALK, ""..killer:GetName().." killed "..victim:GetName().."")
end
end

if killer:IsPlayer() then
net.Start( "Hidden" )
net.Send(killer)
killer.spotted = 0

if killer:Alive() then
	if victim:GetClass() == "npc_metropolice" || victim:GetClass() == "npc_combine_s" then
		local MAX=0
		local TALK=0
		for k, see in pairs(ents.FindInSphere(victim:GetPos(),256)) do
			if see:GetClass() == "npc_combine_s" && see:EntIndex() != victim:EntIndex() then
				if TALK<1 then
				see:EmitSound(table.Random(CombineKilledSounds), 360, 100)
				TALK=TALK+1
				end
				if see:GetEnemy() == nil then
					if see:Visible(victim) then 
					if MAX < 1 then
					--	print("SOSPECHA")
					--	victim:SetName("kill")
						see:Fire("ThrowGrenadeAtTarget",""..tostring(victim:GetName()) .."",0)
					--	see:SetEnemy(killer)
					--	print(see)
						MAX=MAX+1
					end
					end
					elseif math.random (1,8) == 1 then
						killer:SetName("player")
						see:Fire("ThrowGrenadeAtTarget","player",0)
					end
				end
			end
		if victim:GetEnemy() then
			CombineAssisting = 0	
			PrintMessage(HUD_PRINTTALK, ""..killer:GetName().." killed "..victim:GetName().."")
			nearbycombinecome(killer)
			if killer.sex == "male"  then
				killer:EmitSound(table.Random(malecomments), 360, 100)
			else
				killer:EmitSound(table.Random(femalecomments), 360, 100)
			end
		end
		if !victim:GetEnemy() then
			if weapon:GetClass() == "npc_tripmine" || weapon:GetClass() == "npc_satchel" then
			killstyle = 2
			--print("MINE")
			elseif killer:GetActiveWeapon():GetClass() != "weapon_crowbar" && killer:GetActiveWeapon():GetClass() != "weapon_crossbow"  then
			killstyle = 2
			--print("WEAPON")
			elseif killer:GetActiveWeapon():GetClass() == "weapon_crowbar"  || killer:GetActiveWeapon():GetClass() == "weapon_crossbow" then
			killstyle = 3
			--print("SILENT")
			end
			if killstyle == 3 then
				PrintMessage(HUD_PRINTTALK, ""..killer:GetName().." killed "..victim:GetName().." silently")
				if killer:Frags() < 1 then
				timer.Simple(2 , function()	killer:EmitSound("music/hl1_song11.mp3", 40, 100)end)
				end
			end
			if killstyle == 2 then
				PrintMessage(HUD_PRINTTALK, ""..killer:GetName().." killed "..victim:GetName().." (loud)")
				CombineAssisting = 0
				nearbycombinecome(victim)
			end
		end
	end
killer:AddFrags(1)

end
end


end

function helideath()
BossHeliAlive = 0
if HeliA:IsValid() && HeliIsDead != 1 then
HeliIsDead = 1
helispotlight:Remove()
HeliAFocus:Remove()
--HeliA:Fire("Kill","",5)
timer.Create( "SpawnRollermine", 2, 2, function()
SpawnRollermine(HeliA:GetPos() + Vector(0, 0, -100))
end)
--HeliA:Fire("SelfDestruct","",0)
HeliA:Fire("SelfDestruct","",5)
--PrintMessage(HUD_PRINTCENTER, "You killed the Helicopter!")
timer.Stop( "helipath")
timer.Stop( "usedpaths")
end
end

function GM:EntityTakeDamage(damaged,damage)
if damage:GetAttacker():GetClass() =="monster_apc" then
damage:ScaleDamage(GetConVarNumber("h_npcscaledamage"))
end

if !damaged:IsNPC() and !damaged:IsPlayer() then
if CAN_HEAR_BREAK == 1 then
CAN_HEAR_BREAK = 0
timer.Simple(5, function() CAN_HEAR_BREAK = 1 end)
nearbycombinecomecasual(damaged)
end
end

if damaged:IsNPC() then
if damage:GetAttacker():IsPlayer() then
if damaged:Health() > damage:GetDamage() then
damage:GetAttacker():SetNoTarget(false)
end
end
	if damaged:GetClass() != "npc_helicopter" && damaged:GetClass() != "npc_combinegunship" then
		if damaged:GetEnemy() == nil then
		damage:ScaleDamage(GetConVarNumber("h_npcscaledamage")*2)
		else
		damage:ScaleDamage(GetConVarNumber("h_npcscaledamage"))
		end
		if damaged:Health() > damage:GetDamage() then
		damaged:SetEnemy(damage:GetAttacker())
		end
	end
end
if damaged:IsPlayer() then
damage:ScaleDamage(GetConVarNumber("h_playerscaledamage"))
end


if GetConVarNumber("h_friendlyfire") != 1 then
	if damaged:IsPlayer() && damage:GetAttacker():IsPlayer() then
		if damaged:EntIndex() == damage:GetAttacker():EntIndex() then
		damage:ScaleDamage(GetConVarNumber("h_playerscaledamage"))
		else
		damage:ScaleDamage(0)
		end
	end
	if damaged:IsNPC() && damage:GetAttacker():IsNPC() then
	if damaged:GetClass() == damage:GetAttacker():GetClass() then
		damage:ScaleDamage(0)
	end
	end
end

if damaged:GetClass() == "npc_helicopter" then

if damage:IsDamageType(64) then
damage:ScaleDamage(1)
else
damage:ScaleDamage(0)
end

if damaged:Health() < 800 && HeliIsDead != 1 then
if HeliAangered == 0 then
PrintMessage(HUD_PRINTTALK, "[Overwatch]: Air enforcement unit, you are now free to employ aggresive containment tactics.")

RunConsoleCommand( "g_helicopter_chargetime", "1") 
HeliA:Fire("BlindfireOn","",0)
HeliA:Fire("SetPenetrationDepth","200",0)
RunConsoleCommand( "g_helicopter_chargetime", "1") 
RunConsoleCommand( "sk_helicopter_burstcount", "10") 
RunConsoleCommand( "sk_helicopter_firingcone", "2") 
RunConsoleCommand( "sk_helicopter_roundsperburst", "5") 
HeliA:SetKeyValue( "patrolspeed", "5000" )
if HeliCanSpotlight == 1 then
helispotlight:SetKeyValue("lightcolor", "255 0 0") 
HeliAFocus:Remove()
HeliAFocus = ents.Create( "point_spotlight" )
HeliAFocus:SetPos(HeliA:GetPos()+(HeliA:GetForward()*150+Vector(0,0,-50)))
HeliAFocus:SetAngles(helispotlight:GetAngles())
HeliAFocus:SetParent(helispotlight)
HeliAFocus:SetKeyValue( "spawnflags", "1" )
HeliAFocus:SetKeyValue( "SpotlightWidth", "50" )
HeliAFocus:SetKeyValue( "SpotlightLength", "200" )
HeliAFocus:SetKeyValue("rendercolor", "255 0 0")
HeliAFocus:Spawn()
HeliAFocus:Activate()
end
HeliAangered = 1
end

if damaged:Health() < 151 then
PrintMessage(HUD_PRINTTALK, "[Overwatch]: All units, "..damaged:GetName().." state changed to: inoperative.")
timer.Simple(1 , helideath)
creating = ents.Create( "info_target_helicopter_crash" )
creating:SetPos(damage:GetAttacker():GetPos() + Vector(0, 0, 500))
creating:Spawn()
creating:SetParent(damage:GetAttacker())
end

end
end


if damaged:GetClass() == "npc_sniper" then
if damage:GetInflictor():GetClass() == "crossbow_bolt" or damage:IsDamageType(64) or damage:IsDamageType(67108864) then
damaged:SetHealth(0)
PrintMessage(HUD_PRINTTALK, ""..damage:GetAttacker():GetName().." got that Sniper out of the way ")
end
end

if damaged:GetClass() == "npc_turret_ceiling" then
if damage:IsDamageType(64) then
damaged:SetHealth(0)
PrintMessage(HUD_PRINTTALK, ""..damage:GetAttacker():GetName().." destroyed a ceiling turret ")
else
damage:ScaleDamage(0)
end
end

end

function GetAmmoForCurrentWeapon( ply )
	if (  !IsValid( ply ) ) then return -1 end

	local wep = ply:GetActiveWeapon()
	if (  !IsValid( wep ) ) then return -1 end
 
	print(ply:GetAmmoCount(wep:GetPrimaryAmmoType()))
end


function GM:KeyPress(player,key)
if player:Alive() then

if key == IN_ATTACK then
if player:GetActiveWeapon():Clip1() > 0 then
				local silent=0
				table.foreach(SILENT_WEAPONS, function(key,value)
				if player:GetActiveWeapon():GetClass() == value then
				silent=1
				--print("combine not come")
				end
				end)
				if silent==0 then
				--print("combine come (not silent)")
				allthecombinecome(player,GetConVarNumber("h_maxgunshotinvestigate"))
				end
end
end

		if key == IN_ATTACK2 then
			if player:GetAmmoCount(player:GetActiveWeapon():GetSecondaryAmmoType()) > 0 or (player:GetActiveWeapon():GetClass() == "weapon_shotgun") then
					table.foreach(SECONDARY_FIRE_WEAPONS, function(key,value)
					if player:GetActiveWeapon():GetClass() == value then
					allthecombinecome(player,GetConVarNumber("h_maxgunshotinvestigate"))
					--print("combine come (not silent secondary fire)")
					end
					end)
			end
		end
end
end


function GM:PlayerSetHandsModel( ply, ent )
	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end
end

-- GM HOOKS ^
hook.Add( "PlayerInitialSpawn", "playerInitialSpawn", FirstSpawn )
