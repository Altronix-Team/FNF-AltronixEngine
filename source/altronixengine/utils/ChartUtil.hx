package altronixengine.utils;

import flixel.util.FlxColor;
import flixel.util.FlxSort;
import altronixengine.gameplayStuff.Song;
import altronixengine.gameplayStuff.TimingStruct;

class ChartUtil
{
	public static var latestChart:String = "AE1";

	public static function parseJSONshit(songId:String, jsonData:Dynamic, jsonMetaData:Dynamic, jsonEvents:Dynamic = null):SongData
	{
		if (jsonData == null)
			return null;
		var songData:SongData = cast jsonData.song;

		if (songData.chartVersion != null)
		{
			return songData;
		}

		songData.songId = songId;

		// Enforce default values for optional fields.
		if (songData.validScore == null)
			songData.validScore = true;

		// Inject info from _meta.json.
		var songMetaData:SongMeta = cast jsonMetaData;

		if (songMetaData != null)
		{
			if (songMetaData.name != null)
			{
				songData.songName = songMetaData.name;
			}
			else
			{
				songData.songName = songId.split('-').join(' ');
			}

			if (songMetaData.composer != null)
			{
				songData.songComposer = songMetaData.composer;
			}
			else
			{
				songData.songComposer = '???';
			}

			if (songMetaData.barColor != null)
			{
				songData.songPosBarColor = FlxColor.fromString(songMetaData.barColor);
			}
			else
			{
				songData.songPosBarColor = FlxColor.fromString('0xffffff');
			}
		}
		else
		{
			songData.songName = songId.split('-').join(' ');
			songData.songComposer = '???';
			songData.songPosBarColor = FlxColor.fromString('0xffffff');
		}

		if (jsonEvents != null)
		{
			if (Reflect.hasField(jsonEvents, 'song'))
			{
				var events:SongData = cast jsonEvents.song;

				if (events.notes != null)
				{
					for (sect in events.notes)
					{
						if (sect.sectionNotes.length > 0)
						{
							songData.notes.push(sect);
						}
					}
				}
			}
			else
			{
				var events = cast jsonEvents;

				if (events.events != null)
					songData.events = events.events;

				if (events.eventObjects != null)
					songData.eventObjects = events.eventObjects;

				songData.eventsArray = events.eventsArray;
			}
		}

		return conversionChecks(songData);
	}

