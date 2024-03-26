package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.util.FlxColor;
import haxe.CallStack;
import haxe.Exception;
import lime.app.Application;
import lime.system.ThreadPool;
import lime.utils.LogLevel;
import altronixengine.modding.ModUtil;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.utils.AssetCache;
import openfl.utils.AssetLibrary;
import altronixengine.states.HscriptableState.PolymodHscriptState;
import sys.io.Process;
import altronixengine.utils.Debug.DebugLogWriter;
import altronixengine.utils.EngineFPS;
import altronixengine.utils.EngineSave;
import altronixengine.utils.ThreadUtil;
import altronixengine.core.FNFSignals;
import altronixengine.data.EngineConstants;
import altronixengine.utils.CoolUtil;
import altronixengine.utils.EngineData;
import altronixengine.utils.Debug;
#if cpp
import cpp.vm.Gc;
#end
#if FEATURE_MODCORE
import altronixengine.modding.ModCore;
#end

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = altronixengine.states.TitleState; // The FlxState the game starts with.

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

	public static var game:CustomGame;

	public static final defaultWindowTitle:String = 'Friday Night Funkin\': Altronix Engine';

	public static var fnfSignals:FNFSignals = new FNFSignals();

	public static var compileTime:String = '';
	public static var haxeVersion:String = '';

	// You can pretty much ignore everything from here on - your code should go in your states.
	// Ho-ho-ho, no
	var modsToLoad = [];

	public static var configFound = false;
	public static var hscriptClasses:Array<String> = [];

	#if FEATURE_FILESYSTEM
	public static var crashHandler:CrashHandler;
	#end

	public static function main():Void
	{
		// quick checks

		Lib.current.addChild(new Main());
	}

	public function new()
	{
		instance = this;

		super();

		#if FEATURE_FILESYSTEM
		crashHandler = new CrashHandler();
		#end

		compileTime = altronixengine.macros.MacroUtil.buildDateString().toString();
		haxeVersion = altronixengine.macros.CheckHaxeVersion.checkHaxeVersion().toString();

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
		lime.utils.Log.level = LogLevel.NONE;
		lime.utils.Log.throwErrors = false;

		save.bind('funkin', 'ninjamuffin99');

		EngineData.initSave();

		EngineData.keyCheck();

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
		ModUtil.reloadSavedMods();

		modsToLoad = ModUtil.getConfiguredMods();
		configFound = (modsToLoad != null && modsToLoad.length > 0);
		if (configFound)
			ModCore.loadConfiguredMods();
		#else
		configFound = false;
		#end

		hscriptClasses = PolymodHscriptState.listScriptClasses();

		game = new CustomGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash #if (!debug), save.data.fullscreenOnStart #end);
		addChild(game);

		#if !mobile
		// addChild(fpsCounter);
		toggleFPS(Main.save.data.fps);
		#end

		// Finish up loading debug tools.
		Debug.onGameStart();

		// setup automatic beat, step and section updates
		altronixengine.gameplayStuff.Conductor.setupUpdates();
	}

	public static var fpsCounter:EngineFPS = null;

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
		try
		{
			Reflect.setField(save.data, str, value);
			save.flush();
			return true;
		}
		catch (e)
		{
			Debug.logError('Failed to set save ' + e.details());
			return false;
		}
	}
}

class CustomGame extends FlxGame
{
	override function create(_):Void
	{
		try
			super.create(_)
		catch (e:Exception)
			return onError(e);
	}

	override function onFocus(_):Void
	{
		try
			super.onFocus(_)
		catch (e:Exception)
			return onError(e);
	}

	override function onFocusLost(_):Void
	{
		try
			super.onFocusLost(_)
		catch (e:Exception)
			return onError(e);
	}

	override function onEnterFrame(_):Void
	{
		try
			super.onEnterFrame(_)
		catch (e:Exception)
			return onError(e);
	}

	override function update():Void
	{
		try
			super.update()
		catch (e:Exception)
			return onError(e);
	}

	override function draw():Void
	{
		try
			super.draw()
		catch (e:Exception)
			return onError(e);
	}

	public function onError(e:Exception):Void
	{
		var caughtErrors:Array<String> = [];

		for (item in CallStack.exceptionStack(true))
		{
			switch (item)
			{
				case CFunction:
					caughtErrors.push('Non-Haxe (C) Function');
				case Module(moduleName):
					caughtErrors.push('Module (${moduleName})');
				case FilePos(s, file, line, column):
					caughtErrors.push('${file} (line ${line})');
				case Method(className, method):
					caughtErrors.push('${className} (method ${method})');
				case LocalFunction(name):
					caughtErrors.push('Local Function (${name})');
			}

			Debug.logError(item);
		}

		final msg:String = caughtErrors.join('\n');

		Debug.displayAlert('Error!', '$msg\n${e.details()}');
	}
}
