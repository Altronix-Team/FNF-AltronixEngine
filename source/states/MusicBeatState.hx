package states;

import flixel.FlxCamera;
import lime.app.Application;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import openfl.Lib;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import gameplayStuff.Section;
import gameplayStuff.Conductor;
import gameplayStuff.TimingStruct;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;
	private var lastSection:SwagSection = null;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curDecimalBeat:Float = 0;
	private var controls(get, never):Controls;
	private var curSection:SwagSection = null;

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

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (Conductor.songPosition < 0)
			curDecimalBeat = 0;
		else
		{
			lastSection = curSection;

			if (TimingStruct.AllTimings.length > 1)
			{
				var data = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);

				FlxG.watch.addQuick("Current Conductor Timing Seg", data.bpm);

				Conductor.crochet = ((60 / data.bpm) * 1000);

				var step = ((60 / data.bpm) * 1000) / 4;
				var startInMS = (data.startTime * 1000);

				curDecimalBeat = data.startBeat + ((((Conductor.songPosition / 1000)) - data.startTime) * (data.bpm / 60));
				var ste:Int = Math.floor(data.startStep + ((Conductor.songPosition) - startInMS) / step);
				if (ste >= 0)
				{
					if (ste > curStep)
					{
						for (i in curStep...ste)
						{
							curStep++;
							updateBeat();
							stepHit();
							updateSection();
						}
					}
					else if (ste < curStep)
					{
						// Song reset?
						curStep = ste;
						updateBeat();
						stepHit();
						updateSection();
					}
				}
			}
			else
			{
				curDecimalBeat = (((Conductor.songPosition / 1000))) * (Conductor.bpm / 60);
				var nextStep:Int = Math.floor((Conductor.songPosition) / Conductor.stepCrochet);
				if (nextStep >= 0)
				{
					if (nextStep > curStep)
					{
						for (i in curStep...nextStep)
						{
							curStep++;
							updateBeat();
							stepHit();
							updateSection();
						}
					}
					else if (nextStep < curStep)
					{
						// Song reset?
						curStep = nextStep;
						updateBeat();
						stepHit();
						updateSection();
					}
				}
				Conductor.crochet = ((60 / Conductor.bpm) * 1000);				
			}
		}


		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		curSection = TimingStruct.getSectionByTime(Conductor.songPosition);
		if (lastSection != curSection)
		{
			sectionHit();
		}
	}

	private function updateBeat():Void
	{
		lastBeat = curBeat;
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
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
		if (curStep % 4 == 0)
			beatHit();
		/*try{Reflect.callMethod(IMusicBeat, Reflect.field(IMusicBeat, 'stepHit'), []);}
		catch (e) Debug.logError('error with IMusicBeat stepHit ' + e.details());*/
	}

	public function beatHit():Void
	{
		//beatHit
		/*try{Reflect.callMethod(IMusicBeat, Reflect.field(IMusicBeat, 'beatHit'), []);}
		catch (e) Debug.logError('error with IMusicBeat beatHit ' + e.details());*/
	}

	public function sectionHit():Void
	{
		//Section Hit
		/*try{Reflect.callMethod(IMusicBeat, Reflect.field(IMusicBeat, 'sectionHit'), []);}
		catch (e) Debug.logError('error with IMusicBeat sectionHit ' + e.details());*/
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
		if (FlxG.sound.music.playing)
			FlxG.sound.music.pause();
	}

	function onWindowFocusIn():Void
	{
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		FlxG.sound.music.resume();
	}
}

interface IMusicBeat
{
	public function stepHit():Void;

	public function beatHit():Void;

	public function sectionHit():Void;
}