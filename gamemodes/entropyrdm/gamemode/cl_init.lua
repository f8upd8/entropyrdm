include("shared.lua")

--open skin selector if trying to open context menu
function GM:OnContextMenuOpen()
	RunConsoleCommand("playermodel_selector")
	return false
end

--draws player chosen skin when initially spawned
gameevent.Listen( "player_spawn" )
hook.Add( "player_spawn", "plrspawned_initial", function(data)
	if Player(data.userid) == LocalPlayer() then
		RunConsoleCommand("playermodel_apply")
		hook.Remove("player_spawn", "plrspawned_initial")
	end
end )

--Death notice drawer
gameevent.Listen( "entity_killed" )
hook.Add( "entity_killed", "entity_killed_hud_drawer", function(data)
	if data.entindex_attacker and data.entindex_killed and Entity(data.entindex_attacker):IsPlayer() then
		GAMEMODE:AddDeathNotice( Entity(data.entindex_attacker):GetName() , nil, data.entindex_inflictor, Entity(data.entindex_killed):GetName() )
	elseif data.entindex_killed then
		GAMEMODE:AddDeathNotice( nil , nil, data.entindex_inflictor, Entity(data.entindex_killed):GetName() )
	end
end )

