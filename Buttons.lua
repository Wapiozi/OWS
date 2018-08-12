-- Buttons Implementation --------------------------------------------
Buttons = {}
Buttons.__index = Buttons
Buttons.type = 'Buttons'

questMenuButton = false

function Buttons:load(but,strN,ftxt,numButAns,idButAns)
  if but==1 then --W A S D buttons
    --love.graphics.setColor(255,255,255)
    --but_img = suit.ImageButton(normal,{id=5, mask = mask, hovered = hovered, active = active},plen(0.4),plen(0.4))
    but_a = suit.Button("<-",{id=1, cornerRadius=plen(0.05)} , plen(0.1),plen(0.5), plen(0.15), plen(0.15))
    but_s = suit.Button(" ",{id=2, cornerRadius=plen(0.05)} , plen(0.25),plen(0.5), plen(0.15), plen(0.15))
    but_d = suit.Button("->",{id=3, cornerRadius=plen(0.05)} , plen(0.40),plen(0.5), plen(0.15), plen(0.15))
    but_w = suit.Button("^",{id=4, cornerRadius=plen(0.05)} , plen(0.25),plen(0.35), plen(0.15), plen(0.15))
  end
  if but==2 then --It's QUEST MENU, Bae!
    but_menu = suit.Button("It's quest-MENU, bitch, press this button", plen(0.95),plen(0.1), plen(0.5), plen(0.025))
  end
  if but==3 then --It's also part of QUEST
    lab_menu = suit.Label("Mathafaka Mathafaka Mathafaka",plen(0.85),plen(0.2), plen(0.5), plen(0.025))
  end
  if but==4 then --It's for conversations
    --suit.theme.color.normal.fg = {0,0,0}
    --suit.theme.color.normal.bg = {255,0,0}
    suit.Button(Dialogs:readStr(strN,ftxt).f, {id = idButAns}, plen(0.65+0.25*numButAns),plen(0.6), plen(0.25), plen(0.075))
    --suit.theme.color.normal.bg = {0,255,0}
    --suit.theme.color.normal.fg = {255,255,255}
  end
end

function Buttons:update(but)
  --suit.theme.color.normal.bg = {0,255,0}
  --suit.theme.color.normal.fg = {255,255,255}
  if but==1 then --W A S D buttons
    if suit.isActive(3) then
        player1:moveRight()
        player1:moveRight()
    elseif suit.isActive(1) then
        player1:moveLeft()
        player1:moveLeft()
	  elseif (not love.keyboard.isDown("a")) and (not love.keyboard.isDown("d")) then
		    player1.movDirection = 0
	  end

	  if suit.isHit(4) then
		    player1:jump()
	  end
  end

  if but==2 then --It's QUEST MENU, Bae!
    if but_menu.hit then
      if questMenuButton then
  			questMenuButton = false
  		elseif not questMenuButton then
  			questMenuButton = true
  		end
    end
    if questMenuButton == true then
      Buttons:load(3)
    end
  end
end

function Buttons:draw(but)
  if but==1 then --W A S D buttons
    suit:draw()
  end
end
