include( "basewaves.lua" )
CombineFirstWave = 7
CombineSecondWave = 15
CombineThirdWave = 15
CombineFourthWave = 15
CombineFifthWave = 20
CombineInfiniteWave = 20
REUSE_MAP_PROPS = 1

zonescovered ={
Vector(-715.801270, -1541.449219, -175.968750),
Vector(323.394135, -214.058197, -95.968750),
Vector(-1079.747681, 1919.000977, -87.968750),
Vector(-1100.641968, 987.607788, -95.968750),
Vector(234.752258, 2087.459229, 64.031250),
Vector(712.359741, 2196.531006, 192.031250),
}

SPECIALITEMPLACES = {}

ITEMPLACES ={
Vector(-1261.686646, 1220.821899, -99.216232),
Vector(955.465820, 1928.274536, 56.938904),
Vector(698.684509, 2116.305664, 180.031250),
Vector(431.968750, 2255.913574, 96.031250),
Vector(647.080750, -302.631409, -117.468765),
Vector(663.113403, -457.634277, -118.530411),
Vector(460.007019, -383.301483, -117.090652),
Vector(-471.744293, 472.556305, 72.031250),
}







combinespawnzones = {
Vector(-668.826782, -2058.153076, -175.968750),
Vector(-1089.937134, -1855.745605, -87.968750)

}

function GM:PlayerInitialSpawn(ply)
timer.Simple(2, function() ply:PrintMessage(HUD_PRINTTALK, "[Overwatch]: Protection team alert, evidence of anticivil activity in this community.") end )
timer.Simple(4, function() ply:PrintMessage(HUD_PRINTTALK, "[Overwatch]: Code: assemble, plan, contain.") end )

--ply:PrintMessage(HUD_PRINTTALK, "Kill the majority of Combines. then, the second wave will come.")
end


function MapSetup()
--SpawnItem("item_healthcharger", Vector(-456.275421, 479.784363, -414.434113), Angle(-90.000, 90.000, 45.000) )

for k, v in pairs(ents.FindByClass("info_player_start")) do
print(v:GetClass())
v:Remove()
end

for k, v in pairs(ents.FindByClass("info_player_counterterrorist")) do
print(v:GetClass())
v:Remove()
end

for k, v in pairs(ents.FindByClass("info_player_terrorist")) do
print(v:GetClass())
v:Remove()
end

SpawnItem("info_player_start", Vector(-410.501892, -89.787407, -87.968750)+Vector(0,0,-45), Angle(0,0,0))
SpawnItem("info_player_start", Vector(177.478897, 95.992462, -87.968750)+Vector(0,0,-45), Angle(0,0,0))
SpawnItem("info_player_start", Vector(-159.968750, 1913.448975, -95.968750)+Vector(0,0,-45), Angle(0,0,0))

SpawnTurret(Vector(-491.003052, -1442.955566, -239.262634),Angle(0.397, 167.418, 0.522))


--if math.random(1,2) == 1 then
--SpawnTurret(Vector(-86.159615, -1113.844360, -223.263809),Angle(0.257, 92.666, 0.642))
--end
end

