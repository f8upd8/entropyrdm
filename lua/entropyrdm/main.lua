math.randomseed(os.time())

local spawnWeaponOverriden = false
local event_lock = false
local currentSound = false

local config = include("entropyrdm/config.lua")

local function playGlobalSound (path)
	currentSound = path
	for _, plr in pairs( player.GetAll() ) do
		plr:ConCommand("play "..path)
	end
end

local function stopGlobalSound ()
	currentSound = false
	for _, plr in pairs( player.GetAll() ) do
		plr:SendLua([[RunConsoleCommand("stopsound")]])
	end
end

local function stripAllPlayers()
	for _, plr in pairs( player.GetAll() ) do
		plr:StripWeapons()
	end
end

local function getRandomPlayer()
	local players = player.GetAll()
	local playerInd = math.random(1, table.getn(players))
	return players[playerInd]
end

local function giveRandomWeapon(plr)
	local rnd_num = math.random(1, table.getn(config["weapon"]))
	plr:Give(config["weapon"][rnd_num])
	plr:Give("weapon_physcannon")
end

local function grantEveryoneWeapon(certainWeapon)
	if certainWeapon then --If certain weapon specified, gives it to everyone
		for _, plr in pairs( player.GetAll() ) do
			plr:Give(certainWeapon)
		end
	else --If certain weapon unspecified, gives random one to everyone
		for _, plr in pairs( player.GetAll() ) do
			giveRandomWeapon(plr)
		end
	end
end


local function weaponOnlyEvent(weapon, time, music)
	if music then
		playGlobalSound(music)
	end
	event_lock = true
	stripAllPlayers()
	grantEveryoneWeapon(weapon)
	hook.Add( "player_spawn", weapon.."_event", function(data)
		Player(data.userid):Give(weapon)
	end )
	spawnWeaponOverriden = true
	timer.Create( weapon.."_event_stop", time, 1, function()
		spawnWeaponOverriden = false
		event_lock = false
		hook.Remove("player_spawn", weapon.."_event")
		stripAllPlayers()
		grantEveryoneWeapon()
		if music then
			stopGlobalSound()
		end
	end )
end

gameevent.Listen("entity_killed")
gameevent.Listen("player_disconnect")
local function bossEvent(weapon, health, music)
	event_lock = true
	if music then
		playGlobalSound(music)
	end
	local boss = getRandomPlayer()
	if boss:Alive() then
		boss:SetHealth(health)
		boss:StripWeapons()
		for _, wpn in pairs(weapon) do
			boss:Give(wpn)
		end
	else
		hook.Add("player_spawn", "boss_spawned", function (data)
			boss:SetHealth(health)
			boss:StripWeapons()
			if (boss:UserID() == data.userid) then
				for _, wpn in pairs(weapon) do
					boss:Give(wpn)
				end
				hook.Remove("player_spawn", "boss_spawned")
			end
		end )
	end
	hook.Add( "player_disconnect", "boss_event_stop_if_disconnect", function(data)
		if (boss:UserID() == data.userid) then
			hook.Remove("player_death", "boss_event_stop_if_disconnect")
			hook.Remove("player_death", "boss_event_stop_if_killed")
			hook.Remove("player_spawn", "boss_spawned")
			if music then
				stopGlobalSound()
			end
			event_lock = false
		end
	end )
	hook.Add( "entity_killed", "boss_event_stop_if_killed", function(data)
		if (boss:EntIndex() == data.entindex_killed) then
			hook.Remove("player_death", "boss_event_stop_if_disconnect")
			hook.Remove("player_death", "boss_event_stop_if_killed")
			hook.Remove("player_spawn", "boss_spawned")
			if music then
				stopGlobalSound()
			end
			event_lock = false
		end
	end )
end

