package;

import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import LoadingState.LoadingsState;
import flixel.graphics.FlxGraphic;
#if desktop
import DiscordClient;
#end
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.addons.ui.FlxUIState;

using StringTools;

typedef WeekJson =
{
	var weekDataFromJson:Dynamic;
	var weekCharacterFromJson:Dynamic;
	var weekNameFromJson:String;
	var weekBackgroundFromJson:String;
	var weekImageFromJson:String;
	var weekIdFromJson:Int;
}
class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	static var weekDataJson:Array<Dynamic> = [];
	
	static function weekData():Array<Dynamic>
	{
		return weekDataJson;
	}

	var curDifficulty:Int = 2;

	public static var weekUnlocked:Array<Bool> = [];

	static var weekCharacters:Array<Dynamic> = [];
	static var weekNames:Array<String> = [];
	static var weekBackgrounds:Array<String> = [];
	static var weekImages:Array<String> = [];

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var weekbackground:FlxSprite;

	public static function createWeekFile():WeekJson {
		var weekFile:WeekJson = {
			weekDataFromJson: ["bopeebo", "fresh", "dadbattle"],
			weekCharacterFromJson: ['dad', 'bf', 'gf'],
			weekBackgroundFromJson: 'Dad',
			weekIdFromJson: 1,
			weekNameFromJson: 'Daddy Dearest',
			weekImageFromJson: 'week1'
		};
		return weekFile;
	}

	static var defaultWeekFiles:Array<String> = ['tutorial.json', 'week1.json', 'week2.json', 'week3.json', 'week4.json', 'week5.json', 'week6.json', 'week7.json'];
	static var ignoreWeeks:Array<String> = [];
	static function parseStandartWeeks()
	{
		Debug.logTrace("I'm starting");
		weekDataJson = [];
		weekCharacters = [];
		weekNames = [];
		weekBackgrounds = [];
		weekImages = [];
		for (i in defaultWeekFiles)
		{
			var jsonData = Paths.loadWeeksJSON(i);
			if (jsonData == null)
			{
				Debug.logError('Failed to parse JSON data' + i);
				continue;
			}

			var data:WeekJson = cast jsonData;

			Debug.logTrace(data.weekIdFromJson + ' standart weeks pushing');

			weekDataJson.insert(data.weekIdFromJson, data.weekDataFromJson);
			weekCharacters.insert(data.weekIdFromJson, data.weekCharacterFromJson);
			weekNames.insert(data.weekIdFromJson, data.weekNameFromJson);
			weekBackgrounds.insert(data.weekIdFromJson, data.weekBackgroundFromJson);
			weekImages.insert(data.weekIdFromJson, data.weekImageFromJson);
		}
		parseModdedWeeks();
	}

	static var weeksToPush:Array<String> = [];
	static function parseModdedWeeks()
	{
		Debug.logTrace("I'm starting");
		var files = FileSystem.readDirectory(Paths.getPreloadPath('weeks'));
		for (i in files)
		{
			if (defaultWeekFiles.contains(i))
				continue;
			else
				weeksToPush.push(i);

			Debug.logTrace(weeksToPush);
		}
		for (i in weeksToPush)
		{
			var jsonData = Paths.loadWeeksJSON(i);
			if (jsonData == null)
			{
				Debug.logError('Failed to parse JSON data' + i);
				continue;
			}
	
			var data:WeekJson = cast jsonData;
	
			Debug.logTrace(data.weekIdFromJson + ' modded weeks scan');
	
			weekDataJson.insert(data.weekIdFromJson, data.weekDataFromJson);
			weekCharacters.insert(data.weekIdFromJson, data.weekCharacterFromJson);
			weekNames.insert(data.weekIdFromJson, data.weekNameFromJson);
			weekBackgrounds.insert(data.weekIdFromJson, data.weekBackgroundFromJson);
			weekImages.insert(data.weekIdFromJson, data.weekImageFromJson);
		}
	}

	function unlockWeeks():Array<Bool>
	{
		parseStandartWeeks();
		var weeks:Array<Bool> = [];
		#if debug
		for (i in 0...weekNames.length)
			weeks.push(true);
		return weeks;
		#end

		weeks.push(true);

		for (i in 0...weekData().length)
		{
			weeks.push(true);
		}
		return weeks;
	}

	override function create()
	{
		
		weekUnlocked = unlockWeeks();

		PlayState.currentSong = "bruh";
		PlayState.inDaPlay = false;
		#if desktop
		// Updating Discord Rich Presence
		if (!FlxG.save.data.language)
			DiscordClient.changePresence("In the Story Mode Menu", null);
		else
			DiscordClient.changePresence("В сюжетном меню", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				Conductor.changeBPM(102);
			}
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		weekbackground = new FlxSprite(0, 56);
		weekbackground.antialiasing = FlxG.save.data.antialiasing;
		weekbackgroundgenerate(weekBackgrounds[0]);
		add(weekbackground);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		trace("Line 70");

		for (i in 0...weekData().length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, weekImages[i]);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = FlxG.save.data.antialiasing;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				trace('locking week ' + i);
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = FlxG.save.data.antialiasing;
				grpLocks.add(lock);
			}
		}

		trace("Line 96");

		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, weekCharacters[char]);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = FlxG.save.data.antialiasing;
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = FlxG.save.data.antialiasing;
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = FlxG.save.data.antialiasing;
		difficultySelectors.add(rightArrow);

		trace("Line 150");

		//add(yellowBG);

		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		trace("Line 165");

		super.create();
	}

	function weekbackgroundgenerate(imageName:String = 'Tutorial'):Void
	{
		weekbackground.loadGraphic(Paths.image('weekbackgrounds/' + imageName));
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

				if (gamepad != null)
				{
					if (gamepad.justPressed.DPAD_UP)
					{
						changeWeek(-1);
					}
					if (gamepad.justPressed.DPAD_DOWN)
					{
						changeWeek(1);
					}

					if (gamepad.pressed.DPAD_RIGHT)
						rightArrow.animation.play('press')
					else
						rightArrow.animation.play('idle');
					if (gamepad.pressed.DPAD_LEFT)
						leftArrow.animation.play('press');
					else
						leftArrow.animation.play('idle');

					if (gamepad.justPressed.DPAD_RIGHT)
					{
						changeDifficulty(1);
					}
					if (gamepad.justPressed.DPAD_LEFT)
					{
						changeDifficulty(-1);
					}
				}

				if (FlxG.keys.justPressed.UP)
				{
					changeWeek(-1);
				}

				if (FlxG.keys.justPressed.DOWN)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
				{
					changeDifficulty(1);
				}
				if (controls.LEFT_P)
				{
					changeDifficulty(-1);
				}
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				if (grpWeekCharacters.members[1].character != '')
					grpWeekCharacters.members[1].animation.play('confirm');
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData()[curWeek];
			PlayState.isStoryMode = true;
			PlayState.isFreeplay = false;
			PlayState.isExtras = false;
			PlayState.fromPasswordMenu = false;
			selectedWeek = true;
			PlayState.songMultiplier = 1;

			PlayState.isSM = false;

			PlayState.storyDifficulty = curDifficulty;

			var diff:String = ["-easy", "", "-hard", "-hardplus"][PlayState.storyDifficulty];

			PlayState.sicks = 0;
			PlayState.bads = 0;
			PlayState.shits = 0;
			PlayState.goods = 0;
			PlayState.campaignMisses = 0;
			PlayState.SONG = Song.conversionChecks(Song.loadFromJson(PlayState.storyPlaylist[0], diff));
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				openSubState(new LoadingsState());
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 3;
		if (curDifficulty > 3)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		var defaultDifficulties = ['easy', 'normal', 'hard', 'hardplus'];
		var newImage:FlxGraphic = Paths.loadImage('diffsImages/' + defaultDifficulties[curDifficulty]);

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - 15;
	
			if(tweenDifficulty != null) tweenDifficulty.cancel();
			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween)
			{
				tweenDifficulty = null;
			}});
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData().length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData().length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));
		weekbackgroundgenerate(weekBackgrounds[curWeek]);
		
		updateText();
	}

	function updateText()
	{
		for (i in 0...grpWeekCharacters.length)
		{
			grpWeekCharacters.members[i].changeCharacter(weekCharacters[curWeek][i]);
		}

		txtTracklist.text = "Tracks\n";
		var stringThing:Array<String> = weekData()[curWeek];

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}

	public static function unlockNextWeek(week:Int):Void
	{
		if (week <= weekData().length - 1 /*&& FlxG.save.data.weekUnlocked == week*/) // fuck you, unlocks all weeks
		{
			weekUnlocked.push(true);
			trace('Week ' + week + ' beat (Week ' + (week + 1) + ' unlocked)');
		}

		FlxG.save.data.weekUnlocked = weekUnlocked.length - 1;
		FlxG.save.flush();
	}
}
