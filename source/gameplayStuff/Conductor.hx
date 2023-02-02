package gameplayStuff;

import haxe.Constraints.Function;
import gameplayStuff.Section.SwagSection;
import gameplayStuff.Song.SongData;
import flixel.FlxG;
import openfl.events.Event;
import openfl.Lib;
import utils.EngineFPS;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor
{
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var rawPosition:Float;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = Math.floor((safeFrames / 60) * 1000); // is calculated in create(), is safeFrames in milliseconds
	public static var timeScale:Float = Conductor.safeZoneOffset / 166;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	private static var lastBeat:Float = 0;
	private static var lastStep:Float = 0;
	private static var lastSection:SwagSection = null;

	public static var curStep:Int = 0;
	public static var curBeat:Int = 0;
	public static var curDecimalBeat:Float = 0;
	public static var curSection:SwagSection = null;

	public static function setupUpdates()
	{
		Lib.current.addEventListener(Event.ENTER_FRAME, function(_)
		{
			updateSongPosition(FlxG.elapsed);
		});
	}

	private static function listIntClasses():Array<Class<IMusicBeat>>
	{
		var returnArray:Array<Class<IMusicBeat>> = [];

		var list:List<Class<IMusicBeat>> = utils.MacroUtil.getAllClasses(IMusicBeat);

		var val:Null<Class<IMusicBeat>> = list.first();

		while (val != null)
		{
			returnArray.push(val);
			list.remove(val);
			val = list.first();
		}
		return returnArray;
	}

	public function new()
	{
	}

	public static function recalculateTimings()
	{
		Conductor.safeFrames = Main.save.data.frames;
		Conductor.safeZoneOffset = Math.floor((Conductor.safeFrames / 60) * 1000);
		Conductor.timeScale = Conductor.safeZoneOffset / 166;
	}

	public static function mapBPMChanges(song:SongData)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Float, ?recalcLength = true)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}

	public static function updateSongPosition(elapsed:Float)
	{
		if (songPosition < 0)
			curDecimalBeat = 0;
		else
		{
			lastSection = curSection;

			if (TimingStruct.AllTimings.length > 1)
			{
				var data = TimingStruct.getTimingAtTimestamp(songPosition);

				FlxG.watch.addQuick("Current Conductor Timing Seg", data.bpm);

				crochet = ((60 / data.bpm) * 1000);

				var step = ((60 / data.bpm) * 1000) / 4;
				var startInMS = (data.startTime * 1000);

				curDecimalBeat = data.startBeat + ((((songPosition / 1000)) - data.startTime) * (data.bpm / 60));
				Main.fnfSignals.decimalBeatHit.dispatch(curDecimalBeat);
				var ste:Int = Math.floor(data.startStep + ((songPosition) - startInMS) / step);
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
				curDecimalBeat = (((songPosition / 1000))) * (bpm / 60);
				Main.fnfSignals.decimalBeatHit.dispatch(curDecimalBeat);
				var nextStep:Int = Math.floor((songPosition) / stepCrochet);
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
				crochet = ((60 / bpm) * 1000);
			}
		}

		#if !GITHUB_RELEASE
		FPSText.curStep = curStep;
		FPSText.curBeat = curBeat;
		FPSText.curDecimalBeat = curDecimalBeat;
		#end
	}

	private static function updateSection():Void
	{
		curSection = TimingStruct.getSectionByTime(songPosition);
		if (lastSection != curSection)
		{
			sectionHit();
		}
	}

	private static function updateBeat():Void
	{
		lastBeat = curBeat;
		curBeat = Math.floor(curStep / 4);
	}

	public static function stepHit():Void
	{	
		Main.fnfSignals.stepHit.dispatch(curStep);
		if (curStep % 4 == 0)
			beatHit();
	}

	public static function beatHit():Void
	{
		Main.fnfSignals.beatHit.dispatch(curBeat);
	}

	public static function sectionHit():Void
	{
		Main.fnfSignals.sectionHit.dispatch(curSection);
	}
}

interface IMusicBeat
{
	public var curStep:Int;
	public var curBeat:Int;
	public var curDecimalBeat:Float;
	public var curSection:SwagSection;

	public function stepHit():Void;

	public function beatHit():Void;

	public function sectionHit():Void;
}