local DEFAULT_EVENTS_CFG = [[{
	"dice_cooldown":60,
	"only_weapon": {
		"weapon_rpg": {
			"chance":0.15,
			"time":30,
			"music":"tunnels.mp3"
		}
	},
	"boss": {
		"demolitioner": {
			"chance":0.1,
			"weapon":[
				"weapon_rpg",
				"weapon_slam",
				"weapon_frag"
			],
			"health":500,
			"music":"final_fight.mp3"
		}
	},
	"random_swap_chance":0.05,
	"random_gravity": {
		"chance":0.05,
		"time":45
	},
	"one_shot":{
		"chance":0.07,
		"music":"zalyx.mp3",
		"time":45
	}
}]]

local DEFAULT_WEAPONS_PICKUP_BLACKLIST_CFG = [[

	"weapon_to_blacklist"
]]

local DEFAULT_WEAPON_CFG = [[

	"weapon_357",
	"weapon_ar2",
	"weapon_crossbow",
	"weapon_crowbar",
	"weapon_shotgun",
	"weapon_smg1",
	"weapon_stunstick"
]]

weapon_config = {}
event_config = {}
wpn_pickup_blacklist = {}

function cfg_dir_check()
	if not file.Exists("rdmcfg", "DATA") then
		file.CreateDir("rdmcfg")
	end
end

function load_weapon_cfg()
	if file.Exists("rdmcfg/weapons.txt", "DATA") then
		local f = file.Open("rdmcfg/weapons.txt", "r", "DATA")
		local jsonstr = f:Read( f:Size() )
		f:Close()
		weapon_config = util.JSONToTable(jsonstr)
	else
		local f = file.Open("rdmcfg/weapons.txt", "w", "DATA")
		f:Write('[')
		f:Write(DEFAULT_WEAPON_CFG)
		f:Write(']')
		f:Close()
		load_weapon_cfg()
	end
end

function load_event_cfg()
	if file.Exists("rdmcfg/events.txt", "DATA") then
		local f = file.Open("rdmcfg/events.txt", "r", "DATA")
		local jsonstr = f:Read( f:Size() )
		f:Close()
		event_config = util.JSONToTable(jsonstr)
	else
		local f = file.Open("rdmcfg/events.txt", "w", "DATA")
		f:Write(DEFAULT_EVENTS_CFG)
		f:Close()
		load_event_cfg()
	end
end

function load_weapon_pickup_blacklist_cfg()
	if file.Exists("rdmcfg/wpn_pickup_blacklist.txt", "DATA") then
		local f = file.Open("rdmcfg/wpn_pickup_blacklist.txt", "r", "DATA")
		local jsonstr = f:Read( f:Size() )
		f:Close()
		wpn_pickup_blacklist = util.JSONToTable(jsonstr)
	else
		local f = file.Open("rdmcfg/wpn_pickup_blacklist.txt", "w", "DATA")
		f:Write('[')
		f:Write(DEFAULT_WEAPONS_PICKUP_BLACKLIST_CFG)
		f:Write(']')
		f:Close()
		load_weapon_pickup_blacklist_cfg()
	end
end

cfg_dir_check()
load_weapon_cfg()
load_event_cfg()
load_weapon_pickup_blacklist_cfg()

return {["weapon"]=weapon_config, ["events"]=event_config, ["wpn_blacklist"]=wpn_pickup_blacklist}