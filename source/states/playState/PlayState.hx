package states.playState; // Will have separated classes for two players mode and singleplayer which will extend this base class

import animateatlas.AtlasFrameMaker;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIBar;
// import flixel.camera.CameraManager;
import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxSort;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import gameplayStuff.Boyfriend;
import gameplayStuff.Character;
import gameplayStuff.Conductor;
import gameplayStuff.CutsceneHandler;
import gameplayStuff.DialogueBox;
import gameplayStuff.DialogueBoxPsych;
import gameplayStuff.GameUI;
import gameplayStuff.HealthIcon;
import gameplayStuff.Highscore;
import gameplayStuff.Note;
import gameplayStuff.NoteSplash;
import gameplayStuff.PlayStateChangeables;
import gameplayStuff.RatingText;
import gameplayStuff.Ratings;
import gameplayStuff.Section.SwagSection;
import gameplayStuff.Song.Event;
import gameplayStuff.Song.EventsAtPos;
import gameplayStuff.Song.SongData;
import gameplayStuff.Song;
import gameplayStuff.Stage;
import gameplayStuff.StageData;
import gameplayStuff.StaticArrow;
import gameplayStuff.StrumLine;
import gameplayStuff.TimingStruct;
import haxe.EnumTools;
import haxe.Exception;
import haxe.Json;
import lime.app.Application;
import lime.graphics.Image;
import lime.media.AudioContext;
import lime.media.AudioManager;
import modding.ModCore;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.filters.ShaderFilter;
import openfl.filters.ShaderFilter;
import openfl.geom.Matrix;
import openfl.media.Sound;
import openfl.ui.KeyLocation;
import openfl.ui.Keyboard;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetManifest;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import scriptStuff.HScriptHandler.ScriptException;
import scriptStuff.HScriptModchart as ModchartHelper;
import scriptStuff.HscriptStage;
import scriptStuff.ScriptHelper;
// import scriptStuff.scriptBodies.*;
import shaders.Shaders;
import shaders.WiggleEffect.WiggleEffectType;
import shaders.WiggleEffect;
import states.playState.GameData as Data;
import sys.thread.Lock;
import sys.thread.Mutex;

#if FEATURE_FILESYSTEM
import Sys;
import sys.FileSystem;
import sys.io.File;
#end

#if (VIDEOS_ALLOWED && !macro)
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as VideoHandler;
#elseif (hxCodec == "2.6.0") import VideoHandler;
#else import vlc.MP4Handler as VideoHandler; #end
#end

#if desktop
import gamejolt.GameJolt.GameJoltAPI;
#end



