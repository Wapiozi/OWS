-- Buttons Implementation --------------------------------------------
Buttons = {}
Buttons.__index = Buttons
Buttons.type = 'Buttons'

function Buttons:load(but)
  if but==1 then --W A S D buttons
    love.graphics.setColor(255,255,255)
    --but_img = suit.ImageButton(normal,{id=5, mask = mask, hovered = hovered, active = active},plen(0.4),plen(0.4))
    but_a = suit.Button("<-",{id=1, cornerRadius=plen(0.05)} , plen(0.1),plen(0.7), plen(0.15), plen(0.15))
    but_s = suit.Button(" ",{id=2, cornerRadius=plen(0.05)} , plen(0.25),plen(0.7), plen(0.15), plen(0.15))
    but_d = suit.Button("->",{id=3, cornerRadius=plen(0.05)} , plen(0.40),plen(0.7), plen(0.15), plen(0.15))
    but_w = suit.Button("^",{id=4, cornerRadius=plen(0.05)} , plen(0.25),plen(0.55), plen(0.15), plen(0.15))
  end
end

function Buttons:update(but)
  if but==1 then --W A S D buttons
    if (but_d.hit) then
		    player1:moveRight()
		    player1:moveRight()
  	elseif (but_a.hit) then
		    player1:moveLeft()
		    player1:moveLeft()
	  elseif (but_a.left) or (but_d.left) then
		    player1.movDirection = 0
	  end

	  if (but_w.hit) then
		    player1:jump()
	  end
  end
end

function Buttons:draw(but)
  if but==1 then --W A S D buttons
    suit:draw()
  end
end
