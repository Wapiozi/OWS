Item = {}
Item.__index = Item

function Item:init() 
	WandObj{
		image = WandSdImg
		size = 10
		mass = 1
		init = nil
	}
	ClothObj{

	}
	-- more to add
end

function Item:new(x, y, itemID)

	
end