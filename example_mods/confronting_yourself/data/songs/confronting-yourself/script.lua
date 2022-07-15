
local xx = 300;
local yy = 400;
local xx2 = 500;
local yy2 = 500;
local ofs = 60;
local followchars = true;
local del = 0;
local del2 = 0;


function onUpdate()
	if del > 0 then
		del = del - 1
	end
	if del2 > 0 then
		del2 = del2 - 1
	end
    if followchars == true then
        if mustHitSection == false then
            if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
                cameraFollowPos(240, 400)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
                cameraFollowPos(360,400)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP' then
                cameraFollowPos(300,340)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
                cameraFollowPos(300,460)
            end
            if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
                cameraFollowPos(240,400)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
                cameraFollowPos(360,400)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
                cameraFollowPos(300,340)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
                cameraFollowPos(300,460)
            end
            if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
                cameraFollowPos(300,400)
            end
            if getProperty('dad.animation.curAnim.name') == 'idle' then
                cameraFollowPos(300,400)
            end
        else

            if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
                cameraFollowPos(440,500)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
                cameraFollowPos(560,500)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
                cameraFollowPos(500,440)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
                cameraFollowPos(500,550)
            end
	    if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
                cameraFollowPos(500,500)
            end
        end
    else
        triggerEvent('Camera Follow Pos','')
    end
    
end
function opponentNoteHit(id, direction, noteType, sustain)
    health = getProperty('health')
    if getProperty('health') > 0.3 then
        setProperty('health', health- 0.01);
    end
end

function onCreate()
	setPropertyFromClass('GameOverSubstate', 'characterName', 'sonic');
	setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx');
	setPropertyFromClass('GameOverSubstate', 'loopSoundName', 'gameOver');
	setPropertyFromClass('GameOverSubstate', 'endSoundName', 'gameOverEnd');
end