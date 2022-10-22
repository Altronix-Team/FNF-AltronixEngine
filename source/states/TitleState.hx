package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
#if !html5
import sys.thread.Mutex;
#end
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import flixel.input.keyboard.FlxKey;
#if desktop
import GameJolt.GameJoltAPI;
#end
import openfl.utils.Assets as OpenFlAssets;
import flash.net.URLRequest;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMath;
import gameplayStuff.Character;
import gameplayStuff.Conductor;
import gameplayStuff.Highscore;
import gameplayStuff.Song;

#if FEATURE_MODCORE
import ModCore;
#end

#if desktop
import DiscordClient;
#end

using StringTools;
using hx.strings.Strings;

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

	var modsToLoad = [];
	public static var configFound = false;

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

			if (FlxG.save.data.volDownBind == null)
				FlxG.save.data.volDownBind = "MINUS";
			if (FlxG.save.data.volUpBind == null)
				FlxG.save.data.volUpBind = "PLUS";

			FlxG.sound.muteKeys = [FlxKey.fromString(FlxG.save.data.muteBind)];
			FlxG.sound.volumeDownKeys = [FlxKey.fromString(FlxG.save.data.volDownBind)];
			FlxG.sound.volumeUpKeys = [FlxKey.fromString(FlxG.save.data.volUpBind)];

			muteKeys = [FlxKey.fromString(FlxG.save.data.muteBind)];
			volumeDownKeys = [FlxKey.fromString(FlxG.save.data.volDownBind)];
			volumeUpKeys = [FlxKey.fromString(FlxG.save.data.volUpBind)];

			FlxG.mouse.visible = false;

			FlxG.worldBounds.set(0, 0);

			FlxGraphic.defaultPersist = FlxG.save.data.cacheImages;

			MusicBeatState.initSave = true;

			Highscore.load();

			#if FEATURE_MODCORE
				modsToLoad = ModCore.getConfiguredMods();
				configFound = (modsToLoad != null && modsToLoad.length > 0);
				if (configFound)
					ModCore.loadConfiguredMods();
			#else
				configFound = false;	
			#end

			NoteskinHelpers.updateNoteskins();

			MenuMusicStuff.updateMusic();

			Character.initCharacterList();

			LanguageStuff.initLanguages();

			#if desktop
			GameJoltAPI.leaderboardToggle = FlxG.save.data.toggleLeaderboard;

			GameJoltAPI.connect();
			GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);
			#end

			//cacheSongs();

			if (FlxG.save.data.volume != null)
				FlxG.sound.volume = FlxG.save.data.volume;

			if (FlxG.save.data.weekCompleted != null)
			{
				StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
			}

		}

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		clean();
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		clean();
		#else
		#if !cpp
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#else
		#if (!debug && desktop)
		if (!DiscordClient.isInitialized)
		{
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
		}
		#end
		startIntro();
		#end
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

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = FlxG.save.data.antialiasing;
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
		logoBl.antialiasing = FlxG.save.data.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = FlxG.save.data.antialiasing;
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = FlxG.save.data.antialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage('logo'));
		logo.screenCenter();
		logo.antialiasing = FlxG.save.data.antialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

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
		ngSpr.antialiasing = FlxG.save.data.antialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)), 0);
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

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
			Conductor.changeBPM(102);
			initialized = true;
		}

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('data/introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
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
		if (titleTimer > 2) titleTimer -= 2;

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
				if (checkVer)
				{
					//var shit = new URLRequest('https://raw.githubusercontent.com/AltronMaxX/FNF-AltronixEngine/main/version.downloadMe?token=GHSAT0AAAAAABHIQ6SYP4VDYY65FVGRVZ3EYU5R3BA');
					//Debug.logTrace(shit.data);
					FlxG.switchState(new MainMenuState());
						clean();
					
					/*http.onData = function(data:String)
					{
						returnedData[0] = data.substring(0, data.indexOf(';'));
						returnedData[1] = data.substring(data.indexOf('-'), data.length);
						if (EngineConstants.engineVer != returnedData[0].trim() && !OutdatedSubState.leftState)
						{
							trace('outdated lmao! ' + returnedData[0] + ' != ' + EngineConstants.engineVer);
							OutdatedSubState.needVer = returnedData[0];
							OutdatedSubState.currChanges = returnedData[1];
							FlxG.switchState(new OutdatedSubState());
							clean();
						}
						else
						{
							FlxG.switchState(new MainMenuState());
							clean();
						}
					}

					http.onError = function(error)
					{
						trace('error: $error');
						FlxG.switchState(new MainMenuState()); // fail but we go anyway
						clean();
					}

					http.request();*/
				}
				else
				{
					FlxG.switchState(new MainMenuState());
						clean();
				}
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
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

	function cacheSongs()
	{
		Debug.logInfo('Starting to cache songs');

		var songList:Array<String> = Paths.listSongsToCache();
		
		for (i in songList)
		{
			var songJsons:Array<SongData> = [];
			var list = Paths.listJsonInPath('assets/data/songs/' + i + '/');
			for (j in list)
			{
				if (j == '_meta')
					continue;
				if (j == 'events')
					continue;

				var diffName = '';

				if (j != i)
				{
					diffName = j.replaceAll(i + '-', '');
				}

				if (Song.loadFromJson(i, diffName) != null)
				{
					songJsons.push(Song.conversionChecks(Song.loadFromJson(i, diffName)));
				}
			}
			if (songJsons.length > 0)
			{
				Caching.songJsons.set(i, songJsons);
			}
		}
	}
}
