package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	public static var instance:GameOverSubstate;

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.Stage.curStage;
		var daBf:String = '';
		switch (PlayState.instance.boyfriend.curCharacter)
		{
			case 'bf-pixel':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'bfAndGF':
				daBf = 'bfAndGF-DEAD';
			default:
				daBf = 'bf';
		}

		super();

		Conductor.songPosition = 0;

		boyfriend = new Boyfriend(x, y, daBf);
		add(boyfriend);

		camFollow = new FlxObject(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');
	}

	var startVibin:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (FlxG.save.data.InstantRespawn)
		{
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
			{
				GameplayCustomizeState.freeplayBf = 'bf';
				GameplayCustomizeState.freeplayDad = 'dad';
				GameplayCustomizeState.freeplayGf = 'gf';
				GameplayCustomizeState.freeplayNoteStyle = 'normal';
				GameplayCustomizeState.freeplayStage = 'stage';
				GameplayCustomizeState.freeplaySong = 'bopeebo';
				GameplayCustomizeState.freeplayWeek = 1;
				FlxG.switchState(new StoryMenuState());
			}
			else if (PlayState.isExtras)
				FlxG.switchState(new SecretState());
			else
				FlxG.switchState(new FreeplayState());
			PlayState.loadRep = false;
			PlayState.stageTesting = false;
		}

		if (boyfriend.animation.curAnim.name == 'firstDeath' && boyfriend.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (boyfriend.animation.curAnim.name == 'firstDeath' && boyfriend.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			startVibin = true;
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (startVibin && !isEnding)
		{
			boyfriend.playAnim('deathLoop', true);
		}
		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			PlayState.startTime = 0;
			isEnding = true;
			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
					PlayState.stageTesting = false;
				});
			});
		}
	}
	override function onWindowFocusOut():Void
	{
		FlxG.sound.pause();
	}

	override function onWindowFocusIn():Void
	{
		FlxG.sound.resume();
	}
}