	public static function conversionChecks(song:SongData):SongData
	{
		var ba = song.bpm;

		var index = 0;
		// trace("conversion stuff " + song.songId + " " + song.notes.length);
		var convertedStuff:Array<EventsAtPos> = [];

		if (song.eventsArray == null)
		{
			// trace('song events is null, wtf');

			var initBpm:EventsAtPos = {
				position: 0,
				events: []
			};
			var firstEvent:EventObject = new EventObject("Init BPM", song.bpm, "BPM Change");

			initBpm.events.push(firstEvent);
			song.eventsArray = [initBpm];
		}

		for (i in song.eventsArray)
		{
			var pos = Reflect.field(i, "position");

			var convertedPos:EventsAtPos = {
				position: pos,
				events: []
			};

			for (j in i.events)
			{
				var name = Reflect.field(j, "name");
				var type = Reflect.field(j, "type");
				var value = Reflect.field(j, "value");

				var event:EventObject = new EventObject(name, value, type);

				convertedPos.events.push(event);
			}

			convertedStuff.push(convertedPos);
		}

		song.eventsArray = convertedStuff;

		var checkedPositions:Array<Float> = [];

		for (i in song.eventsArray)
		{
			checkedPositions.push(i.position);
		}

		if (song.eventObjects != null)
		{
			convertKadeEvents(song, checkedPositions);
		}

		if (song.stage == null)
		{
			switch (song.songId)
			{
				case 'spookeez' | 'south' | 'monster':
					song.stage = 'halloween';
				case 'pico' | 'blammed' | 'philly':
					song.stage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					song.stage = 'limo';
				case 'cocoa' | 'eggnog':
					song.stage = 'mall';
				case 'winter-horrorland':
					song.stage = 'mallEvil';
				case 'senpai' | 'roses':
					song.stage = 'school';
				case 'thorns':
					song.stage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					song.stage = 'warzone';
				default:
					song.stage = 'stage';
			}
		}

		if (song.noteStyle == null)
			song.noteStyle = "normal";

		if (song.gfVersion == null)
		{
			switch (song.stage)
			{
				case 'limo':
					song.gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					song.gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					song.gfVersion = 'gf-pixel';
				case 'warzone':
					if (song.songId != 'stress')
						song.gfVersion = 'gftank';
					else
						song.gfVersion = 'picospeaker';
				default:
					song.gfVersion = 'gf';
			}
		}

		if (song.hideGF == null)
			song.hideGF = false;

		if (song.diffSoundAssets == null)
			song.diffSoundAssets = false;

		if (song.specialSongNoteSkin == null)
			song.specialSongNoteSkin = Main.save.data.noteskin;

		if (song.showbgdancers == null)
		{
			if (song.songId != 'senpai' && song.songId != 'roses')
				song.showbgdancers = false;
			else
			{
				song.showbgdancers = true;
				if (song.songId == 'roses')
					song.scaredbgdancers = true;
			}
		}

		TimingStruct.clearTimings();

		var currentIndex = 0;

		for (i in song.eventsArray)
		{
			var beat:Float = i.position;

			for (j in i.events)
			{
				switch (j.type)
				{
					case "BPM Change":
						var endBeat:Float = Math.POSITIVE_INFINITY;

						TimingStruct.addTiming(beat, j.value, endBeat, 0);

						if (currentIndex != 0)
						{
							var data = TimingStruct.AllTimings[currentIndex - 1];
							data.endBeat = beat;
							data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
							var step = ((60 / data.bpm) * 1000) / 4;
							TimingStruct.AllTimings[currentIndex].startStep = Math.floor(((data.endBeat / (data.bpm / 60)) * 1000) / step);
							TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
						}

						currentIndex++;
				}
			}
		}

		for (i in song.notes)
		{
			if (i.altAnim)
				i.CPUAltAnim = i.altAnim;

			var currentBeat = 4 * index;

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				continue;

			var beat:Float = currentSeg.startBeat + (currentBeat - currentSeg.startBeat);

			var start:Float = (currentBeat - currentSeg.startBeat) / (currentSeg.bpm / 60);

			i.startTime = (currentSeg.startTime + start) * 1000;

			if (index != 0)
				song.notes[index - 1].endTime = i.startTime;
			i.endTime = Math.POSITIVE_INFINITY;

			if (i.changeBPM && i.bpm != ba)
			{
				ba = i.bpm;

				var eventAtPos:EventsAtPos = {
					position: beat,
					events: [new EventObject("FNF BPM Change " + index, i.bpm, "BPM Change")]
				};

				song.eventsArray.push(eventAtPos);
			}

			for (ii in i.sectionNotes)
			{
				if (Std.isOfType(ii[3], String))
				{
					if (ii[3] == 'Alt Animation')
					{
						ii[3] = true;
						ii[4] = TimingStruct.getBeatFromTime(ii[0]);
					}
					else if (ii[3] == null || ii[3] == '')
					{
						ii[3] = false;
						ii[4] = TimingStruct.getBeatFromTime(ii[0]);
					}
					else
					{
						ii[5] = ii[3];
						ii[3] = false;
						ii[4] = TimingStruct.getBeatFromTime(ii[0]);
					}
				}

				if (ii[3] == null)
				{
					ii[3] = false;
					ii[4] = TimingStruct.getBeatFromTime(ii[0]);
				}

				if (ii[3] == 0)
					ii[3] == false;

				var gottaHitNote:Bool = true;

				if (ii[1] > 3 && i.mustHitSection)
					gottaHitNote = false;
				else if (ii[1] < 4 && (!i.mustHitSection || i.gfSection))
					gottaHitNote = false;

				var altNote = ((i.altAnim || i.CPUAltAnim) && !gottaHitNote) || (i.playerAltAnim && gottaHitNote);

				if (altNote != ii[3])
				{
					ii[3] = altNote;
				}

				if (ii[5] == null)
					ii[5] = 'Default Note';

				if (ii[6] == null || ii[6] == 0 || ii[6] == '' || ii[6] == '0')
					ii[6] = song.noteStyle;
			}

			index++;
		}

		song.eventsArray.sort(sortByBeat);

		song.chartVersion = latestChart;

		return song;
	}

	static function convertKadeEvents(song:SongData, checkedPositions:Array<Float>)
	{
		for (i in song.eventObjects)
		{
			var name = Reflect.field(i, "name");
			var type = Reflect.field(i, "type");
			var pos = Reflect.field(i, "position");
			var value = Reflect.field(i, "value");

			if (checkedPositions.contains(pos))
			{
				for (j in song.eventsArray)
				{
					if (j.position == pos)
						j.events.push(new EventObject(name, value, type));
				}
			}
			else
			{
				var eventAtPos:EventsAtPos = {
					position: pos,
					events: [new EventObject(name, value, type)]
				};

				checkedPositions.push(i.position);

				song.eventsArray.push(eventAtPos);
			}
		}
		song.eventObjects = null;
	}

	static function sortByBeat(Obj1:EventsAtPos, Obj2:EventsAtPos):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, CoolUtil.truncateFloat(Obj1.position, 3), CoolUtil.truncateFloat(Obj2.position, 3));
	}

	public static var betaChart:String = "AE2";
	/*public static function convertToNewChart(song:SongData):gameplayStuff.SongChartData.SongChart
		{
			var newSong:gameplayStuff.SongChartData.SongChart = {
				songMeta: {
					songId: '',

					songName: '',

					songComposer: '',

					songPosBarColor: 0xffffff,

					chartVersion: 'AE2',

					stageId: ''
				},

				songCharacters: {
					opponents: [],

					players: [],

					girlfriends: []
				},

				songSettings: {
					bpm: 0,

					speed: 0,

					needsVoices: true,

					separateVoices: false,

					diffSoundAssets: false,

					hideGFs: false,

					validScore: true
				},

				songSections: [],

				songEvents: []
			};
	}*/
}
