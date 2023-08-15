package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxInput;
import flixel.input.FlxKeyManager;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import gameplayStuff.Conductor;
import gameplayStuff.Highscore;
import gameplayStuff.Ratings;
import gameplayStuff.Section;
import haxe.Exception;
import lime.app.Application;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import options.Options.Option;
import states.LoadingState.LoadingsState;
import states.playState.GameData as Data;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

class ResultsScreen extends FlxSubState
{
	public var background:FlxSprite;
	public var text:FlxText;

	public var anotherBackground:FlxSprite;
	public var graph:HitGraph;
	public var graphSprite:OFLSprite;
	public var graphData:BitmapData;

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

		if (!Data.inResults)
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
		if (Data.isStoryMode)
		{
			score = Data.campaignScore;
			text.text = "Week Cleared!";
		}

		var sicks = Data.isStoryMode ? Data.campaignSicks : Data.sicks;
		var goods = Data.isStoryMode ? Data.campaignGoods : Data.goods;
		var bads = Data.isStoryMode ? Data.campaignBads : Data.bads;
		var shits = Data.isStoryMode ? Data.campaignShits : Data.shits;

		comboText = new FlxText(20, -75, 0,
			'Judgements:\nSicks - ${sicks}\nGoods - ${goods}\nBads - ${bads}\n\nCombo Breaks: ${(Data.isStoryMode ? Data.campaignMisses : Data.misses)}\nHighest Combo: ${Data.highestCombo + 1}\nScore: ${PlayState.instance.songScore}\nAccuracy: ${CoolUtil.truncateFloat(PlayState.instance.accuracy, 2)}%\n\n${Ratings.GenerateLetterRank(PlayState.instance.accuracy)}\nRate: ${Data.songMultiplier}x\n\nF1 - Replay song
        ');
		comboText.size = 28;
		comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		comboText.color = FlxColor.WHITE;
		comboText.scrollFactor.set();
		add(comboText);

		contText = new FlxText(FlxG.width - 475, FlxG.height + 50, 0, 'Press ${Controls.gamepad ? 'A' : 'ENTER'} to continue.');
		contText.size = 28;
		contText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		contText.color = FlxColor.WHITE;
		contText.scrollFactor.set();
		add(contText);

		anotherBackground = new FlxSprite(FlxG.width - 500, 45).makeGraphic(450, 240, FlxColor.BLACK);
		anotherBackground.scrollFactor.set();
		anotherBackground.alpha = 0;
		add(anotherBackground);

		graph = new HitGraph(FlxG.width - 500, 45, 495, 240);
		graph.alpha = 0;

		graphSprite = new OFLSprite(FlxG.width - 510, 45, 460, 240, graph);

		graphSprite.scrollFactor.set();
		graphSprite.alpha = 0;

		add(graphSprite);

		var sicks = CoolUtil.truncateFloat(Data.sicks / Data.goods, 1);
		var goods = CoolUtil.truncateFloat(Data.goods / Data.bads, 1);

		if (sicks == Math.POSITIVE_INFINITY)
			sicks = 0;
		if (goods == Math.POSITIVE_INFINITY)
			goods = 0;

		var mean:Float = 0;

		var curNote:Int = 0;
		for (sect in Data.SONG.notes)
		{
			for (note in sect.sectionNotes)
			{
				// 0 = time
				// 1 = length
				// 2 = type
				// 3 = diff
				var obj = note;
				// judgement
				var obj2 = Data.songJudgements[curNote];

				var obj3 = obj[0];

				var diff = obj[3];
				var judge = obj2;
				if (diff != (166 * Math.floor((Conductor.safeFrames / 60) * 1000) / 166))
					mean += diff;
				if (obj[1] != -1)
					graph.addToHistory(diff / Data.songMultiplier, judge, obj3 / Data.songMultiplier);

				curNote++;
			}
		}

		if (sicks == Math.POSITIVE_INFINITY || sicks == Math.NaN)
			sicks = 0;
		if (goods == Math.POSITIVE_INFINITY || goods == Math.NaN)
			goods = 0;

		graph.update();

		mean = CoolUtil.truncateFloat(mean / Data.songStats.anaArray.length, 2);

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
		FlxTween.tween(anotherBackground, {alpha: 0.6}, 0.5, {
			onUpdate: function(tween:FlxTween)
			{
				graph.alpha = FlxMath.lerp(0, 1, tween.percent);
				graphSprite.alpha = FlxMath.lerp(0, 1, tween.percent);
			}
		});

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

			Data.stageTesting = false;

			#if !switch
			Highscore.saveScore(Data.SONG.songId, Math.round(PlayState.instance.songScore), Data.storyDifficulty);
			Highscore.saveCombo(Data.SONG.songId, Ratings.GenerateLetterRank(PlayState.instance.accuracy), Data.storyDifficulty);
			#end

			if (Data.isStoryMode)
			{
				FlxG.sound.playMusic(Paths.music(Main.save.data.menuMusic));
				Conductor.changeBPM(102);
				MusicBeatState.switchState(new StoryMenuState());
			}
			else
			{
				FlxG.sound.playMusic(Paths.music(Main.save.data.menuMusic));
				MusicBeatState.switchState(new FreeplayState());
			}
			Data.isStoryMode = false;
			Data.isFreeplay = false;
			PlayState.instance.clean();
		}

		if (FlxG.keys.justPressed.F1)
		{
			Data.stageTesting = false;

			#if !switch
			Highscore.saveScore(Data.SONG.songId, Math.round(PlayState.instance.songScore), Data.storyDifficulty);
			Highscore.saveCombo(Data.SONG.songId, Ratings.GenerateLetterRank(PlayState.instance.accuracy), Data.storyDifficulty);
			#end

			if (music != null)
				music.fadeOut(0.3);

			Data.isStoryMode = false;
			Data.storyDifficulty = Data.storyDifficulty;
			LoadingState.loadAndSwitchState(new PlayState());
			PlayState.instance.clean();
		}

		super.update(elapsed);
	}
}
