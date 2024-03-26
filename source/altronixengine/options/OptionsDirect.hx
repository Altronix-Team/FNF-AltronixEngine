package altronixengine.options;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.FlxSprite;

class OptionsDirect extends altronixengine.states.MusicBeatState
{
	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = true;

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(AssetsUtil.loadAsset("menuDesat", IMAGE));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = Main.save.data.antialiasing;
		add(menuBG);

		openSubState(new altronixengine.states.OptionsMenu());
	}
}
