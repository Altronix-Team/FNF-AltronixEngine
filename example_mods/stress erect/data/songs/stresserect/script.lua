function onBeatHit()
	if curBeat == 352 then
			characterPlayAnim('gf','shoot at tankm',true)
			characterPlayAnim('dad','dies',true)
			setProperty('dad.specialAnim',true)
			setObjectOrder('dadGroup',getObjectOrder('boyfriendGroup')+1)
	end
	if curBeat == 355 then
			characterPlayAnim('gf','idle',true)
	end
end