package;

import lime.system.ThreadPool;
import utils.ThreadUtil;
import flixel.system.scaleModes.StageSizeScaleMode;
import modding.ModUtil;
#if FEATURE_MULTITHREADING
import sys.thread.Thread;
#end
import openfl.utils.AssetLibrary;
#if cpp
import cpp.vm.Gc;
#end
import openfl.utils.AssetCache;
import states.HscriptableState.PolymodHscriptState;
import lime.app.Application;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import GameJolt.GJToastManager;
import openfl.events.UncaughtErrorEvent;
import utils.EngineFPS;
import utils.Debug.DebugLogWriter;
import openfl.system.Capabilities;
import haxe.CallStack;
import utils.EngineSave;
import sys.io.Process;

#if FEATURE_MODCORE
import modding.ModCore;
#end

//TODO Altronix Engine start splash
class Main extends Sprite
{
	public static var gjToastManager:GJToastManager;
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = states.TitleState; // The FlxState the game starts with.

	#if (flixel < "5.0.0")
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	#end

	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var isHidden:Bool = false;

	public static var instance:Main;

	/**
	 * Custom FlxSave code to work without init of FlxG
	 */
	public static var save(default, null):EngineSave = new EngineSave();

	public static var watermarks = true; // Whether to put Altronix Engine literally anywhere

	public static var memoryCount = true;

	public static var game:FlxGame;

	public static final defaultWindowTitle:String = 'Friday Night Funkin\': Altronix Engine';

	public static var fnfSignals:FNFSignals = new FNFSignals();

	//public static var compileTime:String = macro utils.MacroUtil.buildDate();
	//public static var gitCommitSha:String = macro utils.MacroUtil.buildGitCommitSha();

	// You can pretty much ignore everything from here on - your code should go in your states.
	// Ho-ho-ho, no

	var modsToLoad = [];
	public static var configFound = false;
	public static var hscriptClasses:Array<String> = [];

	//var globalScripts:Array<scriptStuff.scriptBodies.GlobalScriptBody> = [];

	public static var fromLauncher:Bool = false;

	#if FEATURE_MULTITHREADING
	public static var reservedGameThreads:Array<ReservedThreadObject> = [];
	public static var threadPool:ThreadPool = new ThreadPool(0, 4);
	#end

	public static function main():Void
	{
		// quick checks

		Lib.current.addChild(new Main());
	}

