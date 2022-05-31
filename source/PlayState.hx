package;

import flixel.util.FlxSpriteUtil;
import lime.media.openal.AL;
import Song.Event;
import openfl.media.Sound;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.io.File;
import Sys;
import sys.FileSystem;
#end
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SongData;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import GameJolt.GameJoltAPI;
import FunkinLua;
import flixel.util.FlxSave;
import DialogueBoxPsych;
import StageData;
import openfl.utils.Assets as OpenFlAssets;
import flixel.group.FlxSpriteGroup;
import Replay.Ana;
import Replay.Analysis;
import animateatlas.AtlasFrameMaker;
import hscript.Expr;
import hscript.Parser;
import hscript.Interp;
#if desktop
import DiscordClient;
#end

using StringTools;
using hx.strings.Strings;

@:hscript(SONG, setHealth)
class PlayState extends MusicBeatState implements polymod.hscript.HScriptable
{
	public static var instance:PlayState = null;

	public static var SONG:SongData;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public var timerCount:Float = 0;
	public var maxTimerCounter:Float = 200;

	public static var songPosBG:FlxSprite;

	public var visibleCombos:Array<FlxSprite> = [];

	public var addedBotplay:Bool = false;

	public var visibleNotes:Array<Note> = [];

	public static var songPosBar:FlxBar;

	public var noteType:Dynamic = 0;

	public static var noteskinSprite:FlxAtlasFrames;
	public static var noteskinPixelSprite:BitmapData;
	public static var noteskinPixelSpriteEnds:BitmapData;

	public static var inResults:Bool = false;

	public static var inDaPlay:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var songLength:Float = 0;
	var engineWatermark:FlxText;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var vocals:FlxSound;

	public static var isSM:Bool = false;
	#if FEATURE_STEPMANIA
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	public var cameraSpeed:Float = 1;

	private static var prevCamFollow:FlxObject;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public var strumLineNotes:FlxTypedGroup<StaticArrow> = null;
	public var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public var cpuStrums:FlxTypedGroup<StaticArrow> = null;

	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var stageGroup:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	public static var isFreeplay:Bool = false;
	public static var isExtras:Bool = false;
	public static var fromPasswordMenu:Bool = false;

	private var gfSpeed:Int = 1;

	public var health:Float = 1;

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;

	public var camGame:FlxCamera;

	public var cannotDie = false;
	public var isDead:Bool = false;

	public static var offsetTesting:Bool = false;

