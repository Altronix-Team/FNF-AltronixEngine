package states;

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
import flixel.graphics.FlxGraphic;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.addons.ui.FlxUIState;
import WeekData;
import gameplayStuff.Conductor;
import gameplayStuff.Song;
import gameplayStuff.Highscore;


class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	static var weekDataJson:Array<Dynamic> = [];
	
	static function weekData():Array<Dynamic>
	{
		return weekDataJson;
	}

	var curDifficulty:Int = 1;

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

	var loadedWeeks:Array<WeekData> = [];

	function unlockWeeks():Array<Bool>
	{		
		var weeks:Array<Bool> = [];
		#if debug
		for (i in 0...weekNames.length)
			weeks.push(true);
		return weeks;
		#end

		weeks.push(true);

		for (i in 0...999)//weekData().length)
		{
			weeks.push(true);
		}
		return weeks;
	}

	override function create()
	{
		
		//weekUnlocked = unlockWeeks();
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;

		PlayState.isStoryMode = true;
		PlayState.currentSong = "bruh";
		PlayState.inDaPlay = false;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music(Main.save.data.menuMusic));
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
		weekbackground.antialiasing = Main.save.data.antialiasing;
		weekbackgroundgenerate(weekBackgrounds[0]);
		add(weekbackground);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		trace("Line 70");

		var num:Int = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);

			loadedWeeks.push(weekFile);
			var weekThing:MenuItem;
			if (weekFile.weekImage != null)
				weekThing= new MenuItem(0, weekbackground.y + 396, weekFile.weekImage);
			else
				weekThing= new MenuItem(0, weekbackground.y + 396, WeekData.weeksList[i]);

			weekThing.y += ((weekThing.height + 20) * num);
			weekThing.targetY = num;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = Main.save.data.antialiasing;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (isLocked)
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = Main.save.data.antialiasing;
				grpLocks.add(lock);
			}
			num++;		
		}

		var firstWeek:WeekData = loadedWeeks[0];
		var charArray:Array<String> = firstWeek.weekCharacters;
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}

		var diffStr:String = firstWeek.difficulties;
		if(diffStr != null) diffStr = diffStr.trim();
		else{
			firstWeek.difficulties = 'Easy, Normal, Hard, Hard P';
			diffStr = firstWeek.difficulties;
		}

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				weekDiffs = diffs;
			}
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = Main.save.data.antialiasing;
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = Main.save.data.antialiasing;
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = Main.save.data.antialiasing;
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
			if (item.targetY == Std.int(0) && !weekIsLocked(loadedWeeks[curWeek].fileName))
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
		if (imageName != '')
			weekbackground.loadGraphic(Paths.image('weekbackgrounds/' + imageName, "core"));
		else
			weekbackground.makeGraphic(FlxG.width, 400, 0xFFF9CF51);
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = !weekIsLocked(loadedWeeks[curWeek].fileName);

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
			PlayState.isStoryMode = false;
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

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				if (grpWeekCharacters.members[1].character != '')
					grpWeekCharacters.members[1].animation.play('confirm');
				stopspamming = true;
			}

			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i]);
			}

			for (i in songArray)
			{
				if (CoolUtil.songDiffs.get(i) == null)
					CoolUtil.songDiffs.set(i, weekDiffs);
			}

			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;
			PlayState.songMultiplier = 1;

			for (i in weekDiffs)
			{
				if (!CoolUtil.difficultyArray.contains(i))
					CoolUtil.difficultyArray.push(i);
			}

			PlayState.storyDifficulty = CoolUtil.difficultyArray.indexOf(diffStr);

			var diff:String = '';
			switch (PlayState.storyDifficulty)
			{
				case 0:
					diff = "-easy";
				case 2:
					diff = "-hard";
				case 3:
					diff = "-hardplus";
				case 1:
					diff = '';
				default:
					diff = "-" + diffStr.toLowerCase();
			}

			PlayState.sicks = 0;
			PlayState.bads = 0;
			PlayState.shits = 0;
			PlayState.goods = 0;
			PlayState.campaignMisses = 0;
			PlayState.SONG = /*Song.conversionChecks(*/Song.loadFromJson(PlayState.storyPlaylist[0], diff)/*)*/;
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
		else 
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	var diffStr:String = '';
	var tweenDifficulty:FlxTween;
	var weekDiffs:Array<String> = [];
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = weekDiffs.length -1;
		if (curDifficulty >= weekDiffs.length)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		diffStr = weekDiffs[curDifficulty];

		var diffToLoad = '';

		switch (diffStr)
		{
			case 'Easy':
				diffToLoad = 'easy';
			case 'Normal':
				diffToLoad = 'normal';
			case 'Hard':
				diffToLoad = 'hard';
			case 'Hard P':
				diffToLoad = 'hardplus';
			default:
				diffToLoad = diffStr.toLowerCase();
		}
		var newImage:FlxGraphic = Paths.loadImage('diffsImages/' + diffToLoad);

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
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		weekDiffs = [];
		
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && !weekIsLocked(loadedWeeks[curWeek].fileName))
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		var diffStr:String = leWeek.difficulties;
		if(diffStr != null) diffStr = diffStr.trim();
		else{
			leWeek.difficulties = 'Easy, Normal, Hard, Hard P';
			diffStr = leWeek.difficulties;
		}

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				weekDiffs = diffs;
			}
		}

		if (weekDiffs.length != 4)
		{
			curDifficulty = 0;
			changeDifficulty();
		}
		else
			changeDifficulty();

		FlxG.sound.play(Paths.sound('scrollMenu'));
		weekbackgroundgenerate(leWeek.weekBackground);
		
		updateText();
	}

	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];

		txtTracklist.text = "Tracks\n";
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i]);
		}

		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	public static function unlockNextWeek(week:Int):Void
	{
		if (week <= 900)//weekData().length - 1 /*&& Main.save.data.weekUnlocked == week*/) // fuck you, unlocks all weeks
		{
			weekUnlocked.push(true);
			trace('Week ' + week + ' beat (Week ' + (week + 1) + ' unlocked)');
		}

		Main.save.data.weekUnlocked = weekUnlocked.length - 1;
		Main.save.flush();
	}
}
