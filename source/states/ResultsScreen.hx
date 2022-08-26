package states;

import haxe.Exception;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import flixel.system.FlxSound;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;
import states.LoadingState.LoadingsState;
import gameplayStuff.Highscore;
import gameplayStuff.Conductor;

using StringTools;

class ResultsScreen extends FlxSubState
{
	public var background:FlxSprite;
	public var text:FlxText;

	public var comboText:FlxText;
	public var contText:FlxText;
	public var settingsText:FlxText;

	public var music:FlxSound;


	public var ranking:String;
	public var accuracy:String;

	override function create()
	{
		background = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.scrollFactor.set();
		add(background);

		if (!PlayState.inResults)
		{
			music = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
			music.volume = 0;
			music.play(false, FlxG.random.int(0, Std.int(music.length / 2)));
			FlxG.sound.list.add(music);
		}

		background.alpha = 0;

		text = new FlxText(20, -55, 0, "Song Cleared!");
		text.size = 34;
		text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		text.color = FlxColor.WHITE;
		text.scrollFactor.set();
		add(text);

		var score = PlayState.instance.songScore;
		if (PlayState.isStoryMode)
		{
			score = PlayState.campaignScore;
			text.text = "Week Cleared!";
		}

		var sicks = PlayState.isStoryMode ? PlayState.campaignSicks : PlayState.sicks;
		var goods = PlayState.isStoryMode ? PlayState.campaignGoods : PlayState.goods;
		var bads = PlayState.isStoryMode ? PlayState.campaignBads : PlayState.bads;
		var shits = PlayState.isStoryMode ? PlayState.campaignShits : PlayState.shits;

		comboText = new FlxText(20, -75, 0,
			'Judgements:\nSicks - ${sicks}\nGoods - ${goods}\nBads - ${bads}\n\nCombo Breaks: ${(PlayState.isStoryMode ? PlayState.campaignMisses : PlayState.misses)}\nHighest Combo: ${PlayState.highestCombo + 1}\nScore: ${PlayState.instance.songScore}\nAccuracy: ${CoolUtil.truncateFloat(PlayState.instance.accuracy, 2)}%\n\n${Ratings.GenerateLetterRank(PlayState.instance.accuracy)}\nRate: ${PlayState.songMultiplier}x\n\nF1 - Replay song
        ');
		comboText.size = 28;
		comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		comboText.color = FlxColor.WHITE;
		comboText.scrollFactor.set();
		add(comboText);

		contText = new FlxText(FlxG.width - 475, FlxG.height + 50, 0, 'Press ${KeyBinds.gamepad ? 'A' : 'ENTER'} to continue.');
		contText.size = 28;
		contText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		contText.color = FlxColor.WHITE;
		contText.scrollFactor.set();
		add(contText);

		var sicks = CoolUtil.truncateFloat(PlayState.sicks / PlayState.goods, 1);
		var goods = CoolUtil.truncateFloat(PlayState.goods / PlayState.bads, 1);

		if (sicks == Math.POSITIVE_INFINITY)
			sicks = 0;
		if (goods == Math.POSITIVE_INFINITY)
			goods = 0;

		var mean:Float = 0;

		if (sicks == Math.POSITIVE_INFINITY || sicks == Math.NaN)
			sicks = 0;
		if (goods == Math.POSITIVE_INFINITY || goods == Math.NaN)
			goods = 0;

		mean = CoolUtil.truncateFloat(mean, 2);

		settingsText = new FlxText(20, FlxG.height + 50, 0,
			'Mean: ${mean}ms (SICK:${Ratings.timingWindows[3]}ms,GOOD:${Ratings.timingWindows[2]}ms,BAD:${Ratings.timingWindows[1]}ms,SHIT:${Ratings.timingWindows[0]}ms)');
		settingsText.size = 16;
		settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
		settingsText.color = FlxColor.WHITE;
		settingsText.scrollFactor.set();
		add(settingsText);

		FlxTween.tween(background, {alpha: 0.5}, 0.5);
		FlxTween.tween(text, {y: 20}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(comboText, {y: 145}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(contText, {y: FlxG.height - 45}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(settingsText, {y: FlxG.height - 35}, 0.5, {ease: FlxEase.expoInOut});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}

	var frames = 0;

	override function update(elapsed:Float)
	{
		if (music != null)
			if (music.volume < 0.5)
				music.volume += 0.01 * elapsed;

		// keybinds

		if (PlayerSettings.player1.controls.ACCEPT)
		{
			if (music != null)
				music.fadeOut(0.3);

			PlayState.stageTesting = false;

			#if !switch
			Highscore.saveScore(PlayState.SONG.songId, Math.round(PlayState.instance.songScore), PlayState.storyDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateLetterRank(PlayState.instance.accuracy), PlayState.storyDifficulty);
			#end

			if (PlayState.isStoryMode)
			{
				FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)));
				Conductor.changeBPM(102);
				MusicBeatState.switchState(new StoryMenuState());
			}
			else if (PlayState.isExtras)
			{
				FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)));
				MusicBeatState.switchState(new SecretState());
			}
			else if (PlayState.fromPasswordMenu)
			{
				FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)));
				MusicBeatState.switchState(new MainMenuState());
			}
			else
			{
				FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)));
				MusicBeatState.switchState(new FreeplayState());
			}
			PlayState.isStoryMode = false;
			PlayState.isExtras = false;
			PlayState.fromPasswordMenu = false;
			PlayState.isFreeplay = false;
			PlayState.instance.clean();
		}

		if (FlxG.keys.justPressed.F1)
		{
			PlayState.stageTesting = false;

			#if !switch
			Highscore.saveScore(PlayState.SONG.songId, Math.round(PlayState.instance.songScore), PlayState.storyDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateLetterRank(PlayState.instance.accuracy), PlayState.storyDifficulty);
			#end

			if (music != null)
				music.fadeOut(0.3);

			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = PlayState.storyDifficulty;
			LoadingState.loadAndSwitchState(new PlayState());
			PlayState.instance.clean();
		}

		super.update(elapsed);
	}
}