	public function new()
	{
		instance = this;

		var args = Sys.args();

		if (args[0] != null && args[0] == 'fromLauncher') fromLauncher = true;

		super();

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(onCriticalErrorEvent);
		#end

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		lime.utils.Log.throwErrors = false;
		
		save.bind('funkin', 'ninjamuffin99');

		EngineData.initSave();

		EngineData.keyCheck();

		#if (flixel < "5.0.0")
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
		#end

		framerate = save.data.fpsCap;

		#if !cpp
		framerate = 60;
		#end

		// Run this first so we can see logs.
		Debug.onInitProgram();

		#if !mobile
		fpsCounter = new EngineFPS();
		#end		

		if (save.data.fullscreenOnStart == null)
			save.data.fullscreenOnStart = false;

		#if FEATURE_MODCORE
		modsToLoad = ModUtil.getConfiguredMods();
		configFound = (modsToLoad != null && modsToLoad.length > 0);
		if (configFound)
			ModCore.loadConfiguredMods();
		#else
		configFound = false;
		#end

		hscriptClasses = PolymodHscriptState.listScriptClasses();

		game = new FlxGame(gameWidth, gameHeight, initialState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash#if (!debug), save.data.fullscreenOnStart#end);
		addChild(game);	
		
		FlxG.scaleMode = new StageSizeScaleMode();

		FlxG.signals.preStateCreate.add(preStateSwitch);
		FlxG.signals.postStateSwitch.add(postStateSwitch);

		#if !mobile
		//addChild(fpsCounter);
		toggleFPS(Main.save.data.fps);
		#end

		gjToastManager = new GJToastManager();
		addChild(gjToastManager);

		// Finish up loading debug tools.
		Debug.onGameStart();

		#if FEATURE_MULTITHREADING
		reservedGameThreads.push(new ReservedThreadObject(true, "songLoader"));
		reservedGameThreads.push(new ReservedThreadObject(true, "loadStage"));
		reservedGameThreads.push(new ReservedThreadObject(true, "loadChars"));
		reservedGameThreads.push(new ReservedThreadObject(true, "loadBF"));
		reservedGameThreads.push(new ReservedThreadObject(true, "loadGF"));
		reservedGameThreads.push(new ReservedThreadObject(true, "loadDad"));
		#end
		/*#if debug
		flixel.addons.studio.FlxStudio.create();
		#end*/

		//setup automatic beat, step and section updates
		gameplayStuff.Conductor.setupUpdates();

		Lib.current.addEventListener(Event.ENTER_FRAME, function(_)
		{
			fnfSignals.update.dispatch(FlxG.elapsed);
		});

		//Global scripts
		reloadGlobalScripts();
	}

	public function reloadGlobalScripts()
	{
		/*for (script in globalScripts)
		{
			script.destroy();
		}

		var filesToCheck:Array<String> = AssetsUtil.readLibrary("gameplay", HSCRIPT, "scripts/global/");
		for (file in filesToCheck)
		{
			globalScripts.push(new scriptStuff.scriptBodies.GlobalScriptBody(file));
		}*/
	}

	static final ERROR_REPORT_URL = "https://github.com/AltronMaxX/FNF-AltronixEngine";

	/**
	 * Called when OpenFL encounters an uncaught fatal error.
	 * Note that the default logging system should NOT be used here in case that was the problem.
	 * @param error The error that was thrown.
	 */
	public static function onUncaughtError(error:UncaughtErrorEvent)
	{	
		#if FEATURE_FILESYSTEM
		FlxG.resetGame();
		var errorMsg:String = '';

		var funnyTitle:Array<String> = 
		[
			'Fatal Error!',
			'Monika deleted everything!',
			'Catastrophic Error',
			'Well-well-well, what have we got here?',
			'Game over',
			'Kade Engine moment',
			'Tester couldn`t find it'
		];

		errorMsg += '==========FATAL ERROR==========\n';
		errorMsg += 'An uncaught error was thrown, and the game had to close.\n';
		errorMsg += 'Please use the link below, create a new issue, and upload this file to report the error.\n';
		errorMsg += '\n';
		errorMsg +=  ERROR_REPORT_URL;
		errorMsg += '\n';

		errorMsg += '==========SYSTEM INFO==========\n';
		errorMsg += 'Altronix Engine version: ${EngineConstants.engineVer}\n';
		errorMsg += '  HaxeFlixel version: ${Std.string(FlxG.VERSION)}\n';
		errorMsg += '  Friday Night Funkin\' version: ${states.MainMenuState.gameVer}\n';
		errorMsg += 'System telemetry:\n';
		errorMsg += '  OS: ${Capabilities.os}\n';

		errorMsg += '\n';

		errorMsg += '==========STACK TRACE==========\n';
		errorMsg += error.error + '\n';

		var errorCallStack:Array<StackItem> = CallStack.exceptionStack(true);

		for (line in errorCallStack)
		{
			switch (line)
			{
				case CFunction:
					errorMsg += '  function:\n';
				case Module(m):
					errorMsg += '  module:${m}\n';
				case FilePos(s, file, line, column):
					errorMsg += '  (${file}#${line},${column})\n';
				case Method(className, method):
					errorMsg += '  method:(${className}/${method}\n';
				case LocalFunction(v):
					errorMsg += '  localFunction:${v}\n';
				default:
					errorMsg += line;
			}
		}
		errorMsg += '\n';

		var logFolderPath = CoolUtil.createDirectoryIfNotExists('crashes');

		var path:String = '${logFolderPath}/Altronix Engine - ${DebugLogWriter.getDateString()}.txt';

		sys.io.File.saveContent(path, errorMsg + "\n");

		errorMsg += 'An error has occurred and the game is forced to close.\nPlease access the "crash" folder and send the .crash file to the developers:\n'
			+ ERROR_REPORT_URL +'\n';

		Application.current.window.alert('An error has occurred and the game is forced to close.\nPlease access the "crash" folder and send the .crash file to the developers:\n' + ERROR_REPORT_URL, funnyTitle[FlxG.random.int(0, funnyTitle.length - 1)]);

		try{
			new Process(path);
		}
		#else
		FlxG.resetGame();

		Application.current.window.alert('An error has occurred and the game is forced to close.\nWe cannot write a log file though. Tell the developers:\n'
			+ ERROR_REPORT_URL,
			funnyTitle[FlxG.random.int(0, funnyTitle.length - 1)]);
		#end
	}
	private function onCriticalErrorEvent(message:String):Void
	{
		FlxG.resetGame();
		Debug.logError('Critical error!');
		Debug.logError(message);
		Debug.displayAlert('Critical error!', message);
	}

	public static var fpsCounter:EngineFPS = null;

	// taken from forever engine, cuz optimization very pog.
	// thank you shubs :)
	public static function dumpCache()
	{
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null)
			{
				Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}
		Assets.cache.clear("songs");
	}

	public function toggleFPS(fpsEnabled:Bool):Void
	{
		if (fpsEnabled && !contains(fpsCounter))
		{
			if (fpsCounter == null)
				fpsCounter = new EngineFPS();

			addChild(fpsCounter);
		}
		else if (!fpsEnabled && contains(fpsCounter))
		{
			removeChild(fpsCounter);

			fpsCounter = null;
		}
		else
			return;
	}

	public function changeFPSColor(color:FlxColor)
	{
		EngineFPS.fpsText.textColor = color;
	}

	public function setFPSCap(cap:Float)
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return EngineFPS.fpsText.currentFPS;
	}

	public static function getSaveByString(str:String):Dynamic
	{
		if (Reflect.field(save.data, str) != null)
			return Reflect.field(save.data, str);
		else
			return null;
	}

	public static function setSaveByString(str:String, value:Dynamic):Bool
	{
		try {
			Reflect.setField(save.data, str, value);
			save.flush();
			return true;}
		catch(e){
			Debug.logError('Failed to set save ' + e.details());
			return false;}
	}

	private function preStateSwitch(newState:FlxState)
	{
		var cache = cast(Assets.cache, AssetCache);

		dumpCache();

		cache.clear();
		#if cpp
		Gc.run(true);
		#else
		openfl.system.System.gc();
		#end
	}

	private function postStateSwitch()
	{
		#if cpp
		Gc.run(true);
		#else
		openfl.system.System.gc();
		#end
		EngineFPS.fpsText.clearMaxFPS();
	}

}