local function lowGravityEvent(time)
	for _, plr in pairs(player.GetAll()) do
		plr:ConCommand("play beam_gravity.mp3")
	end
	RunConsoleCommand("sv_gravity", 200)
	timer.Create("low_grav_stop", time, 1, function ()
		RunConsoleCommand("sv_gravity", 600)
	end)
end

local function swapRandomPlayersEvent()
	local playerOne = getRandomPlayer()
	local playerTwo = getRandomPlayer()
	local playerOnePos = playerOne:GetPos()
	local playerTwoPos = playerTwo:GetPos()
	if playerOne:Alive() and playerTwo:Alive() then
		playerOne:SetPos(playerTwoPos)
		playerOne:ConCommand("play beam_main.mp3")
		playerTwo:SetPos(playerOnePos)
		playerTwo:ConCommand("play beam_main.mp3")
	else
		swapRandomPlayersEvent()
	end
end

gameevent.Listen("player_hurt")
local function oneShotEvent(time, music)
	if music then
		playGlobalSound(music)
	end
	event_lock = true
	hook.Add("player_hurt", "one_shot_event", function (data)
		if data.attacker then
			Player(data.userid):Kill() 
		end
	end )
	timer.Create("oneshotstop", time, 1, function()
		hook.Remove("player_hurt", "one_shot_event")
		event_lock = false
		if music then
			stopGlobalSound()
		end
	end )
end

local function throwDice()
	math.randomseed(os.time())
	if event_lock or (player.GetCount() == 0) then
		return false
	end
	local rnd_num = math.random()
	if rnd_num <= config["events"]["random_swap_chance"] then
		swapRandomPlayersEvent()
	end
	local rnd_num = math.random()
	if rnd_num <= config["events"]["random_gravity"]["chance"] then
		lowGravityEvent(config["events"]["random_gravity"]["time"])
	end
	local rnd_num = math.random()
	if rnd_num <= config["events"]["one_shot"]["chance"] then
		oneShotEvent(config["events"]["one_shot"]["time"], config["events"]["one_shot"]["music"])
	end
	local rnd_num = math.random()
 	for weapon, wpncfg in pairs(config["events"]["only_weapon"]) do
 		if rnd_num <= wpncfg["chance"] then
 			weaponOnlyEvent(weapon, wpncfg["time"], wpncfg["music"])
 			return true
 		end
	end
	rnd_num = math.random()
 	for bossname, bosscfg in pairs(config["events"]["boss"]) do
 		if rnd_num <= bosscfg["chance"] then
 			bossEvent(bosscfg["weapon"], bosscfg["health"], bosscfg["music"])
 			return true
 		end
	end
end

function GM:PlayerSpawn(plr)
	if not spawnWeaponOverriden then
		giveRandomWeapon(plr)
		plr:Give("weapon_physcannon")
	end
end

function GM:PlayerConnect(plr)
	if currentSound then
		plr:ConCommand("play "..currentSound)
	end
end

function GM:PlayerDeath(victim, inflictor, attacker)
	local MAXFRAGS = GetConVar("erdm_maxfrags")
	if attacker and attacker:IsPlayer() and (attacker:Frags() >= MAXFRAGS:GetInt()) then
		game.LoadNextMap()
	end
end

function GM:GetFallDamage( plr, speed )
	return ( speed / 10 )
end

--Weapon pickup restrictor
function GM:PlayerCanPickupWeapon(ply, wep)
	for _, wpn in pairs(config["wpn_blacklist"]) do --Checks if given weapon is restricted
		if wep:GetClass() == wpn then
			return false
		end
	end
	return true
end

gameevent.Listen("player_spawn")
timer.Create("entropy_loop", config["events"]["dice_cooldown"], 0, function()
	throwDice()
end)

timer.Create("wpn_regen_loop", 1, 0, function()
	for _, plr in pairs( player.GetAll() ) do
		for _, wpn in pairs( plr:GetWeapons() ) do
			plr:GiveAmmo(1,wpn:GetPrimaryAmmoType(),true)
		end
	end	
end)