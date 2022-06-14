function onCreate()
	for i = 0,getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'plr4' then
			setPropertyFromGroup('unspawnNotes',i,'noAnimation',true)
		end
	end
end
