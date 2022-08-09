package states;

import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import gameplayStuff.Song.SongData;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import openfl.Lib;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import openfl.utils.Assets as OpenFlAssets;
import gameplayStuff.SongMetadata;
import gameplayStuff.HealthIcon;
import gameplayStuff.Song;
import gameplayStuff.DiffCalc;
import gameplayStuff.Highscore;
import gameplayStuff.DiffOverview;
import gameplayStuff.Conductor;
#if desktop
import DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var songs:Array<SongMetadata> = [];

	var selector:FlxText;

	public static var rate:Float = 1.0;

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var songListen:Bool = false;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var diffCalcText:FlxText;
	var previewtext:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';
	var bg:FlxSprite;
	public var freeplayBgColor:FlxColor;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	private var bgColorArray:Array<Int> = [];
	public var intendedColor:FlxColor;
	var colorTween:FlxTween;

	public static var openedPreview = false;

	public static var songData:Map<String, Array<SongData>> = [];

	var blockInput:Bool = false;

	public static function loadDiff(diff:Int, songId:String, array:Array<SongData>, ?diffStr:String)
	{
		var diffName:String = "";

		switch (diff)
		{
			case 1:
				diffName = "";
			case 2:
				diffName = "-hard";
			case 3:
				diffName = "-hardplus";
			case 0:
				diffName = "-easy";
			default:
				diffName = "-" + diffStr.toLowerCase();
		}

		var curSongData = Song.loadFromJson(songId, diffName);
		if (curSongData == null)
			Debug.displayAlert('ERROR', 'ERROR in Freeplay trying to load song data: ${songId} : ${diffName}');
		else
			array.push(Song.conversionChecks(Song.loadFromJson(songId, diffName)));
	}

	override function create()
	{
		clean();

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)), 0);

		cached = false;

		PlayState.isFreeplay = true;
		PlayState.inDaPlay = false;
		PlayState.currentSong = "bruh";

		#if !FEATURE_STEPMANIA
		trace("FEATURE_STEPMANIA was not specified during build, sm file loading is disabled.");
		#elseif FEATURE_STEPMANIA
		// TODO: Refactor this to use OpenFlAssets.
		trace("tryin to load sm files");
		for (i in FileSystem.readDirectory("assets/sm/"))
		{
			if (FileSystem.isDirectory("assets/sm/" + i))
			{
				trace("Reading SM file dir " + i);
				for (file in FileSystem.readDirectory("assets/sm/" + i))
				{
					if (file.contains(" "))
						FileSystem.rename("assets/sm/" + i + "/" + file, "assets/sm/" + i + "/" + file.replace(" ", "_"));
					if (file.endsWith(".sm") && !FileSystem.exists("assets/sm/" + i + "/converted.json"))
					{
						trace("reading " + file);
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
						trace("Converting " + file.header.TITLE);
						var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
						var meta = new SongMetadata(file.header.TITLE, 0, "sm", file, "assets/sm/" + i);
						songs.push(meta);
						var song = Song.loadFromJsonRAW(data);
						songData.set(file.header.TITLE, [song, song, song]);
					}
					else if (FileSystem.exists("assets/sm/" + i + "/converted.json") && file.endsWith(".sm"))
					{
						trace("reading " + file);
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
						trace("Converting " + file.header.TITLE);
						var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
						var meta = new SongMetadata(file.header.TITLE, 0, "sm", file, "assets/sm/" + i);
						songs.push(meta);
						var song = Song.loadFromJsonRAW(File.getContent("assets/sm/" + i + "/converted.json"));
						trace("got content lol");
						songData.set(file.header.TITLE, [song, song, song]);
					}
				}
			}
		}
		#end

		#if desktop
		// Updating Discord Rich Presence
		if (!FlxG.save.data.language)
			DiscordClient.changePresence("In the Freeplay Menu", null);
		else
			DiscordClient.changePresence("В меню свободной игры", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		persistentUpdate = true;

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.loadImage('menuDesat'));
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		if (!SongMetadata.preloaded)
			populateSongData();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			getCharacterIcon(songs[i].songCharacter);
			var icon:HealthIcon = new HealthIcon(characterIcon);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.65, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.4), 135, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		diffCalcText = new FlxText(scoreText.x, scoreText.y + 66, 0, "", 24);
		diffCalcText.font = scoreText.font;
		add(diffCalcText);

		previewtext = new FlxText(scoreText.x, scoreText.y + 96, 0, "Speed: " + FlxMath.roundDecimal(rate, 2) + "x", 24);
		previewtext.font = scoreText.font;
		add(previewtext);

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song / Press 7 to go to the Charting Menu";
		var size:Int = 16;
		#else
		var leText:String = "Press 7 to go to the Charting Menu.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		text.scrollFactor.set();
		add(text);

		add(scoreText);

		changeSelection();

		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}

	public static var cached:Bool = false;

	var characterIcon:String = '';

	function getCharacterIcon(char:String)
	{	
		if (char != null)
		{
			var jsonData;
			if (OpenFlAssets.exists(Paths.json('characters/${char}')))
				jsonData = Paths.loadJSON('characters/${char}');
			else 
			{
				Debug.logError('Failed to parse JSON data for character ${char}');
				getCharacterIcon('bf');
				return;
			}
	
			var data:CharColor = cast jsonData;
	
			characterIcon = data.characterIcon;
		}
		else
		{
			characterIcon = 'face';
		}
	}
	
	function getCharacterColor()
	{
		if (songs[curSelected].songCharacter != null)
		{
			var jsonData;
			if (OpenFlAssets.exists(Paths.json('characters/${songs[curSelected].songCharacter}')))
				jsonData = Paths.loadJSON('characters/${songs[curSelected].songCharacter}');
			else
			{
				Debug.logError('Failed to parse JSON data for character ${songs[curSelected].songCharacter}');
				freeplayBgColor = FlxColor.fromRGB(0, 0, 0);
				return;
			}

			var data:CharColor = cast jsonData;

			if (data.barColorJson != null && data.barColorJson.length > 2)
				bgColorArray = data.barColorJson;
			freeplayBgColor = FlxColor.fromRGB(bgColorArray[0], bgColorArray[1], bgColorArray[2]);
		}
		else
		{
			freeplayBgColor = FlxColor.fromRGB(0, 0, 0);
		}
	}

	public static function populateSongData()
	{
		cached = false;
		var freeplaySonglist = Paths.loadJSON('freeplaySonglist');

		songData = [];
		songs = [];

		var data:FreeplaySonglist = cast freeplaySonglist;

		var songId:String = '';
		for (week in data.freeplaySonglist)
		{
			if (week.weekDiffs == null)
			{
				var diffs = ['Easy', 'Normal', 'Hard', 'Hard P'];
				addWeek(week.weekSongs, week.weekID, week.weekChar, diffs);
			}
			else
			{
				addWeek(week.weekSongs, week.weekID, week.weekChar, week.weekDiffs);
			}			
		}
		SongMetadata.preloaded = true;
	}

	static function getShitSongID(curDiff:String):Int
	{
		if (songs[curSelected].diffs.contains(curDiff))
		{
			return songs[curSelected].diffs.indexOf(curDiff);
		}
		else
			return 0;
	}

	static function checkExistDiffs(songId:String = 'tutorial', meta:SongMetadata, weekDiffs:Array<String>)
	{
		var diffs = [];
		var diffsThatExist = [];
		#if FEATURE_FILESYSTEM
		diffsThatExist = weekDiffs;
		#else
		diffsThatExist = ["Easy", "Normal", "Hard", "Hard P"];
		#end

		for (i in 0...diffsThatExist.length)
		{
			var diff = diffsThatExist[i];
			switch (diff)
			{
				case 'Easy':
					FreeplayState.loadDiff(0, songId, diffs);
				case 'Normal':
					FreeplayState.loadDiff(1, songId, diffs);
				case 'Hard':
					FreeplayState.loadDiff(2, songId, diffs);
				case 'Hard P':
					FreeplayState.loadDiff(3, songId, diffs);
				default:
					FreeplayState.loadDiff(4, songId, diffs, diff);
			}
		}

		if (CoolUtil.songDiffs.get(songId) == null)
			CoolUtil.songDiffs.set(songId, diffsThatExist);
		
		meta.diffs = diffsThatExist;
									
		songData.set(songId, diffs);
	}

	public static function addSong(songName:String, weekNum:Int, songCharacter:String, weekDiffs:Array<String>)
	{
		var meta = new SongMetadata(songName, weekNum, songCharacter);
		songs.push(meta);
		checkExistDiffs(songName, meta, weekDiffs);
	}


	public static function addWeek(songs:Array<String>, weekNum:Int, songCharacters:Array<String>, weekDiffs:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;

		for (i in weekDiffs)
		{
			if (!CoolUtil.difficultyArray.contains(i))
				CoolUtil.difficultyArray.push(i);
		}

		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num], weekDiffs);

			if (songCharacters.length != 1)
				num++;
		}
	}

	private static var vocals:FlxSound = null;
	var instPlaying:Int = -1;

	public static function destroyFreeplayVocals()
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		comboText.text = combo + '\n';

		if (FlxG.sound.music.volume > 0.8)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;
		var dadDebug = FlxG.keys.justPressed.SIX;
		var charting = FlxG.keys.justPressed.SEVEN;
		var bfDebug = FlxG.keys.justPressed.ZERO;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (!blockInput)
		{
			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					if (songs.length > 1)
						changeSelection(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					if (songs.length > 1)
						changeSelection(1);
				}
				if (gamepad.justPressed.DPAD_LEFT)
				{
					if (songs[curSelected].diffs.length > 1)
						changeDiff(-1);
				}
				if (gamepad.justPressed.DPAD_RIGHT)
				{
					if (songs[curSelected].diffs.length > 1)
						changeDiff(1);
				}
			}

			if (upP)
			{
				if (songs.length > 1)
					changeSelection(-1);
			}
			if (downP)
			{
				if (songs.length > 1)
					changeSelection(1);
			}
		

			if (FlxG.keys.justPressed.SPACE)
			{
				if (!songListen)
				{	
					#if PRELOAD_ALL
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;
					var currentSongData = songData.get(songs[curSelected].songName)[getShitSongID(diffTextStr)];
					PlayState.SONG = currentSongData;
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId, PlayState.SONG.diffSoundAssets));

					FlxG.sound.list.add(vocals);
					FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId, PlayState.SONG.diffSoundAssets), 0.7);
					vocals.play();
					vocals.persist = true;
					vocals.looped = true;
					vocals.volume = 0.7;
					songListen = true;
					#end
				}
				else
				{
					destroyFreeplayVocals();
					FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
					songListen = false;
				}
			}

			if (FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.justPressed.LEFT)
				{
					rate -= 0.05;
					diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[getShitSongID(diffTextStr)])}';
				}
				if (FlxG.keys.justPressed.RIGHT)
				{
					rate += 0.05;
					diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[getShitSongID(diffTextStr)])}';
				}

				if (FlxG.keys.justPressed.R)
				{
					rate = 1;
					diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[getShitSongID(diffTextStr)])}';
				}

				if (rate > 3)
				{
					rate = 3;
					diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[getShitSongID(diffTextStr)])}';
				}
				else if (rate < 0.5)
				{
					rate = 0.5;
					diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[getShitSongID(diffTextStr)])}';
				}

				previewtext.text = "Speed: " + FlxMath.roundDecimal(rate, 2) + "x";
			}
			else
			{
				if (FlxG.keys.justPressed.LEFT)
				{
					if (songs[curSelected].diffs.length > 1)
						changeDiff(-1);
				}
				if (FlxG.keys.justPressed.RIGHT)
				{
					if (songs[curSelected].diffs.length > 1)
						changeDiff(1);
				}
			}

			/*#if cpp
			@:privateAccess
			{
				if (FlxG.sound.music.playing)
					lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, rate);
			}
			#end*/

			if (controls.BACK)
			{
				PlayState.isFreeplay = false;
				FlxG.switchState(new MainMenuState());
			}

			if (accepted)
			{
				destroyFreeplayVocals();
				loadSong();
			}
			else if (charting)
			{
				destroyFreeplayVocals();	
				loadSong(true);
			}
		}
	}

	function loadAnimDebug(dad:Bool = true)
	{
		// First, get the song data.
		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[curDifficulty];
			if (hmm == null)
				return;
		}
		catch (ex)
		{
			return;
		}
		PlayState.SONG = hmm;

		var character = dad ? PlayState.SONG.player2 : PlayState.SONG.player1;

		LoadingState.loadAndSwitchState(new editors.AnimationDebug(character));
	}

	function loadSong(isCharting:Bool = false)
	{
		blockInput = true;
		
		loadSongInFreePlay(songs[curSelected].songName, curDifficulty, isCharting);

		clean();
	}

	/**
 * Load into a song in free play, by name.
 * This is a static function, so you can call it anywhere.
 * @param songName The name of the song to load. Use the human readable name, with spaces.
 * @param isCharting If true, load into the Chart Editor instead.
 */
	public static function loadSongInFreePlay(songName:String, difficulty:Int, isCharting:Bool, reloadSong:Bool = false)
	{
		// Make sure song data is initialized first.
		if (songData == null || Lambda.count(songData) == 0)
			populateSongData();

		diffTextStr = CoolUtil.difficultyFromInt(CoolUtil.difficultyArray.indexOf(songs[curSelected].diffs[difficulty]));

		var currentSongData;
		try
		{
			if (songData.get(songName) == null)
				return;
			currentSongData = songData.get(songName)[difficulty];
			if (songData.get(songName)[difficulty] == null)
				if (songData.get(songName)[getShitSongID(diffTextStr)] == null)
					return;
				else
					currentSongData = songData.get(songName)[getShitSongID(diffTextStr)];
		}
		catch (ex)
		{
			return;
		}	

		PlayState.SONG = currentSongData;
		PlayState.storyDifficulty = CoolUtil.difficultyArray.indexOf(songs[curSelected].diffs[difficulty]);
		PlayState.storyWeek = songs[curSelected].week;
		Debug.logInfo('Loading song ${PlayState.SONG.songName} from week ${PlayState.storyWeek} into Free Play...');
		#if FEATURE_STEPMANIA
		if (songs[curSelected].songCharacter == "sm")
		{
			Debug.logInfo('Song is a StepMania song!');
			PlayState.isSM = true;
			PlayState.sm = songs[curSelected].sm;
			PlayState.pathToSm = songs[curSelected].path;
		}
		else
			PlayState.isSM = false;
		#else
		PlayState.isSM = false;
		#end

		PlayState.songMultiplier = rate;

		if (isCharting)
		{
			LoadingState.loadAndSwitchState(new editors.ChartingState(reloadSong));
		}
		else
		{
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	static var diffTextStr:String = 'Normal';

	function changeDiff(change:Int = 0)
	{
		//if (!songs[curSelected].diffs.contains(CoolUtil.difficultyFromInt(curDifficulty + change)))
			//return;

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = songs[curSelected].diffs.length - 1;
		if (curDifficulty > songs[curSelected].diffs.length - 1)
			curDifficulty = 0;
		
		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
		}

		diffTextStr = CoolUtil.difficultyFromInt(CoolUtil.difficultyArray.indexOf(songs[curSelected].diffs[curDifficulty]));

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, CoolUtil.difficultyArray.indexOf(diffTextStr));
		combo = Highscore.getCombo(songHighscore, CoolUtil.difficultyArray.indexOf(diffTextStr));
		#end

		diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[getShitSongID(diffTextStr)])}';

		diffText.text = CoolUtil.difficultyFromInt(CoolUtil.difficultyArray.indexOf(songs[curSelected].diffs[curDifficulty])).toUpperCase();
	}

	function changeSelection(change:Int = 0)
	{
		if (songs.length > 1)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		if (songs[curSelected].diffs.length != 4)
		{
			curDifficulty = 0;
		}

		getCharacterColor();
		if (freeplayBgColor != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			intendedColor = freeplayBgColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
		}

		diffTextStr = CoolUtil.difficultyFromInt(CoolUtil.difficultyArray.indexOf(songs[curSelected].diffs[curDifficulty]));

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, CoolUtil.difficultyArray.indexOf(diffTextStr));
		combo = Highscore.getCombo(songHighscore, CoolUtil.difficultyArray.indexOf(diffTextStr));
		// lerpScore = 0;
		#end

		diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[getShitSongID(diffTextStr)])}';

		diffText.text = CoolUtil.difficultyFromInt(CoolUtil.difficultyArray.indexOf(songs[curSelected].diffs[curDifficulty])).toUpperCase();

		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[curDifficulty];
			if (hmm != null)
			{
				Conductor.changeBPM(hmm.bpm);
				GameplayCustomizeState.freeplayBf = hmm.player1;
				GameplayCustomizeState.freeplayDad = hmm.player2;
				GameplayCustomizeState.freeplayGf = hmm.gfVersion;
				GameplayCustomizeState.freeplayNoteStyle = hmm.noteStyle;
				GameplayCustomizeState.freeplayStage = hmm.stage;
				GameplayCustomizeState.freeplaySong = hmm.songId;
				GameplayCustomizeState.freeplayWeek = songs[curSelected].week;
			}
		}
		catch (ex)
		{
		}

		if (openedPreview)
		{
			closeSubState();
			openSubState(new DiffOverview());
		}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	public static function createEmptyFile():FreeplaySonglist {
		var testWeek:SongsWithWeekId = 
		{
			weekSongs: ['tutorial'],
			weekChar: ['gf'],
			weekID: 0,
			weekDiffs: ['Easy', 'Normal', 'Hard', 'Hard P']
		};
		var freeplayFile:FreeplaySonglist = {
			freeplaySonglist: [testWeek]
		};
		return freeplayFile;
	}

	override function onWindowFocusOut():Void
	{
		FlxG.sound.music.pause();
		if (songListen)
			vocals.pause();
	}

	override function onWindowFocusIn():Void
	{
		Debug.logTrace("IM BACK!!!");
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		FlxG.sound.music.resume();
		if (songListen)
			vocals.resume();
	}
} 
typedef FreeplaySonglist =
{
	var freeplaySonglist:Array<SongsWithWeekId>;
}

typedef SongsWithWeekId =
{
	var weekSongs:Array<String>;
	var weekChar:Array<String>;
	var weekID:Int;
	var weekDiffs:Array<String>;
}

typedef CharColor =
{
	var barColorJson:Array<Int>;

	var characterIcon:String;
}