	public var isSMFile:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)
	var forcedToIdle:Bool = false; // change if bf and dad are forced to idle to every (idleBeat) beats of the song
	var allowedToHeadbang:Bool = true; // Will decide if gf is allowed to headbang depending on the song
	var allowedToCheer:Bool = false; // Will decide if gf is allowed to cheer depending on the song

	public var dialogueeng:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];
	public var dialogueru:Array<String> = ['dad:жопа', 'bf:пизда'];
	var dialogueJson:DialogueFile = null;

	var overlay:ModchartSprite;
	var overlayColor:FlxColor = 0xFFFF0000;
	var colorTween:FlxTween;

	var songName:FlxText;

	var altSuffix:String = "";

	public var currentSection:SwagSection;

	var fc:Bool = true;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public static var currentSong = "noneYet";

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var judgementCounter:FlxText;

	var needSkip:Bool = false;
	var skipActive:Bool = false;
	var skipText:FlxText;
	var skipTo:Float;

	public static var campaignScore:Int = 0;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	public static var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	var shoot:Bool = false;

	public static var stageTesting:Bool = false;

	var camPos:FlxPoint;

	public var randomVar = false;

	public static var Stage:Stage;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	//Psych Engine Stuff
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	public var luaArray:Array<FunkinLua> = [];
	public var defaultCamZoom:Float = 1.05;
	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;
	public static var seenCutscene:Bool = false;
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;
	public static var ratingStuff:Array<Dynamic> = [];
	private var timeBarBG:AttachedSprite;
	var timeTxt:FlxText;
	public var timeBar:FlxBar;
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end
	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public var hideGF:Bool;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];

	public static var highestCombo:Int = 0;

	public var executeModchart = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	var dadTrail:FlxTrail;
	var gfTrail:FlxTrail;
	var bfTrail:FlxTrail;

	public var allowToAttack:Bool = false;

	var gfAltAnim:Bool = false;
	var bfAltAnim:Bool = false;
	var dadAltAnim:Bool = false;

	var luaStage = false;

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	override public function create()
	{
		//buildPlayStateHooks();
		FlxG.mouse.visible = false;
		instance = this;

		// grab variables here too or else its gonna break stuff later on
		GameplayCustomizeState.freeplayBf = SONG.player1;
		GameplayCustomizeState.freeplayDad = SONG.player2;
		GameplayCustomizeState.freeplayGf = SONG.gfVersion;
		GameplayCustomizeState.freeplayNoteStyle = SONG.noteStyle;
		GameplayCustomizeState.freeplayStage = SONG.stage;
		GameplayCustomizeState.freeplaySong = SONG.songId;
		GameplayCustomizeState.freeplayWeek = storyWeek;

		previousRate = songMultiplier - 0.05;

		if (previousRate < 1.00)
			previousRate = 1;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		inDaPlay = true;

		if (currentSong != SONG.songName)
		{
			currentSong = SONG.songName;
			Main.dumpCache();
		}

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		highestCombo = 0;
		inResults = false;

		if (!FlxG.save.data.language)
		{
			ratingStuff = [
				['You Suck!', 0.2], //From 0% to 19%
				['Shit', 0.4], //From 20% to 39%
				['Bad', 0.5], //From 40% to 49%
				['Bruh', 0.6], //From 50% to 59%
				['Meh', 0.69], //From 60% to 68%
				['Nice', 0.7], //69%
				['Good', 0.8], //From 70% to 79%
				['Great', 0.9], //From 80% to 89%
				['Sick!', 1], //From 90% to 99%
				['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
			];
		}
		else
		{
			ratingStuff = [
				['Ты Отстой!', 0.2], //From 0% to 19%
				['Дерьмо', 0.4], //From 20% to 39%
				['Плохо', 0.5], //From 40% to 49%
				['Bruh', 0.6], //From 50% to 59%
				['Так себе', 0.69], //From 60% to 68%
				['Нормально', 0.7], //69%
				['Хорошо', 0.8], //From 70% to 79%
				['Отлично', 0.9], //From 80% to 89%
				['Великолепно!', 1], //From 90% to 99%
				['Идеально!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
				];
		}

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed * songMultiplier;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;

		removedVideo = false;

		#if FEATURE_LUAMODCHART
		executeModchart = true;
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		Debug.logInfo('Searching for mod chart? ($executeModchart) at "songs/${PlayState.SONG.songId}/"');	

		if (OpenFlAssets.exists('assets/data/songs/${SONG.songId}/haxeModchart.hx'))
			{
				var expr = Paths.getHaxeScript(SONG.songId);
				var parser = new hscript.Parser();
				var ast = parser.parseString(expr);
				var interp = new hscript.Interp();
				Debug.logTrace(interp.execute(ast));
			}

		if (executeModchart)
			songMultiplier = 1;

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			if (!FlxG.save.data.language)
				detailsText = "Story Mode: Week " + storyWeek + ":";
			else
				detailsText = "Режим истории: Неделя " + storyWeek + ":";
		}
		if (isFreeplay)
		{
			if (!FlxG.save.data.language)
				detailsText = "Freeplay";
			else
				detailsText = "Свободная игра";
		}
		if (isExtras)
		{
			if (!FlxG.save.data.language)
				detailsText = 'Extras';
			else
				detailsText = 'Дополнительно';
		}

		// String for when the game is paused
		if (!FlxG.save.data.language)
			detailsPausedText = "Paused - " + detailsText;
		else
			detailsPausedText = "Стоит на паузе - " + detailsText;

		// Updating Discord Rich Presence.
		if (PlayStateChangeables.botPlay)
		{
			if (!FlxG.save.data.language)
				DiscordClient.changePresence(detailsText + " " + SONG.songName + " (" + storyDifficultyText + ") " + 'Botplay', iconRPC);
			else
				DiscordClient.changePresence(detailsText + " " + SONG.songName + " (" + storyDifficultyText + ") " + 'Бот-плей', iconRPC);
		}
		else if (!PlayStateChangeables.botPlay)
		{
			if (!FlxG.save.data.language)
				{
			DiscordClient.changePresence(detailsText
				+ " "
				+ SONG.songName
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			}
			else
				{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.songName
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nТочность: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Счёт: "
					+ songScore
					+ " | Пропуски: "
					+ misses, iconRPC);
				}
		}
		#end

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camNotes);

		camHUD.zoom = PlayStateChangeables.zoom;

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', '');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		Conductor.bpm = SONG.bpm;

		if (SONG.eventObjects == null)
		{
			SONG.eventObjects = [new Song.Event("Init BPM", 0, SONG.bpm, "BPM Change")];
		}

		TimingStruct.clearTimings();

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			if (i.type == "BPM Change")
			{
				var beat:Float = i.position;

				var endBeat:Float = Math.POSITIVE_INFINITY;

				var bpm = i.value * songMultiplier;

				TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

				if (currentIndex != 0)
				{
					var data = TimingStruct.AllTimings[currentIndex - 1];
					data.endBeat = beat;
					data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60)) / songMultiplier;
					var step = ((60 / data.bpm) * 1000) / 4;
					TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step) / songMultiplier);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length / songMultiplier;
				}

				currentIndex++;
			}
		}

		recalculateAllSectionTimes();

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		// if the song has dialogue, so we don't accidentally try to load a nonexistant file and crash the game
		if (!FlxG.save.data.language)
			{
				if (Paths.doesTextAssetExist(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue-eng')))
				{
					dialogueeng = CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue-eng'));
				}
				if (OpenFlAssets.exists('assets/data/songs/' + PlayState.SONG.songId + '/dialogue.json')) {
					dialogueJson = DialogueBoxPsych.parseDialogue('assets/data/songs/' + PlayState.SONG.songId + '/dialogue.json');
				}
				else if (FileSystem.exists('assets/data/songs/' + PlayState.SONG.songId + '/dialogue.json')) {
					dialogueJson = DialogueBoxPsych.parseDialogue('assets/data/songs/' + PlayState.SONG.songId + '/dialogue.json');
				}
			}

		if (FlxG.save.data.language)
			{
				if (Paths.doesTextAssetExist(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue-ru')))
				{
					dialogueru = CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue-ru'));
				}
				if (OpenFlAssets.exists('assets/data/songs/' + PlayState.SONG.songId + '/dialogue.json')) {
					dialogueJson = DialogueBoxPsych.parseDialogue('assets/data/songs/' + PlayState.SONG.songId + '/dialogue.json');
				}
				else if (FileSystem.exists('assets/data/songs/' + PlayState.SONG.songId + '/dialogue.json')) {
					dialogueJson = DialogueBoxPsych.parseDialogue('assets/data/songs/' + PlayState.SONG.songId + '/dialogue.json');
				}
			}

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		// If the stage isn't specified in the chart, we use the story week value.
		if (SONG.stage == null)
		{
			switch (storyWeek)
			{
				case 1:
					stageCheck = 'stage';
				case 2:
					stageCheck = 'halloween';
				case 3:
					stageCheck = 'philly';
				case 4:
					stageCheck = 'limo';
				case 5:
					if (SONG.songId == 'winter-horrorland')
					{
						stageCheck = 'mallEvil';
					}
					else
					{
						stageCheck = 'mall';
					}
				case 6:
					if (SONG.songId == 'thorns')
					{
						stageCheck = 'schoolEvil';
					}
					else
					{
						stageCheck = 'school';
					}
				case 7:
					stageCheck = 'warzone';			
			}
		}
		else
		{
			stageCheck = SONG.stage;
		}

		if (isStoryMode)
			songMultiplier = 1;

		var gfCheck:String = 'gf';

		if (SONG.gfVersion == null)
		{
			switch (storyWeek)
			{
				case 4:
					gfCheck = 'gf-car';
				case 5:
					gfCheck = 'gf-christmas';
				case 6:
					gfCheck = 'gf-pixel';
				case 7:
					if (SONG.songId != 'stress') gfCheck = 'gftank';
					else gfCheck = 'picospeaker';
				default:
					gfCheck = 'gf';
			}
		}
		else
		{
			gfCheck = SONG.gfVersion;
		}

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		if (OpenFlAssets.exists('assets/stages/' + SONG.stage + '.lua'))
			luaStage = true;

		if (luaStage)
		{
			add(gfGroup);
			add(dadGroup);
			add(boyfriendGroup);
		}

		if (!stageTesting)
		{
			gf = new Character(400, 130, gfCheck);

			if (gf.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load gf: " + gfCheck + ". Loading default gf"]);
				#end
				gf = new Character(400, 130, 'gf');
			}
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);

			setOnLuas('gfName', gf.curCharacter);

			boyfriend = new Boyfriend(770, 450, SONG.player1);

			if (boyfriend.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load boyfriend: " + SONG.player1 + ". Loading default boyfriend"]);
				#end
				boyfriend = new Boyfriend(770, 450, 'bf');
			}
			startCharacterPos(boyfriend);
			boyfriendGroup.add(boyfriend);

			setOnLuas('boyfriendName', boyfriend.curCharacter);

			dad = new Character(100, 100, SONG.player2);

			if (dad.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load opponent: " + SONG.player2 + ". Loading default opponent"]);
				#end
				dad = new Character(100, 100, 'dad');
			}
			startCharacterPos(dad, true);
			dadGroup.add(dad);

			setOnLuas('dadName', dad.curCharacter);
		}

		if (!stageTesting && !OpenFlAssets.exists('assets/stages/' + SONG.stage + '.lua'))
		{
			Stage = new Stage(SONG.stage);
		}
		else
		{
			if (OpenFlAssets.exists('assets/stages/' + SONG.stage + '.lua'))
			{
				luaArray.push(new FunkinLua(OpenFlAssets.getPath('assets/stages/' + SONG.stage + '.lua')));
			}
			else
				Stage = new Stage('stage');
		}	

		stageGroup = new FlxTypedGroup<FlxSprite>();
			
		var stageData:StageFile = StageData.getStageFile(SONG.stage);
		if (stageData == null)
		{
			Debug.logTrace('shit');
			stageData = {
				defaultZoom: 0.9,
				isPixelStage: false,
				hideGF: false,
			
				boyfriend: [770, 450],
				gf: [400, 130],
				dad: [100, 100],
			
				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}
	
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		boyfriendGroup.setPosition(BF_X, BF_Y);

		GF_X = stageData.gf[0];
		GF_Y = stageData.gf[1];
		gfGroup.setPosition(GF_X, GF_Y);
	
		DAD_X = stageData.dad[0];
		DAD_Y = stageData.dad[1];
		dadGroup.setPosition(DAD_X, DAD_Y);

		this.hideGF = stageData.hideGF;
	
		defaultCamZoom = stageData.defaultZoom;
	
		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null)
			boyfriendCameraOffset = [0, 0];
	
		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];
			
		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];
	

		if (!luaStage)
		{
			for (i in Stage.toAdd)
			{
				add(i);
				stageGroup.add(i);
			}

			//add(stageGroup);
		}

		if (!PlayStateChangeables.Optimize && !luaStage)
			for (index => array in Stage.layInFront)
			{
				switch (index)
				{
					case 0:
						add(gfGroup);
						gfGroup.scrollFactor.set(0.95, 0.95);
						if (!luaStage)
						{
							for (bg in array)
							{
								add(bg);
								stageGroup.add(bg);
							}
						}
					case 1:
						add(dadGroup);
						if (!luaStage)
						{
							for (bg in array)
							{
								add(bg);
								stageGroup.add(bg);
							}
						}
					case 2:
						add(boyfriendGroup);
						if (!luaStage)
						{
							for (bg in array)
							{
								add(bg);
								stageGroup.add(bg);
							}
						}
				}
			}

		// launch song scripts
		#if LUA_ALLOWED
		var filesToCheck:Array<String> = Paths.listLuaInPath('assets/data/songs/' + SONG.songId + '/');
		var filesPushed:Array<String> = [];
		for (file in filesToCheck)
		{
			if(!filesPushed.contains(file))
			{
				luaArray.push(new FunkinLua(OpenFlAssets.getPath('assets/data/songs/' + SONG.songId + '/' + file + '.lua')));
				filesPushed.push(file);
			}
		}
		#end

		// launch global scripts
		#if LUA_ALLOWED
		var filesToCheck:Array<String> = Paths.listLuaInPath('assets/scripts/');
		var filesPushed:Array<String> = [];
		for (file in filesToCheck)
		{
			if(!filesPushed.contains(file))
			{
				luaArray.push(new FunkinLua(OpenFlAssets.getPath('assets/scripts/' + file + '.lua')));
				filesPushed.push(file);
			}
		}
		#end

		overlayColor = FlxColor.fromRGB(0, 0, 0, 0);
		overlay = new ModchartSprite(0, 0);
		overlay.loadGraphic(Paths.loadImage('songoverlay'));
		overlay.scrollFactor.set();
		overlay.setGraphicSize(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2));
		var position:Int = members.indexOf(gfGroup);
		if(members.indexOf(boyfriendGroup) < position) {
			position = members.indexOf(boyfriendGroup);
		} else if(members.indexOf(dadGroup) < position) {
			position = members.indexOf(dadGroup);
		}
		insert(position, overlay);
		modchartSprites.set('overlay', overlay);
	
		colorTween = FlxTween.color(overlay, 1, overlay.color, overlayColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});

		gf.x = stageData.gf[0];
		gf.y = stageData.gf[1];
		dad.x = stageData.dad[0];
		dad.y = stageData.dad[1];
		boyfriend.x = stageData.boyfriend[0];
		boyfriend.y = stageData.boyfriend[1];

		gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];
		dad.x += dad.positionArray[0];
		dad.y += dad.positionArray[1];
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];

		camPos = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.camPos[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.camPos[1];
		}

		if (dad.hasTrail)
		{
			if (FlxG.save.data.distractions)
			{
				if (!PlayStateChangeables.Optimize)
				{
					dadTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
					add(dadTrail);
				}
			}
		}

		if (boyfriend.hasTrail)
		{
			if (FlxG.save.data.distractions)
			{
				if (!PlayStateChangeables.Optimize)
				{
					bfTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
					add(bfTrail);
				}
			}
		}

		if (gf.hasTrail)
		{
			if (FlxG.save.data.distractions)
			{
				if (!PlayStateChangeables.Optimize)
				{
					gfTrail = new FlxTrail(gf, null, 4, 24, 0.3, 0.069);
					add(gfTrail);
				}
			}
		}

		if (SONG.hideGF || hideGF)
			gf.visible = false;
		else
		{
			if (dad.replacesGF)
			{
				if (!stageTesting)
					dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			}
			else
				gf.visible = true;
		}

		if (!luaStage)
			Stage.update(0);

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		var doof = null;

		if (isStoryMode)
		{
			if (FlxG.save.data.language)
				doof = new DialogueBox(false, dialogueru);
			else if (!FlxG.save.data.language)
				doof = new DialogueBox(false, dialogueeng);
			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
			doof.scrollFactor.set();
			doof.finishThing = startCountdown;
		}

		if (!isStoryMode && songMultiplier == 1)
		{
			var firstNoteTime = Math.POSITIVE_INFINITY;
			var playerTurn = false;
			for (index => section in SONG.notes)
			{
				if (section.sectionNotes.length > 0 && !isSM)
				{
					if (section.startTime > 5000)
					{
						needSkip = true;
						skipTo = section.startTime - 1000;
					}
					break;
				}
				else if (isSM)
				{
					for (note in section.sectionNotes)
					{
						if (note[0] < firstNoteTime)
						{
							if (!PlayStateChangeables.Optimize)
							{
								firstNoteTime = note[0];
								if (note[1] > 3)
									playerTurn = true;
								else
									playerTurn = false;
							}
							else if (note[1] > 3)
							{
								firstNoteTime = note[0];
							}
						}
					}
					if (index + 1 == SONG.notes.length)
					{
						var timing = ((!playerTurn && !PlayStateChangeables.Optimize) ? firstNoteTime : TimingStruct.getTimeFromBeat(TimingStruct.getBeatFromTime(firstNoteTime)
							- 4));
						if (timing > 5000)
						{
							needSkip = true;
							skipTo = timing - 1000;
						}
					}
				}
			}
		}

		Conductor.songPosition = -5000;
		Conductor.rawPosition = Conductor.songPosition;

		strumLine = new FlxSprite(FlxG.save.data.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 150;

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlayOpponent.alpha = FlxG.save.data.laneTransparency;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.alpha = FlxG.save.data.laneTransparency;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();

		if (FlxG.save.data.laneUnderlay && !PlayStateChangeables.Optimize)
		{
			if (!FlxG.save.data.middleScroll || executeModchart)
			{
				add(laneunderlayOpponent);
			}
			add(laneunderlay);
		}

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		strumLineNotes = new FlxTypedGroup<StaticArrow>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);

		playerStrums = new FlxTypedGroup<StaticArrow>();
		cpuStrums = new FlxTypedGroup<StaticArrow>();

		noteskinPixelSprite = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin);
		noteskinSprite = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin);
		noteskinPixelSpriteEnds = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin, true);

		generateStaticArrows(0);
		generateStaticArrows(1);
		
		for (i in 0...playerStrums.length) {
			setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
			setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
		}
		for (i in 0...cpuStrums.length) {
			setOnLuas('defaultOpponentStrumX' + i, cpuStrums.members[i].x);
			setOnLuas('defaultOpponentStrumY' + i, cpuStrums.members[i].y);
		}

		// Update lane underlay positions AFTER static arrows :)

		laneunderlay.x = playerStrums.members[0].x - 25;
		laneunderlayOpponent.x = cpuStrums.members[0].x - 25;

		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);

		// startCountdown();

		if (SONG.songId == null)
			trace('song is null???');
		else
			trace('song looks gucci');
		
		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camHUD];
		add(luaDebugGroup);
		#end

		generateSong(SONG.songId);

		// launch custom events
		#if LUA_ALLOWED
		var filesToCheck:Array<String> = Paths.listLuaInPath('assets/custom_events/');
		var filesPushed:Array<String> = [];
		for (file in filesToCheck)
		{
			if(!filesPushed.contains(file))
			{
				luaArray.push(new FunkinLua(OpenFlAssets.getPath('assets/custom_events/' + file + '.lua')));
				filesPushed.push(file);
			}
		}		
		#end

		// launch custom notetypes
		#if LUA_ALLOWED
		var filesToCheck:Array<String> = Paths.listLuaInPath('assets/custom_notetypes/');
		var filesPushed:Array<String> = [];
		for (file in filesToCheck)
		{
			if(!filesPushed.contains(file))
			{
				luaArray.push(new FunkinLua(OpenFlAssets.getPath('assets/custom_notetypes/' + file + '.lua')));
				filesPushed.push(file);
			}
		}		
		#end

		var index = 0;

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for (i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime <= startTime)
					toBeRemoved.push(dunceNote);
			}

			for (i in toBeRemoved)
				unspawnNotes.remove(i);

			Debug.logTrace("Removed " + toBeRemoved.length + " cuz of start time");
		}

		trace('generated');

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.loadImage('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar

		// Add Kade Engine watermark
		engineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			SONG.songName
			+ (FlxMath.roundDecimal(songMultiplier, 2) != 1.00 ? " (" + FlxMath.roundDecimal(songMultiplier, 2) + "x)" : "")
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty),
			16);
		if (!FlxG.save.data.language)
			engineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		else
			engineWatermark.setFormat(Paths.font("UbuntuBold.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		engineWatermark.scrollFactor.set();
		add(engineWatermark);

		if (PlayStateChangeables.useDownscroll)
			engineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.screenCenter(X);
		scoreTxt.scrollFactor.set();
		if (!FlxG.save.data.language)
			scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		else
			scoreTxt.setFormat(Paths.font("UbuntuBold.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (FlxG.save.data.enablePsychInterface)
		{
			if (!FlxG.save.data.language)
			{
				if(ratingName == '?') {
					scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + misses + ' | Rating: ' + ratingName;
				} else {
					scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + misses + ' | Rating: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
				}
			}
			else
			{
				if(ratingName == '?') {
					scoreTxt.text = 'Счёт: ' + songScore + ' | Пропуски: ' + misses + ' | Рейтинг: ' + ratingName;
				} else {
					scoreTxt.text = 'Счёт: ' + songScore + ' | Пропуски: ' + misses + ' | Рейтинг: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
				}
			}
		}
		else
			scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);

		if (!FlxG.save.data.healthBar)
			scoreTxt.y = healthBarBG.y;

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		if (!FlxG.save.data.language)
			judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		else
			judgementCounter.setFormat(Paths.font("UbuntuBold.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
		if (FlxG.save.data.judgementCounter)
		{
			add(judgementCounter);
			if (FlxG.save.data.enablePsychInterface)
				judgementCounter.visible = false;
		}

		// Literally copy-paste of the above, fu
		if (!FlxG.save.data.language)
			botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "BOTPLAY", 20);
		else
			botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "Бот-плей", 20);
		if (!FlxG.save.data.language)
			botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		else
			botPlayState.setFormat(Paths.font("UbuntuBold.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		botPlayState.cameras = [camHUD];
		if (PlayStateChangeables.botPlay)
			add(botPlayState);

		addedBotplay = PlayStateChangeables.botPlay;

		iconP1 = new HealthIcon(boyfriend.characterIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon(dad.characterIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		if (FlxG.save.data.healthBar)
		{
			add(healthBarBG);
			add(healthBar);
			add(iconP1);
			add(iconP2);

			if (FlxG.save.data.colour)
				healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
			else
				healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		}
		add(scoreTxt);

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		laneunderlay.cameras = [camHUD];
		laneunderlayOpponent.cameras = [camHUD];

		if (isStoryMode)
			doof.cameras = [camHUD];
		engineWatermark.cameras = [camHUD];

		startingSong = true;

		trace('starting');

		dad.dance();
		boyfriend.dance();
		gf.dance();

		if (isStoryMode/* && !seenCutscene*/)
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'ugh' | 'guns' | 'stress':
					tankIntro();
				default:
					new FlxTimer().start(1, function(timer)
					{
						if (!inCutscene)
							startCountdown();
						else
							return;
					});
									
			}
			seenCutscene = true;
		}
		else
		{
			new FlxTimer().start(1, function(timer)
			{
					startCountdown();
			});
		}


		callOnLuas('onCreatePost', []);
	
		// This allow arrow key to be detected by flixel. See https://github.com/HaxeFlixel/flixel/issues/2190
		FlxG.keys.preventDefaultKeys = [];
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		super.create();
	}

	var video:MP4Handler;

	public function playCutscene(name:String, ?atend:Bool)
	{
		Debug.logTrace('start cutscene');
		inCutscene = true;

		video = new MP4Handler();
		video.finishCallback = function()
		{
			if (atend == true)
				{
					if (storyPlaylist.length <= 0)
						FlxG.switchState(new StoryMenuState());
					else
					{
						var diff:String = ["-easy", "", "-hard", "-hardplus"][storyDifficulty];
						SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase(), diff);
						FlxG.switchState(new PlayState());
					}
				}
				else
					startCountdown();
		}
		video.playVideo(Paths.video(name));
	}

	var enddial:Bool = false;
	function endDialogue(?dialogueBox:DialogueBox):Void
		{
			enddial = true;
	
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				if (dialogueBox != null)
				{
					camHUD.visible = false;
					
					inCutscene = true;
	
					add(dialogueBox);
				}
				else
				{
					enddial = false;
					endSong();
				}
			});
		}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		inCutscene = true;
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;
	
		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) 
			{
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	var precacheList:Map<String, String> = new Map<String, String>();

	function tankIntro()
		{
			var songName:String = Paths.formatToSongPath(SONG.song);
			dadGroup.alpha = 0.00001;
			camHUD.visible = false;
			//inCutscene = true; //this would stop the camera movement, oops
	
			var tankman:FlxSprite = new FlxSprite(dad.x, dad.y);
			tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
			tankman.antialiasing = FlxG.save.data.antialiasing;
			insert(members.indexOf(dadGroup) + 1, tankman);
	
			var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
			gfDance.antialiasing = FlxG.save.data.antialiasing;
			var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
			gfCutscene.antialiasing = FlxG.save.data.antialiasing;
			var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);
			picoCutscene.antialiasing = FlxG.save.data.antialiasing;
			var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
			boyfriendCutscene.antialiasing = FlxG.save.data.antialiasing;
	
			var tankmanEnd:Void->Void = function()
			{
				var timeForStuff:Float = Conductor.crochet / 1000 * 5;
				FlxG.sound.music.fadeOut(timeForStuff);
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
				moveCamera(true);
				startCountdown();
	
				dadGroup.alpha = 1;
				camHUD.visible = true;
	
				var stuff:Array<FlxSprite> = [tankman, gfDance, gfCutscene, picoCutscene, boyfriendCutscene];
				for (char in stuff)
				{
					char.kill();
					remove(char);
					char.destroy();
				}
			};
	
			camFollow.setPosition(dad.x + 280, dad.y + 170);
			switch(songName)
			{
				case 'ugh':
					precacheList.set('wellWellWell', 'sound');
					precacheList.set('killYou', 'sound');
					precacheList.set('bfBeep', 'sound');
					
					var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
					FlxG.sound.list.add(wellWellWell);
	
					FlxG.sound.playMusic(Paths.music('DISTORTO'), 0, false);
					FlxG.sound.music.fadeIn();
	
					tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
					tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
					tankman.animation.play('wellWell', true);
					FlxG.camera.zoom *= 1.2;
	
					// Well well well, what do we got here?
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						wellWellWell.play(true);
					});
	
					// Move camera to BF
					new FlxTimer().start(3, function(tmr:FlxTimer)
					{
						camFollow.x += 800;
						camFollow.y += 100;
						
						// Beep!
						new FlxTimer().start(1.5, function(tmr:FlxTimer)
						{
							boyfriend.playAnim('singUP', true);
							boyfriend.specialAnim = true;
							FlxG.sound.play(Paths.sound('bfBeep'));
						});
	
						// Move camera to Tankman
						new FlxTimer().start(3, function(tmr:FlxTimer)
						{
							camFollow.x -= 800;
							camFollow.y -= 100;
	
							tankman.animation.play('killYou', true);
							FlxG.sound.play(Paths.sound('killYou'));
							
							// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
							new FlxTimer().start(6.1, function(tmr:FlxTimer)
							{
								tankmanEnd();
							});
						});
					});
	
				case 'guns':
					tankman.x += 40;
					tankman.y += 10;
	
					var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
					FlxG.sound.list.add(tightBars);
	
					FlxG.sound.playMusic(Paths.music('DISTORTO'), 0, false);
					FlxG.sound.music.fadeIn();
	
					new FlxTimer().start(0.01, function(tmr:FlxTimer) //Fixes sync????
					{
						tightBars.play(true);
					});
	
					tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
					tankman.animation.play('tightBars', true);
					boyfriend.animation.curAnim.finish();
	
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
					new FlxTimer().start(4, function(tmr:FlxTimer)
					{
						gf.playAnim('sad', true);
						gf.animation.finishCallback = function(name:String)
						{
							gf.playAnim('sad', true);
						};
					});
	
					new FlxTimer().start(11.6, function(tmr:FlxTimer)
					{
						tankmanEnd();
	
						gf.dance();
						gf.animation.finishCallback = null;
					});
	
				case 'stress':
					tankman.x -= 54;
					tankman.y -= 14;
					gfGroup.alpha = 0.00001;
					boyfriendGroup.alpha = 0.00001;
					camFollow.setPosition(dad.x + 400, dad.y + 170);
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
					Stage.foregroundSprites.forEach(function(spr:FlxSprite)
					{
						spr.y += 100;
					});
					precacheList.set('cutscenes/stress2', 'image');
	
					gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
					gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
					gfDance.animation.play('dance', true);
					insert(members.indexOf(gfGroup) + 1, gfDance);
	
					gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
					gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
					gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
					insert(members.indexOf(gfGroup) + 1, gfCutscene);
					gfCutscene.alpha = 0.00001;
	
					picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
					picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
					insert(members.indexOf(gfGroup) + 1, picoCutscene);
					picoCutscene.alpha = 0.00001;
	
					boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
					boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
					boyfriendCutscene.animation.play('idle', true);
					boyfriendCutscene.animation.curAnim.finish();
					insert(members.indexOf(boyfriendGroup) + 1, boyfriendCutscene);
	
					var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
					FlxG.sound.list.add(cutsceneSnd);
	
					tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
					tankman.animation.play('godEffingDamnIt', true);
	
					var calledTimes:Int = 0;
					var zoomBack:Void->Void = function()
					{
						var camPosX:Float = 630;
						var camPosY:Float = 425;
						camFollow.setPosition(camPosX, camPosY);
						FlxG.camera.zoom = 0.8;
						cameraSpeed = 1;
	
						calledTimes++;
						if (calledTimes > 1)
						{
							Stage.foregroundSprites.forEach(function(spr:FlxSprite)
							{
								spr.y -= 100;
							});
						}
					}
					
					new FlxTimer().start(0.01, function(tmr:FlxTimer) //Fixes sync????
					{
						cutsceneSnd.play(true);
					});
	
					new FlxTimer().start(15.2, function(tmr:FlxTimer)
					{
						FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
						FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});
						new FlxTimer().start(2.3, function(tmr:FlxTimer)
						{
							zoomBack();
						});
						
						gfDance.visible = false;
						gfCutscene.alpha = 1;
						gfCutscene.animation.play('dieBitch', true);
						gfCutscene.animation.finishCallback = function(name:String)
						{
							if(name == 'dieBitch') //Next part
							{
								gfCutscene.animation.play('getRektLmao', true);
								gfCutscene.offset.set(224, 445);
							}
							else
							{
								gfCutscene.visible = false;
								picoCutscene.alpha = 1;
								picoCutscene.animation.play('anim', true);
								
								boyfriendGroup.alpha = 1;
								boyfriendCutscene.visible = false;
								boyfriend.playAnim('bfCatch', true);
								boyfriend.animation.finishCallback = function(name:String)
								{
									if(name != 'idle')
									{
										boyfriend.playAnim('idle', true);
										boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
									}
								};
	
								picoCutscene.animation.finishCallback = function(name:String)
								{
									picoCutscene.visible = false;
									gfGroup.alpha = 1;
									picoCutscene.animation.finishCallback = null;
								};
								gfCutscene.animation.finishCallback = null;
							}
						};
					});
					
					new FlxTimer().start(19.5, function(tmr:FlxTimer)
					{
						tankman.frames = Paths.getSparrowAtlas('cutscenes/stress2');
						tankman.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
						tankman.animation.play('lookWhoItIs', true);
						tankman.x += 90;
						tankman.y += 6;
	
						new FlxTimer().start(0.5, function(tmr:FlxTimer)
						{
							camFollow.setPosition(dad.x + 500, dad.y + 170);
						});
					});
	
					new FlxTimer().start(31.2, function(tmr:FlxTimer)
					{
						boyfriend.playAnim('singUPmiss', true);
						boyfriend.animation.finishCallback = function(name:String)
						{
							if (name == 'singUPmiss')
							{
								boyfriend.playAnim('idle', true);
								boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
							}
						};
	
						camFollow.setPosition(boyfriend.x + 280, boyfriend.y + 200);
						cameraSpeed = 12;
						FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
						
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							zoomBack();
						});
					});
	
					new FlxTimer().start(35.5, function(tmr:FlxTimer)
					{
						tankmanEnd();
						boyfriend.animation.finishCallback = null;
					});
			}
		}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (PlayState.SONG.songId != 'senpai')
		{
			remove(black);

			if (PlayState.SONG.songId == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (PlayState.SONG.songId == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	var luaWiggles:Array<WiggleEffect> = [];

	#if FEATURE_LUAMODCHART
	public static var luaModchart:FunkinLua = null;
	#end

	#if LUA_ALLOWED
	public static var psychLua:FunkinLua = null;
	#end


	function startCountdownEvent():Void
	{
		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('pixel', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var week6Bullshit:String = null;

			if (SONG.noteStyle == 'pixel')
			{
				introAlts = introAssets.get('pixel');
				altSuffix = '-pixel';
				week6Bullshit = 'week6';
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[0], week6Bullshit));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (SONG.noteStyle == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * CoolUtil.daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[1], week6Bullshit));
					set.scrollFactor.set();

					if (SONG.noteStyle == 'pixel')
						set.setGraphicSize(Std.int(set.width * CoolUtil.daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[2], week6Bullshit));
					go.scrollFactor.set();

					if (SONG.noteStyle == 'pixel')
						go.setGraphicSize(Std.int(go.width * CoolUtil.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
			}

			swagCounter += 1;
			if (storyDifficulty == 3)
			{
				PlayStateChangeables.scrollSpeed = 4;
			}
			else
				PlayStateChangeables.scrollSpeed = 1;
		}, 4);
	}

	var oldvalue:Dynamic;
	var curColor = FlxColor.WHITE;

	function songOverlay(value:Dynamic):Void
	{
		if (oldvalue != value)
		{
			var chars:Array<Character> = [boyfriend, gf, dad];
			if (value != 'delete')
			{
				var valueArray:Array<Dynamic> = [value];
				var split:Array<String> = [];
				for (i in 0...valueArray.length)
				{
					split = valueArray[i].split(',');
				}
				var red:Int = Std.parseInt(split[0].trim());
				var green:Int = Std.parseInt(split[1].trim());
				var blue:Int = Std.parseInt(split[2].trim());
				var alpha:Int = Std.parseInt(split[3].trim());
				overlayColor = FlxColor.fromRGB(red, green, blue, alpha);
				var charColor = FlxColor.fromRGB(red, green, blue, 255);

				
				colorTween = FlxTween.color(overlay, 1, overlay.color, overlayColor, {
					onComplete: function(twn:FlxTween)
					{
						colorTween = null;
					}
				});

				for (char in chars) {
					char.colorTween = FlxTween.color(char, 1, curColor, charColor, {onComplete: function(twn:FlxTween) {
						curColor = charColor;
					}, ease: FlxEase.quadInOut});
				}
			}
			else
			{
				overlayColor = FlxColor.fromRGB(0, 0, 0, 0);
				colorTween = FlxTween.color(overlay, 1, overlay.color, overlayColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
				});
				for (char in chars) {
					char.colorTween = FlxTween.color(char, 1, char.color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {

					}, ease: FlxEase.quadInOut});
				}
			}
			oldvalue = value;
		}
		else
			return;
	}
		

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
		appearStaticArrows();

		talking = false;
		startedCountdown = true;	
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;
		setOnLuas('startedCountdown', true);
		callOnLuas('onCountdownStarted', []);

		if (FlxG.sound.music.playing)
			FlxG.sound.music.stop();
		if (vocals != null)
			vocals.stop();

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			// this just based on beatHit stuff but compact
			if (allowedToHeadbang && swagCounter % gfSpeed == 0)
				gf.dance();
			if (swagCounter % idleBeat == 0)
			{
				if (idleToBeat && !boyfriend.animation.curAnim.name.endsWith("miss"))
					boyfriend.dance(forcedToIdle);
				if (idleToBeat)
					dad.dance(forcedToIdle);
			}
			else if (dad.animation.exists('danceRight') && dad.animation.exists('danceLeft'))
				dad.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('pixel', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var week6Bullshit:String = null;

			if (SONG.noteStyle == 'pixel')
			{
				introAlts = introAssets.get('pixel');
				altSuffix = '-pixel';
				week6Bullshit = 'week6';
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[0], week6Bullshit));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (SONG.noteStyle == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * CoolUtil.daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[1], week6Bullshit));
					set.scrollFactor.set();

					if (SONG.noteStyle == 'pixel')
						set.setGraphicSize(Std.int(set.width * CoolUtil.daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[2], week6Bullshit));
					go.scrollFactor.set();

					if (SONG.noteStyle == 'pixel')
						go.setGraphicSize(Std.int(go.width * CoolUtil.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
			}

			swagCounter += 1;
			callOnLuas('onCountdownTick', [swagCounter]);
		}, 4);
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;

		callOnLuas('onKeyRelease', [key]);
	}

	public var closestNotes:Array<Note> = [];

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
		{
			//trace("couldn't find a keybind with the code " + key);
			return;
		}
		if (keys[data])
		{
			//trace("ur already holding " + key);
			return;
		}

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		closestNotes = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit)
				closestNotes.push(daNote);
		}); // Collect notes that can be hit

		closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		var dataNotes = [];
		for (i in closestNotes)
			if (i.noteData == data && !i.isSustainNote)
				dataNotes.push(i);

		//trace("notes able to hit for " + key.toString() + " " + dataNotes.length);

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
			{
				coolNote = i;
				break;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2) && note.noteData == data)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			boyfriend.holdTimer = 0;
			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.judgeNote(noteDiff);
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
			callOnLuas('onKeyPress', [key]);
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			health -= 0.20;
			callOnLuas('noteMissPress', [key]);
		}
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	public var songStarted = false;

	public var doAnything = false;

	public static var songMultiplier = 1.0;

	public var bar:FlxSprite;

	public var previousRate = songMultiplier;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			#if FEATURE_STEPMANIA
			if (!isStoryMode && isSM)
			{
				trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#end
		}
		FlxG.sound.music.onComplete = endSong;

		songLength = ((FlxG.sound.music.length / songMultiplier) / 1000);
		
		vocals.play();

		// have them all dance when the song starts
		if (allowedToHeadbang && !gf.animation.curAnim.name.startsWith("sing"))
			gf.dance();
		if (idleToBeat && (!boyfriend.animation.curAnim.name.startsWith("sing") || boyfriend.animation.curAnim.finished))
			boyfriend.dance(forcedToIdle);
		if (idleToBeat && (!dad.animation.curAnim.name.startsWith("sing") || dad.animation.curAnim.finished))
			dad.dance(forcedToIdle);

		// Song check real quick
		switch (curSong)
		{
			case 'bopeebo' | 'philly nice' | 'blammed' | 'cocoa' | 'eggnog':
				allowedToCheer = true;
			default:
				allowedToCheer = false;
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		if (PlayStateChangeables.botPlay)
		{
			if (!FlxG.save.data.language)
				DiscordClient.changePresence(detailsText + " " + SONG.songName + " (" + storyDifficultyText + ") " + 'Botplay', iconRPC);
			else
				DiscordClient.changePresence(detailsText + " " + SONG.songName + " (" + storyDifficultyText + ") " + 'Бот-плей', iconRPC);
		}
		else if (!PlayStateChangeables.botPlay)
		{
			if (!FlxG.save.data.language)
				{
			DiscordClient.changePresence(detailsText
				+ " "
				+ SONG.songName
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			}
			else
				{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.songName
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nТочность: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Счёт: "
					+ songScore
					+ " | Пропуски: "
					+ misses, iconRPC);
				}
		}
		#end

		FlxG.sound.music.time = startTime;
		if (vocals != null)
			vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		/*@:privateAccess
			{
				var aux = AL.createAux();
				var fx = AL.createEffect();
				AL.effectf(fx,AL.PITCH,songMultiplier);
				AL.auxi(aux, AL.EFFECTSLOT_EFFECT, fx);
				var instSource = FlxG.sound.music._channel.__source;

				var backend:lime._internal.backend.native.NativeAudioSource = instSource.__backend;

				AL.source3i(backend.handle, AL.AUXILIARY_SEND_FILTER, aux, 1, AL.FILTER_NULL);
				if (vocals != null)
				{
					var vocalSource = vocals._channel.__source;

					backend = vocalSource.__backend;
					AL.source3i(backend.handle, AL.AUXILIARY_SEND_FILTER, aux, 1, AL.FILTER_NULL);
				}

				trace("pitched to " + songMultiplier);
		}*/

		#if cpp
		@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		trace("pitched inst and vocals to " + songMultiplier);
		#end

		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);

		if (needSkip)
		{
			skipActive = true;
			skipText = new FlxText(healthBarBG.x + 80, healthBarBG.y - 110, 500);
			skipText.text = "Press Space to Skip Intro";
			skipText.size = 30;
			skipText.color = FlxColor.WHITE;
			skipText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
			skipText.cameras = [camHUD];
			skipText.alpha = 0;
			FlxTween.tween(skipText, {alpha: 1}, 0.2);
			add(skipText);
		}

		if (FlxG.save.data.enablePsychInterface)
		{
			FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		}

		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		if (storyDifficulty == 3)
		{
			PlayStateChangeables.scrollSpeed = 4;
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.songId;

		#if FEATURE_STEPMANIA
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
			vocals = new FlxSound();
		#end

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		if (!paused)
		{
			#if FEATURE_STEPMANIA
			if (!isStoryMode && isSM)
			{
				trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
			#end
		}

		FlxG.sound.music.volume = 1;
		vocals.volume = 1;

		FlxG.sound.music.pause();

		if (SONG.needsVoices && !PlayState.isSM)
			FlxG.sound.cache(Paths.voices(PlayState.SONG.songId));
		if (!PlayState.isSM)
			FlxG.sound.cache(Paths.inst(PlayState.SONG.songId));

		// Song duration in a float, useful for the time left feature
		songLength = ((FlxG.sound.music.length / songMultiplier) / 1000);

		Conductor.crochet = ((60 / (SONG.bpm) * 1000));
		Conductor.stepCrochet = Conductor.crochet / 4;

		if (FlxG.save.data.songPosition)
		{
			if (FlxG.save.data.enablePsychInterface)
			{
				var showTime:Bool = FlxG.save.data.songPosition;
				timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
				if (!FlxG.save.data.language)
					timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				else
					timeTxt.setFormat(Paths.font("UbuntuBold.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				timeTxt.scrollFactor.set();
				timeTxt.borderSize = 2;
				timeTxt.alpha = 0;
				timeTxt.borderSize = 2;
				timeTxt.visible = showTime;
				if(PlayStateChangeables.useDownscroll) timeTxt.y = FlxG.height - 44;

				timeBarBG = new AttachedSprite('timeBar');
				timeBarBG.x = timeTxt.x;
				timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
				timeBarBG.scrollFactor.set();
				timeBarBG.alpha = 0;
				timeBarBG.visible = showTime;
				timeBarBG.color = FlxColor.BLACK;
				timeBarBG.xAdd = -4;
				timeBarBG.yAdd = -4;
				add(timeBarBG);

				timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
					'songPositionBar', 0, songLength);
				timeBar.scrollFactor.set();
				timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
				timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
				timeBar.alpha = 0;
				timeBar.visible = showTime;
				add(timeBar);
				add(timeTxt);

				timeBarBG.sprTracker = timeBar;

				timeBar.cameras = [camHUD];
				timeBarBG.cameras = [camHUD];
				timeTxt.cameras = [camHUD];
			}
			else
			{
				songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.loadImage('healthBar'));
				if (PlayStateChangeables.useDownscroll)
					songPosBG.y = FlxG.height * 0.9 + 35;
				songPosBG.screenCenter(X);
				songPosBG.scrollFactor.set();

				songPosBar = new FlxBar(640 - (Std.int(songPosBG.width - 100) / 2), songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 100),
					Std.int(songPosBG.height + 6), this, 'songPositionBar', 0, songLength);
				songPosBar.scrollFactor.set();
				songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.fromRGB(0, 255, 128));
				add(songPosBar);

				bar = new FlxSprite(songPosBar.x, songPosBar.y).makeGraphic(Math.floor(songPosBar.width), Math.floor(songPosBar.height), FlxColor.TRANSPARENT);

				add(bar);

				FlxSpriteUtil.drawRect(bar, 0, 0, songPosBar.width, songPosBar.height, FlxColor.TRANSPARENT, {thickness: 4, color: FlxColor.BLACK});

				songPosBG.width = songPosBar.width;

				songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.songName.length * 5), songPosBG.y - 15, 0, SONG.songName, 16);
				if (!FlxG.save.data.language)
					songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				else
					songName.setFormat(Paths.font("UbuntuBold.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				songName.scrollFactor.set();

				songName.text = SONG.songName + ' (' + FlxStringUtil.formatTime(songLength, false) + ')';
				songName.y = songPosBG.y + (songPosBG.height / 3);

				add(songName);

				songName.screenCenter(X);

				songPosBG.cameras = [camHUD];
				bar.cameras = [camHUD];
				songPosBar.cameras = [camHUD];
				songName.cameras = [camHUD];
			}
		}

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] / songMultiplier;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = true;

				if (songNotes[1] > 3 && section.mustHitSection)
					gottaHitNote = false;
				else if (songNotes[1] < 4 && !section.mustHitSection)
					gottaHitNote = false;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var daType = null;

				if (songNotes[5] != null)
					daType = songNotes[5];
				else
					daType = 'Default Note';

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, false, songNotes[4], daType);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(songNotes[2] / songMultiplier)));
				swagNote.scrollFactor.set(0, 0);
				swagNote.gfNote = section.gfSection;
				swagNote.noteType = daType;

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				swagNote.isAlt = songNotes[3]
					|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
					|| (section.playerAltAnim && gottaHitNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true,
						daType);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);
					sustainNote.isAlt = songNotes[3]
						|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
						|| (section.playerAltAnim && gottaHitNote);

					sustainNote.mustPress = gottaHitNote;
					sustainNote.gfNote = section.gfSection;
					sustainNote.noteType = daType;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;

		Debug.logTrace("whats the fuckin shit");
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	var noteTypeCheck:String = 'normal';

	private function generateStaticArrows(player:Int):Void
	{
		var index = 0;
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StaticArrow = new StaticArrow(-10, strumLine.y);

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			if (SONG.noteStyle == null && FlxG.save.data.overrideNoteskins)
			{
				switch (storyWeek)
				{
					case 6:
						noteTypeCheck = 'pixel';
				}
			}
			else
			{
				noteTypeCheck = SONG.noteStyle;
			}

				switch (noteTypeCheck)
				{
					case 'pixel':
						babyArrow.loadGraphic(noteskinPixelSprite, true, 17, 17);
						babyArrow.animation.add('green', [6]);
						babyArrow.animation.add('red', [7]);
						babyArrow.animation.add('blue', [5]);
						babyArrow.animation.add('purplel', [4]);

						babyArrow.setGraphicSize(Std.int(babyArrow.width * CoolUtil.daPixelZoom));
						babyArrow.updateHitbox();
						babyArrow.antialiasing = false;

						babyArrow.x += Note.swagWidth * i;
						babyArrow.animation.add('static', [i]);
						babyArrow.animation.add('pressed', [4 + i, 8 + i], 12, false);
						babyArrow.animation.add('confirm', [12 + i, 16 + i], 24, false);

						for (j in 0...4)
						{
							babyArrow.animation.add('dirCon' + j, [12 + j, 16 + j], 24, false);
						}
					default:
						babyArrow.frames = noteskinSprite;
						for (j in 0...4)
						{
							babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);
							babyArrow.animation.addByPrefix('dirCon' + j, dataSuffix[j].toLowerCase() + ' confirm', 24, false);
						}

						var lowerDir:String = dataSuffix[i].toLowerCase();

						babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
						babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
						babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

						babyArrow.x += Note.swagWidth * i;

						babyArrow.antialiasing = FlxG.save.data.antialiasing;
						babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));						
				}
			
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = 0;
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				// babyArrow.alpha = 0;
				if (!FlxG.save.data.middleScroll || executeModchart || player == 1)
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					babyArrow.x += 20;
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 110;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (PlayStateChangeables.Optimize || (FlxG.save.data.middleScroll && !executeModchart && player == 1))
				babyArrow.x -= 320;
			else if (PlayStateChangeables.Optimize || (FlxG.save.data.middleScroll && !executeModchart && player == 0))
			{
				if (index < 2)
					babyArrow.x -= 75;
				else
					babyArrow.x += FlxG.width / 2 + 25;

				index++;
			}

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		var index = 0;
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode && !FlxG.save.data.middleScroll || executeModchart)
				babyArrow.alpha = 1;
			if (FlxG.save.data.middleScroll)
			{
				if (storyDifficulty == 3)
				{
					if (index > 3)
						babyArrow.alpha = 1;
					else
						babyArrow.alpha = 0;
				}
				else
				{
					if (index > 3)
						babyArrow.alpha = 1;
					else
						babyArrow.alpha = 0.5;
				}
			}
			else if (storyDifficulty == 3)
			{
				if (index > 3)
					babyArrow.alpha = 1;
				else
					babyArrow.alpha = 0;
			}
			index++;
		});
	}

	function tweenCamIn():Void
	{
		if (Paths.formatToSongPath(SONG.songId) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music.playing)
			{
				FlxG.sound.music.pause();
				if (vocals != null)
					if (vocals.playing)
						vocals.pause();
			}

			#if desktop
			if (PlayStateChangeables.botPlay)
			{
				if (!FlxG.save.data.language)
					DiscordClient.changePresence("Paused on " + detailsText + " " + SONG.songName + " (" + storyDifficultyText + ") " + 'Botplay', iconRPC);
				else
					DiscordClient.changePresence("Стоит на паузе " + detailsText + " " + SONG.songName + " (" + storyDifficultyText + ") " + 'Бот-плей', iconRPC);
			}
			else if (!PlayStateChangeables.botPlay)
			{
				if (!FlxG.save.data.language)
				{
				DiscordClient.changePresence("PAUSED on "
					+ SONG.songId
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				}
				else
					{
					DiscordClient.changePresence("Стоит на паузе "
						+ SONG.songId
						+ " ("
						+ storyDifficultyText
						+ ") "
						+ Ratings.GenerateLetterRank(accuracy),
						"\nТочность: "
						+ HelperFunctions.truncateFloat(accuracy, 2)
						+ "% | Счёт: "
						+ songScore
						+ " | Пропуски: "
						+ misses, iconRPC);
					}
			}
			#end
			if (!startTimer.finished)
				startTimer.active = false;

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (PauseSubState.goToOptions)
		{
			Debug.logTrace("pause thingyt");
			if (PauseSubState.goBack)
			{
				Debug.logTrace("pause thingyt");
				PauseSubState.goToOptions = false;
				PauseSubState.goBack = false;
				openSubState(new PauseSubState());
			}
			else
				openSubState(new OptionsMenu(true));
		}
		else if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer.finished)
			{
				if (!FlxG.save.data.language)
				{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.songId
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition);
				}
				else
					{
					DiscordClient.changePresence(detailsText
						+ " "
						+ SONG.songId
						+ " ("
						+ storyDifficultyText
						+ ") "
						+ Ratings.GenerateLetterRank(accuracy),
						"\nТочность: "
						+ HelperFunctions.truncateFloat(accuracy, 2)
						+ "% | Счёт: "
						+ songScore
						+ " | Пропуски: "
						+ misses, iconRPC, true,
						songLength
						- Conductor.songPosition);
					}
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.songName + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.stop();
		FlxG.sound.music.stop();

		FlxG.sound.music.play();
		vocals.play();
		FlxG.sound.music.time = Conductor.songPosition * songMultiplier;
		vocals.time = FlxG.sound.music.time;

		@:privateAccess
		{
			#if desktop
			// The __backend.handle attribute is only available on native.
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			#end
		}

		#if desktop
		if (PlayStateChangeables.botPlay)
		{
			if (!FlxG.save.data.language)
				DiscordClient.changePresence(detailsText + " " + SONG.songName + " (" + storyDifficultyText + ") " + 'Botplay', iconRPC);
			else
				DiscordClient.changePresence(detailsText + " " + SONG.songName + " (" + storyDifficultyText + ") " + 'Бот-плей', iconRPC);
		}
		else if (!PlayStateChangeables.botPlay)
		{
			if (!FlxG.save.data.language)
			{
			DiscordClient.changePresence(detailsText
				+ " "
				+ SONG.songName
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			}
			else
				{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.songName
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nТочность: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Счёт: "
					+ songScore
					+ " | Пропуски: "
					+ misses, iconRPC);
				}
		}
		#end
	}

	public var paused:Bool = false;

	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public var stopUpdate = false;
	public var removedVideo = false;

	public var currentBPM = 0;

	public var updateFrame = 0;

	public var pastEvents:Array<Song.Event> = [];

	var currentLuaIndex = 0;

	var blammedeventplayed:Bool = false;

	public var newScroll = 1.0;

	override public function update(elapsed:Float)
	{

		callOnLuas('onUpdate', [elapsed]);

		#if !debug
		perfectMode = false;
		#end
		if (!PlayStateChangeables.Optimize && !luaStage)
			Stage.update(elapsed);

		if (!addedBotplay && FlxG.save.data.botplay)
		{
			PlayStateChangeables.botPlay = true;
			addedBotplay = true;
			add(botPlayState);
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 14000 * songMultiplier)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				dunceNote.cameras = [camHUD];

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
				currentLuaIndex++;
			}
		}

		#if cpp
		if (FlxG.sound.music.playing)
			@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		#end

		if (generatedMusic)
		{
			if (songStarted && !endingSong)
			{
				// Song ends abruptly on slow rate even with second condition being deleted,
				// and if it's deleted on songs like cocoa then it would end without finishing instrumental fully,
				// so no reason to delete it at all
				if ((FlxG.sound.music.length / songMultiplier) - Conductor.songPosition <= 0)
				{
					Debug.logTrace("we're fuckin ending the song ");
					endingSong = true;
					if (Paths.doesTextAssetExist(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue-end-eng'))
						&& Paths.doesTextAssetExist(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue-end-ru')))
				  	{

						if (isStoryMode)
						{
							var dialoguebox = null;
							if (FlxG.save.data.language)
								dialoguebox = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue-end-ru')));
							else if (!FlxG.save.data.language)
								dialoguebox = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue-end-eng')));
							dialoguebox.scrollFactor.set();
							dialoguebox.finishThing = endSong;
							endDialogue(dialoguebox);
						}
						else
							{
								new FlxTimer().start(2, function(timer)
									{
										endSong();
									});
							}
				  	}
					else
					{
						new FlxTimer().start(2, function(timer)
							{
								endSong();
							});
					}
				}
			}
		}

		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();

			var currentIndex = 0;
			for (i in SONG.eventObjects)
			{
				if (i.type == "BPM Change")
				{
					var beat:Float = i.position;

					var endBeat:Float = Math.POSITIVE_INFINITY;

					var bpm = i.value * songMultiplier;

					TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60)) / songMultiplier;
						var step = ((60 / data.bpm) * 1000) / 4;
						TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step) / songMultiplier);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length / songMultiplier;
					}

					currentIndex++;
				}
			}

			updateFrame++;
		}
		else if (updateFrame != 5)
			updateFrame++;

		if (FlxG.sound.music.playing)
		{
			var timingSeg = TimingStruct.getTimingAtBeat(curDecimalBeat);

			if (timingSeg != null)
			{
				var timingSegBpm = timingSeg.bpm;

				if (timingSegBpm != Conductor.bpm)
				{
					trace("BPM CHANGE to " + timingSegBpm);
					Conductor.changeBPM(timingSegBpm, false);
					Conductor.crochet = ((60 / (timingSegBpm) * 1000)) / songMultiplier;
					Conductor.stepCrochet = Conductor.crochet / 4;
				}
			}

			for (i in SONG.eventObjects)
			{
				doEvent(i);
			}

			if (newScroll != 0)
				PlayStateChangeables.scrollSpeed *= newScroll;
		}

		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;


		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		scoreTxt.screenCenter(X);

		var pauseBind = FlxKey.fromString(FlxG.save.data.pauseBind);
		var gppauseBind = FlxKey.fromString(FlxG.save.data.gppauseBind);

		if ((FlxG.keys.anyJustPressed([pauseBind]) || KeyBinds.gamepad && FlxG.keys.anyJustPressed([gppauseBind]))
			&& startedCountdown
			&& canPause
			&& !cannotDie && !enddial)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				if (FlxG.random.bool(0.1))
				{
					trace('GITAROO MAN EASTER EGG');
					MusicBeatState.switchState(new GitarooPause());
					clean();
				}
				else
					openSubState(new PauseSubState());
			}
		}


		if (FlxG.keys.justPressed.SEVEN && songStarted)
		{
			songMultiplier = 1;
			cannotDie = true;

			MusicBeatState.switchState(new ChartingState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
		{
			if (iconP1.nearToDieAnim != null)
				iconP1.animation.play(iconP1.nearToDieAnim);
			else
				iconP1.animation.curAnim.curFrame = 1;
		}
		else
		{
			if (iconP1.defaultAnim != null)
				iconP1.animation.play(iconP1.defaultAnim);
			else
				iconP1.animation.curAnim.curFrame = 0;
		}

		if (healthBar.percent > 80)
		{
			if (iconP2.nearToDieAnim != null)
				iconP2.animation.play(iconP2.nearToDieAnim);
			else
				iconP2.animation.curAnim.curFrame = 1;
		}
		else
		{
			if (iconP2.defaultAnim != null)
				iconP2.animation.play(iconP2.defaultAnim);
			else
				iconP2.animation.curAnim.curFrame = 0;
		}

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (!PlayStateChangeables.Optimize && !luaStage)
			if (FlxG.keys.justPressed.EIGHT && songStarted)
			{
				paused = true;
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					for (bg in Stage.toAdd)
					{
						remove(bg);
					}
					for (array in Stage.layInFront)
					{
						for (bg in array)
							remove(bg);
					}
					for (group in Stage.swagGroup)
					{
						remove(group);
					}
					remove(boyfriend);
					remove(dad);
					remove(gf);
				});
				MusicBeatState.switchState(new StageDebugState(Stage.curStage, gf.curCharacter, boyfriend.curCharacter, dad.curCharacter));
				clean();
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			}

		if (FlxG.keys.justPressed.TWO && songStarted)
		{ // Go 10 seconds into the future, credit: Shadow Mario#9396
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length)
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime - 500 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					usedTimeTravel = false;
				});
			}
		}
		#end

		if (skipActive && Conductor.songPosition >= skipTo)
		{
			remove(skipText);
			skipActive = false;
		}

		if (FlxG.keys.justPressed.SPACE && skipActive)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			Conductor.songPosition = skipTo;
			Conductor.rawPosition = skipTo;

			FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();

			vocals.time = Conductor.songPosition;
			vocals.play();
			FlxTween.tween(skipText, {alpha: 0}, 0.2, {
				onComplete: function(tw)
				{
					remove(skipText);
				}
			});
			skipActive = false;
		}

		if (FlxG.keys.justPressed.SPACE && !skipActive)
		{
			if (boyfriend.animation.exists('hey'))
				boyfriend.playAnim('hey', true);
			if (gf.animation.exists('cheer'))
				gf.playAnim('cheer', true);
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				Conductor.rawPosition = Conductor.songPosition;
				if (Conductor.songPosition >= 0)
				{
					startSong();
				}
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			Conductor.rawPosition = FlxG.sound.music.time;
			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = (Conductor.songPosition - songLength) / 1000;

			currentSection = getSectionByTime(Conductor.songPosition);

			var curTime:Float = FlxG.sound.music.time / songMultiplier;
			if (curTime < 0)
				curTime = 0;

			var secondsTotal:Int = Math.floor(((curTime - songLength) / 1000));
			if (secondsTotal < 0)
				secondsTotal = 0;

			var time:String = FlxStringUtil.formatTime((songLength - secondsTotal), false);

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if (FlxG.save.data.songPosition)
				{
					if (FlxG.save.data.enablePsychInterface)
						timeTxt.text = time;
					else
						songName.text = SONG.songName + ' (' + time + ')';
					
				}
				timerCount += 1;
				if (timerCount > maxTimerCounter)
				{
					if (!FlxG.save.data.language)
						{
						DiscordClient.changePresence(detailsText + " " + SONG.songId + " (" + storyDifficultyText + ") " + " | Time left: " + time + " | "
							+ Ratings.GenerateLetterRank(accuracy),
							"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore
							+ " | Misses: " + misses, iconRPC);
						}
					else
						{
						DiscordClient.changePresence(detailsText + " " + SONG.songId + " (" + storyDifficultyText + ") " + " | Осталось времени: " + time + " | "
							+ Ratings.GenerateLetterRank(accuracy),
							"\nТочность: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Счёт: " + songScore
							+ " | Пропуски: " + misses, iconRPC);
						}
					
					timerCount = 0;
				}
			}
			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && currentSection != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (allowedToCheer)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
					|| gf.animation.curAnim.name == 'danceRight'
					|| gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (curSong)
					{
						case 'philly nice':
							{
								// General duration of the song
								if (curBeat < 250)
								{
									// Beats to skip or to stop GF from cheering
									if (curBeat != 184 && curBeat != 216)
									{
										if (curBeat % 16 == 8)
										{
											// Just a garantee that it'll trigger just once
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'bopeebo':
							{
								// Where it starts || where it ends
								if (curBeat > 5 && curBeat < 130)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'blammed':
							{
								if (curBeat > 30 && curBeat < 190)
								{
									if (curBeat < 90 || curBeat > 128)
									{
										if (curBeat % 4 == 2)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
								if ((curBeat == 128 || curBeat > 128) && curBeat < 192 && !blammedeventplayed && FlxG.save.data.distractions)
									{
										switch (Stage.curLight)
										{
											case 4:
												songOverlay("251, 166, 51, 175");
											case 3:
												songOverlay("253, 69, 49, 175");
											case 2:
												songOverlay("251, 51, 245, 175");
											case 1:
												songOverlay("49, 253, 140, 175");
											case 0:
												songOverlay("49, 162, 253, 175");
										}
									}
								else if (curBeat > 192 && !blammedeventplayed  && FlxG.save.data.distractions)
								{
									songOverlay('delete');
									blammedeventplayed = true;
								}
							}
						case 'cocoa':
							{
								if (curBeat < 170)
								{
									if (curBeat < 65 || curBeat > 130 && curBeat < 145)
									{
										if (curBeat % 16 == 15)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'eggnog':
							{
								if (curBeat > 10 && curBeat != 111 && curBeat < 220)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
					}
				}
			}


			if (!currentSection.gfSection)
			{
				if (camFollow.x != dad.getMidpoint().x + 150 && !currentSection.mustHitSection)
				{
					moveCamera(true);
					callOnLuas('onMoveCamera', ['dad']);
				}

				if (currentSection.mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
				{
					moveCamera(false);
					callOnLuas('onMoveCamera', ['boyfriend']);
				}
			}
			else
			{
				if (gf != null)
					{
						camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
						camFollow.x += gf.camPos[0] + girlfriendCameraOffset[0];
						camFollow.y += gf.camPos[1] + girlfriendCameraOffset[1];
						callOnLuas('onMoveCamera', ['gf']);
					}
			}
		}

		if (camZooming)
		{
			if (FlxG.save.data.zoom < 0.8)
				FlxG.save.data.zoom = 0.8;

			if (FlxG.save.data.zoom > 1.2)
				FlxG.save.data.zoom = 1.2;

			if (!executeModchart)
			{
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, 0.95);

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
			else
			{
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
		}

		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (health <= 0 && !cannotDie)
		{
			if (!usedTimeTravel)
			{
				var ret:Dynamic = callOnLuas('onGameOver', []);
				if(ret != FunkinLua.Function_Stop) {
					isDead = true;
					boyfriend.stunned = true;

					persistentUpdate = false;
					persistentDraw = false;
					paused = true;

					FlxG.sound.music.volume = 0;
					vocals.volume = 0;

					vocals.pause();
					FlxG.sound.music.pause();

					if (FlxG.save.data.InstantRespawn)
					{
						MusicBeatState.switchState(new PlayState());
					}
					else
					{
						openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
					}


					#if desktop
					// Game Over doesn't get his own variable because it's only used here
					if (!FlxG.save.data.language)
					{
					DiscordClient.changePresence("GAME OVER -- "
						+ SONG.songId
						+ " ("
						+ storyDifficultyText
						+ ") "
						+ Ratings.GenerateLetterRank(accuracy),
						"\nAcc: "
						+ HelperFunctions.truncateFloat(accuracy, 2)
						+ "% | Score: "
						+ songScore
						+ " | Misses: "
						+ misses, iconRPC);
					}
					else
						{
						DiscordClient.changePresence("Проиграл -- "
							+ SONG.songId
							+ " ("
							+ storyDifficultyText
							+ ") "
							+ Ratings.GenerateLetterRank(accuracy),
							"\nТочность: "
							+ HelperFunctions.truncateFloat(accuracy, 2)
							+ "% | Счёт: "
							+ songScore
							+ " | Пропуски: "
							+ misses, iconRPC);
						}
					#end
					for (tween in modchartTweens) {
						tween.active = true;
					}
					for (timer in modchartTimers) {
						timer.active = true;
					}
				}
			}
			else
				health = 1;
		}
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			var resetBind = FlxKey.fromString(FlxG.save.data.resetBind);
			var gpresetBind = FlxKey.fromString(FlxG.save.data.gpresetBind);
			if ((FlxG.keys.anyJustPressed([resetBind]) || KeyBinds.gamepad && FlxG.keys.anyJustPressed([gpresetBind])))
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				FlxG.sound.music.volume = 0;
				vocals.volume = 0;

				vocals.pause();
				FlxG.sound.music.pause();

				if (FlxG.save.data.InstantRespawn)
				{
					MusicBeatState.switchState(new PlayState());
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				if (!FlxG.save.data.language)
				{
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.songId
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				}
				else
					{
					DiscordClient.changePresence("Проиграл -- "
						+ SONG.songId
						+ " ("
						+ storyDifficultyText
						+ ") "
						+ Ratings.GenerateLetterRank(accuracy),
						"\nТочность: "
						+ HelperFunctions.truncateFloat(accuracy, 2)
						+ "% | Счёт: "
						+ songScore
						+ " | Пропуски: "
						+ misses, iconRPC);
					}
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayState.SONG.speed, 2));

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)

				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								- daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								- daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height - stepHeight;

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| holdArray[Math.floor(Math.abs(daNote.noteData))]
								&& (daNote.noteType != 1 || daNote.noteType != 'Hurt Note'))
								&& daNote.y
								- daNote.offset.y * daNote.scale.y
								+ daNote.height >= (strumLine.y + Note.swagWidth / 2))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}

						if (daNote.isParent)
						{
							for (i in 0...daNote.children.length)
							{
								var slide = daNote.children[i];
								slide.y = daNote.y - slide.height;
							}
						}
					}
					else
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								+ daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								+ daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| holdArray[Math.floor(Math.abs(daNote.noteData))]
								&& (daNote.noteType != 1 || daNote.noteType != 'Hurt Note'))
								&& daNote.y
								+ daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
				{
					if (SONG.songId != 'tutorial')
						camZooming = true;

					if (daNote.gfNote)
						checkNoteType('gf', daNote);
					else if (daNote.noteType == 3 || daNote.noteType == 'GF Sing Note')
						checkNoteType('gf', daNote);
					else
						checkNoteType('dad', daNote);

					var time:Float = 0.15;
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
						time += 0.15;
					}
					cpuStrums.forEach(function(spr:StaticArrow)
					{
						pressArrow(spr, spr.ID, daNote, time);
					});
					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;
					daNote.active = false;

					if (storyDifficulty == 3 && !daNote.isSustainNote)
					{
						health -= 0.015;
					}

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart)
							daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart)
							daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}

				if (!daNote.mustPress && FlxG.save.data.middleScroll && !executeModchart && storyDifficulty != 3)
					daNote.alpha = 0.5;

				if (storyDifficulty == 3 && !daNote.mustPress)
					daNote.alpha = 0;

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (SONG.noteStyle == 'pixel')
						daNote.x -= 11;
				}

				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
				{
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				else if ((daNote.mustPress && !PlayStateChangeables.useDownscroll || daNote.mustPress && PlayStateChangeables.useDownscroll)
					&& daNote.mustPress
					&& daNote.strumTime / songMultiplier - Conductor.songPosition / songMultiplier < -(166 * Conductor.timeScale)
					&& songStarted)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
					}
					else
					{
							if (daNote.noteType != 1)
								vocals.volume = 0;
							if (theFunne && !daNote.isSustainNote)
							{
								if (PlayStateChangeables.botPlay && daNote.noteType != 1)
								{
									daNote.rating = "bad";
									goodNoteHit(daNote);
								}
								else
									noteMiss(daNote.noteData, daNote);
							}

							if (daNote.isParent && daNote.visible)
							{
								health -= 0.15; // give a health punishment for failing a LN
								trace("hold fell over at the start");
								for (i in daNote.children)
								{
									i.alpha = 0.3;
									i.sustainActive = false;
								}
							}
							else
							{
								if (!daNote.wasGoodHit
									&& daNote.isSustainNote
									&& daNote.sustainActive
									&& daNote.spotInLine != daNote.parent.children.length)
								{
									// health -= 0.05; // give a health punishment for failing a LN
									trace("hold fell over at " + daNote.spotInLine);
									for (i in daNote.parent.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
									if (daNote.parent.wasGoodHit)
									{
										misses++;
										totalNotesHit -= 1;
									}
									if (FlxG.save.data.enablePsychInterface)
										recalculateRating();
									else
										updateAccuracy();
								}
								else if (!daNote.wasGoodHit && !daNote.isSustainNote && daNote.noteType != 1)
								{
									health -= 0.15;
								}
							}
					}

					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
				}
			});
		}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:StaticArrow)
			{
				if (spr.animation.finished)
				{
					spr.playAnim('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene && songStarted)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		super.update(elapsed);

		setOnLuas('cameraX', camFollow.x);
		setOnLuas('cameraY', camFollow.y);
		setOnLuas('botPlay', PlayStateChangeables.botPlay);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
				}
		}
	}
		
	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.replacesGF) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function doEvent(event:Song.Event)
		{
			switch (event.type)
				{
					case "Scroll Speed Change":
						if (event.position <= curDecimalBeat && !pastEvents.contains(event))
						{
							pastEvents.push(event);
							trace("SCROLL SPEED CHANGE to " + event.value);
							newScroll = event.value;
						}


					case "Change Stage":
						if (event.position <= curDecimalBeat && !pastEvents.contains(event))
						{
							pastEvents.push(event);
							if (!luaStage)
							{
								for (i in stageGroup)
									remove(i);
								
								stageGroup.clear();
								remove(boyfriendGroup);
								remove(dadGroup);
								remove(gfGroup);
	
								Debug.logTrace(event.value);
	
								Stage = new Stage(event.value);

								var positions:StageFile = StageData.getStageFile(event.value);
								if (positions != null)
								{
									boyfriendGroup.setPosition(positions.boyfriend[0], positions.boyfriend[1]);
									gfGroup.setPosition(positions.gf[0], positions.gf[1]);
									dadGroup.setPosition(positions.dad[0], positions.dad[1]);
								}
	
								for (i in Stage.toAdd)
								{
									add(i);
									stageGroup.add(i);
								}	
								for (index => array in Stage.layInFront)
									{
										switch (index)
										{
											case 0:
												add(gfGroup);
												for (bg in array)
												{
													add(bg);
													stageGroup.add(bg);
												}
											case 1:
												add(dadGroup);
												for (bg in array)
												{
													add(bg);
													stageGroup.add(bg);
												}
											case 2:
												add(boyfriendGroup);
												for (bg in array)
												{
													add(bg);
													stageGroup.add(bg);
												}
										}
									}
								camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);	
							}
							else
								addTextToDebug('Change Stage event don`t work with lua stages. Please change stage in lua file');				
						}

					case "Start Countdown":
						if (event.position <= curDecimalBeat && !pastEvents.contains(event))
						{
							pastEvents.push(event);
							startCountdownEvent();
						}

					case "Change Character":
						if (event.position <= curDecimalBeat && !pastEvents.contains(event))
						{
							var valueArray:Array<Dynamic> = [event.value];
							var split:Array<String> = [];
							for (i in 0...valueArray.length)
							{
								split = valueArray[i].split(',');
							}
							pastEvents.push(event);
							switch (split[0])
							{
								case 'bf':
								{
									boyfriendGroup.clear();
									boyfriend = null;
									boyfriend = new Boyfriend(BF_X, BF_Y, split[1].ltrim());
									boyfriend.alpha = 0.0000001;
									boyfriendGroup.add(boyfriend);
									boyfriend.alpha = 1;
									setOnLuas('boyfriendName', boyfriend.curCharacter);
								}
								case 'dad':
								{
									dadGroup.clear();
									dad = null;
									dad = new Character(DAD_X, DAD_Y, split[1].ltrim());
									dad.alpha = 0.0000001;
									dadGroup.add(dad);
									dad.alpha = 1;
									setOnLuas('dadName', dad.curCharacter);
								}
								case 'gf':
								{
									gfGroup.clear();
									gf = null;
									gf = new Character(GF_X, GF_Y, split[1].ltrim());
									gf.alpha = 0.0000001;
									gfGroup.add(gf);
									gf.alpha = 1;
									setOnLuas('gfName', gf.curCharacter);
								}
							}
							reloadHealthBarColors();
							reloadIcons();
						}
					case "Song Overlay":
						if (event.position <= curDecimalBeat && !pastEvents.contains(event))
						{
							pastEvents.push(event);
							songOverlay(event.value);
						}
					
					case "Character play animation":
						if (event.position <= curDecimalBeat && !pastEvents.contains(event))
						{
							pastEvents.push(event);
							var valueArray:Array<Dynamic> = [event.value];
							var split:Array<String> = [];
							for (i in 0...valueArray.length)
							{
								split = valueArray[i].split(',');
							}
							switch (split[0])
							{
								case 'gf':
									gf.playAnim(split[1].ltrim(), true);
								case 'dad':
									dad.playAnim(split[1].ltrim(), true);
								case 'bf':
									boyfriend.playAnim(split[1].ltrim(), true);
							}
							
						}

					case "Camera zoom":
						if (event.position <= curDecimalBeat && !pastEvents.contains(event))
							{
								pastEvents.push(event);
								if (FlxG.save.data.camzoom)
								{
									FlxG.camera.zoom += 0.015 * event.value;
									camHUD.zoom += 0.03 * event.value;
								}
							}

					case 'Toggle interface':
						if (event.position <= curDecimalBeat && !pastEvents.contains(event))
							{
								pastEvents.push(event);
								camHUD.visible = false;

								new FlxTimer().start(event.value, function(tmr:FlxTimer)
									{
										camHUD.visible = true;
									});
							}

					case 'Toggle Alt Idle':
						if (event.position <= curDecimalBeat && !pastEvents.contains(event))
							{
								pastEvents.push(event);
								switch (event.value)
								{
									case 'dad':
										dadAltAnim = !dadAltAnim;
									case 'bf':
										bfAltAnim = !bfAltAnim;
									case 'gf':
										gfAltAnim = !gfAltAnim;
								}
							}
					case "Change note skin":
						if (event.position <= curDecimalBeat && !pastEvents.contains(event))
							{
								pastEvents.push(event);
								SONG.noteStyle = event.value;
								strumLineNotes.clear();
								generateStaticArrows(0);
								generateStaticArrows(1);
								for (n in notes)
									n.noteTypeCheck = event.value;
							}

					case 'Screen Shake':
						if (event.position <= curDecimalBeat&& !pastEvents.contains(event))
						{
							pastEvents.push(event);
							var valuesArray:Array<String> = [event.value];
							var targetsArray:Array<FlxCamera> = [camGame, camHUD];
							for (i in 0...targetsArray.length) {
								var split:Array<String> = valuesArray[i].split(',');
								var duration:Float = 0;
								var intensity:Float = 0;
								if(split[0] != null) duration = Std.parseFloat(split[0].trim());
								if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
								if(Math.isNaN(duration)) duration = 0;
								if(Math.isNaN(intensity)) intensity = 0;
						
								if(duration > 0 && intensity != 0) {
									targetsArray[i].shake(intensity, duration);
								}
							}
						}
					default:
						if (event.position <= curDecimalBeat && !pastEvents.contains(event))
						{
							pastEvents.push(event);
							callOnLuas('onEvent', [event.name, event.value, event.type, event.position]);
						}	
				}
		}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
				
		healthBar.updateBar();
	}

	public function reloadIcons() {
		iconP1.changeIcon(boyfriend.characterIcon);
		iconP2.changeIcon(dad.characterIcon);
	}

	public function getSectionByTime(ms:Float):SwagSection
	{
		for (i in SONG.notes)
		{
			var start = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.startTime)));
			var end = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.endTime)));

			if (ms >= start && ms < end)
			{
				return i;
			}
		}

		return null;
	}

	function recalculateAllSectionTimes()
	{
		trace("RECALCULATING SECTION TIMES");

		for (i in 0...SONG.notes.length) // loops through sections
		{
			var section = SONG.notes[i];

			var currentBeat = 4 * i;

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				return;

			var start:Float = (currentBeat - currentSeg.startBeat) / ((currentSeg.bpm) / 60);

			section.startTime = (currentSeg.startTime + start) * 1000;

			if (i != 0)
				SONG.notes[i - 1].endTime = section.startTime;
			section.endTime = Math.POSITIVE_INFINITY;
		}
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup));
		#end
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.camPos[0] + opponentCameraOffset[0];
			camFollow.y += dad.camPos[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.camPos[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.camPos[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.songId) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	public var transitioning = false;
	public function endSong():Void
	{
		endingSong = true;
		seenCutscene = false;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		PlayStateChangeables.botPlay = false;
		PlayStateChangeables.scrollSpeed = 1 / songMultiplier;
		PlayStateChangeables.useDownscroll = false;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		if(ret != FunkinLua.Function_Stop) {
			if (SONG.validScore)
			{
				#if !switch
				Highscore.saveScore(PlayState.SONG.songId, Math.round(songScore), storyDifficulty);
				Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
				#end
			}

			if (offsetTesting)
			{
				FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)));
				offsetTesting = false;
				LoadingState.loadAndSwitchState(new OptionsMenu());
				clean();
				FlxG.save.data.offset = offsetTest;
			}
			else if (stageTesting)
			{
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					for (bg in Stage.toAdd)
					{
						remove(bg);
					}
					for (array in Stage.layInFront)
					{
						for (bg in array)
							remove(bg);
					}
					remove(boyfriend);
					remove(dad);
					remove(gf);
				});
				MusicBeatState.switchState(new StageDebugState(Stage.curStage));
			}
			else
			{
				if (isStoryMode)
				{
					campaignScore += Math.round(songScore);
					campaignMisses += misses;
					campaignSicks += sicks;
					campaignGoods += goods;
					campaignBads += bads;
					campaignShits += shits;

					storyPlaylist.remove(storyPlaylist[0]);

					if (storyPlaylist.length <= 0)
					{
						transIn = FlxTransitionableState.defaultTransIn;
						transOut = FlxTransitionableState.defaultTransOut;

						paused = true;

						FlxG.sound.music.stop();
						vocals.stop();
						if (FlxG.save.data.scoreScreen)
						{
							if (FlxG.save.data.songPosition)
							{
								if (FlxG.save.data.enablePsychInterface)
								{
									FlxTween.tween(timeBar, {alpha: 0}, 0.5, {ease: FlxEase.circOut});
									FlxTween.tween(timeTxt, {alpha: 0}, 0.5, {ease: FlxEase.circOut});
								}
								else
								{
									FlxTween.tween(songPosBar, {alpha: 0}, 1);
									FlxTween.tween(bar, {alpha: 0}, 1);
									FlxTween.tween(songName, {alpha: 0}, 1);
								}
							}
							openSubState(new ResultsScreen());
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								inResults = true;
							});
						}
						else
						{
							GameplayCustomizeState.freeplayBf = 'bf';
							GameplayCustomizeState.freeplayDad = 'dad';
							GameplayCustomizeState.freeplayGf = 'gf';
							GameplayCustomizeState.freeplayNoteStyle = 'normal';
							GameplayCustomizeState.freeplayStage = 'stage';
							GameplayCustomizeState.freeplaySong = 'bopeebo';
							GameplayCustomizeState.freeplayWeek = 1;
							FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)));
							Conductor.changeBPM(102);
							MusicBeatState.switchState(new StoryMenuState());
							clean();
						}

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
						}

						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
					}
					else
					{
						var diff:String = ["-easy", "", "-hard", "-hardplus"][storyDifficulty];

						Debug.logInfo('PlayState: Loading next story song ${PlayState.storyPlaylist[0]}-${diff}');

						if (StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() == 'eggnog')
						{
							var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
								-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
							blackShit.scrollFactor.set();
							add(blackShit);
							camHUD.visible = false;

							FlxG.sound.play(Paths.sound('Lights_Shut_off'));
						}

						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						prevCamFollow = camFollow;

						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0], diff);
						FlxG.sound.music.stop();

						LoadingState.loadAndSwitchState(new PlayState());
						clean();
					}
				}
				else if (isExtras)
				{
					trace('WENT BACK TO EXTRAS MENU??');
					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();


					if (FlxG.save.data.scoreScreen)
					{
						openSubState(new ResultsScreen());
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							inResults = true;
						});
					}
					else
					{
						MusicBeatState.switchState(new SecretState());
						FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)), 0);
						clean();
					}
				}
				else if (fromPasswordMenu)
					{
						trace('WENT BACK TO EXTRAS MENU??');
						paused = true;
		
						FlxG.sound.music.stop();
						vocals.stop();

						if (FlxG.save.data.scoreScreen)
						{
							openSubState(new ResultsScreen());
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								inResults = true;
							});
						}
						else
						{
							MusicBeatState.switchState(new MainMenuState());
							FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)), 0);
							clean();
						}
					}
				else
				{
					trace('WENT BACK TO FREEPLAY??');

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();


					if (FlxG.save.data.scoreScreen)
					{
						openSubState(new ResultsScreen());
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							inResults = true;
						});
					}
					else
					{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)), 0);
						clean();
					}
				}
			}
		}
	}

	public var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	public function getRatesScore(rate:Float, score:Float):Float
	{
		var rateX:Float = 1;
		var lastScore:Float = score;
		var pr = rate - 0.05;
		if (pr < 1.00)
			pr = 1;

		while (rateX <= pr)
		{
			if (rateX > pr)
				break;
			lastScore = score + ((lastScore * rateX) * 0.022);
			rateX += 0.05;
		}

		var actualScore = Math.round(score + (Math.floor((lastScore * pr)) * 0.022));

		return actualScore;
	}

	var timeShown = 0;
	//var currentTimingShown:FlxText = null;

	function checkNoteType(char:String, note:Note)
	{
		switch (char)
		{
			case 'bf':
				if (!note.noAnimation)
				{
				switch (note.noteType)
				{
					case 2 | 'Bullet Note':{
						boyfriend.playAnim('dodge', true);
						FlxG.sound.play(Paths.sound('hankshoot'), FlxG.random.float(0.1, 0.2));}
					case 1 | 'Hurt Note':
						health -= 0.2;
						misses++;
					default:{
						if (note.isAlt) boyfriend.playAnim('sing' + dataSuffix[note.noteData] + '-alt', true);
						else boyfriend.playAnim('sing' + dataSuffix[note.noteData], true);}}}
			case 'dad':
			{
				callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
				if (!note.noAnimation)
				{if (note.isAlt) dad.playAnim('sing' + dataSuffix[note.noteData] + '-alt', true);
				else dad.playAnim('sing' + dataSuffix[note.noteData], true);}
			}
			case 'gf':
			{
				if (!note.noAnimation)
				{if (note.isAlt) gf.playAnim('sing' + dataSuffix[note.noteData] + '-alt', true);
				else gf.playAnim('sing' + dataSuffix[note.noteData], true);}
			}
				
		}	
	}

	private function popUpScore(daNote:Note):Void
	{
		setOnLuas('score', songScore);
		setOnLuas('misses', misses);
		var noteDiff:Float;
		if (daNote != null)
			noteDiff = -(daNote.strumTime - Conductor.songPosition);
		else
			noteDiff = Conductor.safeZoneOffset; // Assumed SHIT if no note was given
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = Ratings.judgeNote(noteDiff);

		switch (daRating)
		{
			case 'shit':
				daRating = 'shit';
				score = -300;
				combo = 0;
				misses++;
				health -= 0.1;
				ss = false;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.06;
				ss = false;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				goods++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				daRating = 'sick';
				if (health < 2)
					health += 0.04;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
		}

		if (songMultiplier >= 1.05)
			score = getRatesScore(songMultiplier, score);

		// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);

			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
			var pixelShitPart3:String = null;

			if (SONG.noteStyle == 'pixel')
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
				pixelShitPart3 = 'week6';
			}

			rating.loadGraphic(Paths.loadImage(pixelShitPart1 + daRating + pixelShitPart2, pixelShitPart3));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;

			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = HelperFunctions.truncateFloat(noteDiff / songMultiplier, 3);
			if (PlayStateChangeables.botPlay)
				msTiming = 0;


			/*if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			timeShown = 0;
			switch (daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;*/

			if (msTiming >= 0.03 && offsetTesting)
			{
				// Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
			}

			/*if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;*/

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(pixelShitPart1 + 'combo' + pixelShitPart2, pixelShitPart3));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			/*currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;*/

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			//currentTimingShown.velocity.x += comboSpr.velocity.x;
			if (!PlayStateChangeables.botPlay)
				add(rating);

			if (SONG.noteStyle != 'pixel')
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = FlxG.save.data.antialiasing;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = FlxG.save.data.antialiasing;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * CoolUtil.daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * CoolUtil.daPixelZoom * 0.7));
			}

			//currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();

			//currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (combo > highestCombo)
				highestCombo = combo;

			// make sure we have 3 digits to display (looks weird otherwise lol)
			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2, pixelShitPart3));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (SONG.noteStyle != 'pixel')
				{
					numScore.antialiasing = FlxG.save.data.antialiasing;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * CoolUtil.daPixelZoom));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				add(numScore);

				visibleCombos.push(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						visibleCombos.remove(numScore);
						numScore.destroy();
					},
					onUpdate: function(tween:FlxTween)
					{
						if (!visibleCombos.contains(numScore))
						{
							tween.cancel();
							numScore.destroy();
						}
					},
					startDelay: Conductor.crochet * 0.002
				});

				if (visibleCombos.length > seperatedScore.length + 20)
				{
					for (i in 0...seperatedScore.length - 1)
					{
						visibleCombos.remove(visibleCombos[visibleCombos.length - 1]);
					}
				}

				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */

			coolText.text = Std.string(seperatedScore);
			// add(coolText);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					//if (currentTimingShown != null)
						//currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					/*if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}*/
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		var anas:Array<Ana> = [null, null, null, null];

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					goodNoteHit(daNote);
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false, false, false, false];

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
							{
								noteMiss(shit, null);
							}
						}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[coolNote.noteData].hit = true;
							anas[coolNote.noteData].hitJudge = Ratings.judgeNote(noteDiff);
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};

				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.dance();
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}
		}
		if (PlayStateChangeables.botPlay)
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.mustPress && Conductor.songPosition >= daNote.strumTime && (daNote.noteType != 1 || daNote.noteType != 'Hurt Note'))
				{
					goodNoteHit(daNote);
					boyfriend.holdTimer = 0;
				}
			});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss')
				&& (boyfriend.animation.curAnim.curFrame >= 10 || boyfriend.animation.curAnim.finished))
				boyfriend.dance();
		}

		if (controls.ATTACK && allowToAttack && !FlxFlicker.isFlickering(dad))
		{
			if (boyfriend.curCharacter == 'bf' || boyfriend.animation.exists('attack'))
			{
				boyfriend.playAnim('attack', true);
				if (FlxG.save.data.flashing)
					FlxFlicker.flicker(dad, 0.2, 0.05, true);
				health += 0.02;
			}
		}

		playerStrums.forEach(function(spr:StaticArrow)
		{
			if (!PlayStateChangeables.botPlay)
			{
				if (keys[spr.ID]
					&& spr.animation.curAnim.name != 'confirm'
					&& spr.animation.curAnim.name != 'pressed'
					&& !spr.animation.curAnim.name.startsWith('dirCon'))
					spr.playAnim('pressed', false);
				if (!keys[spr.ID])
					spr.playAnim('static', false);
			}
			else if (FlxG.save.data.cpuStrums)
			{
				if (spr.animation.finished)
					spr.playAnim('static');
			}
		});
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned && (daNote.noteType != 1 || daNote.noteType != 'Hurt Note'))
		{
			if (daNote.noteType == 2 || daNote.noteType == 'Bullet Note')
			{
				health = 0;
			}
			// health -= 0.2;
			if (combo > 5 && gf.animOffsets.exists('sad') && (daNote.noteType != 1 || daNote.noteType != 'Hurt Note'))
			{
				gf.playAnim('sad');
			}
			if (combo != 0)
			{
				combo = 0;
				popUpScore(null);
			}
			misses++;

			totalNotesHit -= 1;

			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;

			if (FlxG.save.data.missSounds)
			{
				FlxG.sound.play(Paths.soundRandom('missnote' + altSuffix, 1, 3), FlxG.random.float(0.1, 0.2));
			}

			// Hole switch statement replaced with a single line :)
			if (boyfriend.curCharacter == 'bf'
				|| boyfriend.curCharacter == 'bf-christmas'
				|| boyfriend.curCharacter == 'bf-car'
				|| boyfriend.curCharacter == 'bf-pixel'
				&& (daNote.noteType != 1 || daNote.noteType != 'Hurt Note'))
			{
				boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);
			}

			callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
			if (FlxG.save.data.enablePsychInterface)
				recalculateRating();
			else
				updateAccuracy();
		}
	}

	/*function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;

			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
			updateAccuracy();
		}
	 */
	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function recalculateRating() {
		totalPlayed += 1;
		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (misses > 0 && misses < 10) ratingFC = "SDCB";
			else if (misses >= 10) ratingFC = "Clear";
		}

		if (!FlxG.save.data.language)
			{
				if(ratingName == '?') {
					scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + misses + ' | Rating: ' + ratingName;
				} else {
					scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + misses + ' | Rating: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
				}
			}
			else
			{
				if(ratingName == '?') {
					scoreTxt.text = 'Счёт: ' + songScore + ' | Пропуски: ' + misses + ' | Рейтинг: ' + ratingName;
				} else {
					scoreTxt.text = 'Счёт: ' + songScore + ' | Пропуски: ' + misses + ' | Рейтинг: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
				}
			}

		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.judgeNote(noteDiff);

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));

		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.judgeNote(noteDiff);

		if (note.rating == "miss")
		{
			return;
		}

		if (note.rating == 'sick' && !note.isSustainNote && !PlayStateChangeables.botPlay)
		{
			spawnNoteSplashOnNote(note);
		}

		if (note.isSustainNote && note.rating != "miss")
		{
			health += 0.005;
		}

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
			}

			if (note.gfNote)
				checkNoteType('gf', note);
			else if (note.noteType == 3 || note.noteType == 'GF Sing Note')
				checkNoteType('gf', note);
			else 
				checkNoteType('bf', note);


			if (!PlayStateChangeables.botPlay/* || FlxG.save.data.cpuStrums*/)
			{
				playerStrums.forEach(function(spr:StaticArrow)
				{
					pressArrow(spr, spr.ID, note);
				});
			}
			else
			{
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				playerStrums.forEach(function(spr:StaticArrow)
				{
					pressArrow(spr, spr.ID, note, time);
				});
			}

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			else
			{
				note.wasGoodHit = true;
			}
			if (!note.isSustainNote)
			{
				if (FlxG.save.data.enablePsychInterface)
					recalculateRating();
				else
					updateAccuracy();
			}

			var isSus:Bool = note.isSustainNote;
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:Int = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(FlxG.save.data.notesplashes && note != null) {
			var strum:StaticArrow = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var type:Int = note.noteType;

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, type);
		grpNoteSplashes.add(splash);
	}

	function pressArrow(spr:StaticArrow, idCheck:Int, daNote:Note, ?time:Float)
	{
		if (Math.abs(daNote.noteData) == idCheck)
		{
			if (!FlxG.save.data.stepMania)
			{
				if (spr != null) spr.playAnim('confirm', true);
				if (time != null) spr.resetAnim = time;
			}
			else
			{
				spr.playAnim('dirCon' + daNote.originColor, true);
				spr.localAngle = daNote.originAngle;
			}
		}
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		setOnLuas('curBpm', Conductor.bpm);
		setOnLuas('crochet', Conductor.crochet);
		setOnLuas('stepCrochet', Conductor.stepCrochet);
			
		if (currentSection != null)
		{
			setOnLuas('mustHitSection', currentSection.mustHitSection);
			setOnLuas('altAnim', currentSection.playerAltAnim);
			setOnLuas('gfSection', currentSection.gfSection);

			dadAltAnim = currentSection.CPUAltAnim;
			bfAltAnim = currentSection.playerAltAnim;
			gfAltAnim = currentSection.gfAltAnim;

			if (curBeat % idleBeat == 0)
			{
				if (allowedToHeadbang && (!gf.animation.curAnim.name.startsWith("sing") || gf.animation.curAnim.finished) && (!gf.animation.exists('danceRight') && !gf.animation.exists('danceLeft')))
					gf.dance(forcedToIdle, gfAltAnim);
				if (idleToBeat && (!dad.animation.curAnim.name.startsWith('sing') || dad.animation.curAnim.finished))
					dad.dance(forcedToIdle, dadAltAnim);
				if (idleToBeat && (!boyfriend.animation.curAnim.name.startsWith('sing') || boyfriend.animation.curAnim.finished))
					boyfriend.dance(forcedToIdle, bfAltAnim);
			}
			else if ((dad.animation.exists('danceRight') && dad.animation.exists('danceLeft')) && (!dad.animation.curAnim.name.startsWith('sing') || dad.animation.curAnim.finished))
				dad.dance(forcedToIdle, dadAltAnim);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camzoom && songMultiplier == 1)
		{
			// HARDCODING FOR MILF ZOOMS!
			if (PlayState.SONG.songId == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015 / songMultiplier;
				camHUD.zoom += 0.03 / songMultiplier;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015 / songMultiplier;
				camHUD.zoom += 0.03 / songMultiplier;
			}
		}
		if (songMultiplier == 1)
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		else
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 4));
			iconP2.setGraphicSize(Std.int(iconP2.width + 4));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if (!endingSong && currentSection != null)
		{
			gfAltAnim = currentSection.gfAltAnim;
			if (allowedToHeadbang && (!gf.animation.curAnim.name.startsWith("sing") || gf.animation.curAnim.finished) && (gf.animation.exists('danceRight') && gf.animation.exists('danceLeft')))
				gf.dance(forcedToIdle, gfAltAnim);

			if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			{
				boyfriend.playAnim('hey', true);
			}

			if (curBeat % 16 == 15 && SONG.songId == 'tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
			{
				if (vocals.volume != 0)
				{
					boyfriend.playAnim('hey', true);
					dad.playAnim('cheer', true);
				}
				else
				{
					dad.playAnim('sad', true);
					FlxG.sound.play(Paths.soundRandom('GF_', 1, 4, 'shared'), 0.3);
				}
			}

			if (PlayStateChangeables.Optimize)
				if (vocals.volume == 0 && !currentSection.mustHitSection)
					vocals.volume = 1;
		}
		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	private var preventLuaRemove:Bool = false;
	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	public var closeLuas:Array<FunkinLua> = [];
	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}

		for (i in 0...closeLuas.length) {
			luaArray.remove(closeLuas[i]);
			closeLuas[i].stop();
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	public var cleanedSong:SongData;

	function poggers(?cleanTheSong = false)
	{
		var notes = [];

		if (cleanTheSong)
		{
			cleanedSong = SONG;

			for (section in cleanedSong.notes)
			{
				var removed = [];

				for (note in section.sectionNotes)
				{
					// commit suicide
					var old = note[0];
					if (note[0] < section.startTime)
					{
						notes.push(note);
						removed.push(note);
					}
					if (note[0] > section.endTime)
					{
						notes.push(note);
						removed.push(note);
					}
				}

				for (i in removed)
				{
					section.sectionNotes.remove(i);
				}
			}

			for (section in cleanedSong.notes)
			{
				var saveRemove = [];

				for (i in notes)
				{
					if (i[0] >= section.startTime && i[0] < section.endTime)
					{
						saveRemove.push(i);
						section.sectionNotes.push(i);
					}
				}

				for (i in saveRemove)
					notes.remove(i);
			}

			trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);

			SONG = cleanedSong;
		}
		else
		{
			for (section in SONG.notes)
			{
				var removed = [];

				for (note in section.sectionNotes)
				{
					// commit suicide
					var old = note[0];
					if (note[0] < section.startTime)
					{
						notes.push(note);
						removed.push(note);
					}
					if (note[0] > section.endTime)
					{
						notes.push(note);
						removed.push(note);
					}
				}

				for (i in removed)
				{
					section.sectionNotes.remove(i);
				}
			}

			for (section in SONG.notes)
			{
				var saveRemove = [];

				for (i in notes)
				{
					if (i[0] >= section.startTime && i[0] < section.endTime)
					{
						saveRemove.push(i);
						section.sectionNotes.push(i);
					}
				}

				for (i in saveRemove)
					notes.remove(i);
			}

			trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);

			SONG = cleanedSong;
		}
	}
}
// u looked :O -ides
