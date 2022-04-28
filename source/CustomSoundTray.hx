package;

import flixel.system.ui.FlxSoundTray;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;

class CustomSoundTray extends FlxSoundTray
{
	/**
	 * Makes the little volume tray slide out.
	 *
	 * @param	Silent	Whether or not it should beep.
	 */
	override public function show(Silent:Bool = false):Void
	{
		if (!Silent)
		{
			var sound = FlxAssets.getSound("sounds/scrollMenu");
			if (sound != null)
				FlxG.sound.load(sound).play();
		}

		_timer = 1;
		y = 0;
		visible = true;
		active = true;
		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

		if (FlxG.sound.muted)
		{
			globalVolume = 0;
		}

		for (i in 0..._bars.length)
		{
			if (i < globalVolume)
			{
				_bars[i].alpha = 1;
			}
			else
			{
				_bars[i].alpha = 0.5;
			}
		}
	}
}