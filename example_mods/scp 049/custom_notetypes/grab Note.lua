function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'grab Note' then --Check if the note on the chart is a Bullet Note
			setPropertyFromGroup('unspawnNotes', i, 'texture', '049NOTE');

			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true);
			end
		end
	end
end

function goodNoteHit(a, b, c, d)
	if c == 'grab Note' then
		setProperty('health', 0)
	end
end