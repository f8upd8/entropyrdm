# EntropyRDM

Just a simple random deathmatch gamemode for Garry's Mod

### Adding events variances

FROM EVENTS.TXT (UNMODIFIED):

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

FROM EVENTS.TXT (MODIFIED):

		"demolitioner": {
			"chance":0.1,
			"weapon":[
				"weapon_rpg",
				"weapon_slam",
				"weapon_frag"
			],
			"health":500,
			"music":"final_fight.mp3"
		},
		"JhonCena": {
			"chance":0.999,
			"weapon":[
				"weapon_jhoncena"
			],
			"health":999,
			"music":"cena_intro.mp3"
		}

And the same way you are able to create event of type "only-weapon"

### Adding your weapon to rotation (or removing one from)

To add weapon to random rotation, just open weapons.txt and.. add it?

FROM WEAPONS.TXT (UNMODIFIED)

[
	"weapon_357",
	"weapon_ar2",
	"weapon_crossbow",
	"weapon_crowbar",
	"weapon_shotgun",
	"weapon_smg1",
	"weapon_stunstick"
]

FROM WEAPONS.TXT (MODIFIED)

[
	"weapon_357",
	"weapon_ar2",
	"weapon_crossbow",
	"weapon_crowbar",
	"weapon_shotgun",
	"weapon_smg1",
	"weapon_stunstick",
  "weapon_nyangun"
]

And now you have neat nyangun. Pickup-restriction config modified the same way. To add your sound, just make sure that its 44100Hgz and drop it in your garrysmod/sound folder. 
