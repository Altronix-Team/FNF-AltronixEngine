package states;

import animateatlas.AtlasFrameMaker;
import flixel.util.FlxSpriteUtil;
import gameplayStuff.Song.Event;
import openfl.media.Sound;
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
import gameplayStuff.Section.SwagSection;
import gameplayStuff.Song.SongData;
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
#if desktop
import GameJolt.GameJoltAPI;
#end
import gameplayStuff.FunkinLua;
import flixel.util.FlxSave;
import gameplayStuff.DialogueBoxPsych;
import gameplayStuff.StageData;
import openfl.utils.Assets as OpenFlAssets;
import flixel.group.FlxSpriteGroup;
import Replay.Ana;
import Replay.Analysis;
import gameplayStuff.Character;
import gameplayStuff.Boyfriend;
import gameplayStuff.Note;
import gameplayStuff.StaticArrow;
import gameplayStuff.NoteSplash;
import gameplayStuff.HealthIcon;
import gameplayStuff.Stage;
import gameplayStuff.Song;
import gameplayStuff.Song.EventsAtPos;
import gameplayStuff.DialogueBox;
import gameplayStuff.Conductor;
import gameplayStuff.PlayStateChangeables;
import gameplayStuff.Highscore;
import gameplayStuff.CutsceneHandler;
import gameplayStuff.TimingStruct;
import scriptStuff.ModchartHelper;
import scriptStuff.HscriptStage;
import scriptStuff.ScriptHelper.ScriptException;
import scriptStuff.PolymodHscriptStage;
#if desktop
import DiscordClient;
#end

#if VIDEOS_ALLOWED
import vlc.MP4Handler;
#end

using StringTools;
using hx.strings.Strings;

