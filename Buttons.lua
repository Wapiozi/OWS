-- Buttons Implementation --------------------------------------------
Buttons = {}
Buttons.__index = Buttons
Buttons.type = 'Buttons'
answerButtons = suit.new()
answerButtons.theme = setmetatable({}, {__index = suit.theme})


questMenuButton = false

function Buttons:load(but,strN,ftxt,numButAns,idButAns)
    suit.theme.color = {
        normal  = {bg = {0, 255, 1, 0.5}, fg = {0,0,0}},
        hovered = {bg = {0, 255, 1, 0.5}, fg = {0,0,0}},
        active  = {bg = {0, 0, 255}, fg = {0,0,0}}
    }
    answerButtons.layout:reset()
    answerButtons.theme.color = {
        normal  = {bg = {255, 0, 0, 0.5}, fg = {0,0,0}},
        hovered = {bg = {255, 0, 1}, fg = {0,0,0}},
        active  = {bg = {255, 0, 0}, fg = {0,0,0}}
    }
    if but==1 then --W A S D buttons
        --love.graphics.setColor(255,255,255)
        --but_img = suit.ImageButton(normal,{id=5, mask = mask, hovered = hovered, active = active},relateWH(0.4),relateWH(0.4))
        if DialogIsOn == true then slash = 0.15 else slash = 0 end
        but_a = suit.Button("<-",{id=1, cornerRadius=relateWH(0.05)} , relateWH(0.1),relateWH(0.5-slash), relateWH(0.1), relateWH(0.1))
        but_s = suit.Button(" ",{id=2, cornerRadius=relateWH(0.05)} , relateWH(0.2),relateWH(0.5-slash), relateWH(0.1), relateWH(0.1))
        but_d = suit.Button("->",{id=3, cornerRadius=relateWH(0.05)} , relateWH(0.3),relateWH(0.5-slash), relateWH(0.1), relateWH(0.1))
        but_w = suit.Button("^",{id=4, cornerRadius=relateWH(0.05)} , relateWH(0.2),relateWH(0.4-slash), relateWH(0.1), relateWH(0.1))
    end
    if but==2 then --It's QUEST MENU, Bae!
        but_menu = suit.Button("It's quest-MENU, bitch, press this button", relateWH(0.95),relateWH(0.1), relateWH(0.5), relateWH(0.025))
    end
    if but==3 then --It's also part of QUEST
        lab_menu = suit.Label("Mathafaka Mathafaka Mathafaka",relateWH(0.85),relateWH(0.2), relateWH(0.5), relateWH(0.025))
    end
    if but==4 then --It's for conversations
        --suit.theme.color.normal.fg = {0,0,0}
        --suit.theme.color.normal.bg = {255,0,0}
        suit.Button(Dialogs:readStr(strN,ftxt).f, {id = idButAns, font = fontEd, valign = "top", color = answerButtons.theme.color}, relateWH(0.5+0.15*numButAns),relateWH(0.45), relateWH(0.15), relateWH(0.075))
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
    --answerButtons:draw()
  end
end