class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public var currentBeat:Int = 0;
	public var currentStep:Int = 0;

	public var timerCount:Float = 0;
	public var maxTimerCounter:Float = 200;

	public var songPosBG:FlxSprite;

	public var visibleCombos:Array<FlxSprite> = [];

	public var addedBotplay:Bool = false;
	public var addedBotplayOnce:Bool = false;

	public var visibleNotes:Array<Note> = [];

	public var songPosBar:FlxUIBar;
	public var songPositionBar:Float = 0;

	public var noteType:Dynamic = 0;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var songLength:Float = 0;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
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

	public var camFollow:FlxObject;
	public var cameraSpeed:Float = 1;

	private var prevCamFollow:FlxObject;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public var strumLineNotes:StrumLine = null;

	public var ratingsGroup:FlxTypedGroup<FlxSprite>;

	public var camZooming:Bool = false;

	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health(default, set):Float = 1;

	private var combo:Int = 0;

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var camHUD:FlxCamera;

	// public var camSustains:FlxCamera;
	// public var camNotes:FlxCamera;
	// public var camManager:CameraManager;
	public var camGame:FlxCamera;

	public var cannotDie = false;
	public var isDead:Bool = false;

	var currentFrames:Int = 0;
	var idleToBeat:Bool = true;
	var idleBeat:Int = 2;
	var forcedToIdle:Bool = false;
	var allowedToHeadbang:Bool = true;

	public var dialogue:DialogueJson = null;

	var dialogueJson:DialogueFile = null;

	var overlay:FlxSprite; /*ModchartSprite;*/
	var overlayColor:FlxColor = 0xFFFF0000;
	var colorTween:FlxTween;

	var songName:FlxText;

	var altSuffix:String = "";

	var fc:Bool = true;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public var songScore:Int = 0;

	var needSkip:Bool = false;
	var skipActive:Bool = false;
	var skipText:FlxText;
	var skipTo:Float;

	var usedTimeTravel:Bool = false;

	var shoot:Bool = false;

	var camPos:FlxPoint;

	public var randomVar = false;

	public var Stage:Stage;

	public var hscriptStage:HscriptStage;

	public var defaultCamZoom:Float = 1.05;
	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	private var isCameraOnForcedPos:Bool = false;

	public var skipCountdown:Bool = false;

	public var hideGF:Bool;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	var dadTrail:FlxTrail;
	var gfTrail:FlxTrail;
	var bfTrail:FlxTrail;

	public var allowToAttack:Bool = false;

	var gfAltAnim:Bool = false;
	var bfAltAnim:Bool = false;
	var dadAltAnim:Bool = false;

	var hscriptStageCheck = false;

	public var doof:DialogueBox = null;

	public var events:Array<gameplayStuff.Song.EventsAtPos> = [];

	public var noteTypeCheck:String = 'normal';

	var useDownscroll(default, set):Bool = false;

	// Hscript groups
	// public static var noteScripts:Array<NoteScriptBody> = [];
	/*public static var diffScripts:Array<DiffScriptBody> = [];
		public static var characterScripts:Array<CharacterScriptBody> = [];
		public static var eventScripts:Array<EventScriptBody> = [];
		public static var songScripts:Array<SongScriptBody> = []; */
	// public static var stageScript:StageScriptBody = null;
	var openChart:Bool = false;

	public function new(openChart:Bool = false)
	{
		super();
		this.openChart = openChart;
	}

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
		// buildPlayStateHooks();
		FlxG.mouse.visible = false;
		instance = this;

		// grab variables here too or else its gonna break stuff later on
		GameplayCustomizeState.freeplayBf = Data.SONG.player1;
		GameplayCustomizeState.freeplayDad = Data.SONG.player2;
		GameplayCustomizeState.freeplayGf = Data.SONG.gfVersion;
		GameplayCustomizeState.freeplayNoteStyle = Data.SONG.noteStyle;
		GameplayCustomizeState.freeplayStage = Data.SONG.stage;
		GameplayCustomizeState.freeplaySong = Data.SONG.songId;
		GameplayCustomizeState.freeplayWeek = Data.storyWeek;

		previousRate = Data.songMultiplier - 0.05;

		if (previousRate < 1.00)
			previousRate = 1;

		if (Main.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		Data.inDaPlay = true;

		if (Data.currentSong != Data.SONG.songName)
		{
			Data.currentSong = Data.SONG.songName;
			// Main.dumpCache();
		}

		Data.sicks = 0;
		Data.bads = 0;
		Data.shits = 0;
		Data.goods = 0;

		Data.misses = 0;

		Data.highestCombo = 0;
		Data.inResults = false;

		PlayStateChangeables.useMiddlescroll = Main.save.data.middleScroll;
		PlayStateChangeables.useDownscroll = Main.save.data.downscroll;
		PlayStateChangeables.safeFrames = Main.save.data.frames;
		PlayStateChangeables.scrollSpeed = Main.save.data.scrollSpeed * Data.songMultiplier;
		PlayStateChangeables.botPlay = Main.save.data.botplay;
		PlayStateChangeables.Optimize = Main.save.data.optimize;
		PlayStateChangeables.zoom = Main.save.data.zoom;

		useDownscroll = PlayStateChangeables.useDownscroll;

		removedVideo = false;

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(Data.storyDifficulty);

		iconRPC = Data.SONG.player2;

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
		if (Data.isStoryMode)
		{
			detailsText = LanguageStuff.replaceFlagsAndReturn("$STORY_MODE", "playState", ["<storyWeek>"], [Std.string(Data.storyWeek)]);
		}
		if (Data.isFreeplay)
		{
			detailsText = LanguageStuff.getPlayState("$FREEPLAY");
		}

		// Updating Discord Rich Presence.
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
				Data.SONG.songName,
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
			],
				[
					Std.string(detailsText),
					Data.SONG.songName,
					storyDifficultyText,
					'',
					Ratings.GenerateLetterRank(accuracy)
				]),
				LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_TWO", "playState", ["<accuracy>", "<songScore>", "<misses>"],
					[CoolUtil.truncateFloat(accuracy, 2), songScore, Data.misses]),
				iconRPC);
		}
		#end

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		/*camSustains = new FlxCamera();
			camSustains.bgColor.alpha = 0;
			camNotes = new FlxCamera();
			camNotes.bgColor.alpha = 0; */

		// camManager = new CameraManager(camGame);

		#if debug
		// camManager.enableDebugFeatures();
		#end

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		/*FlxG.cameras.add(camSustains, false);
			FlxG.cameras.add(camNotes, false); */

		camHUD.zoom = PlayStateChangeables.zoom;

		// FlxCamera.defaultCameras = [camGame];
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (Data.SONG == null)
			Data.SONG = Song.loadFromJson('tutorial', '');

		Conductor.mapBPMChanges(Data.SONG);
		Conductor.changeBPM(Data.SONG.bpm);

		Conductor.bpm = Data.SONG.bpm;

		/*if (Data.SONG.eventObjects == null)
			{
				Data.SONG.eventObjects = [new Song.Event("Init BPM", 0, Data.SONG.bpm, "BPM Change")];
		}*/

		if (Data.SONG.eventsArray == null)
		{
			var initBpm:gameplayStuff.Song.EventsAtPos = {
				position: 0,
				events: []
			};
			var firstEvent:gameplayStuff.Song.EventObject = new gameplayStuff.Song.EventObject("Init BPM", Data.SONG.bpm, "BPM Change");

			initBpm.events.push(firstEvent);
			Data.SONG.eventsArray = [initBpm];
		}

		TimingStruct.clearTimings();

		var currentIndex = 0;
		for (i in Data.SONG.eventsArray)
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

			events.push(i);
		}
		recalculateAllSectionTimes();

		ratingsGroup = new FlxTypedGroup<FlxSprite>();

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		if (Data.isStoryMode)
			if (Paths.formatToDialoguePath('${Data.SONG.songId}/dialogue') != null)
				dialogue = cast Paths.formatToDialoguePath('${Data.SONG.songId}/dialogue');

		switch (Data.SONG.noteStyle)
		{
			case 'pixel':
				Data.isPixel = true;
			case 'normal':
				Data.isPixel = false;
		}

		noteTypeCheck = Data.SONG.noteStyle;

		Data.stageCheck = Data.SONG.stage;

		if (Data.isStoryMode)
			Data.songMultiplier = 1;

		var gfCheck:String = 'gf';

		gfCheck = Data.SONG.gfVersion;

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		var stageData:StageFile = StageData.getStageFile(Data.SONG.stage);
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

		defaultCamZoom = stageData.defaultZoom;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if (boyfriendCameraOffset == null)
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if (opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if (girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		if (!hideGF)
			camPos = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		else
			camPos = new FlxPoint(boyfriendCameraOffset[0], boyfriendCameraOffset[1]);

		Debug.logInfo('Loading characters');

		gf = new Character(400, 130, gfCheck);

		startCharacterPos(gf);
		gf.scrollFactor.set(0.95, 0.95);
		gfGroup.add(gf);
		startCharacterHscript(gf.curCharacter);

		ScriptHelper.setOnHscript('gfName', gf.curCharacter);

		GF_X = stageData.gf[0];
		GF_Y = stageData.gf[1];
		gfGroup.setPosition(GF_X, GF_Y);

		gf.x = stageData.gf[0];
		gf.y = stageData.gf[1];

		if (gf.positionArray != null)
		{
			gf.x += gf.positionArray[0];
			gf.y += gf.positionArray[1];
		}

		if (hideGF)
			gf.visible = false;

		boyfriend = new Boyfriend(770, 450, Data.SONG.player1);

		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterHscript(boyfriend.curCharacter);

		ScriptHelper.setOnHscript('boyfriendName', boyfriend.curCharacter);

		switch (boyfriend.curCharacter)
		{
			case 'bf-pixel':
				GameOverSubstate.stageSuffix = '-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';
			case 'bfAndGF':
				GameOverSubstate.characterName = 'bfAndGF-DEAD';
		}

		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		boyfriendGroup.setPosition(BF_X, BF_Y);

		boyfriend.x = stageData.boyfriend[0];
		boyfriend.y = stageData.boyfriend[1];

		if (boyfriend.positionArray != null)
		{
			boyfriend.x += boyfriend.positionArray[0];
			boyfriend.y += boyfriend.positionArray[1];
		}

		dad = new Character(100, 100, Data.SONG.player2);

		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterHscript(dad.curCharacter);

		ScriptHelper.setOnHscript('dadName', dad.curCharacter);

		DAD_X = stageData.dad[0];
		DAD_Y = stageData.dad[1];
		dadGroup.setPosition(DAD_X, DAD_Y);

		dad.x = stageData.dad[0];
		dad.y = stageData.dad[1];

		if (dad.positionArray != null)
		{
			dad.x += dad.positionArray[0];
			dad.y += dad.positionArray[1];
		}

		chars = [boyfriend, gf, dad];

		Debug.logInfo('Generated all song characters');

		if (gf != null && !hideGF)
		{
			if (gf.camPos != null)
			{
				camPos.x += gf.getGraphicMidpoint().x + gf.camPos[0];
				camPos.y += gf.getGraphicMidpoint().y + gf.camPos[1];
			}
			else
			{
				camPos.x += gf.getGraphicMidpoint().x;
				camPos.y += gf.getGraphicMidpoint().y;
			}
		}
		else
		{
			if (boyfriend.camPos != null)
			{
				camPos.x += boyfriend.getGraphicMidpoint().x + boyfriend.camPos[0];
				camPos.y += boyfriend.getGraphicMidpoint().y + boyfriend.camPos[1];
			}
			else
			{
				camPos.x += boyfriend.getGraphicMidpoint().x;
				camPos.y += boyfriend.getGraphicMidpoint().y;
			}
		}

		// camManager.setFullFocusTo(gf);

		if (hideGF)
			gf.visible = false;
		else
		{
			if (dad.replacesGF)
			{
				if (!Data.stageTesting)
					dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (Data.isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			}
			else
				gf.visible = true;
		}

		Debug.logInfo('Loading stage');
		if (!Data.stageTesting)
		{
			if (Paths.getHscriptPath(Data.SONG.stage, 'stages') != null)
			{
				try
				{
					hscriptStage = new HscriptStage(Paths.getHscriptPath(Data.SONG.stage, 'stages'), this);
					add(hscriptStage);
					ScriptHelper.hscriptFiles.push(hscriptStage);
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
			else
			{
				Stage = new Stage(Data.SONG.stage);
			}
		}

		if (hscriptStageCheck)
		{
			if (!hscriptStage.members.contains(gfGroup))
				add(gfGroup);
			else
				gfGroup = hscriptStage.gfGroup;

			if (!hscriptStage.members.contains(dadGroup))
				add(dadGroup);
			else
				dadGroup = hscriptStage.dadGroup;

			if (!hscriptStage.members.contains(boyfriendGroup))
				add(boyfriendGroup);
			else
				boyfriendGroup = hscriptStage.boyfriendGroup;
		}

		if (!hscriptStageCheck)
		{
			for (i in Stage.toAdd)
			{
				add(i);
			}
		}

		this.hideGF = stageData.hideGF || Data.SONG.hideGF;

		if (!PlayStateChangeables.Optimize && (!hscriptStageCheck))
			for (index => array in Stage.layInFront)
			{
				switch (index)
				{
					case 0:
						add(gfGroup);
						gfGroup.scrollFactor.set(0.95, 0.95);
						if (!hscriptStageCheck)
						{
							for (bg in array)
							{
								add(bg);
							}
						}
					case 1:
						add(dadGroup);
						if (!hscriptStageCheck)
						{
							for (bg in array)
							{
								add(bg);
							}
						}
					case 2:
						add(boyfriendGroup);
						if (!hscriptStageCheck)
						{
							for (bg in array)
							{
								add(bg);
							}
						}
				}
			}

		Debug.logTrace('Generated stage');

		if (!hscriptStageCheck)
			Stage.update(0);

		#if desktop
		if (Paths.getHscriptPath(Data.SONG.songId, 'songs') != null)
		{
			try
			{
				ScriptHelper.hscriptFiles.push(new ModchartHelper(Paths.getHscriptPath(Data.SONG.songId, 'songs'), this));
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

		overlayColor = FlxColor.fromRGB(0, 0, 0, 0);
		overlay = new FlxSprite(0, 0);
		overlay.loadGraphic(Paths.loadImage('songoverlay'));
		overlay.scrollFactor.set();
		overlay.setGraphicSize(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2));
		var position:Int = members.indexOf(gfGroup);
		if (members.indexOf(boyfriendGroup) < position)
		{
			position = members.indexOf(boyfriendGroup);
		}
		else if (members.indexOf(dadGroup) < position)
		{
			position = members.indexOf(dadGroup);
		}
		insert(position, overlay);
		// modchartSprites.set('overlay', overlay);

		colorTween = FlxTween.color(overlay, 1, overlay.color, overlayColor, {
			onComplete: function(twn:FlxTween)
			{
				colorTween = null;
			}
		});

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		if (Data.isStoryMode && dialogue != null)
		{
			doof = new DialogueBox(dialogue);

			if (Data.SONG.songId == 'senpai')
				doof.dialogueSound = 'Lunchbox';
			else if (Data.SONG.songId == 'thorns')
				doof.dialogueSound = 'LunchboxScary';

			doof.isPixel = Data.isPixel;
			doof.scrollFactor.set();
			doof.finishThing = startCountdown;
		}

		if (!Data.isStoryMode && Data.songMultiplier == 1)
		{
			var firstNoteTime = Math.POSITIVE_INFINITY;
			var playerTurn = false;
			for (index => section in Data.SONG.notes)
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

		strumLine = new FlxSprite(PlayStateChangeables.useMiddlescroll ? Data.STRUM_X_MIDDLESCROLL : Data.STRUM_X, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (useDownscroll)
			strumLine.y = FlxG.height - 150;

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlayOpponent.alpha = Main.save.data.laneTransparency;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.alpha = Main.save.data.laneTransparency;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();

		if (Main.save.data.laneUnderlay && !PlayStateChangeables.Optimize)
		{
			if (!PlayStateChangeables.useMiddlescroll)
			{
				add(laneunderlayOpponent);
			}
			add(laneunderlay);
		}

		if (Data.SONG.specialSongNoteSkin != Main.save.data.noteskin && Data.SONG.specialSongNoteSkin != null)
		{
			if (Data.isPixel)
			{
				Data.noteskinPixelSprite = NoteskinHelpers.generatePixelSprite(Data.SONG.specialSongNoteSkin);
				Data.noteskinPixelSpriteEnds = NoteskinHelpers.generatePixelSprite(Data.SONG.specialSongNoteSkin, true);
			}
			else
				Data.noteskinSprite = NoteskinHelpers.generateNoteskinSprite(Data.SONG.specialSongNoteSkin);
			Data.noteskinTexture = Data.SONG.specialSongNoteSkin;
		}
		else
		{
			if (Data.isPixel)
			{
				Data.noteskinPixelSprite = NoteskinHelpers.generatePixelSprite(Main.save.data.noteskin);
				Data.noteskinPixelSpriteEnds = NoteskinHelpers.generatePixelSprite(Main.save.data.noteskin, true);
			}
			else
				Data.noteskinSprite = NoteskinHelpers.generateNoteskinSprite(Main.save.data.noteskin);
			Data.noteskinTexture = Main.save.data.noteskin;
		}

		strumLineNotes = new StrumLine();

		for (i in 0...strumLineNotes.playerStrums.length)
		{
			ScriptHelper.setOnHscript('defaultPlayerStrumX' + i, strumLineNotes.playerStrums.members[i].x);
			ScriptHelper.setOnHscript('defaultPlayerStrumY' + i, strumLineNotes.playerStrums.members[i].y);
		}
		for (i in 0...strumLineNotes.opponentStrums.length)
		{
			ScriptHelper.setOnHscript('defaultOpponentStrumX' + i, strumLineNotes.opponentStrums.members[i].x);
			ScriptHelper.setOnHscript('defaultOpponentStrumY' + i, strumLineNotes.opponentStrums.members[i].y);
		}

		ScriptHelper.setOnHscript("enemyStrumLine", strumLineNotes.opponentStrums);
		ScriptHelper.setOnHscript("playerStrumLine", strumLineNotes.playerStrums);

		// Update lane underlay positions AFTER static arrows :)

		laneunderlay.x = strumLineNotes.playerStrums.members[0].x - 25;
		laneunderlayOpponent.x = strumLineNotes.opponentStrums.members[0].x - 25;

		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);

		// startCountdown();

		if (Data.SONG.songId == null)
			Debug.logTrace('song is null???');
		else
			Debug.logTrace('song looks gucci');

		generateSong(Data.SONG.songId);

		#if desktop
		var filesToCheck:Array<String> = AssetsUtil.listAssetsInPath('assets/gameplay/scripts/notes/', HSCRIPT);
		var filesPushed:Array<String> = [];
		for (file in filesToCheck)
		{
			if (!filesPushed.contains(file))
			{
				if (Paths.getHscriptPath(file, 'notes', false) != null)
				{
					ScriptHelper.hscriptFiles.push(new ModchartHelper(Paths.getHscriptPath(file, 'notes', false), this));
					filesPushed.push(file);
				}
			}
		}

		var filesToCheck:Array<String> = AssetsUtil.listAssetsInPath('assets/gameplay/scripts/difficulties/', HSCRIPT);
		var filesPushed:Array<String> = [];
		for (file in filesToCheck)
		{
			if (!filesPushed.contains(file))
			{
				if (Paths.getHscriptPath(file, 'difficulties', false) != null)
				{
					ScriptHelper.hscriptFiles.push(new ModchartHelper(Paths.getHscriptPath(file, 'difficulties', false), this));
					filesPushed.push(file);
				}
			}
		}
		#end

		/*var filesToCheck:Array<String> = AssetsUtil.readLibrary("gameplay", HSCRIPT, "scripts/notes/");
			for (file in filesToCheck)
			{
				noteScripts.push(new NoteScriptBody(file));
		}*/

		if (Data.startTime != 0)
		{
			var toBeRemoved = [];
			for (i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime <= Data.startTime)
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

		songUI = new GameUI(this, camHUD);
		add(songUI);

		startingSong = true;

		trace('starting');

		if (Data.isStoryMode /* && !seenCutscene*/)
		{
			songCutscene();
		}
		else
		{
			new FlxTimer().start(1, function(timer)
			{
				startCountdown();
			});
		}

		ScriptHelper.callOnHscript('onCreatePost', []);

		// This allow arrow key to be detected by flixel. See https://github.com/HaxeFlixel/flixel/issues/2190
		FlxG.keys.preventDefaultKeys = [];
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		super.create();

		if (openChart)
			openChartEditor();
	}

	public var songUI:GameUI;

	public static function songCutscene()
	{
		if (!ScriptHelper.isFunctionExists('startCutscene')) // Cutscenes for scripts Hmmm. Hscript exclusive
		{
			if (!Data.inCutscene)
			{
				new FlxTimer().start(1, function(timer)
				{
					instance.startCountdown();
				});

				Data.seenCutscene = true;
			}
		}
		else
			ScriptHelper.callOnHscript('startCutscene', []);
	}

	#if (VIDEOS_ALLOWED && !macro)
	var video:VideoHandler;
	#end

	public function playCutscene(name:String, atend:Bool = false, blockFinish:Bool = false)
	{
		#if (VIDEOS_ALLOWED && !macro)
		Data.inCutscene = true;

		var filepath = Paths.video(name);

		video = new VideoHandler();
		if (!OpenFlAssets.exists(filepath))
		{
			Debug.logError('Failed to find video');
			startAndEnd(atend, false);
			return;
		}

		#if (hxCodec >= "3.0.0")
		// Recent versions
		video.play(filepath);
		video.onEndReached.add(function()
		{
			video.dispose();
			startAndEnd(atend, blockFinish);
			return;
		}, true);
		#else
		// Older versions
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			startAndEnd(atend, blockFinish);
			return;
		}
		#end
		#else
		Debug.logTrace('Videos is not allowed');
		#end
	}

	private function startAndEnd(atend:Bool = false, blockFinish:Bool = false)
	{
		if (!blockFinish)
		{
			if (atend)
			{
				if (Data.storyPlaylist.length <= 0)
					FlxG.switchState(new StoryMenuState());
				else
				{
					var diff:String = CoolUtil.difficultyPrefixes[Data.storyDifficulty];
					Data.SONG = Song.loadFromJson(Data.storyPlaylist[0].toLowerCase(), diff);
					FlxG.switchState(new PlayState());
				}
			}
			else
				startCountdown();
		}
	}

	// TODO Redo to work with DialogueBox.hx
	var dialogueCount:Int = 0;

	public var psychDialogue:DialogueBoxPsych;

	// You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		Data.inCutscene = true;
		// TO DO: Make this more flexible, maybe?
		if (psychDialogue != null)
			return;

		if (dialogueFile.dialogue.length > 0)
		{
			Data.inCutscene = true;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if (endingSong)
			{
				psychDialogue.finishThing = function()
				{
					psychDialogue = null;
					endSong();
				}
			}
			else
			{
				psychDialogue.finishThing = function()
				{
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		}
		else
		{
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if (endingSong)
			{
				endSong();
			}
			else
			{
				startCountdown();
			}
		}
	}

	// Thorns shit part 2
	// var screenShake:WindowUtil.WindowShakeEvent;
	// var shake = false;

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

		if (Data.SONG.songId != 'senpai')
		{
			remove(black);

			if (Data.SONG.songId == 'thorns')
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
					Data.inCutscene = true;

					if (Data.SONG.songId == 'thorns')
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
								// shake = true;
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									// shake = false;
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

	var oldvalue:Dynamic;
	var curColor = FlxColor.WHITE;
	var charColor:FlxColor = FlxColor.WHITE;

	function songOverlay(value:Dynamic, time:Float = 1):Void
	{
		if (oldvalue != value)
		{
			if (value != 'delete')
			{
				overlayColor = value;
				charColor = value;
				charColor.alpha = 255;

				colorTween = FlxTween.color(overlay, time, overlay.color, overlayColor, {
					onComplete: function(twn:FlxTween)
					{
						colorTween = null;
					}
				});

				for (char in chars)
				{
					char.colorTween = FlxTween.color(char, time, curColor, charColor, {
						onComplete: function(twn:FlxTween)
						{
							curColor = charColor;
						},
						ease: FlxEase.quadInOut
					});
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
				for (char in chars)
				{
					char.colorTween = FlxTween.color(char, time, char.color, FlxColor.WHITE, {
						onComplete: function(twn:FlxTween)
						{
						},
						ease: FlxEase.quadInOut
					});
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
		if (startedCountdown)
		{
			ScriptHelper.callOnHscript('onStartCountdown', []);
			return;
		}

		Data.inCutscene = false;

		ScriptHelper.callOnHscript('onStartCountdown', []);
		if (!blockCountdown)
		{
			appearStaticArrows();

			for (object in songUI.funnyStartObjects)
				FlxTween.tween(object, {alpha: 1}, 1, {ease: FlxEase.circOut});

			talking = false;
			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;

			ScriptHelper.setOnHscript('startedCountdown', true);

			ScriptHelper.callOnHscript('onCountdownStarted', []);

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
				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', [
					Paths.getUIImagePath('ready', false),
					Paths.getUIImagePath('set', false),
					Paths.getUIImagePath('go', false)
				]);
				introAssets.set('pixel', [
					Paths.getUIImagePath('ready', true),
					Paths.getUIImagePath('set', true),
					Paths.getUIImagePath('date', true)
				]);
				var introSndPaths:Array<String> = [
					"intro3" + altSuffix, "intro2" + altSuffix,
					"intro1" + altSuffix, "introGo" + altSuffix
				];

				var introAlts:Array<String> = introAssets.get('default');
				var week6Bullshit:String = null;

				if (Data.SONG.noteStyle == 'pixel')
				{
					introAlts = introAssets.get('pixel');
					altSuffix = '-pixel';
					week6Bullshit = 'week6';
				}

				if (swagCounter > 0)
					readySetGo(introAlts[swagCounter - 1]);
				FlxG.sound.play(Paths.sound(introSndPaths[swagCounter]), 0.6);

				swagCounter += 1;

				ScriptHelper.callOnHscript('onCountdownTick', [swagCounter]);
			}, 4);
		}
	}

	function readySetGo(path:String):Void
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(OpenFlAssets.getBitmapData(path));
		spr.scrollFactor.set();

		if (Data.SONG.noteStyle == 'pixel')
			spr.setGraphicSize(Std.int(spr.width * CoolUtil.daPixelZoom));

		spr.updateHitbox();
		spr.screenCenter();
		add(spr);
		FlxTween.tween(spr, {y: spr.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				spr.destroy();
			}
		});
	}

	public function setSongTime(time:Float)
	{
		if (time < 0)
			time = 0;

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

	private function releaseInput(evt:KeyboardEvent):Void 
	{
		var key:Int = getKeyFromEvent(evt.keyCode);

		if (key == -1) return;

		var spr:StaticArrow = strumLineNotes.playerStrums.members[key];	
		if (spr != null){
			spr.playAnim('static', false);
			spr.resetAnim = 0;
		}

		ScriptHelper.callOnHscript('onKeyRelease', [FlxKey.toStringMap.get(key)]);
	}

	public static function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;
	
		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function handleInput(evt:KeyboardEvent):Void
	{

		if (PlayStateChangeables.botPlay || paused || evt.keyCode < 0) return;
		if (!generatedMusic || endingSong || boyfriend.stunned) return;

		var key:Int = getKeyFromEvent(evt.keyCode);

		if (key == -1) return;

		if(Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time;

		var plrInputNotes:Array<Note> = notes.members.filter(function(n:Note):Bool {
			var canHit:Bool = n.canBeHit && n.mustPress && !n.tooLate && !n.wasGoodHit;
			return n != null && canHit && !n.isSustainNote && n.noteData == key;
		});
		plrInputNotes.sort(sortHitNotes);

		if (plrInputNotes.length != 0)
		{
			var coolNote = plrInputNotes[0];

			if (plrInputNotes.length > 1)
			{
				for (i in 1...plrInputNotes.length)
				{
					var note = plrInputNotes[i];

					if (note.noteData == coolNote.noteData) {
						if (Math.abs(note.strumTime - coolNote.strumTime) < 1.0)
							invalidateNote(note);
						else if (note.strumTime < coolNote.strumTime)
						{
							coolNote = note;
						}
					}
				}
			}	

			boyfriend.holdTimer = 0;
			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);

			ScriptHelper.callOnHscript('onKeyPress', [FlxKey.toStringMap.get(key)]);
		}
		else if (!Main.save.data.ghost && songStarted)
		{
			noteMiss(key, null);
			health -= 0.20;

			ScriptHelper.callOnHscript('noteMissPress', [FlxKey.toStringMap.get(key)]);
		}

		var spr:StaticArrow = strumLineNotes.playerStrums.members[key];	
		if (spr != null && spr.animation.curAnim.name != 'confirm'){
			spr.playAnim('pressed', false);
			spr.resetAnim = 0;
		}
	}

	private static function getKeyFromEvent(key:FlxKey):Int
	{
		var binds:Array<String> = [
			Main.save.data.leftBind,
			Main.save.data.downBind,
			Main.save.data.upBind,
			Main.save.data.rightBind
		];

		if (key != NONE){
			for (i in binds){
				if (FlxKey.fromString(i) == key){
					return binds.indexOf(i);
				};
			}
		}
		return -1;
	}

	function startNextDialogue()
	{
		dialogueCount++;

		ScriptHelper.callOnHscript('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue()
	{
		ScriptHelper.callOnHscript('onSkipDialogue', [dialogueCount]);
	}

	public var songStarted = false;

	public var doAnything = false;

	public var bar:FlxSprite;

	public var previousRate = Data.songMultiplier;

	public function startSong():Void
	{
		WindowUtil.setWindowTitle(Main.defaultWindowTitle + ' | ${Data.SONG.songName}');

		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(Data.SONG.songId, Data.SONG.diffSoundAssets), 1, false);
		}

		FlxG.sound.music.onComplete = function()
		{
			FlxG.sound.music.time = 0;
			FlxG.sound.music.stop();
			finishSong();
		}
		vocals.onComplete = function()
		{
			vocals.time = 0;
			vocals.stop();
		};

		songLength = ((FlxG.sound.music.length / Data.songMultiplier) / 1000);

		vocals.play();

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
				Data.SONG.songName,
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
			],
				[
					Std.string(detailsText),
					Data.SONG.songName,
					storyDifficultyText,
					'',
					Ratings.GenerateLetterRank(accuracy)
				]),
				LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_TWO", "playState", ["<accuracy>", "<songScore>", "<misses>"],
					[CoolUtil.truncateFloat(accuracy, 2), songScore, Data.misses]),
				iconRPC);
		}
		#end

		FlxG.sound.music.time = Data.startTime;
		if (vocals != null)
			vocals.time = Data.startTime;
		Conductor.songPosition = Data.startTime;
		Data.startTime = 0;

		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < Data.startTime)
				unspawnNotes.remove(unspawnNotes[i]);

		if (needSkip)
		{
			skipActive = true;
			skipText = new FlxText(songUI.healthBarBG.x + 80, songUI.healthBarBG.y - 110, 500, "Press space to skip intro");
			skipText.size = 30;
			skipText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
			skipText.cameras = [camHUD];
			add(skipText);
		}

		ScriptHelper.setOnHscript('songLength', songLength);

		ScriptHelper.callOnHscript('onSongStart', []);

		sectionHit();
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		if (Data.storyDifficulty == 3)
		{
			PlayStateChangeables.scrollSpeed = 4;
		}

		var songData = Data.SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.songId;

		if (Data.SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(Data.SONG.songId, Data.SONG.diffSoundAssets));
		else
			vocals = new FlxSound();

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(Data.SONG.songId, Data.SONG.diffSoundAssets), 1, false);
		}

		FlxG.sound.music.volume = 1;
		vocals.volume = 1;

		FlxG.sound.music.pause();

		if (Data.SONG.needsVoices)
			FlxG.sound.cache(Paths.voices(Data.SONG.songId, Data.SONG.diffSoundAssets));

		// Song duration in a float, useful for the time left feature
		songLength = ((FlxG.sound.music.length / Data.songMultiplier) / 1000);

		Conductor.crochet = ((60 / (Data.SONG.bpm) * 1000));
		Conductor.stepCrochet = Conductor.crochet / 4;

		if (Main.save.data.songPosition)
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.loadImage('healthBar'));
			if (useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 35;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();

			songPosBar = new FlxUIBar(640 - (Std.int(songPosBG.width - 100) / 2), songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 100),
				Std.int(songPosBG.height + 6), this, 'songPositionBar', 0, songLength);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.BLACK, Data.SONG.songPosBarColor);
			add(songPosBar);

			bar = new FlxSprite(songPosBar.x, songPosBar.y).makeGraphic(Math.floor(songPosBar.width), Math.floor(songPosBar.height), FlxColor.TRANSPARENT);
			add(bar);

			FlxSpriteUtil.drawRect(bar, 0, 0, songPosBar.width, songPosBar.height, FlxColor.TRANSPARENT, {thickness: 4, color: FlxColor.BLACK});

			songPosBG.width = songPosBar.width;

			songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (Data.SONG.songName.length * 5), songPosBG.y - 15, 0, Data.SONG.songName, 16);
			songName.setFormat(Paths.font(LanguageStuff.fontName), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();

			songName.text = Data.SONG.songName + ' (' + FlxStringUtil.formatTime(songLength, false) + ')';
			songName.y = songPosBG.y + (songPosBG.height / 3);

			add(songName);

			if (Data.isStoryMode)
			{
				songPosBG.alpha = 0;
				songPosBar.alpha = 0;
				bar.alpha = 0;
				songName.alpha = 0;

				songUI.funnyStartObjects.push(songPosBG);
				songUI.funnyStartObjects.push(songPosBar);
				songUI.funnyStartObjects.push(bar);
				songUI.funnyStartObjects.push(songName);
			}

			songName.screenCenter(X);

			songPosBG.cameras = [camHUD];
			bar.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
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
				if (songNotes[1] == -1) // Skip psych engine event notes
					continue;

				var daStrumTime:Float = songNotes[0] / Data.songMultiplier;
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

				var noteStyle = noteTypeCheck;
				if (songNotes[6] != null)
					noteStyle = songNotes[6];

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, altNote, songNotes[4], noteStyle);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = /*TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(*/songNotes[2]/* / Data.songMultiplier)))*/;
				swagNote.scrollFactor.set(0, 0);
				swagNote.gfNote = (section.gfSection && (songNotes[1] < 4));
				swagNote.noteType = daType;

				if (gottaHitNote)
				{
					swagNote.sprTracker = strumLineNotes.playerStrums.members[daNoteData];
				}
				else
				{
					swagNote.sprTracker = strumLineNotes.opponentStrums.members[daNoteData];
				}

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				swagNote.isAlt = altNote;

				if (songNotes[3])
					swagNote.animSuffix = '-alt';

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(swagNote.sustainLength / Conductor.stepCrochet))
				{
					var altSusNote = songNotes[3]
						|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
						|| (section.playerAltAnim && gottaHitNote);

					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var noteStyle = noteTypeCheck;
					if (songNotes[6] != null)
						noteStyle = songNotes[6];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, false,
						altSusNote, 0, noteStyle);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);
					sustainNote.isAlt = altSusNote;
					sustainNote.parent = swagNote;

					sustainNote.mustPress = gottaHitNote;
					sustainNote.gfNote = (section.gfSection && (songNotes[1] < 4));
					sustainNote.noteType = daType;

					if (gottaHitNote)
					{
						sustainNote.sprTracker = strumLineNotes.playerStrums.members[daNoteData];
					}
					else
					{
						sustainNote.sprTracker = strumLineNotes.opponentStrums.members[daNoteData];
					}

					if (songNotes[3])
						sustainNote.animSuffix = '-alt';

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

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

	public function KillNotes()
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			// if(modchartObjects.exists('note${daNote.ID}'))modchartObjects.remove('note${daNote.ID}');
			invalidateNote(daNote);
		}
		unspawnNotes = [];
	}

	private function invalidateNote(note:Note){
		note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function appearStaticArrows():Void
	{
		var index = 0;
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			if (Data.isStoryMode && !PlayStateChangeables.useMiddlescroll)
				babyArrow.alpha = 1;
			if (PlayStateChangeables.useMiddlescroll)
			{
				if (Data.storyDifficulty == 3)
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
			else if (Data.storyDifficulty == 3)
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
		if (Data.SONG.songId == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
		{
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {
				ease: FlxEase.elasticInOut,
				onComplete: function(twn:FlxTween)
				{
					cameraTwn = null;
				}
			});
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		// if (paused)
		// {
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			if (vocals != null)
				vocals.pause();
		}
		// }

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

			FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
			{
				if (!tmr.finished)
					tmr.active = true;
			});

			FlxTween.globalManager.forEach(function(twn:FlxTween)
			{
				if (!twn.finished)
					twn.active = true;
			});

			paused = false;

			ScriptHelper.callOnHscript('onResume', []);
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		if (finishTimer != null)
			return;

		vocals.stop();
		FlxG.sound.music.stop();

		FlxG.sound.music.play();
		vocals.play();
		FlxG.sound.music.time = Conductor.songPosition * Data.songMultiplier;
		vocals.time = FlxG.sound.music.time;

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
				Data.SONG.songName,
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
			],
				[
					Std.string(detailsText),
					Data.SONG.songName,
					storyDifficultyText,
					'',
					Ratings.GenerateLetterRank(accuracy)
				]),
				LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_TWO", "playState", ["<accuracy>", "<songScore>", "<misses>"],
					[CoolUtil.truncateFloat(accuracy, 2), songScore, Data.misses]),
				iconRPC);
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

	public var pastEvents:Array<Float> = [];

	public var blockPause:Bool = false;

	public var blockGameOver:Bool = false;

	override public function update(elapsed:Float)
	{
		ScriptHelper.callOnHscript('onUpdate', [elapsed]);

		#if !debug
		perfectMode = false;
		#end
		if (!PlayStateChangeables.Optimize && !hscriptStageCheck)
			if (Stage != null)
				Stage.update(elapsed);

		if (Main.save.data.botplay != PlayStateChangeables.botPlay)
		{
			PlayStateChangeables.botPlay = Main.save.data.botplay;
			if (!addedBotplay)
			{
				addedBotplayOnce = true;
				addedBotplay = true;
				add(songUI.botPlayState);
			}
			else
			{
				addedBotplay = false;
				songUI.botPlayState.kill();
			}
		}

		if (Main.save.data.downscroll != useDownscroll)
		{
			useDownscroll = Main.save.data.downscroll;
		}

		if (Main.save.data.middleScroll != PlayStateChangeables.useMiddlescroll)
		{
			PlayStateChangeables.useMiddlescroll = Main.save.data.middleScroll;
			strumLineNotes.useMiddlescroll = PlayStateChangeables.useMiddlescroll;
			strumLine.y = PlayStateChangeables.useMiddlescroll ? Data.STRUM_X_MIDDLESCROLL : Data.STRUM_X;
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 14000 * Data.songMultiplier)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				dunceNote.cameras = [camHUD];

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();

			var currentIndex = 0;
			for (i in Data.SONG.eventsArray)
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

		if (FlxG.keys.justPressed.NINE)
			songUI.iconP1.swapOldIcon();

		songUI.scoreTxt.screenCenter(X);

		var pauseBind = FlxKey.fromString(Main.save.data.pauseBind);
		var gppauseBind = FlxKey.fromString(Main.save.data.gppauseBind);

		if ((FlxG.keys.anyJustPressed([pauseBind]) || Controls.gamepad && FlxG.keys.anyJustPressed([gppauseBind]))
			&& startedCountdown
			&& canPause
			&& !cannotDie)
		{
			ScriptHelper.callOnHscript('onPause', []);
			if (!blockPause)
			{
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.pause();
					if (vocals != null)
						vocals.pause();
				}
				FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
				{
					if (!tmr.finished)
						tmr.active = false;
				});

				FlxTween.globalManager.forEach(function(twn:FlxTween)
				{
					if (!twn.finished)
						twn.active = false;
				});

				for (note in strumLineNotes.playerStrums){
					if(note.animation.curAnim != null && note.animation.curAnim.name != 'static')
						{
							note.playAnim('static');
							note.resetAnim = 0;
						}
				}	

				openSubState(new PauseSubState());
			}
		}

		if (FlxG.keys.justPressed.SEVEN && songStarted)
		{
			Data.songMultiplier = 1;
			cannotDie = true;

			openChartEditor();
		}

		#if debug
		if (!PlayStateChangeables.Optimize && (!hscriptStageCheck))
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

						invalidateNote(daNote);
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

		#if debug
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

		if (FlxG.keys.justPressed.SPACE && !skipActive && !Data.inCutscene)
		{
			if (boyfriend.animationExists('hey'))
				boyfriend.playAnim('hey', true);
			if (gf.animationExists('cheer'))
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

			var curTime:Float = FlxG.sound.music.time / Data.songMultiplier;
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

				if (Main.save.data.songPosition)
				{
					songName.text = Data.SONG.songName + ' (' + time + ')';
					songPosBar.percent = songPositionBar;
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
							Data.SONG.songName,
							storyDifficultyText,
							LanguageStuff.getPlayState("$TIME_LEFT_TEXT") + time,
							Ratings.GenerateLetterRank(accuracy)
						]),
						LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_TWO", "playState", ["<accuracy>", "<songScore>", "<misses>"],
							[CoolUtil.truncateFloat(accuracy, 2), songScore, Data.misses]),
						iconRPC);

					timerCount = 0;
				}
			}
			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			if (Main.save.data.zoom < 0.8)
				Main.save.data.zoom = 0.8;

			if (Main.save.data.zoom > 1.2)
				Main.save.data.zoom = 1.2;

			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(Main.save.data.zoom, camHUD.zoom, 0.95);
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

		if (health <= 0 && !cannotDie)
		{
			if (!usedTimeTravel)
			{
				ScriptHelper.callOnHscript('onGameOver', []);
				if (!blockGameOver)
				{
					isDead = true;
					boyfriend.stunned = true;

					persistentUpdate = false;
					persistentDraw = false;
					paused = true;

					FlxG.sound.music.volume = 0;
					vocals.volume = 0;

					vocals.pause();
					FlxG.sound.music.pause();

					if (Main.save.data.InstantRespawn)
					{
						MusicBeatState.switchState(new PlayState());
					}
					else
					{
						if (Data.storyWeek == 3 && Data.isStoryMode && !PlayStateChangeables.botPlay && !addedBotplayOnce)
						{
							Achievements.getAchievement(167273, 'dead');
						}
						if (Data.SONG.songId == 'winter-horrorland'
							&& Data.isStoryMode
							&& !PlayStateChangeables.botPlay
							&& !addedBotplayOnce)
						{
							Achievements.getAchievement(167275, 'corruption');
						}
						if (Data.SONG.songId == 'thorns' && Data.isStoryMode && !PlayStateChangeables.botPlay && !addedBotplayOnce)
						{
							Achievements.getAchievement(167276, 'dead-pixel');
						}
						if (Data.SONG.songId == 'stress' && Data.isStoryMode && !PlayStateChangeables.botPlay && !addedBotplayOnce)
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
							Data.SONG.songName,
							storyDifficultyText,
							'',
							Ratings.GenerateLetterRank(accuracy)
						]),
						LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_TWO", "playState", ["<accuracy>", "<songScore>", "<misses>"],
							[CoolUtil.truncateFloat(accuracy, 2), songScore, Data.misses]),
						iconRPC);
					#end
					/*for (tween in modchartTweens) {
							tween.active = true;
						}
						for (timer in modchartTimers) {
							timer.active = true;
					}*/
				}
			}
			else
				health = 1;
		}
		if (!Data.inCutscene && Main.save.data.resetButton)
		{
			var resetBind = FlxKey.fromString(Main.save.data.resetBind);
			var gpresetBind = FlxKey.fromString(Main.save.data.gpresetBind);
			if ((FlxG.keys.anyJustPressed([resetBind]) || Controls.gamepad && FlxG.keys.anyJustPressed([gpresetBind])))
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				FlxG.sound.music.volume = 0;
				vocals.volume = 0;

				vocals.pause();
				FlxG.sound.music.pause();

				if (Main.save.data.InstantRespawn)
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
						Data.SONG.songName,
						storyDifficultyText,
						'',
						Ratings.GenerateLetterRank(accuracy)
					]),
					LanguageStuff.replaceFlagsAndReturn("$DISCORD_RPC_TWO", "playState", ["<accuracy>", "<songScore>", "<misses>"],
						[CoolUtil.truncateFloat(accuracy, 2), songScore, Data.misses]),
					iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(Data.SONG.speed, 2));

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (useDownscroll)
				{
					daNote.y = (daNote.sprTracker.y
						+
						0.45 * ((Conductor.songPosition - daNote.strumTime) / Data.songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? Data.SONG.speed : PlayStateChangeables.scrollSpeed,
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
					daNote.y = (daNote.sprTracker.y
						- 0.45 * ((Conductor.songPosition - daNote.strumTime) / Data.songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? Data.SONG.speed : PlayStateChangeables.scrollSpeed,
							2)))
						+ daNote.noteYOff;

					if (daNote.isSustainNote)
					{
						if ((PlayStateChangeables.botPlay
							|| !daNote.mustPress
							|| daNote.wasGoodHit
							|| holdArray[Math.floor(Math.abs(daNote.noteData))]
							&& !daNote.ignoreNote)
							&& daNote.y
							+ daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
						{
							// Clip to strumline
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				if (!daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
				{
					if (Data.SONG.songId != 'tutorial')
						camZooming = true;

					if (daNote.gfNote)
						checkNoteType('gf', daNote);
					else
						checkNoteType('dad', daNote);

					var time:Float = 0.15;
					if (daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end'))
					{
						time += 0.15;
					}

					strumLineNotes.opponentStrums.forEach(function(spr:StaticArrow)
					{
						if (daNote.sprTracker == spr)
							pressArrow(spr, spr.ID, daNote, time);
					});
					dad.holdTimer = 0;

					if (Data.SONG.needsVoices)
						vocals.volume = 1;
					daNote.active = false;

					if (Data.storyDifficulty == 3 && !daNote.isSustainNote)
					{
						health -= 0.015;
					}

					invalidateNote(daNote);

					ScriptHelper.callOnHscript('opponentNoteHit', [
						notes.members.indexOf(daNote),
						Math.abs(daNote.noteData),
						daNote.noteType,
						daNote.isSustainNote
					]);
					/*for (script in noteScripts)
						{
							script.opponentNoteHit(daNote);
					}*/
				}

				if (!daNote.mustPress
					&& PlayStateChangeables.useMiddlescroll
					&& Data.storyDifficulty != 3)
					daNote.alpha = 0.5;

				if (Data.storyDifficulty == 3 && !daNote.mustPress)
					daNote.alpha = 0;

				if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
				{
					invalidateNote(daNote);
				}
				else if (daNote.strumTime / Data.songMultiplier - Conductor.songPosition / Data.songMultiplier < -(166 * Conductor.timeScale)
					&& songStarted)
				{
					if ((daNote.mustPress && !useDownscroll || daNote.mustPress && useDownscroll) && daNote.mustPress)
					{
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							invalidateNote(daNote);
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
								Data.misses++;
								totalNotesHit -= 1;
							}
							updateAccuracy();
						}
						else
						{
							if (!daNote.ignoreNote)
								vocals.volume = 0;
							if (Data.theFunne && !daNote.isSustainNote)
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
						invalidateNote(daNote);
					}
				}
			});
		}

		if (!Data.inCutscene && songStarted)
			keyShit();

		
		if (controls.ATTACK && allowToAttack && !FlxFlicker.isFlickering(dad))
		{
			if (boyfriend.curCharacter == 'bf' || boyfriend.animationExists('attack'))
			{
				boyfriend.playAnim('attack', true);
				if (Main.save.data.flashing)
					FlxFlicker.flicker(dad, 0.2, 0.05, true);
				health += 0.02;
	
				ScriptHelper.callOnHscript('onAttack', []);
			}
		}

		super.update(elapsed);

		ScriptHelper.setOnHscript('cameraX', camFollow.x);
		ScriptHelper.setOnHscript('cameraY', camFollow.y);
		ScriptHelper.setOnHscript('botPlay', PlayStateChangeables.botPlay);

		ScriptHelper.setOnHscript('curDecimalBeat', curDecimalBeat);

		ScriptHelper.callOnHscript('onUpdatePost', [elapsed]);
	}

	public function addCharacterToList(newCharacter:String, type:Int)
	{
		switch (type)
		{
			case 0:
				if (!boyfriendMap.exists(newCharacter))
				{
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
				}

			case 1:
				if (!dadMap.exists(newCharacter))
				{
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
				}

			case 2:
				if (gf != null && !gfMap.exists(newCharacter))
				{
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
				}
		}
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		canPause = false;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new editors.ChartingState());
		Data.chartingMode = true;

		#if desktop
		DiscordClient.changePresence(LanguageStuff.getPlayState("$CHART_EDITOR_TEXT") + Data.SONG.songName, null);
		#end
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false)
	{
		if (gfCheck && char.replacesGF)
		{
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		if (char.positionArray != null)
		{
			char.x += char.positionArray[0];
			char.y += char.positionArray[1];
		}
	}

	public function camFollowPos(x:Float = 0, y:Float = 0)
	{
		isCameraOnForcedPos = false;
		camFollow.setPosition(x, y);
		isCameraOnForcedPos = true;
	}

	public function checkEventAtPos(eventAtPos:gameplayStuff.Song.EventsAtPos)
	{
		if (eventAtPos.position <= curDecimalBeat && !pastEvents.contains(eventAtPos.position))
		{
			pastEvents.push(eventAtPos.position);
		}
	}

	var blammedeventplayed:Bool = false;

	public function reloadHealthBarColors()
	{
		songUI.reloadHealthBarColors();
	}

	public function changeCharacter(charType:String = 'bf', newCharName:String)
	{
		switch (charType)
		{
			case 'bf':
				{
					if (boyfriend.hasTrail)
					{
						if (Main.save.data.distractions)
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

					ScriptHelper.setOnHscript('boyfriendName', boyfriend.curCharacter);

					if (hscriptStage != null)
					{
						hscriptStage.boyfriend = boyfriend;
						hscriptStage.boyfriendGroup = boyfriendGroup;
					}

					if (boyfriend.hasTrail)
					{
						if (Main.save.data.distractions)
						{
							if (!PlayStateChangeables.Optimize)
							{
								bfTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
								add(bfTrail);
							}
						}
					}
				}
				startCharacterHscript(boyfriend.curCharacter);
			case 'dad':
				{
					if (dad.hasTrail)
					{
						if (Main.save.data.distractions)
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

					ScriptHelper.setOnHscript('dadName', dad.curCharacter);

					if (hscriptStage != null)
					{
						hscriptStage.dad = dad;
						hscriptStage.dadGroup = dadGroup;
					}

					if (dad.hasTrail)
					{
						if (Main.save.data.distractions)
						{
							if (!PlayStateChangeables.Optimize)
							{
								dadTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
								add(dadTrail);
							}
						}
					}
				}
				startCharacterHscript(dad.curCharacter);
			case 'gf':
				{
					if (gf.hasTrail)
					{
						if (Main.save.data.distractions)
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

					ScriptHelper.setOnHscript('gfName', gf.curCharacter);

					if (hscriptStage != null)
					{
						hscriptStage.gf = gf;
						hscriptStage.gfGroup = gfGroup;
					}

					if (gf.hasTrail)
					{
						if (Main.save.data.distractions)
						{
							if (!PlayStateChangeables.Optimize)
							{
								gfTrail = new FlxTrail(gf, null, 4, 24, 0.3, 0.069);
								add(gfTrail);
							}
						}
					}
				}
				startCharacterHscript(gf.curCharacter);
		}
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

		switch (charType)
		{
			case 'bf':
				{
					if (boyfriend.hasTrail)
					{
						if (Main.save.data.distractions)
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

					ScriptHelper.setOnHscript('boyfriendName', boyfriend.curCharacter);

					if (hscriptStage != null)
					{
						hscriptStage.boyfriend = boyfriend;
						hscriptStage.boyfriendGroup = boyfriendGroup;
					}

					if (boyfriend.hasTrail)
					{
						if (Main.save.data.distractions)
						{
							if (!PlayStateChangeables.Optimize)
							{
								bfTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
								add(bfTrail);
							}
						}
					}
				}
				startCharacterHscript(boyfriend.curCharacter);
			case 'dad':
				{
					if (dad.hasTrail)
					{
						if (Main.save.data.distractions)
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

					ScriptHelper.setOnHscript('dadName', dad.curCharacter);

					if (hscriptStage != null)
					{
						hscriptStage.dad = dad;
						hscriptStage.dadGroup = dadGroup;
					}

					if (dad.hasTrail)
					{
						if (Main.save.data.distractions)
						{
							if (!PlayStateChangeables.Optimize)
							{
								dadTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
								add(dadTrail);
							}
						}
					}
				}
				startCharacterHscript(dad.curCharacter);
			case 'gf':
				{
					if (gf.hasTrail)
					{
						if (Main.save.data.distractions)
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

					ScriptHelper.setOnHscript('gfName', gf.curCharacter);

					if (hscriptStage != null)
					{
						hscriptStage.gf = gf;
						hscriptStage.gfGroup = gfGroup;
					}

					if (gf.hasTrail)
					{
						if (Main.save.data.distractions)
						{
							if (!PlayStateChangeables.Optimize)
							{
								gfTrail = new FlxTrail(gf, null, 4, 24, 0.3, 0.069);
								add(gfTrail);
							}
						}
					}
				}
				startCharacterHscript(gf.curCharacter);
		}
		reloadHealthBarColors();
		reloadIcons();
	}

	public function reloadIcons()
	{
		songUI.iconP1.changeIcon(boyfriend.curCharacter, boyfriend.characterIcon);
		songUI.iconP2.changeIcon(dad.curCharacter, dad.characterIcon);
	}

	public function getSectionByTime(ms:Float):SwagSection
	{
		for (i in Data.SONG.notes)
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

		for (i in 0...Data.SONG.notes.length) // loops through sections
		{
			var section = Data.SONG.notes[i];

			var currentBeat = 4 * i;

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				return;

			var start:Float = (currentBeat - currentSeg.startBeat) / ((currentSeg.bpm) / 60);

			section.startTime = (currentSeg.startTime + start) * 1000;

			if (i != 0)
				Data.SONG.notes[i - 1].endTime = section.startTime;
			section.endTime = Math.POSITIVE_INFINITY;
		}
	}

	public static function cancelMusicFadeTween()
	{
		if (FlxG.sound.music.fadeTween != null)
		{
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public var transitioning = false;
	public var blockSongEnd:Bool = false;

	public function endSong():Void
	{
		endingSong = true;
		Data.seenCutscene = false;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		PlayStateChangeables.botPlay = false;
		PlayStateChangeables.scrollSpeed = 1 / Data.songMultiplier;
		PlayStateChangeables.useDownscroll = false;
		PlayStateChangeables.useMiddlescroll = false;

		if (Main.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		ScriptHelper.callOnHscript('onEndSong', []);

		canPause = false;
		/*FlxG.sound.music.volume = 0;
			vocals.volume = 0;
			FlxG.sound.music.pause();
			vocals.pause(); */
		if (!blockSongEnd)
		{
			if (Data.SONG.validScore)
			{
				#if !switch
				Highscore.saveScore(Data.SONG.songId, Math.round(songScore), Data.storyDifficulty);
				Highscore.saveCombo(Data.SONG.songId, Ratings.GenerateLetterRank(accuracy), Data.storyDifficulty);
				#end
			}

			ScriptHelper.clearAllScripts();
			WindowUtil.setWindowTitle(Main.defaultWindowTitle);

			if (Data.offsetTesting)
			{
				FlxG.sound.playMusic(Paths.music(Main.save.data.menuMusic));
				Data.offsetTesting = false;
				LoadingState.loadAndSwitchState(new OptionsMenu());
				clean();
				Main.save.data.offset = offsetTest;
			}
			else if (Data.stageTesting)
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
				var savedAchievements:Array<String> = Main.save.data.savedAchievements;

				if (Data.SONG.songId == 'blammed'
					&& !savedAchievements.contains('blammed_completed')
					&& !PlayStateChangeables.botPlay
					&& !addedBotplayOnce)
				{
					var played:Int = Main.save.data.playedBlammed;
					played += 1;
					Main.save.data.playedBlammed = played;
					if (played == 100)
					{
						Achievements.getAchievement(167278);
					}
				}
				if (Data.isStoryMode)
				{
					Data.campaignScore += Math.round(songScore);
					Data.campaignMisses += Data.misses;
					Data.campaignSicks += Data.sicks;
					Data.campaignGoods += Data.goods;
					Data.campaignBads += Data.bads;
					Data.campaignShits += Data.shits;

					Data.storyPlaylist.remove(Data.storyPlaylist[0]);

					if (Data.storyPlaylist.length <= 0)
					{
						transIn = FlxTransitionableState.defaultTransIn;
						transOut = FlxTransitionableState.defaultTransOut;

						paused = true;

						FlxG.sound.music.stop();
						vocals.stop();
						if (Main.save.data.scoreScreen)
						{
							if (Main.save.data.songPosition)
							{
								FlxTween.tween(songPosBar, {alpha: 0}, 1);
								FlxTween.tween(bar, {alpha: 0}, 1);
								FlxTween.tween(songName, {alpha: 0}, 1);
							}
							openSubState(new ResultsScreen());
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								Data.inResults = true;
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
							FlxG.sound.playMusic(Paths.music(Main.save.data.menuMusic));
							Conductor.changeBPM(102);
							MusicBeatState.switchState(new StoryMenuState());
							clean();
						}

						if (Data.SONG.validScore)
						{
							Highscore.saveWeekScore(Data.storyWeek, Data.campaignScore, Data.storyDifficulty);
						}

						if (ModCore.loadedModsLength == 0
							&& (Data.storyDifficulty == 2 || Data.storyDifficulty == 3)
							&& Data.campaignMisses == 0
							&& !savedAchievements.contains(Achievements.getWeekSaveId(Data.storyWeek))
							&& !PlayStateChangeables.botPlay
							&& !addedBotplayOnce)
							Achievements.checkWeekAchievement(Data.storyWeek);

						if (savedAchievements.contains('week1_nomiss')
							&& savedAchievements.contains('week2_nomiss')
							&& savedAchievements.contains('week3_nomiss')
							&& savedAchievements.contains('week4_nomiss')
							&& savedAchievements.contains('week5_nomiss')
							&& savedAchievements.contains('week6_nomiss')
							&& savedAchievements.contains('week7_nomiss')
							&& !savedAchievements.contains('vanila_game_completed')
							&& !PlayStateChangeables.botPlay
							&& !addedBotplayOnce)
						{
							Achievements.getAchievement(167263);
						}

						StoryMenuState.weekCompleted.set(WeekData.weeksList[Data.storyWeek], true);
						Main.save.data.weekCompleted = StoryMenuState.weekCompleted;
					}
					else
					{
						var diff:String = CoolUtil.difficultyPrefixes[Data.storyDifficulty];

						Debug.logInfo('PlayState: Loading next story song ${Data.storyPlaylist[0]}${diff}');

						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						prevCamFollow = camFollow;

						Data.SONG = Song.loadFromJson(Data.storyPlaylist[0], diff);
						FlxG.sound.music.stop();

						LoadingState.loadAndSwitchState(new PlayState());

						clean();
					}
				}
				else if (Data.chartingMode)
				{
					openChartEditor();
					return;
				}
				else
				{
					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();

					if (Main.save.data.scoreScreen)
					{
						openSubState(new ResultsScreen());
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							Data.inResults = true;
						});
					}
					else
					{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music(Main.save.data.menuMusic), 0);
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

	var finishTimer:FlxTimer = null;

	public var songEndCallback:Void->Void = null;

	public function finishSong():Void
	{
		Debug.logTrace("we're fuckin ending the song ");

		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		if (songEndCallback == null)
			songEndCallback = endSong;

		#if desktop
		if (!Data.chartingMode)
			GameJoltAPI.addScore(Math.round(songScore), 716199, 'Song - ' + Data.SONG.songName);
		#end

		if (Main.save.data.offset <= 0)
		{
			songEndCallback();
		}
		else
		{
			finishTimer = new FlxTimer().start(Main.save.data.offset / 1000, function(tmr:FlxTimer)
			{
				songEndCallback();
			});
		}
	}

	var timeShown = 0;
	private var lastDadNote:Note = null;
	private var lastBfNote:Note = null;
	private var lastGfNote:Note = null;

	function checkNoteType(char:String, note:Note)
	{
		switch (char)
		{
			case 'bf':
				if (!note.noAnimation)
				{
					if (note.bulletNote)
					{
						boyfriend.playAnim('dodge', true);
						FlxG.sound.play(Paths.sound('hankshoot'));
					}
					else if (note.hurtNote)
					{
						health -= 0.2;
						Data.misses++;
					}
					else
					{
						boyfriend.playAnim('sing' + dataSuffix[note.noteData] + note.animSuffix, true);
						if (lastBfNote != null)
						{
							if (!note.isSustainNote)
								if (lastBfNote.strumTime == note.strumTime)
									doGhostAnim(boyfriend, 'sing' + dataSuffix[lastBfNote.noteData] + lastBfNote.animSuffix);
						}
					}
				}
				if (!note.isSustainNote)
					lastBfNote = note;
			case 'dad':
				if (!note.noAnimation)
				{
					dad.playAnim('sing' + dataSuffix[note.noteData] + note.animSuffix, true);
					if (lastDadNote != null)
					{
						if (!note.isSustainNote)
							if (lastDadNote.strumTime == note.strumTime)
								doGhostAnim(dad, 'sing' + dataSuffix[lastDadNote.noteData] + lastDadNote.animSuffix);
					}
				}
				if (!note.isSustainNote)
					lastDadNote = note;
			case 'gf':
				if (!note.noAnimation)
				{
					gf.playAnim('sing' + dataSuffix[note.noteData] + note.animSuffix, true);
					if (lastGfNote != null)
					{
						if (!note.isSustainNote)
							if (lastGfNote.strumTime == note.strumTime)
								doGhostAnim(gf, 'sing' + dataSuffix[lastGfNote.noteData] + lastGfNote.animSuffix);
					}
				}
				if (!note.isSustainNote)
					lastGfNote = note;
		}
	}

	function doGhostAnim(char:Character, animToPlay:String)
	{
		if (char.ghostTween != null)
			char.ghostTween.cancel();
		char.ghost.alpha = 0.8;
		char.ghost.visible = true;
		char.ghost.animation.play(animToPlay, true);
		char.ghost.offset.set(char.animOffsets.get(animToPlay)[0], char.animOffsets.get(animToPlay)[1]);
		char.ghostTween = FlxTween.tween(char.ghost, {alpha: 0}, 0.75, {
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				char.ghostTween = null;
			}
		});
	}

	private function popUpScore(daNote:Note):Void
	{
		ScriptHelper.setOnHscript('score', songScore);
		ScriptHelper.setOnHscript('misses', Data.misses);

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

		if (Main.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = Ratings.judgeNote(noteDiff);

		switch (daRating)
		{
			case 'shit':
				daRating = 'shit';
				score = -300;
				combo = 0;
				Data.misses++;
				health -= 0.1 * (daNote != null ? daNote.noteScore : 1);
				ss = false;
				Data.shits++;
				if (Main.save.data.accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.06 * (daNote != null ? daNote.noteScore : 1);
				ss = false;
				Data.bads++;
				if (Main.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				health += 0.023 * (daNote != null ? daNote.noteScore : 1);
				Data.goods++;
				if (Main.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				daRating = 'sick';
				if (health < 2)
					health += 0.04 * (daNote != null ? daNote.noteScore : 1);
				if (Main.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				Data.sicks++;
		}

		if (Data.songMultiplier >= 1.05)
			score = getRatesScore(Data.songMultiplier, score);

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
			var pixelShitPart3:String = null;

			if (Data.SONG.noteStyle == 'pixel')
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
				pixelShitPart3 = 'week6';
			}

			rating.loadGraphic(FlxGraphic.fromBitmapData(OpenFlAssets.getBitmapData(Paths.getUIImagePath(daRating, Data.SONG.noteStyle == 'pixel'))));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;

			if (Main.save.data.changedHit)
			{
				rating.x = Main.save.data.changedHitX;
				rating.y = Main.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = CoolUtil.truncateFloat(noteDiff / Data.songMultiplier, 3);
			if (PlayStateChangeables.botPlay)
				msTiming = 0;

			if (msTiming >= 0.03 && Data.offsetTesting)
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

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(FlxGraphic.fromBitmapData(OpenFlAssets.getBitmapData(Paths.getUIImagePath("combo",
				Data.SONG.noteStyle == 'pixel'))));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			ratingsGroup.add(rating);

			if (Data.SONG.noteStyle != 'pixel')
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = Main.save.data.antialiasing;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = Main.save.data.antialiasing;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * CoolUtil.daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * CoolUtil.daPixelZoom * 0.7));
			}

			comboSpr.updateHitbox();
			rating.updateHitbox();

			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (combo > Data.highestCombo)
				Data.highestCombo = combo;

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
				var numScore:FlxSprite = new FlxSprite().loadGraphic(FlxGraphic.fromBitmapData(OpenFlAssets.getBitmapData(Paths.getUIImagePath('num'
					+ Std.int(i), Data.SONG.noteStyle == 'pixel'))));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (Data.SONG.noteStyle != 'pixel')
				{
					numScore.antialiasing = Main.save.data.antialiasing;
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
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					ratingsGroup.remove(coolText);
					ratingsGroup.remove(comboSpr);
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

	//Hold notes and gamepad inputs helper
	private function keyShit():Void
	{
		if (!generatedMusic) return;
		if (PlayStateChangeables.botPlay) {
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.mustPress && Conductor.songPosition >= daNote.strumTime && !daNote.ignoreNote)
				{
					goodNoteHit(daNote);
					boyfriend.holdTimer = 0;
				}
			});
			return;
		}

		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];

		if (holdArray.contains(true))
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] 
					&& daNote.sustainActive && !daNote.tooLate && !daNote.wasGoodHit)
				{
					goodNoteHit(daNote);
				}
			});
		}

		/*if (Controls.gamepad)
		{
			if (pressArray.contains(true))
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
								{
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{
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
					invalidateNote(note);
				}

				possibleNotes.sort(sortHitNotes);

				var hit = [false, false, false, false];

				if (perfectMode){
					goodNoteHit(possibleNotes[0]);
				}
				else if (possibleNotes.length > 0)
				{
					if (possibleNotes.length > 0)
					{
						if (!Main.save.data.ghost)
						{
							for (shit in 0...pressArray.length)
							{
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
									// scoreTxt.color = FlxColor.WHITE;
									var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
									goodNoteHit(coolNote);
								}
							}
						}
					}
				};

				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true))
				{
					playerBop();
				}

				if (!Main.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}
		}*/

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true))
		{
			playerBop();
		}
	}

	private function playerBop(){
		if (boyfriend.getCurAnimName().startsWith('sing')
			&& !boyfriend.getCurAnimName().endsWith('miss')
			&& (boyfriend.getCurAnim().curFrame >= 10 || boyfriend.getCurAnim().finished))
			boyfriend.dance();
	}

	function noteMiss(direction:Int = 1, daNote:Note, isDad:Bool = false):Void
	{
		if (daNote != null && daNote.bulletNote)
		{
			health = 0;
			Data.songJudgements.push("miss");
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
			Data.misses++;

			totalNotesHit -= 1;

			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;

			if (Main.save.data.missSounds)
			{
				FlxG.sound.play(Paths.soundRandom('missnote' + altSuffix, 1, 3), FlxG.random.float(0.1, 0.2));
			}

			if (isDad)
			{
				dad.playAnim('sing' + dataSuffix[direction] + 'miss' + daNote?.animSuffix, true);
			}
			else if (!isDad || (daNote != null && !daNote.hitByP2))
			{
				boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss' + daNote?.animSuffix, true);
			}
			else
				Debug.logError('No one should miss, lol');

			if (daNote != null)
			{
				ScriptHelper.callOnHscript('noteMiss', [
					notes.members.indexOf(daNote),
					daNote.noteData,
					daNote.noteType,
					daNote.isSustainNote
				]);
				/*for (script in noteScripts)
					{
						script.noteMiss(daNote);
				}*/
			}

			updateAccuracy();
		}

		songUI.scoreTxt.onMiss();
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		songUI.scoreTxt.updateTexts();
		WindowUtil.setWindowTitle(Main.defaultWindowTitle
			+ ' | Song: ${Data.SONG.songName} | Score: ${Std.string(instance.songScore)} | Misses: ${Std.string(Data.misses)}');
		songUI.judgementCounter.text = 'Sicks: ${Data.sicks}\nGoods: ${Data.goods}\nBads: ${Data.bads}\nShits: ${Data.shits}\nMisses: ${Data.misses}';
	}

	function moveCameraSection():Void
	{
		if (curSection == null)
			return;

		if (gf != null && curSection.gfSection)
		{
			camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.camPos[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.camPos[1] + girlfriendCameraOffset[1];
			tweenCamIn();

			// camManager.tweenTargetFocusTo(gf, 1, 1);
			ScriptHelper.callOnHscript('onMoveCamera', ['gf']);
			return;
		}

		if (!curSection.mustHitSection)
		{
			// camManager.tweenTargetFocusTo(dad, 1, 1);
			moveCamera(true);
			ScriptHelper.callOnHscript('onMoveCamera', ['dad']);
		}
		else
		{
			// camManager.tweenTargetFocusTo(boyfriend, 1, 1);
			moveCamera(false);
			ScriptHelper.callOnHscript('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;

	public var blockCameraMoves:Bool = false;

	public function moveCamera(isDad:Bool)
	{
		if (blockCameraMoves)
			return;

		if (isDad)
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

			if (Data.SONG.songId == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {
					ease: FlxEase.elasticInOut,
					onComplete: function(twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.judgeNote(noteDiff);

		Data.songJudgements.push(note.rating);

		if (note.rating == "miss")
		{
			return;
		}

		if (note.rating == 'sick' && !note.isSustainNote && !PlayStateChangeables.botPlay)
		{
			strumLineNotes.spawnNoteSplashOnNote(note);
		}

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
			else if (note.gfNote)
				checkNoteType('dad', note);
			else
				checkNoteType('bf', note);

			if (!PlayStateChangeables.botPlay)
			{
				strumLineNotes.playerStrums.forEach(function(spr:StaticArrow)
				{
					pressArrow(spr, spr.ID, note);
				});
			}
			else
			{
				var time:Float = 0.15;
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					time += 0.15;
				}
				strumLineNotes.playerStrums.forEach(function(spr:StaticArrow)
				{
					pressArrow(spr, spr.ID, note, time);
				});
			}

			if (!note.isSustainNote)
			{
				invalidateNote(note);
			}
			else
			{
				note.wasGoodHit = true;
			}
			if (!note.isSustainNote)
			{
				updateAccuracy();
			}
			ScriptHelper.callOnHscript('goodNoteHit', [
				notes.members.indexOf(note),
				Math.abs(note.noteData),
				note.noteType,
				note.isSustainNote
			]);
			/*for (script in noteScripts)
				{
					script.playerNoteHit(note);
			}*/
		}
	}

	function pressArrow(spr:StaticArrow, idCheck:Int, daNote:Note, ?time:Float)
	{
		if (Math.abs(daNote.noteData) == idCheck)
		{
			if (spr != null)
				spr.playAnim('confirm', true);
			if (time != null)
				spr.resetAnim = time;
		}
	}

	var danced:Bool = false;

	override function stepHit()
	{
		currentStep = curStep;

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (Data.SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		ScriptHelper.setOnHscript('curStep', curStep);

		if (Stage != null)
			Stage.stepHit();

		super.stepHit();
	}

	override function sectionHit()
	{
		if (curSection != null)
		{
			dad.altIdle = dadAltAnim = curSection.CPUAltAnim;
			boyfriend.altIdle = bfAltAnim = curSection.playerAltAnim;
			gf.altIdle = gfAltAnim = curSection.gfAltAnim;

			ScriptHelper.setOnHscript('mustHitSection', curSection.mustHitSection);
			ScriptHelper.setOnHscript('playerAltAnim', bfAltAnim);
			ScriptHelper.setOnHscript('dadAltAnim', dadAltAnim);
			ScriptHelper.setOnHscript('gfAltAnim', gfAltAnim);
			ScriptHelper.setOnHscript('gfSection', curSection.gfSection);

			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}
		}

		ScriptHelper.setOnHscript('curSectionNumber', curSectionInt);

		ScriptHelper.setOnHscript('curSection', curSection);

		if (Stage != null)
			Stage.sectionHit();

		super.sectionHit();
	}

	var shdrFilter:ShaderFilter;

	override function beatHit()
	{
		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		currentBeat = curBeat;

		ScriptHelper.setOnHscript('curBpm', Conductor.bpm);
		ScriptHelper.setOnHscript('crochet', Conductor.crochet);
		ScriptHelper.setOnHscript('stepCrochet', Conductor.stepCrochet);

		wiggleShit.update(Conductor.crochet);

		if (Main.save.data.camzoom && Data.songMultiplier == 1)
		{
			// HARDCODING FOR MILF ZOOMS!
			if (Data.SONG.songId == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015 / Data.songMultiplier;
				camHUD.zoom += 0.03 / Data.songMultiplier;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015 / Data.songMultiplier;
				camHUD.zoom += 0.03 / Data.songMultiplier;
			}
		}
		if (Data.songMultiplier == 1)
		{
			songUI.iconP1.setGraphicSize(Std.int(songUI.iconP1.width + 30));
			songUI.iconP2.setGraphicSize(Std.int(songUI.iconP2.width + 30));

			songUI.iconP1.updateHitbox();
			songUI.iconP2.updateHitbox();
		}
		else
		{
			songUI.iconP1.setGraphicSize(Std.int(songUI.iconP1.width + 4));
			songUI.iconP2.setGraphicSize(Std.int(songUI.iconP2.width + 4));

			songUI.iconP1.updateHitbox();
			songUI.iconP2.updateHitbox();
		}

		if (!endingSong && curSection != null)
		{
			gfAltAnim = curSection.gfAltAnim;

			if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			{
				boyfriend.playAnim('hey', true);
			}

			if (curBeat % 16 == 15 && Data.SONG.songId == 'tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
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
			if (!hscriptStageCheck)
			{
				if (curBeat % 4 == 0)
				{
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
					if ((curBeat >= 128 && curBeat <= 192) && !blammedeventplayed && Main.save.data.distractions)
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

				if (curBeat >= 192 && !blammedeventplayed && Main.save.data.distractions)
				{
					overlayColor = FlxColor.fromRGB(0, 0, 0, 0);
					colorTween = FlxTween.color(overlay, 0.1, overlay.color, overlayColor, {
						onComplete: function(twn:FlxTween)
						{
							colorTween = null;
						}
					});
					for (char in chars)
					{
						char.colorTween = FlxTween.color(char, 0.1, char.color, FlxColor.WHITE, {
							onComplete: function(twn:FlxTween)
							{
							},
							ease: FlxEase.quadInOut
						});
					}
					blammedeventplayed = true;
				}
			}
		}

		ScriptHelper.setOnHscript('curBeat', curBeat);

		if (Stage != null)
			Stage.beatHit();

		super.beatHit();

		ScriptHelper.callOnHscript('onBeat', [curBeat]);
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

	function startCharacterHscript(name:String)
	{
		try
		{
			var path = Paths.getHscriptPath(name, name, true);
			Debug.logTrace(path);
			if (path != null)
			{
				ScriptHelper.hscriptFiles.push(new ModchartHelper(path, this));
			}
		}
		catch (e)
		{
			scriptError(e);
		}
	}

	function scriptError(e:Exception)
	{
		Debug.displayAlert("Script error!", Std.string(e));

		if (Data.isFreeplay)
			MusicBeatState.switchState(new FreeplayState());
		else if (Data.isStoryMode)
			MusicBeatState.switchState(new StoryMenuState());
		else if (Data.chartingMode)
			openChartEditor();
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

		// super.onWindowFocusOut();

		openSubState(new PauseSubState());
	}

	override function onWindowFocusIn():Void
	{
		Debug.logTrace("IM BACK!!!");
		// super.onWindowFocusIn();
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(Main.save.data.fpsCap);
	}

	function set_useDownscroll(value:Bool):Bool
	{
		useDownscroll = value;
		toggleDownscroll(value);
		return value;
	}

	public function toggleDownscroll(value:Bool)
	{
		if (songStarted)
		{
			if (value)
			{
				if (songPosBG != null)
				{
					FlxTween.tween(songPosBG, {y: FlxG.height * 0.9 + 35}, 0.5);
					FlxTween.tween(songPosBar, {y: FlxG.height * 0.9 + 39}, 0.5);
					FlxTween.tween(songName, {y: FlxG.height * 0.9 + 35 + (songPosBG.height / 3)}, 0.5);
					FlxTween.tween(bar, {y: FlxG.height * 0.9 + 39}, 0.5);
				}
				FlxTween.tween(songUI.healthBarBG, {y: 50}, 0.5);
				FlxTween.tween(songUI.scoreTxt, {y: 100}, 0.5);
				FlxTween.tween(songUI.chartingState, {y: 150}, 0.5);
				FlxTween.tween(songUI.botPlayState, {y: 150}, 0.5);
				FlxTween.tween(songUI.engineWatermark, {y: FlxG.height * 0.9 + 45}, 0.5);
				FlxTween.tween(strumLine, {y: FlxG.height - 150}, 0.5);
				FlxTween.tween(songUI.healthBar, {y: 54}, 0.5);
				FlxTween.tween(songUI.iconP1, {y: 54 - (songUI.iconP1.height / 2)}, 0.5);
				FlxTween.tween(songUI.iconP2, {y: 54 - (songUI.iconP2.height / 2)}, 0.5);
				strumLineNotes.tweenArrowsY(FlxG.height - 150);
			}
			else
			{
				if (songPosBG != null)
				{
					FlxTween.tween(songPosBG, {y: 10}, 0.5);
					FlxTween.tween(songPosBar, {y: 14}, 0.5);
					FlxTween.tween(songName, {y: 10 + (songPosBG.height / 3)}, 0.5);
					FlxTween.tween(bar, {y: 14}, 0.5);
				}
				FlxTween.tween(songUI.healthBarBG, {y: FlxG.height * 0.9}, 0.5);
				FlxTween.tween(songUI.scoreTxt, {y: FlxG.height * 0.9 + 50}, 0.5);
				FlxTween.tween(songUI.chartingState, {y: FlxG.height * 0.9 - 100}, 0.5);
				FlxTween.tween(songUI.botPlayState, {y: FlxG.height * 0.9 - 100}, 0.5);
				FlxTween.tween(songUI.engineWatermark, {y: FlxG.height * 0.9 + 50}, 0.5);
				FlxTween.tween(strumLine, {y: 50}, 0.5);
				FlxTween.tween(songUI.healthBar, {y: FlxG.height * 0.9 + 4}, 0.5);
				FlxTween.tween(songUI.iconP1, {y: FlxG.height * 0.9 + 4 - (songUI.iconP1.height / 2)}, 0.5);
				FlxTween.tween(songUI.iconP2, {y: FlxG.height * 0.9 + 4 - (songUI.iconP2.height / 2)}, 0.5);
				strumLineNotes.tweenArrowsY(50);
			}
		}
	}

	// Well, how about to not check health max value every frame?
	function set_health(value:Float):Float
	{
		if (value > 2)
			health = 2;
			// else if (value < 0)
		// health = 0;
		else
			health = value;

		ScriptHelper.callOnHscript('onHealthChange', [health]);

		return value;
	}
}
