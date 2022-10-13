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
import gameplayStuff.Conductor;
import gameplayStuff.TimingStruct;

class MusicBeatState extends BaseState implements IMusicBeat
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
		if (FlxG.save.data.optimize)
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
		if (FlxG.save.data.optimize)
		{
			for (i in assets)
			{
				remove(i);
			}
		}
	}

	override function create()
	{
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		if (initSave)
		{
			if (FlxG.save.data.laneTransparency < 0)
				FlxG.save.data.laneTransparency = 0;

			if (FlxG.save.data.laneTransparency > 1)
				FlxG.save.data.laneTransparency = 1;
		}

		Application.current.window.onFocusIn.add(onWindowFocusIn);
		Application.current.window.onFocusOut.add(onWindowFocusOut);
		TimingStruct.clearTimings();

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
		if (Conductor.MusicBeatInterface == this)
			Conductor.updateSongPosition(elapsed);

		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

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

	public function stepHit():Void
	{
		/*if (curStep % 4 == 0)
			beatHit();*/
		ScriptHelper.stepHit();
	}

	public function beatHit():Void
	{
		//beatHit
		ScriptHelper.beatHit();
	}

	public function sectionHit():Void
	{
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
		FlxG.save.data.volume = volume;
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
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		/*soundList.forEach(function(sound:FlxSound)
		{
			sound.resume();
		});*/
		FlxG.sound.music.resume();
	}
}