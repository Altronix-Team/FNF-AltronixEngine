function onCreate()	
	makeAnimationList()
	makeOffsets()
	
	makeAnimatedLuaSprite('gfP', 'characters/Playable GF V2', defaultBoyfriendX - 150, defaultBoyfriendY - 100)
	addAnimationByPrefix('gfP', 'singLEFT', 'GF Left', 24, false)
	addAnimationByPrefix('gfP', 'singDOWN', 'GF Down', 24, false)
	addAnimationByPrefix('gfP', 'singUP', 'GF Up', 24, false)
	addAnimationByPrefix('gfP', 'singRIGHT', 'GF Right', 24, false)
	addAnimationByPrefix('gfP', 'idle', 'GF Idle dance', 24, false)
	addAnimationByPrefix('gfP', 'singLEFTmiss', 'GF Miss Left', 24, false)
	addAnimationByPrefix('gfP', 'singDOWNmiss', 'GF Miss Down', 24, false)
	addAnimationByPrefix('gfP', 'singUPmiss', 'GF Miss Up', 24, false)
	addAnimationByPrefix('gfP', 'singRIGHTmiss', 'GF Miss Right', 24, false)
	
	addLuaSprite('gfP', false)
	
	playAnimation('gfP', 4, false)
end

local danced = false

function goodNoteHit(id, direction, noteType, isSustainNote)
	if noteType == 'plr4' or noteType == 'gfAndBf' then
		playAnimation('gfP', direction, true)
	end
end

function noteMiss(id, dir, ntype, sus)
	if ntype == 'plr4' or ntype == 'gfAndBf' then
		anim = dir + 4
		playAnimation('gfP', anim, true)
	end
end

function onBeatHit()
	if curBeat % 2 == 0 then
		playAnimation('gfP', 4, true)
	end
end 

function onCountdownTick(counter)
	playAnimation('gfP', 4, true)
end

animationsList = {}
offsetsgf = {}

function makeAnimationList()
	animationsList[0] = 'singLEFT';
	animationsList[1] = 'singDOWN';
	animationsList[2] = 'singUP';
	animationsList[3] = 'singRIGHT';
	animationsList[4] = 'idle';
	animationsList[5] = 'singLEFTmiss';
	animationsList[6] = 'singDOWNmiss';
	animationsList[7] = 'singUPmiss';
	animationsList[8] = 'singRIGHTmiss';
end

function makeOffsets()
	offsetsgf[0] = {x = 45, y = -36}; --left
	offsetsgf[1] = {x = -6, y = -75}; --down
	offsetsgf[2] = {x = -60, y = 17}; --up
	offsetsgf[3] = {x = -49, y = -7}; --right
	offsetsgf[4] = {x = -6, y = -1}; --idle
	offsetsgf[5] = {x = 35, y = -18}; -- left miss
	offsetsgf[6] = {x = -42, y = 44}; -- down miss
	offsetsgf[7] = {x = -60, y = 55}; -- up miss
	offsetsgf[8] = {x = -80, y = 22}; -- right miss
end

function playAnimation(character, animId, forced)

	animName = animationsList[animId];
	
	objectPlayAnimation(character, animName, forced);
	setProperty('gfP.offset.x', offsetsgf[animId].x);
	setProperty('gfP.offset.y', offsetsgf[animId].y);
end