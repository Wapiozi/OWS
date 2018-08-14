-----------Dialogs-----------------------------------------------------
Dialogs = {}
Dialogs.__index = Dialogs
Dialogs.type = 'Dialogs'
strCount = 1
outf = {f = ''}
strNum = 1
DialogIsOn = false
NPCTypeChallengeStoryIsHeard = false

function Dialogs:readStr(str,diaTxt)
    file = io.open(diaTxt, "r")
    io.input(file)
    --strCount = strCount + 1

    while strCount<str do
        t = file:read()
        strCount = strCount + 1
    end
    --[[  t = file:read(1)
    if t ~= nil and t ~= "\n" then
        outf.f = outf.f .. t
        io.input(file)
    end
    if t == "\n" then
        strCount = strCount + 1
        if strCount > str then
            outf.stop = 1
        end
    end
    --]]
    outf.f = file:read()
    file.close()
    strCount = 1
    --create button prodolzhitj
    return outf
end

function Dialogs:startConversation(enemy1)
    if enemy1.type.name == "EnemyTypeBat" then

    end
    if enemy1.type.name == "EnemyTypeRat" then

    end
    if enemy1.type.name == "EnemyTypeMadwizard" then

    end
    if enemy1.type.name == "NpcTypeMerchant" then

    end
    if enemy1.type.name == "NpcTypeChallenge" then
        if enemy1.question == true then
            DialogIsOn = true
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(MessageFromNpcImg, 0, relateWH(0.43), 0, MessageFromNpc.scale, MessageFromNpc.scale)
            suit.Label(strNum, relateWH(0.05), relateWH(0.1), relateWH(0.1), relateWH(0.1))
            stringFromFile = Dialogs:readStr(strNum,NPCTypeChallengeDialog).f
            numberOfAns = Dialogs:readStr(strNum+1,NPCTypeChallengeDialog).f
            love.graphics.printf(stringFromFile, relateWH(0.275), relateWH(0.55) ,relateWH(0.8))
            for i = 1,tonumber(numberOfAns) do
                Buttons:load(4,strNum+(i*2),NPCTypeChallengeDialog,i-1,strNum..i)
                local newStrNum = Dialogs:readStr(strNum+1+(i*2),NPCTypeChallengeDialog).f
                if suit.isHit(strNum..i) then
                    if newStrNum == "STOPTHISSHITTIMETOEXIT" then
                        enemy1.question = false
                        break
                    end
                    strNum = tonumber(newStrNum)
                end
            end
        else
            DialogIsOn = false
            local x1, y1 = enemy1.body:getPosition()
            x1 = x1 - camera._x
            y1 = y1 - camera._y
            suit.Label(Dialogs:readStr(randForPhrase,NpcTypeChallengeCommonPhrases).f, {color = commonPhrasesLabels.theme.color}, x1-relateWH(0.145), y1-relateWH(0.2), relateWH(0.3), relateWH(0.2))
            suit.Button("talk", {color = answerButtons.theme.color}, x1+relateWH(0.05), y1, relateWH(0.08), relateWH(0.04))
            if suit.isHit("talk") then
                enemy1.question = true
  	        end
        end


    end
end
