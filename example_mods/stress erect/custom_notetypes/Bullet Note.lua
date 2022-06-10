function onCreate()
	for i = 0,getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Bullet Note' then
			setPropertyFromGroup('unspawnNotes',i,'noAnimation',true)
		end
	end
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
	if noteType == 'Bullet Note' then
		characterPlayAnim('gf','shoot at tankm',true)
		characterPlayAnim('dad','dodge',true)
	end
end
