function onEvent(name, value)
	if name == "hitStatic" then
		objectPlayAnimation('static', 'appear', true)
		setObjectCamera('static', 'camHud');
		runTimer('wait', 0.05);
	end
end

function onTimerCompleted(tag, loops, loopsleft)
	if tag == 'wait' then
		doTweenAlpha('byebye', 'static', 0, 0.1, 'linear');
	end
end

function onTweenCompleted(tag)
	if tag == 'byebye' then
		setProperty('static.visible', false)
	end
end