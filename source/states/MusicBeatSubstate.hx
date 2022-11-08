package states;

import flixel.FlxBasic;
import gameplayStuff.Section.SwagSection;
import lime.app.Application;
import openfl.Lib;
import flixel.text.FlxText;
import flixel.input.gamepad.FlxGamepad;
import gameplayStuff.Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;
import gameplayStuff.Conductor;
import gameplayStuff.TimingStruct;

class MusicBeatSubstate extends FlxSubState implements IMusicBeat
{
	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	public var curDecimalBeat:Float = 0;
	public var curSection:SwagSection = null;

	private var assets:Array<FlxBasic> = [];

	public function new()
	{
		super();
	}

	override function add(Object:flixel.FlxBasic):flixel.FlxBasic
	{
		if (Main.save.data.optimize)
			assets.push(Object);
		var result = super.add(Object);
		return result;
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

	override function destroy()
	{
		Application.current.window.onFocusOut.remove(onWindowFocusOut);
		Application.current.window.onFocusIn.remove(onWindowFocusIn);
		super.destroy();
	}

	override function create()
	{
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(Main.save.data.fpsCap);
		Application.current.window.onFocusIn.add(onWindowFocusIn);
		Application.current.window.onFocusOut.add(onWindowFocusOut);

		Conductor.MusicBeatInterface = this;
		super.create();
	}

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
			KeyBinds.gamepad = true;
		else
			KeyBinds.gamepad = false;

		super.update(elapsed);
	}

	public function stepHit():Void
	{
		//Step Hit
	}

	public function beatHit():Void
	{
		//Beat Hit
	}

	public function sectionHit():Void
	{
		//Section Hit
	}

	function onWindowFocusOut():Void
	{
		if (PlayState.inDaPlay)
		{
			if (!PlayState.instance.paused && !PlayState.instance.endingSong && PlayState.instance.songStarted)
			{
				Debug.logTrace("Lost Focus");
				PlayState.instance.openSubState(new PauseSubState());
				PlayState.instance.boyfriend.stunned = true;

				PlayState.instance.persistentUpdate = false;
				PlayState.instance.persistentDraw = true;
				PlayState.instance.paused = true;

				PlayState.instance.vocals.stop();
				FlxG.sound.music.stop();
			}
		}
	}

	function onWindowFocusIn():Void
	{
		Debug.logTrace("IM BACK!!!");
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(Main.save.data.fpsCap);
	}
}
