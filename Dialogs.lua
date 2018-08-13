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
            --for enemy1
            --love.graphics.draw(MessageImg, 0, relateWH(0.55))
            --for player1
            --love.graphics.printf(Dialogs:readStr(3,NpcTypeChallengeAnswers).f, 600, 130 ,300,left,0,1.5)
            suit.Label(strNum, relateWH(0.05), relateWH(0.1), relateWH(0.1), relateWH(0.1))
            if strNum == 1 then
                love.graphics.printf(Dialogs:readStr(strNum,NpcTypeChallengeQuestions).f, relateWH(0.275), relateWH(0.55) ,relateWH(0.8))
                Buttons:load(4,1,NpcTypeChallengeAnswers,0,"NPCTypeChallenge_1But_1StrNum")
                if suit.isHit("NPCTypeChallenge_1But_1StrNum") then strNum = 2 end -- first ans button
                Buttons:load(4,2,NpcTypeChallengeAnswers,1,"NPCTypeChallenge_2But_1StrNum")
                if suit.isHit("NPCTypeChallenge_2But_1StrNum") then strNum = 4 end -- second ans button
                Buttons:load(4,3,NpcTypeChallengeAnswers,2,"NPCTypeChallenge_3But_1StrNum")
                if suit.isHit("NPCTypeChallenge_3But_1StrNum") then strNum = 5 end -- third ans button
                if NPCTypeChallengeStoryIsHeard == true then
                    Buttons:load(4,8,NpcTypeChallengeAnswers,3,"NPCTypeChallenge_4But_1StrNum")
                    if suit.isHit("NPCTypeChallenge_4But_1StrNum") then strNum = 12 end -- fourth ans button
                end
            end
            if strNum == 2 then
                love.graphics.printf(Dialogs:readStr(strNum,NpcTypeChallengeQuestions).f, relateWH(0.275), relateWH(0.55) ,relateWH(0.8))
                Buttons:load(4,2,NpcTypeChallengeAnswers,0,"NPCTypeChallenge_1But_2StrNum")
                if suit.isHit("NPCTypeChallenge_1But_2StrNum") then strNum = 4 end -- first ans button
                Buttons:load(4,3,NpcTypeChallengeAnswers,1,"NPCTypeChallenge_2But_2StrNum")
                if suit.isHit("NPCTypeChallenge_2But_2StrNum") then strNum = 5 end -- second ans button
                Buttons:load(4,4,NpcTypeChallengeAnswers,2,"NPCTypeChallenge_3But_2StrNum")
                if suit.isHit("NPCTypeChallenge_3But_2StrNum") then strNum = 3 end -- third ans button
                if NPCTypeChallengeStoryIsHeard == true then
                    Buttons:load(4,8,NpcTypeChallengeAnswers,3,"NPCTypeChallenge_4But_2StrNum")
                    if suit.isHit("NPCTypeChallenge_4But_2StrNum") then strNum = 12 end -- fourth ans button
                end
            end
            if strNum == 3 then
                love.graphics.printf(Dialogs:readStr(strNum,NpcTypeChallengeQuestions).f, relateWH(0.275), relateWH(0.55) ,relateWH(0.8))
                Buttons:load(4,1,NpcTypeChallengeAnswers,0,"NPCTypeChallenge_1But_3StrNum")
                if suit.isHit("NPCTypeChallenge_1But_3StrNum") then strNum = 2 end -- first ans button
                Buttons:load(4,2,NpcTypeChallengeAnswers,1,"NPCTypeChallenge_2But_3StrNum")
                if suit.isHit("NPCTypeChallenge_2But_3StrNum") then strNum = 4 end -- second ans button
                Buttons:load(4,3,NpcTypeChallengeAnswers,2,"NPCTypeChallenge_3But_3StrNum")
                if suit.isHit("NPCTypeChallenge_3But_3StrNum") then strNum = 5 end -- third ans button
            end
            if strNum == 4 then
                love.graphics.printf(Dialogs:readStr(strNum,NpcTypeChallengeQuestions).f, relateWH(0.275), relateWH(0.55) ,relateWH(0.8))
                Buttons:load(4,1,NpcTypeChallengeAnswers,0,"NPCTypeChallenge_1But_4StrNum")
                if suit.isHit("NPCTypeChallenge_1But_4StrNum") then strNum = 2 end -- first ans button
                Buttons:load(4,3,NpcTypeChallengeAnswers,1,"NPCTypeChallenge_2But_4StrNum")
                if suit.isHit("NPCTypeChallenge_2But_4StrNum") then strNum = 5 end -- second ans button
                if NPCTypeChallengeStoryIsHeard == true then
                    Buttons:load(4,8,NpcTypeChallengeAnswers,2,"NPCTypeChallenge_3But_4StrNum")
                    if suit.isHit("NPCTypeChallenge_3But_4StrNum") then strNum = 12 end -- fourth ans button
                end
            end
            if strNum == 5 then
                love.graphics.printf(Dialogs:readStr(strNum,NpcTypeChallengeQuestions).f, relateWH(0.275), relateWH(0.55) ,relateWH(0.8))
                Buttons:load(4,1,NpcTypeChallengeAnswers,0,"NPCTypeChallenge_1But_5StrNum")
                if suit.isHit("NPCTypeChallenge_1But_5StrNum") then strNum = 2 end -- first ans button
                Buttons:load(4,4,NpcTypeChallengeAnswers,1,"NPCTypeChallenge_2But_5StrNum")
                if suit.isHit("NPCTypeChallenge_2But_5StrNum") then strNum = 3 end -- second ans button
                Buttons:load(4,5,NpcTypeChallengeAnswers,2,"NPCTypeChallenge_3But_5StrNum")
                if suit.isHit("NPCTypeChallenge_3But_5StrNum") then strNum = 6 end -- third ans button
            end
            if strNum == 6 then
                love.graphics.printf(Dialogs:readStr(strNum,NpcTypeChallengeQuestions).f, relateWH(0.275), relateWH(0.55) ,relateWH(0.8))
                Buttons:load(4,6,NpcTypeChallengeAnswers,0,"NPCTypeChallenge_1But_6StrNum")
                if suit.isHit("NPCTypeChallenge_1But_6StrNum") then strNum = 7 end -- first ans button
                Buttons:load(4,7,NpcTypeChallengeAnswers,1,"NPCTypeChallenge_2But_6StrNum")
                if suit.isHit("NPCTypeChallenge_2But_6StrNum") then strNum = 11 end -- second ans button
            end
            if strNum == 7 then
                love.graphics.printf(Dialogs:readStr(strNum,NpcTypeChallengeQuestions).f, relateWH(0.275), relateWH(0.55) ,relateWH(0.8))
                Buttons:load(4,6,NpcTypeChallengeAnswers,0,"NPCTypeChallenge_1But_7StrNum")
                if suit.isHit("NPCTypeChallenge_1But_7StrNum") then strNum = 8 end -- first ans button
                Buttons:load(4,7,NpcTypeChallengeAnswers,1,"NPCTypeChallenge_2But_7StrNum")
                if suit.isHit("NPCTypeChallenge_2But_7StrNum") then strNum = 11 end -- second ans button
            end
            if strNum == 8 then
                love.graphics.printf(Dialogs:readStr(strNum,NpcTypeChallengeQuestions).f, relateWH(0.275), relateWH(0.55) ,relateWH(0.8))
                Buttons:load(4,6,NpcTypeChallengeAnswers,0,"NPCTypeChallenge_1But_8StrNum")
                if suit.isHit("NPCTypeChallenge_1But_8StrNum") then strNum = 9 end -- first ans button
                Buttons:load(4,7,NpcTypeChallengeAnswers,1,"NPCTypeChallenge_2But_8StrNum")
                if suit.isHit("NPCTypeChallenge_2But_8StrNum") then strNum = 11 end -- second ans button
            end
            if strNum == 9 then
                love.graphics.printf(Dialogs:readStr(strNum,NpcTypeChallengeQuestions).f, relateWH(0.275), relateWH(0.55) ,relateWH(0.8))
                Buttons:load(4,6,NpcTypeChallengeAnswers,0,"NPCTypeChallenge_1But_9StrNum")
                if suit.isHit("NPCTypeChallenge_1But_9StrNum") then strNum = 10 end -- first ans button
                Buttons:load(4,7,NpcTypeChallengeAnswers,1,"NPCTypeChallenge_2But_9StrNum")
                if suit.isHit("NPCTypeChallenge_2But_9StrNum") then strNum = 11 end -- second ans button
            end
            if strNum == 10 then
                NPCTypeChallengeStoryIsHeard = true
                love.graphics.printf(Dialogs:readStr(strNum,NpcTypeChallengeQuestions).f, relateWH(0.275), relateWH(0.55) ,relateWH(0.8))
                Buttons:load(4,1,NpcTypeChallengeAnswers,0,"NPCTypeChallenge_1But_10StrNum")
                if suit.isHit("NPCTypeChallenge_1But_10StrNum") then strNum = 2 end -- first ans button
                Buttons:load(4,2,NpcTypeChallengeAnswers,1,"NPCTypeChallenge_2But_10StrNum")
                if suit.isHit("NPCTypeChallenge_2But_10StrNum") then strNum = 4 end -- second ans button
                Buttons:load(4,8,NpcTypeChallengeAnswers,2,"NPCTypeChallenge_3But_10StrNum")
                if suit.isHit("NPCTypeChallenge_3But_10StrNum") then strNum = 12 end -- third ans button
            end
            if strNum == 11 then
                love.graphics.printf(Dialogs:readStr(strNum,NpcTypeChallengeQuestions).f, relateWH(0.275), relateWH(0.55) ,relateWH(0.8))
                Buttons:load(4,6,NpcTypeChallengeAnswers,0,"NPCTypeChallenge_1But_11StrNum")
                if suit.isHit("NPCTypeChallenge_1But_11StrNum") then strNum = 10 end -- first ans button
            end
            if strNum == 12 then
                love.graphics.printf(Dialogs:readStr(strNum,NpcTypeChallengeQuestions).f, relateWH(0.275), relateWH(0.55) ,relateWH(0.8))
                Buttons:load(4,9,NpcTypeChallengeAnswers,0,"NPCTypeChallenge_1But_12StrNum")
                if suit.isHit("NPCTypeChallenge_1But_12StrNum") then
                    enemy1.question = false
                end -- first ans button
            end
            if strNum == 13 then
                -- if task isn't complited
                love.graphics.printf(Dialogs:readStr(strNum,NpcTypeChallengeQuestions).f, relateWH(0.275), relateWH(0.55) ,relateWH(0.8))
                Buttons:load(4,9,NpcTypeChallengeAnswers,0,"NPCTypeChallenge_1But_13StrNum")
                if suit.isHit("NPCTypeChallenge_1But_13StrNum") then
                    enemy1.question = false
                end -- first ans button
                -- if task is complited do smthing...
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
                strNum = 13
  	        end
        end


    end
end
