package funkin.stages;

import altronixengine.states.GameplayCustomizeState;
import flixel.tweens.FlxTween;
import altronixengine.gameplayStuff.Conductor;
import flixel.util.FlxColor;
import altronixengine.gameplayStuff.BGSprite;

class HalloweenStage extends BaseStage
{
	var halloweenBG:FlxSprite;
	var halloweenWhite:BGSprite;

	override function create()
	{
		halloweenBG = new FlxSprite(-200, -80);
		halloweenBG.frames = Paths.getSparrowAtlas('weeks/assets/week2/images/halloween_bg', 'gameplay');
		halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
		halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
		halloweenBG.animation.play('idle');
		halloweenBG.antialiasing = Main.save.data.antialiasing;
		add(halloweenBG);

		halloweenWhite = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
		halloweenWhite.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.WHITE);
		halloweenWhite.alpha = 0;
		halloweenWhite.blend = ADD;
		add(halloweenWhite);

		add(gfGroup);
		add(dadGroup);
		add(boyfriendGroup);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		if (FlxG.random.bool(Conductor.bpm > 320 ? 100 : 10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			if (Main.save.data.distractions)
			{
				lightningStrikeShit();
				trace('spooky');
			}
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2, 'core'));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if (Main.save.data.camzoom)
		{
			FlxG.camera.zoom += 0.015;
			PlayState.instance.camHUD.zoom += 0.03;

			FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom}, 0.5);
			FlxTween.tween(PlayState.instance.camHUD, {zoom: 1}, 0.5);
		}

		if (PlayState.instance.boyfriend != null)
		{
			PlayState.instance.boyfriend.playAnim('scared', true);
			PlayState.instance.gf.playAnim('scared', true);
		}
		else
		{
			GameplayCustomizeState.boyfriend.playAnim('scared', true);
			GameplayCustomizeState.gf.playAnim('scared', true);
		}

		if (Main.save.data.flashing)
		{
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}
}
