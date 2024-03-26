package altronixengine.states;

import flash.net.URLRequest;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import altronixengine.gameplayStuff.Character;
import altronixengine.gameplayStuff.Conductor;
import altronixengine.gameplayStuff.Highscore;
import altronixengine.gameplayStuff.Song;
import haxe.Json;
import lime.app.Application;
import openfl.Assets;
import openfl.utils.Assets as OpenFlAssets;
import altronixengine.scriptStuff.HscriptStage;
import altronixengine.states.HscriptableState.PolymodHscriptState;
import altronixengine.core.Alphabet;
import sys.FileSystem;
import sys.io.File;
#if !html5
import sys.thread.Mutex;
#end

class TitleState extends MusicBeatState
{
	public static var songCached:Bool = false;
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	public var muteKeys:Array<FlxKey>;
	public var volumeDownKeys:Array<FlxKey>;
	public var volumeUpKeys:Array<FlxKey>;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var checkVer:Bool = true;

	public function new(?reset:Bool = false)
	{
		if (initialized)
			initialized = !reset;

		super();
	}

	override public function create():Void
	{
		/*@:privateAccess
			{
				Debug.logTrace("We loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets into the default library");
		}*/

		if (!initialized)
		{
			FlxG.autoPause = false;

			PlayerSettings.init();

			EngineData.initAfterGame();

			if (Main.save.data.volDownBind == null)
				Main.save.data.volDownBind = "MINUS";
			if (Main.save.data.volUpBind == null)
				Main.save.data.volUpBind = "PLUS";

			FlxG.sound.muteKeys = [FlxKey.fromString(Main.save.data.muteBind)];
			FlxG.sound.volumeDownKeys = [FlxKey.fromString(Main.save.data.volDownBind)];
			FlxG.sound.volumeUpKeys = [FlxKey.fromString(Main.save.data.volUpBind)];

			muteKeys = [FlxKey.fromString(Main.save.data.muteBind)];
			volumeDownKeys = [FlxKey.fromString(Main.save.data.volDownBind)];
			volumeUpKeys = [FlxKey.fromString(Main.save.data.volUpBind)];

			FlxG.mouse.visible = false;

			FlxG.worldBounds.set(0, 0);

			FlxGraphic.defaultPersist = Main.save.data.cacheImages;

			MusicBeatState.initSave = true;

			Highscore.load();

			if (Main.save.data.volume != null)
				FlxG.sound.volume = Main.save.data.volume;

			if (Main.save.data.weekCompleted != null)
			{
				StoryMenuState.weekCompleted = Main.save.data.weekCompleted;
			}
		}

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		#if !cpp
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#else
		#if (DISCORD_ALLOWED)
		if (!DiscordClient.isInitialized)
		{
			DiscordClient.initialize();
		}
		#end
		startIntro();
		#end
		Debug.logTrace('oh fuck, Altronix Engine is working!');
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		persistentUpdate = true;

		var scriptedStatesList = PolymodHscriptState.listScriptClasses();
		for (state in scriptedStatesList)
		{
			if (state.contains('TitleState'))
			{
				var hscriptState = PolymodHscriptState.init(state);
				FlxG.switchState(hscriptState); // Automatically switches states to hscript variant
			}
		}

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = Main.save.data.antialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		if (Main.watermarks)
		{
			logoBl = new FlxSprite(-10, -200);
			logoBl.frames = Paths.getSparrowAtlas('altronixenginelogobumpin');
		}
		else
		{
			logoBl = new FlxSprite(-150, -100);
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		}
		logoBl.antialiasing = Main.getSaveByString('antialiasing'); // Main.save.data.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = Main.getSaveByString('antialiasing'); // Main.save.data.antialiasing;
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = Main.getSaveByString('antialiasing');
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage('logo'));
		logo.screenCenter();
		logo.antialiasing = Main.getSaveByString('antialiasing');
		// add(logo);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.loadImage('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = Main.getSaveByString('antialiasing');

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music(Main.save.data.menuMusic), 0);
			skipIntro();
		}
		else
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			FlxG.sound.playMusic(Paths.music(Main.save.data.menuMusic), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
			Conductor.changeBPM(102);
			initialized = true;
		}

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:IntroTextFile = cast AssetsUtil.loadAsset('data/introText', JSON);

		var firstArray:Array<IntroText> = fullText.funnyTexts;
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push([i.firstText, i.secondText]);
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
		if (titleTimer > 2)
			titleTimer -= 2;

		if (!pressedEnter && !transitioning && skippedIntro)
		{
			var timer:Float = titleTimer;
			if (timer >= 1)
				timer = (-timer) + 2;

			timer = FlxEase.quadInOut(timer);

			titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
			titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			titleText.color = FlxColor.WHITE;
			titleText.alpha = 1;
			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			MainMenuState.firstStart = true;
			MainMenuState.finishedFunnyMove = false;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.switchState(new MainMenuState());
				clean();
			});
		}

		if (pressedEnter && !skippedIntro && initialized)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');

		switch (curBeat)
		{
			case 0:
				deleteCoolText();
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			case 3:
				addMoreText('present');
			case 4:
				deleteCoolText();
			case 5:
				if (Main.watermarks)
					createCoolText(['Altronix Engine', 'by']);
				else
					createCoolText(['In Partnership', 'with']);
			case 7:
				if (Main.watermarks)
					addMoreText('AltronMaxX');
				else
				{
					addMoreText('Newgrounds');
					ngSpr.visible = true;
				}
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			case 9:
				createCoolText([curWacky[0]]);
			case 11:
				addMoreText(curWacky[1]);
			case 12:
				deleteCoolText();
			case 13:
				addMoreText('Friday');
			case 14:
				addMoreText('Night');
			case 15:
				addMoreText('Funkin');
			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			Debug.logInfo("Skipping intro...");

			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);

			if (!Main.watermarks)
				FlxTween.tween(logoBl, {y: -100}, 1.4, {ease: FlxEase.expoInOut});
			else
				FlxTween.tween(logoBl, {y: -10}, 1.4, {ease: FlxEase.expoInOut});

			logoBl.angle = -4;

			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				if (logoBl.angle == -4)
					FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
				if (logoBl.angle == 4)
					FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
			}, 0);

			FlxG.sound.music.time = 9400;
			FlxG.sound.music.volume = 0.7;

			skippedIntro = true;
		}
	}
}

typedef IntroTextFile =
{
	var funnyTexts:Array<IntroText>;
}

typedef IntroText =
{
	var firstText:String;
	var secondText:String;
}
