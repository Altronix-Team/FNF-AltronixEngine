package states;

import scriptStuff.ScriptHelper;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameplayStuff.Boyfriend;
import gameplayStuff.Conductor;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var camFollow:FlxObject;

	public static var stageSuffix:String = "";

	public static var instance:GameOverSubstate;

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.stageCheck;

		super();

		Conductor.songPosition = 0;

		boyfriend = new Boyfriend(x, y, characterName);
		add(boyfriend);

		camFollow = new FlxObject(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound(deathSoundName + stageSuffix));
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
			ScriptHelper.clearAllScripts();
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
				MusicBeatState.switchState(new StoryMenuState());
			}
			/*else if (PlayState.isExtras)
				MusicBeatState.switchState(new SecretState());
			else if (PlayState.fromPasswordMenu)
				MusicBeatState.switchState(new MainMenuState());*/
			else
				MusicBeatState.switchState(new FreeplayState());
			//PlayState.loadRep = false;
			PlayState.stageTesting = false;
			PlayState.isStoryMode = false;
			PlayState.isExtras = false;
			PlayState.fromPasswordMenu = false;
			PlayState.isFreeplay = false;
			ScriptHelper.clearAllScripts();

			if (PlayState.SONG.songId == 'thorns')
			{
				//WindowUtil.resizeWindow(FlxG.initialWidth, FlxG.initialHeight);
				//WindowUtil.setBorderlessWindowed(false);
				if (PlayState.fullscree)
					WindowUtil.setFullscreen(true);
			}
		}

		if (boyfriend.animation.curAnim.name == 'firstDeath' && boyfriend.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (boyfriend.animation.curAnim.name == 'firstDeath' && boyfriend.animation.curAnim.finished)
		{
			if (PlayState.SONG.stage == 'warzone')
				{				
					var exclude:Array<Int> = [];
	
					FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true, function() {
						if(!isEnding)
						{
							FlxG.sound.music.fadeIn(0.2, 1, 4);
						}
					});
				}
			FlxG.sound.playMusic(Paths.music(loopSoundName + stageSuffix));
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
			FlxG.sound.play(Paths.music(endSoundName + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					ScriptHelper.clearAllScripts();
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
