singDir = {'LEFT', 'DOWN', 'UP', 'RIGHT'}

function opponentNoteHit(id, direction, noteType, isSustainNote)
	-- Works the same as goodNoteHit, but for Opponent's notes being hit
	if noteType == 'GF and Dad Sing' then
		for i = 0,3,1 do
			j = i + 1
			if direction == i then
				characterPlayAnim('gf','sing'..singDir[j],true)
			end
		end
	end
end
