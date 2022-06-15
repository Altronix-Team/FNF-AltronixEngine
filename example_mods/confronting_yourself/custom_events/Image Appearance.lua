function onEvent(name, value)
	if name == "Image Appearance" then
		makeLuaSprite('image', 'EXE', -150, -200);
		addLuaSprite('image', true);
		doTweenColor('hello', 'image', 'FFFFFFFF', 0.5, 'quartIn');
		setObjectCamera('image', 'camHud');
		runTimer('wait', 0.05);
	end
end

function onTimerCompleted(tag, loops, loopsleft)
	if tag == 'wait' then
		doTweenAlpha('byebye', 'image', 0, 0.1, 'linear');
	end
end

function onTweenCompleted(tag)
	if tag == 'byebye' then
		removeLuaSprite('image', true);
	end
end