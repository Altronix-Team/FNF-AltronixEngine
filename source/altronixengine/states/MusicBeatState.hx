package altronixengine.states;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.sound.FlxSound;
import altronixengine.gameplayStuff.Conductor;
import altronixengine.gameplayStuff.Section;
import altronixengine.gameplayStuff.TimingStruct;
import lime.app.Application;
import openfl.Lib;
import altronixengine.scriptStuff.ScriptHelper;
import altronixengine.core.Controls;
import altronixengine.core.PlayerSettings;
import altronixengine.utils.WindowUtil;
import altronixengine.utils.EngineFPS;

class MusicBeatState extends BaseState implements altronixengine.gameplayStuff.Conductor.IMusicBeat
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
		Main.fnfSignals.beatHit.remove(_beatHit);
		Main.fnfSignals.sectionHit.remove(_sectionHit);
		Main.fnfSignals.stepHit.remove(_stepHit);
		Main.fnfSignals.decimalBeatHit.remove(_decimalBeatHit);

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

		Main.fnfSignals.beatHit.add(_beatHit);
		Main.fnfSignals.sectionHit.add(_sectionHit);
		Main.fnfSignals.stepHit.add(_stepHit);
		Main.fnfSignals.decimalBeatHit.add(_decimalBeatHit);

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

		Main.fnfSignals.update.dispatch(elapsed);
	};

	public static function switchState(nextState:FlxState)
	{
		FlxG.switchState(nextState);
		/*if (!FlxTransitionableState.skipNextTransIn)
			{
				var switchState = new TransitionableState();
				switchState.nextState = nextState;

				FlxG.switchState(switchState);
			}
			else
			{
				FlxTransitionableState.skipNextTransIn = false;
				FlxG.switchState(nextState);
		}*/
	}

	public static function resetState()
	{
		MusicBeatState.switchState(FlxG.state);
	}

	public function stepHit():Void
	{
		/*if (curStep % 4 == 0)
			beatHit(); */
		ScriptHelper.stepHit(curStep);
	}

	public function beatHit():Void
	{
		// beatHit
		ScriptHelper.beatHit(curBeat);
	}

	public function sectionHit():Void
	{
		// Section Hit
		ScriptHelper.sectionHit(curSection);
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

	private function _stepHit(step:Int):Void
	{
		curStep = step;
		stepHit();
	}

	private function _beatHit(beat:Int):Void
	{
		curBeat = beat;
		beatHit();
	}

	private function _sectionHit(section:SwagSection):Void
	{
		curSection = section;
		sectionHit();
	}

	private function _decimalBeatHit(beat:Float):Void
	{
		curDecimalBeat = beat;
	}
}
