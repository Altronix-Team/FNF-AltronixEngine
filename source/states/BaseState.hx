package states;

import flixel.addons.ui.FlxUIState;
import flixel.system.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;

class BaseState extends FlxUIState
{
	public static var soundList(default, null):FlxTypedGroup<FlxSound> = new FlxTypedGroup<FlxSound>();

    override function update(elapsed:Float) {
		// fetch all current sounds being played in the game.
		// idk when i will use this, but i will
		if (soundList.members != FlxG.sound.list.members)
		{
			soundList.clear();
			for (sound in FlxG.sound.list.members)
				soundList.add(sound);
		}
        super.update(elapsed);
    }
    
}