class PlayState extends MusicBeatState
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

	public var currentBeat:Int = 0;
	public var currentStep:Int = 0;

	public var timerCount:Float = 0;
	public var maxTimerCounter:Float = 200;

	public static var songPosBG:FlxSprite;

	public var visibleCombos:Array<FlxSprite> = [];

	public var addedBotplay:Bool = false;
	public var addedBotplayOnce:Bool = false;

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

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	var chars:Array<Character> = [];

	public var notes:FlxTypedGroup<Note>;

	public var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSectionInt:Int = 0;

	private var camFollow:FlxObject;
	public var cameraSpeed:Float = 1;

	private static var prevCamFollow:FlxObject;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public var strumLineNotes:FlxTypedGroup<StaticArrow> = null;
	public var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public var opponentStrums:FlxTypedGroup<StaticArrow> = null;

	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var stageGroup:FlxTypedGroup<FlxSprite>;
	public var ratingsGroup:FlxTypedGroup<FlxSprite>;

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

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;

	public var camGame:FlxCamera;

	public var cannotDie = false;
	public var isDead:Bool = false;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true;
	var idleBeat:Int = 2;
	var forcedToIdle:Bool = false;
	var allowedToHeadbang:Bool = true;
	var allowedToCheer:Bool = false;
	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];
	var dialogueJson:DialogueFile = null;

	var overlay:ModchartSprite;
	var overlayColor:FlxColor = 0xFFFF0000;
	var colorTween:FlxTween;

	var songName:FlxText;

	var altSuffix:String = "";

	var fc:Bool = true;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public static var currentSong = "noneYet";

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var judgementCounter:FlxText;

	//Two players mode stuff
	var scoreP1:FlxText;
	var scoreP2:FlxText;
	var intScoreP1:Int = 0;
	var intScoreP2:Int = 0;
	

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

	public var Stage:Stage;

	public var hscriptStage:HscriptStage;
	var hscriptFiles:Array<ModchartHelper> = [];

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
	public var modchartObjects:Map<String, FlxSprite> = new Map<String, FlxSprite>();

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
	private var isCameraOnForcedPos:Bool = false;
	public var skipCountdown:Bool = false;

	public var songPosBarColorRGB:Array<Int> = [0, 255, 128];

	public var hideGF:Bool;

	private var chartingState:FlxText;

	public static var isPixel:Bool;

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
	var hscriptStageCheck = false;

	public static var doof = null;

	public static var stageCheck:String = 'stage';

	public var events:Array<gameplayStuff.Song.EventsAtPos> = [];

	var noteTypeCheck:String = 'normal';

	var funnyStartObjects:Array<FlxBasic> = [];

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

		PlayStateChangeables.useMiddlescroll = FlxG.save.data.middleScroll;
		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed * songMultiplier;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;

		if (isStoryMode)
			PlayStateChangeables.twoPlayersMode = false;

		if (PlayStateChangeables.twoPlayersMode)
			PlayStateChangeables.botPlay = false;

		removedVideo = false;

		#if FEATURE_LUAMODCHART
		executeModchart = true;
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		Debug.logInfo('Searching for mod chart? ($executeModchart) at "songs/${PlayState.SONG.songId}/"');	

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
			detailsText = LanguageStuff.replaceFlagsAndReturn("$STORY_MODE", "playState", ["<storyWeek>"], [Std.string(storyWeek)]);
		}
		if (isFreeplay)
		{
			detailsText = LanguageStuff.getPlayState("$FREEPLAY");
		}
		if (isExtras)
		{
			detailsText = LanguageStuff.getPlayState("$EXTRAS");
		}
		if (fromPasswordMenu)
		{
			detailsText = LanguageStuff.getPlayState("$EXTRAS");
		}

		// String for when the game is paused
		detailsPausedText = LanguageStuff.replaceFlagsAndReturn("$PAUSED", "playState", ["<detailsText>"], [Std.string(detailsText)]);

		// Updating Discord Rich Presence.
		if (PlayStateChangeables.botPlay)
		{
			DiscordClient.changePresence(LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_ONE", "playState",
				["<detailsText>", "<songName>", "<storyDifficultyText>", "<timeLeft>", "<accuracy>"],
				[Std.string(detailsText), SONG.songName, storyDifficultyText, '', LanguageStuff.getPlayState("$BOTPLAY_TEXT")]), iconRPC);
		}
		else if (!PlayStateChangeables.botPlay)
		{	
			DiscordClient.changePresence(LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_ONE", "playState", [
				"<detailsText>",
				"<songName>",
				"<storyDifficultyText>",
				"<timeLeft>",
				"<accuracy>"
			], [
				Std.string(detailsText),
				SONG.songName,
				storyDifficultyText,
				'',
				Ratings.GenerateLetterRank(accuracy)
			]),
				LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_TWO", "playState", [
				"<accuracy>",
				"<songScore>",
				"<misses>"
				], [
					CoolUtil.truncateFloat(accuracy, 2),
				songScore,
				misses
				]), iconRPC);
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
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camSustains, false);
		FlxG.cameras.add(camNotes, false);

		camHUD.zoom = PlayStateChangeables.zoom;

		//FlxCamera.defaultCameras = [camGame];
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', '');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		Conductor.bpm = SONG.bpm;

		/*if (SONG.eventObjects == null)
		{
			SONG.eventObjects = [new Song.Event("Init BPM", 0, SONG.bpm, "BPM Change")];
		}*/

		if (SONG.eventsArray == null)
		{	
			var initBpm:gameplayStuff.Song.EventsAtPos = 
			{
				position: 0,
				events: []
			};
			var firstEvent:gameplayStuff.Song.EventObject = new gameplayStuff.Song.EventObject("Init BPM", SONG.bpm, "BPM Change");
	
			initBpm.events.push(firstEvent);
			SONG.eventsArray = [initBpm];
		}

		TimingStruct.clearTimings();

		var currentIndex = 0;
		for (i in SONG.eventsArray)
		{
			var beat:Float = i.position;
			for (j in i.events)
			{
				if (j.type == "BPM Change")
				{
					var endBeat:Float = Math.POSITIVE_INFINITY;

					var bpm = j.value;

					TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60));
						var step = ((60 / data.bpm) * 1000) / 4;
						TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step));
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
					}

					currentIndex++;
				}
			}
		}

		recalculateAllSectionTimes();

		ratingsGroup = new FlxTypedGroup<FlxSprite>();

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		if (Paths.doesTextAssetExist(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue')))
			dialogue = CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue'));

		switch (SONG.noteStyle)
		{
			case 'pixel':
				isPixel = true;
			case 'normal':
				isPixel = false;
		}

		noteTypeCheck = SONG.noteStyle;

		stageCheck = SONG.stage;

		if (isStoryMode)
			songMultiplier = 1;

		var gfCheck:String = 'gf';

		gfCheck = SONG.gfVersion;

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		#if LUA_ALLOWED
		if (OpenFlAssets.exists('assets/stages/' + SONG.stage + '.lua'))
			luaStage = true;
		#end

		if (luaStage && !hscriptStageCheck)
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
			startCharacterLua(gf.curCharacter);
			startCharacterHscript(gf.curCharacter);

			setOnHscript('gfName', gf.curCharacter);

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
			startCharacterLua(boyfriend.curCharacter);
			startCharacterHscript(boyfriend.curCharacter);

			setOnHscript('boyfriendName', boyfriend.curCharacter);

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
			startCharacterLua(dad.curCharacter);
			startCharacterHscript(dad.curCharacter);

			setOnHscript('dadName', dad.curCharacter);

			setOnLuas('dadName', dad.curCharacter);
		}

		chars = [boyfriend, gf, dad];

		if (!stageTesting 
			#if LUA_ALLOWED
			&& !OpenFlAssets.exists('assets/stages/' + SONG.stage + '.lua')
			&& !OpenFlAssets.exists('assets/scripts/stages/${SONG.stage}.hscript')
			#end)
		{
			Stage = new Stage(SONG.stage);
		}
		else
		{
			if (OpenFlAssets.exists('assets/scripts/stages/${SONG.stage}.hscript'))
			{
				try
				{
					hscriptStage = /*PolymodHscriptStage.init(SONG.stage, FlxG.random.int());*/new HscriptStage('assets/scripts/stages/${SONG.stage}.hscript', this);
					add(hscriptStage);
					hscriptFiles.push(hscriptStage);
					hscriptStageCheck = true;
				}						
				catch (e)
				{
					if (Std.isOfType(e, ScriptException))
					{
						scriptError(e);
						return;
					}
					else
						Debug.displayAlert('Error with hscript stage file!', Std.string(e));
				}
			}	
			#if LUA_ALLOWED
			else if (OpenFlAssets.exists('assets/stages/' + SONG.stage + '.lua'))
			{
				luaArray.push(new FunkinLua(OpenFlAssets.getPath('assets/stages/' + SONG.stage + '.lua')));
			}
			#if FEATURE_FILESYSTEM
			else if (FileSystem.exists('assets/stages/' + SONG.stage + '.lua'))
			{
				luaArray.push(new FunkinLua('assets/stages/' + SONG.stage + '.lua'));
			}
			#end
			else
			#end
			{
				Debug.logError('Something strange with stage scripts, loading default stage');
				Stage = new Stage('stage');
			}
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
	
		if (!luaStage && hscriptStageCheck)
		{
			if (!hscriptStage.addedCharacterGroups.contains(gfGroup))
				add(gfGroup);
			else
				gfGroup = hscriptStage.gfGroup;

			if (!hscriptStage.addedCharacterGroups.contains(dadGroup))
				add(dadGroup);
			else
				dadGroup = hscriptStage.dadGroup;
			
			if (!hscriptStage.addedCharacterGroups.contains(boyfriendGroup))
				add(boyfriendGroup);
			else
				boyfriendGroup = hscriptStage.boyfriendGroup;
		}

		if (!luaStage && !hscriptStageCheck)
		{
			for (i in Stage.toAdd)
			{
				add(i);
				stageGroup.add(i);
			}
		}

		if (!PlayStateChangeables.Optimize && (!luaStage && !hscriptStageCheck))
			for (index => array in Stage.layInFront)
			{
				switch (index)
				{
					case 0:
						add(gfGroup);
						gfGroup.scrollFactor.set(0.95, 0.95);
						if (!luaStage && !hscriptStageCheck)
						{
							for (bg in array)
							{
								add(bg);
								stageGroup.add(bg);
							}
						}
					case 1:
						add(dadGroup);
						if (!luaStage && !hscriptStageCheck)
						{
							for (bg in array)
							{
								add(bg);
								stageGroup.add(bg);
							}
						}
					case 2:
						add(boyfriendGroup);
						if (!luaStage && !hscriptStageCheck)
						{
							for (bg in array)
							{
								add(bg);
								stageGroup.add(bg);
							}
						}
				}
			}

		switch (boyfriend.curCharacter)
		{
			case 'bf-pixel':
				GameOverSubstate.stageSuffix = '-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';
			case 'bfAndGF':
				GameOverSubstate.characterName = 'bfAndGF-DEAD';
		}

		// launch song lua and hscript
		#if LUA_ALLOWED
		var filesToCheck:Array<String> = Paths.listLuaInPath('assets/data/songs/' + SONG.songId + '/');
		var filesPushed:Array<String> = [];
		for (file in filesToCheck)
		{
			if(!filesPushed.contains(file))
			{
				if (OpenFlAssets.exists('assets/data/songs/' + SONG.songId + '/' + file + '.lua'))
				{
					luaArray.push(new FunkinLua(OpenFlAssets.getPath('assets/data/songs/' + SONG.songId + '/' + file + '.lua')));
					filesPushed.push(file);
				}
			}
		}
		#end

		#if desktop
		if (OpenFlAssets.exists(Paths.getScriptFile(SONG.songId, 'songs')))
		{
			try
			{
				hscriptFiles.push(new ModchartHelper(Paths.getScriptFile(SONG.songId, 'songs'), this));
			}
			catch (e)
			{
				if (Std.isOfType(e, ScriptException))
				{
					scriptError(e);
					return;
				}
				else
					Debug.displayAlert('Error with hscript file!', Std.string(e));
			}
		}
		#end

		// launch global lua
		#if LUA_ALLOWED
		var filesToCheck:Array<String> = Paths.listLuaInPath('assets/scripts/');
		var filesPushed:Array<String> = [];
		for (file in filesToCheck)
		{
			if(!filesPushed.contains(file))
			{
				if (OpenFlAssets.exists('assets/scripts/' + file + '.lua'))
				{
					luaArray.push(new FunkinLua(OpenFlAssets.getPath('assets/scripts/' + file + '.lua')));
					filesPushed.push(file);
				}		
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

		if (gf.positionArray != null){
		gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];}
		if (dad.positionArray != null){
		dad.x += dad.positionArray[0];
		dad.y += dad.positionArray[1];}
		if (boyfriend.positionArray != null){
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];}

		camPos = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			if (gf.camPos != null){
				camPos.x += gf.getGraphicMidpoint().x + gf.camPos[0];
				camPos.y += gf.getGraphicMidpoint().y + gf.camPos[1];}
			else{
				camPos.x += gf.getGraphicMidpoint().x;
				camPos.y += gf.getGraphicMidpoint().y;
			}
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

		if (!luaStage && !hscriptStageCheck)
			Stage.update(0);

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		if (isStoryMode)
		{
			doof = new DialogueBox(false, dialogue);
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
				if (section.sectionNotes.length > 0)
				{
					if (section.startTime > 5000)
					{
						needSkip = true;
						skipTo = section.startTime - 1000;
					}
					break;
				}
			}
		}

		Conductor.songPosition = -5000;
		Conductor.rawPosition = Conductor.songPosition;

		strumLine = new FlxSprite(PlayStateChangeables.useMiddlescroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
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
			if (!PlayStateChangeables.useMiddlescroll || executeModchart)
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
		opponentStrums = new FlxTypedGroup<StaticArrow>();

		if (SONG.specialSongNoteSkin != FlxG.save.data.noteskin && SONG.specialSongNoteSkin != null){
			noteskinPixelSprite = NoteskinHelpers.generatePixelSprite(SONG.specialSongNoteSkin);
			noteskinPixelSpriteEnds = NoteskinHelpers.generatePixelSprite(SONG.specialSongNoteSkin, true);
			noteskinSprite = NoteskinHelpers.generateNoteskinSprite(SONG.specialSongNoteSkin);}
		else{
			noteskinPixelSprite = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin);
			noteskinSprite = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin);
			noteskinPixelSpriteEnds = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin, true);}

		generateStaticArrows(0);
		generateStaticArrows(1);
		
		for (i in 0...playerStrums.length) {
			setOnHscript('defaultPlayerStrumX' + i, playerStrums.members[i].x);

			setOnHscript('defaultPlayerStrumY' + i, playerStrums.members[i].y);

			setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
			setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
		}
		for (i in 0...opponentStrums.length) {

			setOnHscript('defaultOpponentStrumX' + i, opponentStrums.members[i].x);

			setOnHscript('defaultOpponentStrumY' + i, opponentStrums.members[i].y);

			setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
			setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
		}

		// Update lane underlay positions AFTER static arrows :)

		laneunderlay.x = playerStrums.members[0].x - 25;
		laneunderlayOpponent.x = opponentStrums.members[0].x - 25;

		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);

		// startCountdown();

		if (SONG.songId == null)
			Debug.logTrace('song is null???');
		else
			trace('song looks gucci');
		
		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camHUD];
		add(luaDebugGroup);
		#end

		generateSong(SONG.songId);

		// launch custom events
		#if desktop
		var filesToCheck:Array<String> = Paths.listLuaInPath('assets/custom_events/').concat(Paths.listHscriptInPath('assets/custom_events/'));
		var filesPushed:Array<String> = [];
		for (file in filesToCheck)
		{
			if(!filesPushed.contains(file))
			{
				if (OpenFlAssets.exists('assets/custom_events/' + file + '.lua'))
				{
					luaArray.push(new FunkinLua(OpenFlAssets.getPath('assets/custom_events/' + file + '.lua')));
					filesPushed.push(file);		
				}
				else if (OpenFlAssets.exists('assets/custom_events/' + file + '.hscript'))
				{
					hscriptFiles.push(new ModchartHelper('assets/custom_events/' + file + '.hscript', this));
					filesPushed.push(file);
				}
				else
				{
					Debug.logError('Error with file ' + file);
					filesPushed.push(file);
				}
			}
		}		
		#end

		// launch custom notetypes
		#if desktop
		var filesToCheck:Array<String> = Paths.listLuaInPath('assets/custom_notetypes/').concat(Paths.listHscriptInPath('assets/custom_notetypes/'));
		var filesPushed:Array<String> = [];
		for (file in filesToCheck)
		{
			if(!filesPushed.contains(file))
			{
				if (OpenFlAssets.exists('assets/custom_notetypes/' + file + '.lua'))
				{
					luaArray.push(new FunkinLua(OpenFlAssets.getPath('assets/custom_notetypes/' + file + '.lua')));
					filesPushed.push(file);
				}
				else if (OpenFlAssets.exists('assets/custom_notetypes/' + file + '.hscript'))
				{
					hscriptFiles.push(new ModchartHelper('assets/custom_notetypes/' + file + '.hscript', this));
					filesPushed.push(file);
				}
				else
				{
					Debug.logError('Error with file ' + file);
					filesPushed.push(file);
				}
			}
		}		
		#end

		// launch custom diffs scripts
		#if desktop
		var filesToCheck:Array<String> = Paths.listLuaInPath('assets/custom_difficulties/').concat(Paths.listHscriptInPath('assets/custom_difficulties/'));
		var filesPushed:Array<String> = [];
		for (file in filesToCheck)
		{
			if (!filesPushed.contains(file))
			{
				if (OpenFlAssets.exists('assets/custom_difficulties/' + file + '.lua'))
				{
					luaArray.push(new FunkinLua(OpenFlAssets.getPath('assets/custom_difficulties/' + file + '.lua')));
					filesPushed.push(file);
				}
				else if (OpenFlAssets.exists('assets/custom_difficulties/' + file + '.hscript'))
				{
					hscriptFiles.push(new ModchartHelper('assets/custom_difficulties/' + file + '.hscript', this));
					filesPushed.push(file);
				}
				else
				{
					Debug.logError('Error with file ' + file);
					filesPushed.push(file);
				}
			}
		}
		#end

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
		moveCameraSection();

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.loadImage('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		if (isStoryMode)
		{
			healthBarBG.alpha = 0;
			funnyStartObjects.push(healthBarBG);
		}

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		if (isStoryMode)
		{
			healthBar.alpha = 0;
			funnyStartObjects.push(healthBar);
		}
		// healthBar

		engineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			SONG.songName
			+ (FlxMath.roundDecimal(songMultiplier, 2) != 1.00 ? " (" + FlxMath.roundDecimal(songMultiplier, 2) + "x)" : "")
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty),
			16);
		engineWatermark.setFormat(Paths.font(LanguageStuff.fontName), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		engineWatermark.scrollFactor.set();
		add(engineWatermark);
		if (isStoryMode)
		{
			engineWatermark.alpha = 0;
			funnyStartObjects.push(engineWatermark);
		}

		if (PlayStateChangeables.useDownscroll)
			engineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.screenCenter(X);
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font(LanguageStuff.fontName), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (FlxG.save.data.enablePsychInterface)
		{
			if(ratingName == '?') {
			scoreTxt.text = LanguageStuff.replaceFlagsAndReturn("$PSYCH_RATING_WITHOUT_AC", "playState", ["<score>", "<misses>", "<ratingName>"],
				[Std.string(songScore), Std.string(misses), ratingName]);
			} else {
				scoreTxt.text = LanguageStuff.replaceFlagsAndReturn("$PSYCH_RATING_WITH_AC", "playState", ["<score>", "<misses>", "<ratingName>", "<ratingPercent>", "<ratingFC>"],
				[
					Std.string(songScore),
					Std.string(misses),
					ratingName,
					Std.string(Highscore.floorDecimal(ratingPercent * 100, 2)),
					ratingFC]);
			}
		}
		else
			scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);

		if (isStoryMode)
		{
			scoreTxt.alpha = 0;
			funnyStartObjects.push(scoreTxt);
		}

		if (!FlxG.save.data.healthBar)
			scoreTxt.y = healthBarBG.y;

		scoreP1 = new FlxText(755, healthBarBG.y + 50, 0, 'Player 1 score: ' + Std.string(intScoreP1), 20);
		scoreP1.scrollFactor.set();
		scoreP1.setFormat(Paths.font(LanguageStuff.fontName), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		scoreP2 = new FlxText(400, healthBarBG.y + 50, 0, 'Player 2 score: ' + Std.string(intScoreP2), 20);
		scoreP2.scrollFactor.set();
		scoreP2.setFormat(Paths.font(LanguageStuff.fontName), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(Paths.font(LanguageStuff.fontName), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
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

			if (isStoryMode)
			{
				judgementCounter.alpha = 0;
				funnyStartObjects.push(judgementCounter);
			}
		}

		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			LanguageStuff.getPlayState("$BOTPLAY"), 20);
		botPlayState.setFormat(Paths.font(LanguageStuff.fontName), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		botPlayState.cameras = [camHUD];
		if (PlayStateChangeables.botPlay && !chartingMode)
			add(botPlayState);

		if (isStoryMode)
		{
			botPlayState.alpha = 0;
			funnyStartObjects.push(botPlayState);
		}

		addedBotplay = PlayStateChangeables.botPlay;

		chartingState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			LanguageStuff.getPlayState("$CHARTING"), 20);
		chartingState.setFormat(Paths.font(LanguageStuff.fontName), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		chartingState.scrollFactor.set();
		chartingState.borderSize = 4;
		chartingState.borderQuality = 2;
		chartingState.cameras = [camHUD];
		if (chartingMode)
			add(chartingState);

		if (isStoryMode)
		{
			chartingState.alpha = 0;
			funnyStartObjects.push(chartingState);
		}

		iconP1 = new HealthIcon(boyfriend.characterIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		if (isStoryMode)
		{
			iconP1.alpha = 0;
			funnyStartObjects.push(iconP1);
		}

		iconP2 = new HealthIcon(dad.characterIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		
		if (isStoryMode)
		{
			iconP2.alpha = 0;
			funnyStartObjects.push(iconP2);
		}

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
		if (!PlayStateChangeables.twoPlayersMode)
			add(scoreTxt);
		else
		{
			add(scoreP1);
			add(scoreP2);
		}

		if (!PlayStateChangeables.botPlay)
			add(ratingsGroup);

		//Doing that for lua
		for (i in SONG.eventsArray)
		{
			events.push(i);
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		scoreP1.cameras = [camHUD];
		scoreP2.cameras = [camHUD];
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
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

					if (!PlayStateChangeables.botPlay && !addedBotplayOnce)
						Achievements.getAchievement(167272, 'lemon');

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

		for (script in hscriptFiles)
			script.onCreatePost();

		callOnLuas('onCreatePost', []);
	
		// This allow arrow key to be detected by flixel. See https://github.com/HaxeFlixel/flixel/issues/2190
		FlxG.keys.preventDefaultKeys = [];
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		super.create();
	}

	var video:MP4Handler;

	public function playCutscene(name:String, atend:Bool = false, blockFinish:Bool = false)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		video = new MP4Handler();
		video.finishCallback = function()
		{
			if (!blockFinish)
			{
				if (atend)
				{
					if (storyPlaylist.length <= 0)
						FlxG.switchState(new StoryMenuState());
					else
					{
						var diff:String = CoolUtil.difficultyPrefixes[storyDifficulty];
						SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase(), diff);
						FlxG.switchState(new PlayState());
					}
				}
				else
					startCountdown();
			}
		}
		if (OpenFlAssets.getPath(Paths.video(name)) != null)
			video.playVideo(OpenFlAssets.getPath(Paths.video(name)));
		else if (OpenFlAssets.exists(Paths.video(name)))
			video.playVideo(Paths.video(name));
		else
		{
			Debug.logError('Failed to find video');
			if (atend == true)
				{
					if (storyPlaylist.length <= 0)
						FlxG.switchState(new StoryMenuState());
					else
					{
						var diff:String = CoolUtil.difficultyPrefixes[storyDifficulty];
						SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase(), diff);
						FlxG.switchState(new PlayState());
					}
				}
				else
					startCountdown();
		}
		#else
			Debug.logTrace('Videos is not allowed');
		#end
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
			var cutsceneHandler:CutsceneHandler = new CutsceneHandler();

			var songName:String = Paths.formatToSongPath(SONG.songId);
			dadGroup.alpha = 0.00001;
			camHUD.visible = false;
			inCutscene = true;
	
			var tankman:FlxSprite = new FlxSprite(dad.x, dad.y);
			tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
			tankman.antialiasing = FlxG.save.data.antialiasing;
			cutsceneHandler.push(tankman);
			insert(members.indexOf(dadGroup) + 1, tankman);

			var tankman2:FlxSprite = new FlxSprite(dad.x, dad.y);
			tankman2.antialiasing = FlxG.save.data.antialiasing;
			tankman2.alpha = 0.000001;
			cutsceneHandler.push(tankman2);
	
			var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
			gfDance.antialiasing = FlxG.save.data.antialiasing;
			cutsceneHandler.push(gfDance);
			var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
			gfCutscene.antialiasing = FlxG.save.data.antialiasing;
			cutsceneHandler.push(gfCutscene);
			var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);
			picoCutscene.antialiasing = FlxG.save.data.antialiasing;
			cutsceneHandler.push(picoCutscene);
			var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
			boyfriendCutscene.antialiasing = FlxG.save.data.antialiasing;
			cutsceneHandler.push(boyfriendCutscene);

			Main.gjToastManager.visible = false;
	
			cutsceneHandler.finishCallback = function()
			{
				var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
				FlxG.sound.music.fadeOut(timeForStuff);
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
				moveCamera(true);
				startCountdown();
		
				Main.gjToastManager.visible = true;
				camHUD.visible = true;
				dadGroup.alpha = 1;
				gfGroup.alpha = 1;
				boyfriendGroup.alpha = 1;
				boyfriend.visible = true;
				boyfriend.animation.finishCallback = null;
				gf.animation.finishCallback = null;
				gf.dance();
			};
	
			camFollow.setPosition(dad.x + 280, dad.y + 170);
			switch(songName)
			{
				case 'ugh':
					cutsceneHandler.endTime = 12;
					cutsceneHandler.music = 'DISTORTO';
					precacheList.set('wellWellWell', 'sound');
					precacheList.set('killYou', 'sound');
					precacheList.set('bfBeep', 'sound');
					
					var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
					FlxG.sound.list.add(wellWellWell);
					cutsceneHandler.sounds.push(wellWellWell);

					var beep:FlxSound = new FlxSound().loadEmbedded(Paths.sound('bfBeep'));
					FlxG.sound.list.add(beep);
					cutsceneHandler.sounds.push(beep);

					var killYou:FlxSound = new FlxSound().loadEmbedded(Paths.sound('killYou'));
					FlxG.sound.list.add(killYou);
					cutsceneHandler.sounds.push(killYou);
	
					tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
					tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
					tankman.animation.play('wellWell', true);
					FlxG.camera.zoom *= 1.2;
	
					// Well well well, what do we got here?
					cutsceneHandler.timer(0.1, function()
					{
						wellWellWell.play(true);
					});
	
					// Move camera to BF
					cutsceneHandler.timer(3, function()
					{
						camFollow.x += 700;
						camFollow.y += 100;
					});
	
					// Beep!
					cutsceneHandler.timer(4.5, function()
					{
						boyfriend.playAnim('singUP', true);
						boyfriend.specialAnim = true;
						beep.play(true);
					});
	
					// Move camera to Tankman
					cutsceneHandler.timer(6, function()
					{
						camFollow.x -= 750;
						camFollow.y -= 100;
	
						// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
						tankman.animation.play('killYou', true);
						killYou.play(true);
					});
	
				case 'guns':
					cutsceneHandler.endTime = 11.5;
					cutsceneHandler.music = 'DISTORTO';
					tankman.x += 40;
					tankman.y += 10;
	
					var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
					FlxG.sound.list.add(tightBars);
					cutsceneHandler.sounds.push(tightBars);

					tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
					tankman.animation.play('tightBars', true);
					boyfriend.animation.curAnim.finish();
	
					cutsceneHandler.onStart = function()
					{
						tightBars.play(true);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
					};
	
					cutsceneHandler.timer(4, function()
					{
						gf.playAnim('sad', true);
						gf.animation.finishCallback = function(name:String)
						{
							gf.playAnim('sad', true);
						};
					});
	
				case 'stress':
					cutsceneHandler.endTime = 35.5;
					tankman.x -= 54;
					tankman.y -= 14;
					gfGroup.alpha = 0.00001;
					boyfriendGroup.alpha = 0.00001;
					camFollow.setPosition(dad.x + 400, dad.y + 170);
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
					precacheList.set('cutscenes/stress2', 'image');

					tankman2.frames = Paths.getSparrowAtlas('cutscenes/stress2');
					insert(members.indexOf(dadGroup) + 1, tankman2);
	
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
					cutsceneHandler.sounds.push(cutsceneSnd);

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
					}
					
					cutsceneHandler.onStart = function()
					{
						cutsceneSnd.play(true);
					};
	
					cutsceneHandler.timer(15.2, function()
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
					
					cutsceneHandler.timer(17.5, function()
					{
						zoomBack();
					});
		
					cutsceneHandler.timer(19.5, function()
					{
						tankman2.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
						tankman2.animation.play('lookWhoItIs', true);
						tankman2.alpha = 1;
						tankman.visible = false;
					});
		
					cutsceneHandler.timer(20, function()
					{
						camFollow.setPosition(dad.x + 500, dad.y + 170);
					});
		
					cutsceneHandler.timer(31.2, function()
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
					});
		
					cutsceneHandler.timer(32.2, function()
					{
						zoomBack();
					});
			}
		}

	public function schoolIntro(?dialogueBox:DialogueBox):Void
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
				camHUD.visible = false;
				Main.gjToastManager.visible = false;
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
									camHUD.visible = true;
									Main.gjToastManager.visible = true;
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
		}, 4);
	}

	var oldvalue:Dynamic;
	var curColor = FlxColor.WHITE;
	var charColor:FlxColor = FlxColor.WHITE;

	function songOverlay(value:Dynamic, time:Float = 1):Void
	{
		if (oldvalue != value)
		{
			if (value != 'delete')
			{
				/*if (!Std.isOfType(value, FlxColor)){
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
				charColor = FlxColor.fromRGB(red, green, blue, 255);
				}
				else
				{*/
					overlayColor = value;
					charColor = value;
					charColor.alpha = 255;
				//}

				colorTween = FlxTween.color(overlay, time, overlay.color, overlayColor, {
					onComplete: function(twn:FlxTween)
					{
						colorTween = null;
					}
				});

				for (char in chars) {
					char.colorTween = FlxTween.color(char, time, curColor, charColor, {onComplete: function(twn:FlxTween) {
						curColor = charColor;
					}, ease: FlxEase.quadInOut});
				}
			}
			else
			{
				overlayColor = FlxColor.fromRGB(0, 0, 0, 0);
				colorTween = FlxTween.color(overlay, time, overlay.color, overlayColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
				});
				for (char in chars) {
					char.colorTween = FlxTween.color(char, time, char.color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {

					}, ease: FlxEase.quadInOut});
				}
			}
			oldvalue = value;
		}
		else
			return;
	}
		

	public var blockCountdown:Bool = false;

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;

		for (script in hscriptFiles)
			script.onStartCountdown();

		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop && !blockCountdown) {
			appearStaticArrows();

			for (object in funnyStartObjects)
				FlxTween.tween(object, {alpha: 1}, 1, {ease: FlxEase.circOut});

			talking = false;
			startedCountdown = true;	
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;

			setOnHscript('startedCountdown', true);

			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			for (script in hscriptFiles)
				script.onCountdownStarted();

			if (FlxG.sound.music.playing)
				FlxG.sound.music.stop();
			if (vocals != null)
				vocals.stop();

			var swagCounter:Int = 0;

			if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				// this just based on beatHit stuff but compact
				if (allowedToHeadbang && swagCounter % gfSpeed == 0 && (gf.animation.exists('danceRight') && gf.animation.exists('danceLeft')))
					gf.dance();
				if (swagCounter % idleBeat == 0)
				{
					if (idleToBeat && !boyfriend.animation.curAnim.name.endsWith("miss"))
						boyfriend.dance(forcedToIdle);
					if (idleToBeat)
						dad.dance(forcedToIdle);
					if (idleToBeat && (!gf.animation.exists('danceRight') && !gf.animation.exists('danceLeft')))
						gf.dance(forcedToIdle);
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

				for (script in hscriptFiles)
					script.onCountdownTick(swagCounter);

				callOnLuas('onCountdownTick', [swagCounter]);
			}, 4);
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;
	
		FlxG.sound.music.pause();
		vocals.pause();
	
		FlxG.sound.music.time = time;
		FlxG.sound.music.play();
	
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
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

	var keys = [false, false, false, false, false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind,		
			FlxG.save.data.leftBindP2,
			FlxG.save.data.downBindP2,
			FlxG.save.data.upBindP2,
			FlxG.save.data.rightBindP2,
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
			case 65:
				data = 4;
			case 83:
				data = 5;
			case 87:
				data = 6;
			case 68:
				data = 7;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;

		for (script in hscriptFiles)
			script.onKeyRelease(key);

		callOnLuas('onKeyRelease', [key]);
	}

	public var closestNotes:Array<Note> = [];

	public var closestNotesP2:Array<Note> = [];

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
			FlxG.save.data.rightBind,
			FlxG.save.data.leftBindP2,
			FlxG.save.data.downBindP2,
			FlxG.save.data.upBindP2,
			FlxG.save.data.rightBindP2,
		];

		var data = -1;
		var dataP2 = -1;
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
			case 65:
				data = 4;
				dataP2 = 0;
			case 83:
				data = 5;
				dataP2 = 1;
			case 87:
				data = 6;
				dataP2 = 2;
			case 68:
				data = 7;
				dataP2 = 3;
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
		closestNotesP2 = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit)
				closestNotes.push(daNote);
			else if (PlayStateChangeables.twoPlayersMode && daNote.canBeHit && !daNote.mustPress && !daNote.wasGoodHit)
				closestNotesP2.push(daNote);
		}); // Collect notes that can be hit

		closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
		closestNotesP2.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		var dataNotes = [];
		var dataNotesP2 = [];

		if (!PlayStateChangeables.twoPlayersMode){
			for (i in closestNotes)
				if (i.noteData == data && !i.isSustainNote)
					dataNotes.push(i);}
		else{
			for (i in closestNotes){
				if (i.noteData == data && !i.isSustainNote)
					dataNotes.push(i);}
			for (i in closestNotesP2){
				if (i.noteData == dataP2 && !i.isSustainNote)
					dataNotesP2.push(i);
			}}

		if (dataNotes.length != 0 || dataNotesP2.length != 0)
		{
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

						if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2))
						{
							if (note.noteData == data)
							{
								trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
								// just fuckin remove it since it's a stacked note and shouldn't be there
								note.kill();
								notes.remove(note, true);
								note.destroy();
							}				
						}
					}
				}

				boyfriend.holdTimer = 0;
				goodNoteHit(coolNote);
				var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
				ana.hit = true;
				ana.hitJudge = Ratings.judgeNote(noteDiff);
				ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];

				for (script in hscriptFiles)
					script.onKeyPress(key);

				callOnLuas('onKeyPress', [key]);
			}
			else if (dataNotesP2.length != 0 && PlayStateChangeables.twoPlayersMode)
			{
				var coolNote = null;

				for (i in dataNotesP2)
				{
					coolNote = i;
					break;
				}

				if (dataNotesP2.length > 1) // stacked notes or really close ones
				{
					for (i in 0...dataNotesP2.length)
					{
						if (i == 0) // skip the first note
							continue;

						var note = dataNotesP2[i];

						if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2))
						{
							if (note.noteData == dataP2)
							{
								trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
									// just fuckin remove it since it's a stacked note and shouldn't be there
								note.kill();
								notes.remove(note, true);
								note.destroy();
							}
						}
					}
				}

				dad.holdTimer = 0;
				coolNote.hitByP2 = true;
				goodNoteHit(coolNote);
				var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
				ana.hit = true;
				ana.hitJudge = Ratings.judgeNote(noteDiff);
				ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];

				for (script in hscriptFiles)
					script.onKeyPress(key);

				callOnLuas('onKeyPress', [key]);
			}
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			health -= 0.20;

			for (script in hscriptFiles)
				script.noteMissPress(key);

			callOnLuas('noteMissPress', [key]);
		}
	}

	function startNextDialogue() {
		dialogueCount++;

		for (script in hscriptFiles)
			script.onNextDialogue(dialogueCount);

		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {

		for (script in hscriptFiles)
			script.onSkipDialogue(dialogueCount);

		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	public var songStarted = false;

	public var doAnything = false;

	public static var songMultiplier = 1.0;

	public var bar:FlxSprite;

	public var previousRate = songMultiplier;

	public function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId, PlayState.SONG.diffSoundAssets), 1, false);
		}

		FlxG.sound.music.onComplete = onSongComplete;

		songLength = ((FlxG.sound.music.length / songMultiplier) / 1000);
		
		vocals.play();

		// have them all dance when the song starts
		if (allowedToHeadbang && !gf.animation.curAnim.name.startsWith("sing") && (gf.animation.exists('danceRight') && gf.animation.exists('danceLeft')))
			gf.dance();
		if (idleToBeat && (!boyfriend.animation.curAnim.name.startsWith("sing") || boyfriend.animation.curAnim.finished))
			boyfriend.dance(forcedToIdle);
		if (idleToBeat && (!dad.animation.curAnim.name.startsWith("sing") || dad.animation.curAnim.finished))
			dad.dance(forcedToIdle);
		if (idleToBeat && (!gf.animation.exists('danceRight') && !gf.animation.exists('danceLeft')))
			gf.dance(forcedToIdle);

		// Song check real quick
		switch (curSong)
		{
			case 'bopeebo' | 'philly nice' | 'blammed' | 'cocoa' | 'eggnog':
				allowedToCheer = true;
			default:
				allowedToCheer = false;
		}

		#if desktop
		if (PlayStateChangeables.botPlay)
		{
				DiscordClient.changePresence(LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_ONE", "playState", [
					"<detailsText>",
					"<songName>",
					"<storyDifficultyText>",
					"<timeLeft>",
					"<accuracy>"
				], [
					Std.string(detailsText),
					SONG.songName,
					storyDifficultyText,
					'',
					LanguageStuff.getPlayState("$BOTPLAY_TEXT")
				]), iconRPC);
		}
		else if (!PlayStateChangeables.botPlay)
		{
			DiscordClient.changePresence(LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_ONE", "playState", [
				"<detailsText>",
				"<songName>",
				"<storyDifficultyText>",
				"<timeLeft>",
				"<accuracy>"
			], [
				Std.string(detailsText),
				SONG.songName,
				storyDifficultyText,
				'',
				Ratings.GenerateLetterRank(accuracy)
			]),
				LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_TWO", "playState", [
				"<accuracy>",
				"<songScore>",
				"<misses>"
				], [
					CoolUtil.truncateFloat(accuracy, 2),
				songScore,
				misses
				]), iconRPC);
		}
		#end

		FlxG.sound.music.time = startTime;
		if (vocals != null)
			vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;	

		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);

		if (needSkip)
		{
			skipActive = true;
			skipText = new FlxText(healthBarBG.x + 80, healthBarBG.y - 110, 500, "Press space to skip intro");
			skipText.size = 30;
			skipText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
			skipText.cameras = [camHUD];
			add(skipText);
		}

		if (FlxG.save.data.enablePsychInterface)
		{
			FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		}

		setOnHscript('songLength', songLength);

		setOnLuas('songLength', songLength);

		for (script in hscriptFiles)
			script.onSongStart();

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

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId, PlayState.SONG.diffSoundAssets));
		else
			vocals = new FlxSound();

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId, PlayState.SONG.diffSoundAssets), 1, false);
		}

		FlxG.sound.music.volume = 1;
		vocals.volume = 1;

		FlxG.sound.music.pause();

		if (SONG.needsVoices)
			FlxG.sound.cache(Paths.voices(PlayState.SONG.songId, PlayState.SONG.diffSoundAssets));

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
				timeTxt.setFormat(Paths.font(LanguageStuff.fontName), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
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

				songPosBarColorRGB = [255, 255, 255];

				timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
					'songPositionBar', 0, songLength);
				timeBar.scrollFactor.set();
				timeBar.createFilledBar(0xFF000000, FlxColor.fromRGB(songPosBarColorRGB[0],songPosBarColorRGB[1],songPosBarColorRGB[2]));
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
				songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.fromRGB(songPosBarColorRGB[0],songPosBarColorRGB[1],songPosBarColorRGB[2]));
				add(songPosBar);


				bar = new FlxSprite(songPosBar.x, songPosBar.y).makeGraphic(Math.floor(songPosBar.width), Math.floor(songPosBar.height), FlxColor.TRANSPARENT);

				add(bar);

				FlxSpriteUtil.drawRect(bar, 0, 0, songPosBar.width, songPosBar.height, FlxColor.TRANSPARENT, {thickness: 4, color: FlxColor.BLACK});

				songPosBG.width = songPosBar.width;

				songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.songName.length * 5), songPosBG.y - 15, 0, SONG.songName, 16);
				songName.setFormat(Paths.font(LanguageStuff.fontName), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				songName.scrollFactor.set();

				songName.text = SONG.songName + ' (' + FlxStringUtil.formatTime(songLength, false) + ')';
				songName.y = songPosBG.y + (songPosBG.height / 3);

				add(songName);

				if(isStoryMode)
				{
					songPosBG.alpha = 0;
					songPosBar.alpha = 0;
					bar.alpha = 0;
					songName.alpha = 0;

					funnyStartObjects.push(songPosBG);
					funnyStartObjects.push(songPosBar);
					funnyStartObjects.push(bar);
					funnyStartObjects.push(songName);
				}

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
				else if (songNotes[1] < 4 && (!section.mustHitSection || section.gfSection))
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

				var altNote = songNotes[3]
					|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
					|| (section.playerAltAnim && gottaHitNote);

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, altNote, songNotes[4], songNotes[6]);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(songNotes[2] / songMultiplier)));
				swagNote.scrollFactor.set(0, 0);
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = daType;

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				swagNote.isAlt = altNote;

				if (songNotes[3])
					swagNote.animSuffix = '-alt';

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					var altSusNote = songNotes[3]
						|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
						|| (section.playerAltAnim && gottaHitNote);

					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, false, altSusNote, 0, songNotes[6]);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);
					sustainNote.isAlt = altSusNote;

					sustainNote.mustPress = gottaHitNote;
					sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
					sustainNote.noteType = daType;

					if (songNotes[3])
						sustainNote.animSuffix = '-alt';

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

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			if(modchartObjects.exists('note${daNote.ID}'))modchartObjects.remove('note${daNote.ID}');
			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int, tweenShit:Bool = true):Void
	{
		var index = 0;
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StaticArrow = new StaticArrow(-10, strumLine.y);

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

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
					babyArrow.animation.add('confirm', [12 + i, 16 + i], 12, false);
				default:
					if (noteTypeCheck == 'normal')
					{
						babyArrow.frames = noteskinSprite;

						var lowerDir:String = dataSuffix[i].toLowerCase();

						babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
						babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
						babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

						babyArrow.x += Note.swagWidth * i;

						babyArrow.antialiasing = FlxG.save.data.antialiasing;
						babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));	
					}
					else
					{
						babyArrow.frames = NoteskinHelpers.generateNoteskinSprite(noteTypeCheck);

						var lowerDir:String = dataSuffix[i].toLowerCase();

						babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
						babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
						babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

						babyArrow.x += Note.swagWidth * i;

						babyArrow.antialiasing = FlxG.save.data.antialiasing;
						babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));	
					}						
			}
			
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (tweenShit)
				babyArrow.alpha = 0;
			
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				// babyArrow.alpha = 0;
				if (tweenShit)
					if (!PlayStateChangeables.useMiddlescroll || executeModchart || player == 1)
						FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					babyArrow.x += 20;
					opponentStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 110;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (PlayStateChangeables.Optimize || (PlayStateChangeables.useMiddlescroll && !executeModchart && player == 1))
				babyArrow.x -= 320;
			else if (PlayStateChangeables.Optimize || (PlayStateChangeables.useMiddlescroll && !executeModchart && player == 0))
			{
				if (index < 2)
					babyArrow.x -= 75;
				else
					babyArrow.x += FlxG.width / 2 + 25;

				index++;
			}

			opponentStrums.forEach(function(spr:FlxSprite)
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
			if (isStoryMode && !PlayStateChangeables.useMiddlescroll || executeModchart)
				babyArrow.alpha = 1;
			if (PlayStateChangeables.useMiddlescroll)
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
			if(FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				if (vocals != null)
					vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;

			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;

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
			if (PauseSubState.goBack)
			{
				PauseSubState.goToOptions = false;
				PauseSubState.goBack = false;
				openSubState(new PauseSubState());
			}
			else
				openSubState(new OptionsMenu(true));
		}
		else if (paused)
		{
			canPause = true;

			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			paused = false;

			for (script in hscriptFiles)
				script.onResume();

			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null){
			if (startTimer.finished){
					DiscordClient.changePresence(LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_ONE", "playState", [
						"<detailsText>",
						"<songName>",
						"<storyDifficultyText>",
						"<timeLeft>",
						"<accuracy>"
					],
						[
							Std.string(detailsText),
							SONG.songName,
							storyDifficultyText,
							'',
							Ratings.GenerateLetterRank(accuracy)
						]),
						LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_TWO", "playState", ["<accuracy>", "<songScore>", "<misses>"],
							[CoolUtil.truncateFloat(accuracy, 2), songScore, misses]),
						iconRPC, true,songLength- Conductor.songPosition);}
			else{DiscordClient.changePresence(LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_ONE", "playState",
				["<detailsText>", "<songName>", "<storyDifficultyText>", "<timeLeft>", "<accuracy>"],
				[Std.string(detailsText), SONG.songName, storyDifficultyText, '', Ratings.GenerateLetterRank(accuracy)]), iconRPC);}}
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
		if(finishTimer != null) return;

		vocals.stop();
		FlxG.sound.music.stop();

		FlxG.sound.music.play();
		vocals.play();
		FlxG.sound.music.time = Conductor.songPosition * songMultiplier;
		vocals.time = FlxG.sound.music.time;

		#if desktop
		if (PlayStateChangeables.botPlay){
			DiscordClient.changePresence(LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_ONE", "playState", [
				"<detailsText>",
				"<songName>",
				"<storyDifficultyText>",
				"<timeLeft>",
				"<accuracy>"
			], [
				Std.string(detailsText),
				SONG.songName,
				storyDifficultyText,
				'',
				LanguageStuff.getPlayState("$BOTPLAY_TEXT")
			]), iconRPC);}
		else if (!PlayStateChangeables.botPlay){
			DiscordClient.changePresence(LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_ONE", "playState", [
				"<detailsText>",
				"<songName>",
				"<storyDifficultyText>",
				"<timeLeft>",
				"<accuracy>"
			],
				[
					Std.string(detailsText),
					SONG.songName,
					storyDifficultyText,
					'',
					Ratings.GenerateLetterRank(accuracy)
				]),
				LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_TWO", "playState", ["<accuracy>", "<songScore>", "<misses>"],
					[CoolUtil.truncateFloat(accuracy, 2), songScore, misses]),
				iconRPC);}
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

	public var pastEvents:Array<Float> = [];

	public var blockPause:Bool = false;

	public var blockGameOver:Bool = false;

	var currentLuaIndex = 0;

	override public function update(elapsed:Float)
	{

		callOnLuas('onUpdate', [elapsed]);

		#if !debug
		perfectMode = false;
		#end
		if (!PlayStateChangeables.Optimize && (!luaStage && !hscriptStageCheck))
			Stage.update(elapsed);

		if (FlxG.save.data.botplay != PlayStateChangeables.botPlay)
		{
			PlayStateChangeables.botPlay = FlxG.save.data.botplay;
			if (!addedBotplay)
			{
				addedBotplayOnce = true;
				addedBotplay = true;
				add(botPlayState);
			}
			else
			{
				addedBotplay = false;
				botPlayState.kill();
			}
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
					new FlxTimer().start(2, function(timer)
						{
							endSong();
						});
				}
			}
		}

		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();

			var currentIndex = 0;
			for (i in SONG.eventsArray)
			{
				var beat:Float = i.position;

				for (j in i.events)
				{
					if (j.type == "BPM Change")
					{
						var endBeat:Float = Math.POSITIVE_INFINITY;

						var bpm = j.value;

						TimingStruct.addTiming(beat, bpm, endBeat, 0);

						if (currentIndex != 0)
						{
							var data = TimingStruct.AllTimings[currentIndex - 1];
							data.endBeat = beat;
							data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60));
							var step = ((60 / data.bpm) * 1000) / 4;
							TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step));
							TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
						}

						currentIndex++;
					}
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
					Conductor.changeBPM(timingSegBpm, false);
					Conductor.crochet = ((60 / (timingSegBpm) * 1000));
					Conductor.stepCrochet = Conductor.crochet / 4;
				}
			}

			for (i in events)
			{
				checkEventAtPos(i);
			}
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
			&& !cannotDie)
		{
			for (script in hscriptFiles)
				script.onPause();

			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop && !blockPause) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				/*if (FlxG.random.bool(0.1))
				{
					trace('GITAROO MAN EASTER EGG');
					MusicBeatState.switchState(new GitarooPause());
					clean();
				}
				else*/
				if(FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					if (vocals != null)
						vocals.pause();
				}
					openSubState(new PauseSubState());
			}
		}


		if (FlxG.keys.justPressed.SEVEN && songStarted)
		{
			songMultiplier = 1;
			cannotDie = true;

			openChartEditor();

			/*MusicBeatState.switchState(new ChartingState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);*/
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
			/*if (iconP1.nearToDieAnim != null)
				iconP1.animation.play(iconP1.nearToDieAnim);
			else*/
				iconP1.animation.curAnim.curFrame = 1;
		}
		else
		{
			/*if (iconP1.defaultAnim != null)
				iconP1.animation.play(iconP1.defaultAnim);
			else*/
				iconP1.animation.curAnim.curFrame = 0;
		}

		if (healthBar.percent > 80)
		{
			/*if (iconP2.nearToDieAnim != null)
				iconP2.animation.play(iconP2.nearToDieAnim);
			else*/
				iconP2.animation.curAnim.curFrame = 1;
		}
		else
		{
			/*if (iconP2.defaultAnim != null)
				iconP2.animation.play(iconP2.defaultAnim);
			else*/
				iconP2.animation.curAnim.curFrame = 0;
		}

		#if debug
		if (!PlayStateChangeables.Optimize && (!luaStage && !hscriptStageCheck))
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
				MusicBeatState.switchState(new editors.StageDebugState(Stage.curStage, gf.curCharacter, boyfriend.curCharacter, dad.curCharacter));
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

		#if !GITHUB_RELEASE
		if (FlxG.keys.justPressed.ONE && songStarted)
			endSong();
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

		if (FlxG.keys.justPressed.SPACE && !skipActive && !inCutscene)
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
					DiscordClient.changePresence(LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_ONE", "playState", [
						"<detailsText>",
						"<songName>",
						"<storyDifficultyText>",
						"<timeLeft>",
						"<accuracy>"
					],
						[
							Std.string(detailsText),
							SONG.songName,
							storyDifficultyText,
							LanguageStuff.getPlayState("$TIME_LEFT_TEXT") + time,
							Ratings.GenerateLetterRank(accuracy)
						]),
						LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_TWO", "playState", ["<accuracy>", "<songScore>", "<misses>"],
							[CoolUtil.truncateFloat(accuracy, 2), songScore, misses]),
						iconRPC);
					
					timerCount = 0;
				}
			}
			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && curSection != null)
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
			}
		}

		if (health <= 0 && !cannotDie && !PlayStateChangeables.twoPlayersMode)
		{
			if (!usedTimeTravel)
			{

				for (script in hscriptFiles)
					script.onGameOver();

				var ret:Dynamic = callOnLuas('onGameOver', []);
				if(ret != FunkinLua.Function_Stop && !blockGameOver) {
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
						if (storyWeek == 3 && isStoryMode && !PlayStateChangeables.botPlay && !addedBotplayOnce)
						{
							Achievements.getAchievement(167273, 'dead');
						}
						if (PlayState.SONG.songId == 'winter-horrorland'
							&& isStoryMode
							&& !PlayStateChangeables.botPlay
							&& !addedBotplayOnce)
						{
							Achievements.getAchievement(167275, 'corruption');
						}
						if (PlayState.SONG.songId == 'thorns' && isStoryMode && !PlayStateChangeables.botPlay && !addedBotplayOnce)
						{
							Achievements.getAchievement(167276, 'dead-pixel');
						}
						if (PlayState.SONG.songId == 'stress' && isStoryMode && !PlayStateChangeables.botPlay && !addedBotplayOnce)
						{
							Achievements.getAchievement(167277, 'dead-withGf');
						}
						openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
					}

					#if desktop
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence(LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_ONE", "playState", [
						"<detailsText>",
						"<songName>",
						"<storyDifficultyText>",
						"<timeLeft>",
						"<accuracy>"
					],
						[
							LanguageStuff.getPlayState("$GAME_OVER"),
							SONG.songName,
							storyDifficultyText,
							'',
							Ratings.GenerateLetterRank(accuracy)
						]),
						LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_TWO", "playState", ["<accuracy>", "<songScore>", "<misses>"],
							[CoolUtil.truncateFloat(accuracy, 2), songScore, misses]),
						iconRPC);
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
				DiscordClient.changePresence(LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_ONE", "playState", [
					"<detailsText>",
					"<songName>",
					"<storyDifficultyText>",
					"<timeLeft>",
					"<accuracy>"
				],
					[
						LanguageStuff.getPlayState("$GAME_OVER"),
						SONG.songName,
						storyDifficultyText,
						'',
						Ratings.GenerateLetterRank(accuracy)
					]),
					LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_TWO", "playState", ["<accuracy>", "<songScore>", "<misses>"],
						[CoolUtil.truncateFloat(accuracy, 2), songScore, misses]),
					iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			var holdArrayP2:Array<Bool> = [controls.LEFTP2, controls.DOWNP2, controls.UPP2, controls.RIGHTP2];
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
							daNote.y = (opponentStrums.members[Math.floor(Math.abs(daNote.noteData))].y
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
								|| holdArrayP2[Math.floor(Math.abs(daNote.noteData))]
								&& !daNote.ignoreNote)
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
							daNote.y = (opponentStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								+ daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| holdArray[Math.floor(Math.abs(daNote.noteData))]
								|| holdArrayP2[Math.floor(Math.abs(daNote.noteData))]
								&& !daNote.ignoreNote)
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

				if (!daNote.mustPress && Conductor.songPosition >= daNote.strumTime && !PlayStateChangeables.twoPlayersMode)
				{
					if (SONG.songId != 'tutorial')
						camZooming = true;

					if (daNote.gfNote)
						checkNoteType('gf', daNote);
					else
						checkNoteType('dad', daNote);

					var time:Float = 0.15;
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
						time += 0.15;
					}

					opponentStrums.forEach(function(spr:StaticArrow)
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

					callOnLuas('opponentNoteHit', [notes.members.indexOf(daNote), Math.abs(daNote.noteData), daNote.noteType, daNote.isSustainNote]);

					for (script in hscriptFiles)
						script.opponentNoteHit(notes.members.indexOf(daNote), Math.abs(daNote.noteData), daNote.noteType, daNote.isSustainNote);
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

				if (!daNote.mustPress
					&& PlayStateChangeables.useMiddlescroll
					&& !executeModchart
					&& storyDifficulty != 3
					&& !PlayStateChangeables.twoPlayersMode)
					daNote.alpha = 0.5;

				if (storyDifficulty == 3 && !daNote.mustPress && !PlayStateChangeables.twoPlayersMode)
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
				else if (daNote.strumTime / songMultiplier - Conductor.songPosition / songMultiplier < -(166 * Conductor.timeScale) && songStarted)
				{
					if ((daNote.mustPress && !PlayStateChangeables.useDownscroll || daNote.mustPress && PlayStateChangeables.useDownscroll)
						&& daNote.mustPress
						&& !PlayStateChangeables.twoPlayersMode)
					{
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
						else if (!daNote.wasGoodHit
							&& daNote.isSustainNote
							&& daNote.sustainActive
							&& daNote.spotInLine != daNote.parent.children.length)
						{
							health -= 0.05;
							for (i in daNote.parent.children)
							{
								i.alpha = 0.3;
								i.sustainActive = false;
								noteMiss(i.noteData, i);
							}
							if (daNote.parent.wasGoodHit)
							{
								misses++;
								totalNotesHit -= 1;
							}
							if (FlxG.save.data.enablePsychInterface)
								recalculateRating();

							updateAccuracy();
						}
						else
						{
							if (!daNote.ignoreNote)
								vocals.volume = 0;
							if (theFunne && !daNote.isSustainNote)
							{
								if (PlayStateChangeables.botPlay && !daNote.ignoreNote)
								{
									daNote.rating = "bad";
									goodNoteHit(daNote);
								}
								else if (!daNote.ignoreNote)
									noteMiss(daNote.noteData, daNote);
							}

							if (daNote.isParent && daNote.visible)
							{
								health -= 0.15;
								for (i in daNote.children)
								{
									i.alpha = 0.3;
									i.sustainActive = false;
								}
							}
							else
							{
								if (!daNote.wasGoodHit && !daNote.isSustainNote && !daNote.ignoreNote)
								{
									health -= 0.15;
								}
							}
						}

						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
					else if ((!daNote.mustPress && !PlayStateChangeables.useDownscroll || !daNote.mustPress && PlayStateChangeables.useDownscroll) && !daNote.mustPress && PlayStateChangeables.twoPlayersMode)
					{
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
						else if (!daNote.wasGoodHit
							&& daNote.isSustainNote
							&& daNote.sustainActive
							&& daNote.spotInLine != daNote.parent.children.length)
						{
							health += 0.05;
							/*for (i in daNote.parent.children)
							{
								i.alpha = 0.3;
								i.sustainActive = false;
								noteMiss(i.noteData, i, true);
							}*/ //Don`t know why its so buggy
							if (daNote.parent.wasGoodHit)
							{
								misses++;
								totalNotesHit -= 1;
							}
							if (FlxG.save.data.enablePsychInterface)
								recalculateRating();

							updateAccuracy();
						}
						else
						{
							if (!daNote.ignoreNote)
								vocals.volume = 0;
							if (theFunne && !daNote.isSustainNote)
							{
								if (PlayStateChangeables.botPlay && !daNote.ignoreNote)
								{
									daNote.rating = "bad";
									goodNoteHit(daNote);
								}
								else if (!daNote.ignoreNote)
									noteMiss(daNote.noteData, daNote, true);
							}

							if (daNote.isParent && daNote.visible)
							{
								health += 0.15;
								for (i in daNote.children)
								{
									i.alpha = 0.3;
									i.sustainActive = false;
								}
							}
							else
							{
								if (!daNote.wasGoodHit && !daNote.isSustainNote && !daNote.ignoreNote)
								{
									health += 0.15;
								}
							}
						}

						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}
			});
		}

		if (!inCutscene && songStarted)
			keyShit();

		super.update(elapsed);

		setOnHscript('cameraX', camFollow.x);

		setOnHscript('cameraY', camFollow.y);

		setOnHscript('botPlay', PlayStateChangeables.botPlay);

		setOnLuas('cameraX', camFollow.x);
		setOnLuas('cameraY', camFollow.y);
		setOnLuas('botPlay', PlayStateChangeables.botPlay);

		setOnHscript('curDecimalBeat', curDecimalBeat);
		setOnLuas('curDecimalBeat', curDecimalBeat);

		for (script in hscriptFiles)
			script.onUpdatePost(elapsed);

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

	public static var chartingMode:Bool = false;

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		canPause = false;
		cancelMusicFadeTween();
		LoadingState.loadAndSwitchState(new editors.ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence(LanguageStuff.getPlayState("$CHART_EDITOR_TEXT") + SONG.songName, null);
		#end
	}

		
	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.replacesGF) {
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		if (char.positionArray != null){
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];}
	}

	public function camFollowPos(x:Float = 0, y:Float = 0)
	{
		isCameraOnForcedPos = false;
		camFollow.setPosition(x,y);
		isCameraOnForcedPos = true;
	}

	public function checkEventAtPos(eventAtPos:gameplayStuff.Song.EventsAtPos)
	{
		if (eventAtPos.position <= curDecimalBeat && !pastEvents.contains(eventAtPos.position))
		{
			pastEvents.push(eventAtPos.position);
			for (i in eventAtPos.events)
			{
				doEvent(i.type, i.value);
			}
		}
	}

	public function doEvent(eventType:String, eventValue:Dynamic)
		{
			switch (eventType)
				{
					case "Scroll Speed Change":
						var newValue:Float = SONG.speed * eventValue;
						PlayStateChangeables.scrollSpeed = newValue;

					case "Change Stage":
					if (!luaStage && !hscriptStageCheck){
							for (i in stageGroup)
								remove(i);
								
							stageGroup.clear();
							remove(boyfriendGroup);
							remove(dadGroup);
							remove(gfGroup);
	
							Debug.logTrace(eventValue);
	
							Stage = new Stage(eventValue);

							var positions:StageFile = StageData.getStageFile(eventValue);
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
								{switch (index)
									{case 0:
									add(gfGroup);
									for (bg in array){add(bg);stageGroup.add(bg);}
									case 1:
									add(dadGroup);for (bg in array){add(bg);stageGroup.add(bg);}
									case 2:
									add(boyfriendGroup);for (bg in array){add(bg);stageGroup.add(bg);}}}
							camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);}
						else
							addTextToDebug('Change Stage event don`t work with lua stages. Please change stage in lua file');

					case "Start Countdown":
						startCountdownEvent();

					case "Change Character":
						var valueArray:Array<Dynamic> = [eventValue];
						var split:Array<String> = [];
						for (i in 0...valueArray.length){
							split = valueArray[i].split(',');}

						changeCharacter(split[0], split[1].ltrim());

					case "Song Overlay":
						if (eventValue != 'delete'){
							var valueArray:Array<Dynamic> = [eventValue];
							var split:Array<String> = [];
							for (i in 0...valueArray.length)
							{
								split = valueArray[i].split(',');
							}
							var red:Int = Std.parseInt(split[0].trim());
							var green:Int = Std.parseInt(split[1].trim());
							var blue:Int = Std.parseInt(split[2].trim());
							var alpha:Int = Std.parseInt(split[3].trim());
							songOverlay(FlxColor.fromRGB(red, green, blue, alpha));}
						else
							songOverlay('delete');
					
					case "Character play animation":
						var valueArray:Array<Dynamic> = [eventValue];
						var split:Array<String> = [];
						for (i in 0...valueArray.length){
							split = valueArray[i].split(',');}
						switch (split[0]){
							case 'gf':
								gf.playAnim(split[1].ltrim(), true);
							case 'dad':
								dad.playAnim(split[1].ltrim(), true);
							case 'bf':
								boyfriend.playAnim(split[1].ltrim(), true);}

					case "Camera zoom":
						if (FlxG.save.data.camzoom){
							FlxG.camera.zoom += 0.015 * Std.int(eventValue);
							camHUD.zoom += 0.03 * Std.int(eventValue);}

					case 'Toggle interface':
						camHUD.visible = false;

						new FlxTimer().start(Std.int(eventValue), function(tmr:FlxTimer){
							camHUD.visible = true;});

					case 'Toggle Alt Idle':
						switch (eventValue){
							case 'dad':
								dadAltAnim = !dadAltAnim;
							case 'bf':
								bfAltAnim = !bfAltAnim;
							case 'gf':
								gfAltAnim = !gfAltAnim;}
					case "Change strum note skin":
						noteTypeCheck = eventValue;
						strumLineNotes.clear();
						generateStaticArrows(0);
						generateStaticArrows(1);

					case 'Screen Shake':
						var valuesArray:Array<String> = [eventValue];
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
								targetsArray[i].shake(intensity, duration);}}
					case 'Camera Follow Pos':
						var valuesArray:Array<String> = [eventValue];
						var split:Array<String> = [];
						for (i in 0...valuesArray.length){
							split = valuesArray[i].split(',');
						}
						var val1:Float = Std.parseFloat(split[0]);
						var val2:Float = Std.parseFloat(split[1]);
						if(Math.isNaN(val1)) val1 = 0;
						if(Math.isNaN(val2)) val2 = 0;

						isCameraOnForcedPos = false;
						if(!Math.isNaN(Std.parseFloat(split[0])) || !Math.isNaN(Std.parseFloat(split[1]))) {
							camFollow.x = val1;
							camFollow.y = val2;
							isCameraOnForcedPos = true;
						}			
					default:
						var valuesArray:Array<String> = [eventValue];
						var split:Array<String> = [];
						for (i in 0...valuesArray.length){
							split = valuesArray[i].split(',');
						}
						if (split.length < 2)
							split.push('');

						for (script in hscriptFiles)
							script.onEvent(eventType, split[0], split[1]);

						callOnLuas('onEvent', [eventType, split[0], split[1]]);
				}
		}

	var blammedeventplayed:Bool = false;

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
				
		healthBar.updateBar();}

	public function changeCharacter(charType:String = 'bf', newCharName:String)
	{
		switch (charType){
			case 'bf':{
				if (boyfriend.hasTrail)
				{
					if (FlxG.save.data.distractions)
					{
						if (!PlayStateChangeables.Optimize)
						{
							remove(bfTrail);
						}
					}
				}
				boyfriendGroup.clear();
				boyfriend = null;
				boyfriend = new Boyfriend(BF_X, BF_Y, newCharName);
				boyfriend.alpha = 0.0000001;
				boyfriendGroup.add(boyfriend);
				boyfriend.alpha = 1;

				boyfriend.setPosition(BF_X, BF_Y);
				boyfriend.x += boyfriend.positionArray[0];
				boyfriend.y += boyfriend.positionArray[1];

				setOnHscript('boyfriendName', boyfriend.curCharacter);

				if (hscriptStage != null)
				{
					hscriptStage.boyfriend = boyfriend;
					hscriptStage.boyfriendGroup = boyfriendGroup;
				}

				setOnLuas('boyfriendName', boyfriend.curCharacter);
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
				}}
				startCharacterLua(boyfriend.curCharacter);
				startCharacterHscript(boyfriend.curCharacter);
			case 'dad':{
				if (dad.hasTrail)
				{
					if (FlxG.save.data.distractions)
					{
						if (!PlayStateChangeables.Optimize)
						{
							remove(dadTrail);
						}
					}
				}
				dadGroup.clear();
				dad = null;
				dad = new Character(DAD_X, DAD_Y, newCharName);
				dad.alpha = 0.0000001;
				dadGroup.add(dad);
				dad.alpha = 1;

				dad.setPosition(DAD_X, DAD_Y);
				dad.x += dad.positionArray[0];
				dad.y += dad.positionArray[1];

				setOnHscript('dadName', dad.curCharacter);

				if (hscriptStage != null)
				{
					hscriptStage.dad = dad;
					hscriptStage.dadGroup = dadGroup;
				}

				setOnLuas('dadName', dad.curCharacter);
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
				}}
				startCharacterLua(dad.curCharacter);
				startCharacterHscript(dad.curCharacter);
			case 'gf':{
				if (gf.hasTrail)
				{
					if (FlxG.save.data.distractions)
					{
						if (!PlayStateChangeables.Optimize)
						{
							remove(gfTrail);
						}
					}
				}
				gfGroup.clear();
				gf = null;
				gf = new Character(GF_X, GF_Y, newCharName);
				gf.alpha = 0.0000001;
				gfGroup.add(gf);
				gf.alpha = 1;

				gf.setPosition(GF_X, GF_Y);
				gf.x += gf.positionArray[0];
				gf.y += gf.positionArray[1];

				setOnHscript('gfName', gf.curCharacter);

				if (hscriptStage != null)
				{
					hscriptStage.gf = gf;
					hscriptStage.gfGroup = gfGroup;
				}

				setOnLuas('gfName', gf.curCharacter);
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
				}}
				startCharacterLua(gf.curCharacter);
				startCharacterHscript(gf.curCharacter);}
		reloadHealthBarColors();
		reloadIcons();
	}

	public function changeCharacterToCached(charType:String = 'bf', newChar:Dynamic)
	{
		if (newChar == null)
		{
			Debug.logError('Cached character is null');
			return;
		}

		switch (charType){
			case 'bf':{
				if (boyfriend.hasTrail)
				{
					if (FlxG.save.data.distractions)
					{
						if (!PlayStateChangeables.Optimize)
						{
							remove(bfTrail);
						}
					}
				}
				boyfriendGroup.clear();
				boyfriend = null;
				boyfriend = newChar;
				boyfriend.alpha = 0.0000001;
				boyfriendGroup.add(boyfriend);
				boyfriend.alpha = 1;

				boyfriend.setPosition(BF_X, BF_Y);
				boyfriend.x += boyfriend.positionArray[0];
				boyfriend.y += boyfriend.positionArray[1];

				setOnHscript('boyfriendName', boyfriend.curCharacter);

				if (hscriptStage != null)
				{
					hscriptStage.boyfriend = boyfriend;
					hscriptStage.boyfriendGroup = boyfriendGroup;
				}

				setOnLuas('boyfriendName', boyfriend.curCharacter);
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
				}}
				startCharacterLua(boyfriend.curCharacter);
				startCharacterHscript(boyfriend.curCharacter);
			case 'dad':{
				if (dad.hasTrail)
				{
					if (FlxG.save.data.distractions)
					{
						if (!PlayStateChangeables.Optimize)
						{
							remove(dadTrail);
						}
					}
				}
				dadGroup.clear();
				dad = null;
				dad = newChar;
				dad.alpha = 0.0000001;
				dadGroup.add(dad);
				dad.alpha = 1;

				dad.setPosition(DAD_X, DAD_Y);
				dad.x += dad.positionArray[0];
				dad.y += dad.positionArray[1];

				setOnHscript('dadName', dad.curCharacter);

				if (hscriptStage != null)
				{
					hscriptStage.dad = dad;
					hscriptStage.dadGroup = dadGroup;
				}

				setOnLuas('dadName', dad.curCharacter);
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
				}}
				startCharacterLua(dad.curCharacter);
				startCharacterHscript(dad.curCharacter);
			case 'gf':{
				if (gf.hasTrail)
				{
					if (FlxG.save.data.distractions)
					{
						if (!PlayStateChangeables.Optimize)
						{
							remove(gfTrail);
						}
					}
				}
				gfGroup.clear();
				gf = null;
				gf = newChar;
				gf.alpha = 0.0000001;
				gfGroup.add(gf);
				gf.alpha = 1;

				gf.setPosition(GF_X, GF_Y);
				gf.x += gf.positionArray[0];
				gf.y += gf.positionArray[1];

				setOnHscript('gfName', gf.curCharacter);

				if (hscriptStage != null)
				{
					hscriptStage.gf = gf;
					hscriptStage.gfGroup = gfGroup;
				}

				setOnLuas('gfName', gf.curCharacter);
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
				}}
				startCharacterLua(gf.curCharacter);
				startCharacterHscript(gf.curCharacter);}
		reloadHealthBarColors();
		reloadIcons();
	}

	public function reloadIcons() {
		iconP1.changeIcon(boyfriend.characterIcon);
		iconP2.changeIcon(dad.characterIcon);}

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
	public var blockSongEnd:Bool = false;
	public function endSong():Void
	{
		endingSong = true;
		seenCutscene = false;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		PlayStateChangeables.botPlay = false;
		PlayStateChangeables.scrollSpeed = 1 / songMultiplier;
		PlayStateChangeables.useDownscroll = false;
		PlayStateChangeables.useMiddlescroll = false;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		for (script in hscriptFiles)
			script.onEndSong();

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
		if(ret != FunkinLua.Function_Stop && !blockSongEnd) {
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
				MusicBeatState.switchState(new editors.StageDebugState(Stage.curStage));
			}
			else
			{
				var savedAchievements:Array<String> = FlxG.save.data.savedAchievements;

				if (SONG.songId == 'blammed'
					&& !savedAchievements.contains('blammed_completed')
					&& !PlayStateChangeables.botPlay
					&& !addedBotplayOnce)
				{
					var played:Int = FlxG.save.data.playedBlammed;
					played += 1;
					FlxG.save.data.playedBlammed = played;
					if (played == 100)
					{
						Achievements.getAchievement(167278);
					}
				}
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

						if (ModCore.loadedModsLength == 0
							&& (storyDifficulty == 2 || storyDifficulty == 3)
							&& campaignMisses == 0
							&& !savedAchievements.contains(AchievementsState.getWeekSaveId(storyWeek))
							&& !PlayStateChangeables.botPlay
							&& !addedBotplayOnce)
							Achievements.checkWeekAchievement(storyWeek);

						if (savedAchievements.contains('week1_nomiss') && savedAchievements.contains('week2_nomiss')
							&& savedAchievements.contains('week3_nomiss')
							&& savedAchievements.contains('week4_nomiss')
							&& savedAchievements.contains('week5_nomiss')
							&& savedAchievements.contains('week6_nomiss')
							&& savedAchievements.contains('week7_nomiss')
							&& !savedAchievements.contains('vanila_game_completed')
							&& !PlayStateChangeables.botPlay && !addedBotplayOnce){
								Achievements.getAchievement(167263);
							}

						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
					}
					else
					{
						var diff:String = CoolUtil.difficultyPrefixes[storyDifficulty];

						Debug.logInfo('PlayState: Loading next story song ${PlayState.storyPlaylist[0]}${diff}');

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
				else if (isExtras){
					trace('WENT BACK TO EXTRAS MENU??');
					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();

					if (FlxG.save.data.scoreScreen){
						openSubState(new ResultsScreen());
						new FlxTimer().start(1, function(tmr:FlxTimer){inResults = true;});}
					else{
						MusicBeatState.switchState(new SecretState());
						FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)), 0);
						clean();}}
				else if (fromPasswordMenu){
					trace('WENT BACK TO EXTRAS MENU??');
					paused = true;
		
					FlxG.sound.music.stop();
					vocals.stop();

					if (FlxG.save.data.scoreScreen){
						openSubState(new ResultsScreen());
						new FlxTimer().start(1, function(tmr:FlxTimer){inResults = true;});}
					else{
						MusicBeatState.switchState(new MainMenuState());
						FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)), 0);
						clean();}}
				else if (chartingMode){
					openChartEditor();
					return;}
				else{
					trace('WENT BACK TO FREEPLAY??');

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();


					if (FlxG.save.data.scoreScreen){
						openSubState(new ResultsScreen());
						new FlxTimer().start(1, function(tmr:FlxTimer){
							inResults = true;});}
					else{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)), 0);
						clean();}}
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

	private function onSongComplete()
	{
		finishSong(false);
	}

	var finishTimer:FlxTimer = null;

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.
	
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();

		#if desktop
		if (!chartingMode && !PlayStateChangeables.twoPlayersMode)
			GameJoltAPI.addScore(Math.round(songScore), 716199, 'Song - ' + SONG.songName);
		#end

		if(FlxG.save.data.offset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(FlxG.save.data.offset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}

	var timeShown = 0;
	//var currentTimingShown:FlxText = null;

	function checkNoteType(char:String, note:Note)
	{
		switch (char)
		{
			case 'bf':
				if (!note.noAnimation){
				if (note.bulletNote){
					boyfriend.playAnim('dodge', true);
					FlxG.sound.play(Paths.sound('hankshoot'), FlxG.random.float(0.1, 0.2));}
				else if (note.hurtNote){
					health -= 0.2;
					misses++;}
				else{
					boyfriend.playAnim('sing' + dataSuffix[note.noteData] + note.animSuffix, true);}}
			case 'dad':{
				if (!note.noAnimation)
					dad.playAnim('sing' + dataSuffix[note.noteData] + note.animSuffix, true);}
			case 'gf':{
				if (!note.noAnimation)
					gf.playAnim('sing' + dataSuffix[note.noteData] + note.animSuffix, true);}				
		}	
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	private function popUpScore(daNote:Note):Void
	{
		setOnHscript('score', songScore);

		setOnHscript('misses', misses);

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
				if (daNote != null){
					if (!daNote.hitByP2)
						health -= 0.1 * (daNote != null ? daNote.noteScore : 1);
					else
						health += 0.1 * (daNote != null ? daNote.noteScore : 1);
				}
				else
					health -= 0.1 * (daNote != null ? daNote.noteScore : 1);
				ss = false;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				if (daNote != null){
					if (!daNote.hitByP2)
						health -= 0.06 * (daNote != null ? daNote.noteScore : 1);
					else
						health += 0.06 * (daNote != null ? daNote.noteScore : 1);
				}
				else
					health -= 0.06 * (daNote != null ? daNote.noteScore : 1);
				ss = false;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				if (daNote != null){
					if (!daNote.hitByP2)
						health += 0.023 * (daNote != null ? daNote.noteScore : 1);
					else
						health -= 0.023 * (daNote != null ? daNote.noteScore : 1);
				}
				else
					health += 0.023 * (daNote != null ? daNote.noteScore : 1);
				goods++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				daRating = 'sick';
				if (daNote != null){
					if (!daNote.hitByP2)
					{
						if (health < 2)
							health += 0.04 * (daNote != null ? daNote.noteScore : 1);
					}
					else
					{
						health -= 0.04 * (daNote != null ? daNote.noteScore : 1);
					}
				}
				else{
					if (health < 2)
						health += 0.04 * (daNote != null ? daNote.noteScore : 1);
				}

				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
		}

		if (songMultiplier >= 1.05)
			score = getRatesScore(songMultiplier, score);

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);
			
			if (PlayStateChangeables.twoPlayersMode)
			{
				if (daNote != null)
				{
					if (daNote.hitByP2)
						intScoreP2 += Math.round(score);
					else
						intScoreP1 += Math.round(score);
				}
			}

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

			var msTiming = CoolUtil.truncateFloat(noteDiff / songMultiplier, 3);
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

				offsetTest = CoolUtil.truncateFloat(total / hits.length, 2);
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
			ratingsGroup.add(rating);

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

				ratingsGroup.add(numScore);

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
					ratingsGroup.remove(coolText);
					ratingsGroup.remove(comboSpr);
					/*if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}*/
					ratingsGroup.remove(rating);
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSectionInt += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	/*var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;*/

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [
			PlayerSettings.player1.controls.LEFT,
			PlayerSettings.player1.controls.DOWN,
			PlayerSettings.player1.controls.UP,
			PlayerSettings.player1.controls.RIGHT];
		var pressArray:Array<Bool> = [
			PlayerSettings.player1.controls.LEFT_P,
			PlayerSettings.player1.controls.DOWN_P,
			PlayerSettings.player1.controls.UP_P,
			PlayerSettings.player1.controls.RIGHT_P];
		var releaseArray:Array<Bool> = [
			PlayerSettings.player1.controls.LEFT_R,
			PlayerSettings.player1.controls.DOWN_R,
			PlayerSettings.player1.controls.UP_R,
			PlayerSettings.player1.controls.RIGHT_R];
		var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];

		var holdArrayP2:Array<Bool> = [
			PlayerSettings.player1.controls.LEFTP2,
			PlayerSettings.player1.controls.DOWNP2,
			PlayerSettings.player1.controls.UPP2,
			PlayerSettings.player1.controls.RIGHTP2
		];

		var pressArrayP2:Array<Bool> = [
			PlayerSettings.player1.controls.LEFT_PP2,
			PlayerSettings.player1.controls.DOWN_PP2,
			PlayerSettings.player1.controls.UP_PP2,
			PlayerSettings.player1.controls.RIGHT_PP2
		];

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

		if ((holdArray.contains(true) || holdArrayP2.contains(true)) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (holdArray.contains(true))
				{
					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
					{
						goodNoteHit(daNote);
					}
				}
				else if (holdArrayP2.contains(true) && PlayStateChangeables.twoPlayersMode)
				{
					if (daNote.canBeHit && daNote.isSustainNote && !daNote.mustPress && holdArrayP2[daNote.noteData] && daNote.sustainActive)
					{
						goodNoteHit(daNote);
					}
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if ((pressArray.contains(true) || pressArrayP2.contains(true)) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var possibleNotesP2:Array<Note> = [];
				var directionList:Array<Int> = []; // directions that can be hit
				var directionListP2:Array<Int> = [];
				var dumbNotes:Array<Note> = []; // notes to kill later
				var dumbNotesP2:Array<Note> = [];
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses
				var directionsAccountedP2:Array<Bool> = [false, false, false, false];

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit
						&& daNote.mustPress
						&& !daNote.wasGoodHit
						&& !directionsAccounted[daNote.noteData])
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
					else if (daNote.canBeHit && !daNote.mustPress && !daNote.wasGoodHit && !directionsAccountedP2[daNote.noteData])
					{
						if (directionListP2.contains(daNote.noteData))
						{
							directionsAccountedP2[daNote.noteData] = true;
							for (coolNote in possibleNotesP2)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotesP2.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotesP2.remove(coolNote);
									possibleNotesP2.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccountedP2[daNote.noteData] = true;
							possibleNotesP2.push(daNote);
							directionListP2.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				for (note in dumbNotesP2)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
				possibleNotesP2.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false, false, false, false];
				var hitP2 = [false, false, false, false];

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0 || possibleNotesP2.length > 0)
				{
					if (possibleNotes.length > 0)
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
							if (coolNote.mustPress)
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
						}
					}
					else if (PlayStateChangeables.twoPlayersMode && possibleNotesP2.length > 0)
					{
						if (!FlxG.save.data.ghost)
						{
							for (shit in 0...pressArrayP2.length)
							{ // if a direction is hit that shouldn't be
								if (pressArrayP2[shit] && !directionListP2.contains(shit))
								{
									noteMiss(shit, null);
								}
							}
						}
						for (coolNote in possibleNotesP2)
						{
							if (coolNote.mustPress)
							{
								if (pressArrayP2[coolNote.noteData] && !hitP2[coolNote.noteData])
								{
									if (mashViolations != 0)
										mashViolations--;
									hitP2[coolNote.noteData] = true;
									scoreTxt.color = FlxColor.WHITE;
									var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
									anas[coolNote.noteData].hit = true;
									anas[coolNote.noteData].hitJudge = Ratings.judgeNote(noteDiff);
									anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
									goodNoteHit(coolNote);
								}
							}
						}
					}
				};

				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.dance();
				}
				else if (dad.holdTimer > Conductor.stepCrochet * 4 * 0.001
					&& (!holdArray.contains(true) || PlayStateChangeables.botPlay) && PlayStateChangeables.twoPlayersMode)
				{
					if (dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.endsWith('miss'))
						dad.dance();
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
				if (daNote.mustPress && Conductor.songPosition >= daNote.strumTime && !daNote.ignoreNote)
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

		if (PlayStateChangeables.twoPlayersMode)
		{
			if (dad.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArrayP2.contains(true))
			{
				if (dad.animation.curAnim.name.startsWith('sing')
					&& !dad.animation.curAnim.name.endsWith('miss')
					&& (dad.animation.curAnim.curFrame >= 10 || dad.animation.curAnim.finished))
					dad.dance();
			}
		}

		if (controls.ATTACK && allowToAttack && !FlxFlicker.isFlickering(dad))
		{
			if (boyfriend.curCharacter == 'bf' || boyfriend.animation.exists('attack'))
			{
				boyfriend.playAnim('attack', true);
				if (FlxG.save.data.flashing)
					FlxFlicker.flicker(dad, 0.2, 0.05, true);
				health += 0.02;

				for (script in hscriptFiles)
					script.onAttack();

				callOnLuas('onAttack', []);
			}
		}

		if (PlayStateChangeables.twoPlayersMode)
		{
			opponentStrums.forEach(function(spr:StaticArrow)
			{
				if (keys[spr.ID + 4]
					&& spr.animation.curAnim.name != 'confirm'
					&& spr.animation.curAnim.name != 'pressed')
					spr.playAnim('pressed', false);
				if (!keys[spr.ID + 4])
					spr.playAnim('static', false);
			});
		}

		playerStrums.forEach(function(spr:StaticArrow)
		{
			if (!PlayStateChangeables.botPlay)
			{
				if (keys[spr.ID]
					&& spr.animation.curAnim.name != 'confirm'
					&& spr.animation.curAnim.name != 'pressed')
					spr.playAnim('pressed', false);
				if (!keys[spr.ID])
					spr.playAnim('static', false);
			}
		});
	}

	function noteMiss(direction:Int = 1, daNote:Note, isDad:Bool = false):Void
	{
		if (daNote != null && daNote.bulletNote)
		{
			health = 0;
		}

		if (!boyfriend.stunned)
		{
			// health -= 0.2;
			if (combo > 5 && gf.animOffsets.exists('sad') && (daNote != null && !daNote.ignoreNote))
			{
				gf.playAnim('sad');
			}
			else if (combo > 5 && gf.animOffsets.exists('sad') && daNote == null)
			{
				gf.playAnim('sad');
			}	

			if (combo != 0)
			{
				combo = 0;
				popUpScore(daNote != null ? daNote : null);
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

			if (isDad || (daNote != null && daNote.hitByP2))
			{
				if (daNote != null)
				{
					if (daNote.hitByP2 && !daNote.ignoreNote)
						dad.playAnim('sing' + dataSuffix[direction] + 'miss' + daNote.animSuffix, true);
				}
				else
					dad.playAnim('sing' + dataSuffix[direction] + 'miss', true);
			}
			else if (!isDad || (daNote != null && !daNote.hitByP2))
			{
				if (daNote != null)
				{
					if (daNote != null && !daNote.ignoreNote)
					{
						boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss' + daNote.animSuffix, true);
					}
				}
				else
					boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);	
			}
			else
				Debug.logError('No one should miss, lol');

			if (daNote != null)
			{

				for (script in hscriptFiles)
					script.noteMiss(notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote);

				callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
			}
			if (FlxG.save.data.enablePsychInterface)
				recalculateRating();

			updateAccuracy();
		}
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		if (!PlayStateChangeables.twoPlayersMode)
			scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);
		else{
			scoreP1.text = 'Player 1 score: ' + Std.string(intScoreP1);
			scoreP2.text = 'Player 2 score: ' + Std.string(intScoreP2);
		}
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public var blockRecalculateRating:Bool = false;
	public function recalculateRating() {
		totalPlayed += 1;

		for (script in hscriptFiles)
			script.onRecalculateRating();
		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if (ret != FunkinLua.Function_Stop && !blockRecalculateRating)
		{
			if(totalPlayed < 1)
				ratingName = '?';
			else
			{
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
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

		if (ratingName == '?')
		{
			scoreTxt.text = LanguageStuff.replaceFlagsAndReturn("$PSYCH_RATING_WITHOUT_AC", "playState", ["<score>", "<misses>", "<ratingName>"],
				[Std.string(songScore), Std.string(misses), ratingName]);
		}
		else
		{
			scoreTxt.text = LanguageStuff.replaceFlagsAndReturn("$PSYCH_RATING_WITH_AC", "playState",
				["<score>", "<misses>", "<ratingName>", "<ratingPercent>", "<ratingFC>"], [
					Std.string(songScore),
					Std.string(misses),
					ratingName,
					Std.string(Highscore.floorDecimal(ratingPercent * 100, 2)),
					ratingFC
				]);
		}

		setOnHscript('rating', ratingPercent);

		setOnHscript('ratingName', ratingName);

		setOnHscript('ratingFC', ratingFC);

		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	function moveCameraSection():Void {
		if(curSection == null) return;
	
		if (gf != null && curSection.gfSection)
		{
			camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.camPos[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.camPos[1] + girlfriendCameraOffset[1];
			tweenCamIn();

			for (script in hscriptFiles)
				script.onMoveCamera('gf');

			callOnLuas('onMoveCamera', ['gf']);
			return;
		}
	
		if (!curSection.mustHitSection)
		{
			moveCamera(true);

			for (script in hscriptFiles)
				script.onMoveCamera('dad');

			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);

			for (script in hscriptFiles)
				script.onMoveCamera('boyfriend');

			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	/*function getKeyPresses(note:Note):Int
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
	}*/

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	/*function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.judgeNote(noteDiff);

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));

		}
	}*/

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

			if (note.gfNote && !note.hitByP2)
				checkNoteType('gf', note);
			else if (note.hitByP2 && !note.gfNote)
				checkNoteType('dad', note);
			else 
				checkNoteType('bf', note);

			if (!PlayStateChangeables.botPlay)
			{
				if (note.hitByP2)
					opponentStrums.forEach(function(spr:StaticArrow)
					{
						pressArrow(spr, spr.ID, note);
					});
				else
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

				updateAccuracy();
			}
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

			for (script in hscriptFiles)
				script.goodNoteHit(notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote);
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(FlxG.save.data.notesplashes && note != null) {
			if (note.hitByP2)
			{
				var strum:StaticArrow = opponentStrums.members[note.noteData];
				if (strum != null)
				{
					spawnNoteSplash(strum.x, strum.y, note.noteData, note);
				}	
			}
			else
			{
				var strum:StaticArrow = playerStrums.members[note.noteData];
				if(strum != null) {
					spawnNoteSplash(strum.x, strum.y, note.noteData, note);
				}
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var type:String = note.noteType;

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, type);
		grpNoteSplashes.add(splash);
	}

	function pressArrow(spr:StaticArrow, idCheck:Int, daNote:Note, ?time:Float)
	{
		if (Math.abs(daNote.noteData) == idCheck)
		{
			if (spr != null) spr.playAnim('confirm', true);
			if (time != null) spr.resetAnim = time;
		}
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();

		currentStep = curStep;

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		for (script in hscriptFiles)
			script.onStep(curStep);

		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (curSection != null)
		{
			setOnHscript('mustHitSection', curSection.mustHitSection);

			setOnHscript('playerAltAnim', curSection.playerAltAnim);

			setOnHscript('dadAltAnim', curSection.CPUAltAnim);

			setOnHscript('gfAltAnim', curSection.gfAltAnim);

			setOnHscript('gfSection', curSection.gfSection);

			setOnLuas('mustHitSection', curSection.mustHitSection);
			setOnLuas('playerAltAnim', curSection.playerAltAnim);
			setOnLuas('dadAltAnim', curSection.CPUAltAnim);
			setOnLuas('gfAltAnim', curSection.gfAltAnim);
			setOnLuas('gfSection', curSection.gfSection);

			dadAltAnim = curSection.CPUAltAnim;
			bfAltAnim = curSection.playerAltAnim;
			gfAltAnim = curSection.gfAltAnim;

			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}
		}

		setOnHscript('curSectionNumber', curSectionInt);

		for (script in hscriptFiles)
			script.onSectionHit();

		setOnHscript('curSection', curSection);

		setOnLuas('curSection', curSectionInt);
		callOnLuas('onSectionHit', []);
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		currentBeat = curBeat;

		setOnHscript('curBpm', Conductor.bpm);

		setOnHscript('crochet', Conductor.crochet);

		setOnHscript('stepCrochet', Conductor.stepCrochet);

		setOnLuas('curBpm', Conductor.bpm);
		setOnLuas('crochet', Conductor.crochet);
		setOnLuas('stepCrochet', Conductor.stepCrochet);
			
		if (curSection != null)
		{
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

		if (!endingSong && curSection != null)
		{
			gfAltAnim = curSection.gfAltAnim;
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
				if (vocals.volume == 0 && !curSection.mustHitSection)
					vocals.volume = 1;
		}

		if (curSong == 'blammed')
		{
			if (curBeat % 4 == 0){
				var windowColor:FlxColor = FlxColor.WHITE;

				switch (Stage.curLight)
				{
					case 4:
						windowColor = FlxColor.fromRGB(251, 166, 51);
					case 3:
						windowColor = FlxColor.fromRGB(253, 69, 49);
					case 2:
						windowColor = FlxColor.fromRGB(251, 51, 245);
					case 1:
						windowColor = FlxColor.fromRGB(49, 253, 140);
					case 0:
						windowColor = FlxColor.fromRGB(49, 162, 253);
				}
				if ((curBeat >= 128 && curBeat <= 192) && !blammedeventplayed && FlxG.save.data.distractions)
				{
					var eventColor:FlxColor = FlxColor.WHITE;

					eventColor = windowColor;
					eventColor.alpha = 175;

					camGame.flash(windowColor, 0.1);
					camHUD.flash(windowColor, 0.1);
					songOverlay(eventColor, 0.1);
				}

				var phillyCityLight:FlxSprite = Stage.swagBacks['light'];

				phillyCityLight.color = windowColor;
			}
			
			if (curBeat >= 192 && !blammedeventplayed && FlxG.save.data.distractions)
			{
				overlayColor = FlxColor.fromRGB(0, 0, 0, 0);
				colorTween = FlxTween.color(overlay, 0.1, overlay.color, overlayColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
				});
				for (char in chars) {
					char.colorTween = FlxTween.color(char, 0.1, char.color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {

					}, ease: FlxEase.quadInOut});
				}
				blammedeventplayed = true;
			}
		}

		for (script in hscriptFiles)
			script.onBeat(curBeat);

		setOnHscript('curBeat', curBeat);

		setOnLuas('curBeat', curBeat);
		callOnLuas('onBeatHit', []);
	}

	public function setOnHscript(name:String, value:Dynamic) {
		for (script in hscriptFiles)
		{
			script.set(name, value);
		}

		if (hscriptStage != null)
			hscriptStage.set(name, value);
	}

	public function callOnHscript(functionToCall:String, ?params:Array<Any>) //Maybe will use this in engine XD
	{
		for (script in hscriptFiles)
		{
			var scriptHelper = script.scriptHelper;
			if (scriptHelper.get(functionToCall) != null)
			{
				scriptHelper.get(functionToCall)(params);
			}
		}

		if (hscriptStage != null)
		{
			var scriptHelper = hscriptStage.scriptHelper;
			if (scriptHelper.get(functionToCall) != null)
			{
				scriptHelper.get(functionToCall)(params);
			}
		}
	}

	public function updateBars()
	{
		if (FlxG.save.data.enablePsychInterface && FlxG.save.data.songPosition)
		{
			remove(timeBar);
			timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
				'songPositionBar', 0, songLength);
			timeBar.scrollFactor.set();
			timeBar.createFilledBar(0xFF000000, FlxColor.fromRGB(songPosBarColorRGB[0],songPosBarColorRGB[1],songPosBarColorRGB[2]));
			timeBar.numDivisions = 800;
			timeBar.alpha = 0;
			add(timeBar);
			timeBarBG.sprTracker = timeBar;
			timeBar.cameras = [camHUD];
		}
		else if (FlxG.save.data.songPosition && !FlxG.save.data.enablePsychInterface)
		{
			remove(songPosBar);
			songPosBar = new FlxBar(640 - (Std.int(songPosBG.width - 100) / 2), songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 100),
				Std.int(songPosBG.height + 6), this, 'songPositionBar', 0, songLength);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.fromRGB(songPosBarColorRGB[0],songPosBarColorRGB[1],songPosBarColorRGB[2]));
			add(songPosBar);
			songPosBar.cameras = [camHUD];
		}
	}

	private var preventLuaRemove:Bool = false;
	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	public var closeLuas:Array<FunkinLua> = [];
	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops=false, ?exclusions:Array<String>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		if(exclusions==null)exclusions=[];
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			if(exclusions.contains(luaArray[i].scriptName)){
				continue;
			}
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret == FunkinLua.Function_StopLua) {
				if(ignoreStops)
					ret = FunkinLua.Function_Continue;
				else
					break;
			}
			
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

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartObjects.exists(tag))return modchartObjects.get(tag);
		if(modchartSprites.exists(tag))return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag))return modchartTexts.get(tag);
		return null;
	}

	public function setNoteTypeTexture(type:String, texture:String)
	{
		if (type != null && texture != null)
		{
			for (note in unspawnNotes)
			{
				if (note.noteType == type)
				{
					note.texture = texture;
				}
			}
		}
	}

	public function setNoteTypeIgnore(type:String, ignore:Bool = false)
	{
		if (type != null)
		{
			for (note in unspawnNotes)
			{
				if (note.noteType == type)
				{
					note.ignoreNote = ignore;
				}
			}
		}
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

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'assets/data/characters/' + name + '.lua';	

		if(OpenFlAssets.exists(luaFile)) {
			for (script in luaArray)
				{
					if(script.scriptName == luaFile) return;
				}
				luaArray.push(new FunkinLua(OpenFlAssets.getPath(luaFile)));
		}
		#end
	}

	function startCharacterHscript(name:String)
	{
		if (OpenFlAssets.exists('assets/scripts/characters/$name.hscript'))
		{
			hscriptFiles.push(new ModchartHelper(OpenFlAssets.getPath('assets/scripts/characters/$name.hscript'), this));
		}
	}

	function scriptError(e:Exception)
	{
		Debug.displayAlert("Script error!", Std.string(e));

		quit();
	}

	function quit()
	{
		if (isFreeplay)
			MusicBeatState.switchState(new FreeplayState());
		else if (isStoryMode)
			MusicBeatState.switchState(new StoryMenuState());
		else if (isExtras)
			MusicBeatState.switchState(new SecretState());
		else if (chartingMode)
			openChartEditor();
		else if (fromPasswordMenu)
			MusicBeatState.switchState(new ExtrasPasswordState());
		else
			MusicBeatState.switchState(new MainMenuState());
	}

	override function onWindowFocusOut():Void
	{
		if (paused)
			return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		openSubState(new PauseSubState());
	}
	
	override function onWindowFocusIn():Void
	{
		Debug.logTrace("IM BACK!!!");
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}
