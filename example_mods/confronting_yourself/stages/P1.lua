function onCreate()
	-- background shit

	makeAnimatedLuaSprite('Bg','Bg',-600, -300)
	addAnimationByPrefix('Bg', 'idle','Bg',20,true)
	objectPlayAnimation('Bg','idle',false)
	setScrollFactor('Bg', 0.9, 0.9);
	
	makeAnimatedLuaSprite('Mountains','Mountains',-600, -300)
	addAnimationByPrefix('Mountains', 'idle','Mountains',32,true)
	objectPlayAnimation('Mountains','idle',false)
	setScrollFactor('Mountains', 0.9, 0.9);
	
	makeAnimatedLuaSprite('Floor','Floor',-650, -200)
	addAnimationByPrefix('Floor', 'idle','Floor',24,true)
	objectPlayAnimation('Floor','idle',false)
	scaleObject('Floor', 1.1, 1.1);

	
	addLuaSprite('Bg', false);
	addLuaSprite('Mountains', false);
	addLuaSprite('Floor', false);
	

	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end