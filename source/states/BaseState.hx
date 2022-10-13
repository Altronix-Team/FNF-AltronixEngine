package states;

import flixel.addons.ui.FlxUIState;
import flixel.system.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;

class BaseState extends FlxUIState
{
	public var soundList:FlxTypedGroup<FlxSound> = new FlxTypedGroup<FlxSound>();

    override function update(elapsed:Float) {
		// fetch all current sounds being played in the game.
		// idk when i will use this, but i will
		if (soundList.members != FlxG.sound.list.members)
		{
			soundList.clear();
			soundList.members = FlxG.sound.list.members.copy();
		}
        super.update(elapsed);
    }  
}