-- NPC Implementation --------------------------------------------
npc = {}
npc.__index = Enemy
npc.type = 'enemy'

function npc:init()

	--[[
			there will be one part of behaviour :
			1) movement :
				neutral	= do nothing just moving around
			2) sensor :
				no sensor? just moving around
			3) ...
	]]--

    NpcTypeMerchant = {
		image = NpcMerchantImg,
		imgturn = -1,
		size = 0.028,
		Restitution = 0,
		Friction = 0.09,
		Damage = 0,
		hp = 1,
		Reload = 0,
		mass = 70,

		behaviour = {
			movement_bd = "move",
			movement_ad = "victim",
			sensor = {vision = true, smell = false, noise = true},
			playerdist = 0
		},

		timer = 5,
		Init = nil
		--Collis = nil
	}
end
