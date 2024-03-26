package altronixengine.gameplayStuff;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import altronixengine.states.playState.PlayState;

class CutsceneHandler extends FlxBasic
{
	public var timedEvents:Array<Dynamic> = [];
	public var finishCallback:Void->Void = null;
	public var finishCallback2:Void->Void = null;
	public var onStart:Void->Void = null;
	public var endTime:Float = 0;
	public var objects:Array<FlxSprite> = [];
	public var music:String = null;
	public var assetLibrary:String = "gameplay";
	public var sounds:Array<FlxSound> = [];
	public var tweens:Array<FlxTween> = [];

	public function new()
	{
		super();

		timer(0, function()
		{
			if (music != null)
			{
				FlxG.sound.playMusic(Paths.getPath(music + '.${Paths.SOUND_EXT}', MUSIC, assetLibrary), 0, false);
				FlxG.sound.music.fadeIn();
			}
			if (onStart != null)
				onStart();
		});
		PlayState.instance.add(this);
	}

	private var cutsceneTime:Float = 0;
	private var firstFrame:Bool = false;

	override function update(elapsed)
	{
		super.update(elapsed);

		if (FlxG.state != PlayState.instance || !firstFrame)
		{
			firstFrame = true;
			return;
		}

		cutsceneTime += elapsed;
		if (endTime <= cutsceneTime)
		{
			if (finishCallback != null)
				finishCallback();
			if (finishCallback2 != null)
				finishCallback2();

			for (spr in objects)
			{
				spr.kill();
				PlayState.instance.remove(spr);
				spr.destroy();
			}

			kill();
			destroy();
			PlayState.instance.remove(this);
		}

		if (PlayerSettings.player1.controls.ACCEPT)
		{
			finishCallback();
			if (finishCallback2 != null)
				finishCallback2();

			for (spr in objects)
			{
				spr.kill();
				PlayState.instance.remove(spr);
				spr.destroy();
			}

			for (sound in sounds)
			{
				if (sound.playing)
					sound.stop();
			}

			for (twn in tweens)
			{
				if (twn.active)
					twn.cancel();
			}

			kill();
			destroy();
			PlayState.instance.remove(this);
		}

		while (timedEvents.length > 0 && timedEvents[0][0] <= cutsceneTime)
		{
			timedEvents[0][1]();
			timedEvents.splice(0, 1);
		}
	}

	public function push(spr:FlxSprite)
	{
		objects.push(spr);
	}

	public function timer(time:Float, func:Void->Void)
	{
		timedEvents.push([time, func]);
		timedEvents.sort(sortByTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}
}
