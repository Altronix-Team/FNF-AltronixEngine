package altronixengine.states;

import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;

using altronixengine.utils.CoolUtil;

class BaseState extends FlxUIState
{
	public var soundList:FlxTypedGroup<FlxSound> = new FlxTypedGroup<FlxSound>();

	override function update(elapsed:Float)
	{
		// fetch all current sounds being played in the game.
		// idk when i will use this, but i will
		if (soundList.members != FlxG.sound.list.members)
		{
			soundList.clear();
			soundList.fromArray(FlxG.sound.list.members);
		}
		super.update(elapsed);
	}
}
