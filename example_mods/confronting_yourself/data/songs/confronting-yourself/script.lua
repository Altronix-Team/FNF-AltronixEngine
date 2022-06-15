
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
                triggerEvent('Camera Follow Pos',curBeat,'240,400','Camera Follow Pos')
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',curBeat,'360,400','Camera Follow Pos')
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',curBeat,'300,340','Camera Follow Pos')
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',curBeat,'300,460','Camera Follow Pos')
            end
            if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
                triggerEvent('Camera Follow Pos',curBeat,'240,400','Camera Follow Pos')
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
                triggerEvent('Camera Follow Pos',curBeat,'360,400','Camera Follow Pos')
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
                triggerEvent('Camera Follow Pos',curBeat,'300,340','Camera Follow Pos')
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
                triggerEvent('Camera Follow Pos',curBeat,'300,460','Camera Follow Pos')
            end
            if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
                triggerEvent('Camera Follow Pos',curBeat,'300,400','Camera Follow Pos')
            end
            if getProperty('dad.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',curBeat,'300,400','Camera Follow Pos')
            end
        else

            if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos',curBeat,'440,500','Camera Follow Pos')
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',curBeat,'560,500','Camera Follow Pos')
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',curBeat,'500,440','Camera Follow Pos')
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',curBeat,'500,550','Camera Follow Pos')
            end
	    if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',curBeat,'500,500','Camera Follow Pos')
            end
        end
    else
        triggerEvent('Camera Follow Pos',curBeat,'')
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