package states;

import flixel.system.FlxSound;
import scriptStuff.ScriptHelper;
import flixel.FlxCamera;
import lime.app.Application;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import openfl.Lib;
import flixel.FlxG;
import gameplayStuff.Section;
import gameplayStuff.TimingStruct;
import gameplayStuff.Conductor;

class MusicBeatState extends BaseState implements gameplayStuff.Conductor.IMusicBeat
{
	private var controls(get, never):Controls;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	public var curDecimalBeat:Float = 0;
	public var curSection:SwagSection = null;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public static var initSave:Bool = false;

	public static var camBeat:FlxCamera;

	private var assets:Array<FlxBasic> = [];

	override function destroy()
	{
		Application.current.window.onFocusOut.remove(onWindowFocusOut);
		Application.current.window.onFocusIn.remove(onWindowFocusIn);
		super.destroy();
	}

	override function add(Object:flixel.FlxBasic):flixel.FlxBasic
	{
		if (Main.save.data.optimize)
			assets.push(Object);
		var result = super.add(Object);
		return result;
	}

	public function assetExists(asset:FlxBasic):Bool
	{
		if (assets.contains(asset))
			return true;
		else
			return false;
	}

	public function clean()
	{
		if (Main.save.data.optimize)
		{
			for (i in assets)
			{
				remove(i);
			}
		}
	}

	override function create()
	{
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(Main.save.data.fpsCap);
		if (initSave)
		{
			if (Main.save.data.laneTransparency < 0)
				Main.save.data.laneTransparency = 0;

			if (Main.save.data.laneTransparency > 1)
				Main.save.data.laneTransparency = 1;
		}

		Application.current.window.onFocusIn.add(onWindowFocusIn);
		Application.current.window.onFocusOut.add(onWindowFocusOut);
		TimingStruct.clearTimings();

		if (WindowUtil.getWindowTitle() != Main.defaultWindowTitle)
			WindowUtil.setWindowTitle(Main.defaultWindowTitle);

		camBeat = FlxG.camera;

		FlxG.watch.addMouse();

		FlxG.sound.volumeHandler = volumeHandler;

		if (transIn != null)
			trace('reg ' + transIn.region);

		Conductor.MusicBeatInterface = this;

		super.create();
	}

	override function update(elapsed:Float)
	{
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(Main.save.data.fpsCap);

		#if !GITHUB_RELEASE
		if (FlxG.keys.justPressed.F10)
		{
			EngineFPS.showDebugInfo = !EngineFPS.showDebugInfo;
		}
		#end

		super.update(elapsed);
	}

	public static function switchState(nextState:FlxState) 
	{
		if(!FlxTransitionableState.skipNextTransIn) {
			var switchState = new TransitionableState();
			switchState.nextState = nextState;

			FlxG.switchState(switchState);
		}
		else {
			FlxTransitionableState.skipNextTransIn = false;
			FlxG.switchState(nextState);
		}
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	/*override*/ public function stepHit():Void
	{
		//super.stepHit();
		/*if (curStep % 4 == 0)
			beatHit();*/
		ScriptHelper.stepHit();
	}

	/*override*/ public function beatHit():Void
	{
		//super.beatHit();
		//beatHit
		ScriptHelper.beatHit();
	}

	/*override*/ public function sectionHit():Void
	{
		//super.sectionHit();
		//Section Hit
		ScriptHelper.sectionHit();
	}

	public function fancyOpenURL(schmancy:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}

	function volumeHandler(volume:Float)
	{
		Main.save.data.volume = volume;
	}

	function onWindowFocusOut():Void
	{
		/*soundList.forEach(function(sound:FlxSound)
		{
			if (sound.playing)
				sound.pause();
		});*/
		if (FlxG.sound.music.playing)
			FlxG.sound.music.pause();
	}

	function onWindowFocusIn():Void
	{
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(Main.save.data.fpsCap);
		/*soundList.forEach(function(sound:FlxSound)
		{
			sound.resume();
		});*/
		FlxG.sound.music.resume();
	}
}