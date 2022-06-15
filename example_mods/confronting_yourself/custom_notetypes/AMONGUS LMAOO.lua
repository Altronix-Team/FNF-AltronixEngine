function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'AMONGUS LMAOO' then 
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'staticNotes');
			
			setPropertyFromGroup('unspawnNotes',i,'noAnimation',true)

			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false); --Miss has penalties
			end
		end
	end
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
	if noteType == 'AMONGUS LMAOO' then
		characterPlayAnim('dad', 'laugh', true);
		setProperty('dad.specialAnim', true);
	end
end


