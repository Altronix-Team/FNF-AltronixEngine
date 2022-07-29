package gameplayStuff;

import gameplayStuff.Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.utils.Assets as OpenFlAssets;
import flixel.util.FlxSort;

using StringTools;

class Event //Kade Engine events
{
	public var name:String;
	public var position:Float;
	public var value:Dynamic;
	public var type:String;

	public function new(name:String, pos:Float, value:Dynamic, type:String)
	{
		this.name = name;
		this.position = pos;
		this.value = value;
		this.type = type;
	}
}

class EventObject
{
	public var name:String;
	public var value:Dynamic;
	public var type:String;

	public function new(name:String, value:Dynamic, type:String)
	{
		this.name = name;
		this.value = value;
		this.type = type;
	}
}

typedef EventsAtPos = //Altronix Engine Events
{
	var position:Float; //Song Beat
	var events:Array<EventObject>; // Events
}

typedef SongData =
{
	@:deprecated('SONG.song is deprecated, use SONG.songId instead.')
	var ?song:String;

	/**
	 * The readable name of the song, as displayed to the user.
	 		* Can be any string.
	 */
	var songName:String;

	/**
	 * The internal name of the song, as used in the file system.
	 */
	var songId:String;

	var chartVersion:String;
	var notes:Array<SwagSection>;
	var ?eventObjects:Array<Event>;//DO NOT USE THIS!!!!!!!!!!!
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var player1:String;
	var player2:String;
	var gfVersion:String;
	var ?hideGF:Bool;
	var noteStyle:String;
	var stage:String;
	var specialSongNoteSkin:String;

	var eventsArray:Array<EventsAtPos>; //Fuck yeah, now more conversions for old or Psych events
	var ?events:Array<Dynamic>;//DO NOT USE THIS!!!!!!!!!!!
	var ?validScore:Bool;
	var ?scaredbgdancers:Bool;
	var ?showbgdancers:Bool;
	var ?diffSoundAssets:Bool;
}

typedef SongMeta =
{
	var ?name:String;
}

class Song
{
	public static var latestChart:String = "AE1";

	public static function loadFromJsonRAW(rawJson:String)
	{
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		var jsonData = Json.parse(rawJson);
		return parseJSONshit("rawsong", jsonData, ["name" => jsonData.name]);
	}

	public static function loadMetadata(songId:String):SongMeta
		{
			var rawMetaJson = null;
			if (OpenFlAssets.exists(Paths.songMeta(songId)))
			{
				rawMetaJson = Paths.loadJSON('songs/$songId/_meta');
			}
			else
			{
				Debug.logInfo('Hey, you didn\'t include a _meta.json with your song files (id ${songId}).Won\'t break anything but you should probably add one anyway.');
			}
			if (rawMetaJson == null)
			{
				return null;
			}
			else
			{
				return cast rawMetaJson;
			}
		}

	public static function loadFromJson(songId:String, difficulty:String):SongData
	{
		var songFile = '$songId/$songId$difficulty';

		if (OpenFlAssets.exists('assets/data/songs/' + songFile + '.json'))
		{
			Debug.logInfo('Loading song JSON: $songFile');

			var rawJson = Paths.loadJSON('songs/$songFile');

			var metaData:SongMeta = loadMetadata(songId);

			if (OpenFlAssets.exists(Paths.json('songs/$songId/events')))
			{
				var rawEvents = Paths.loadJSON('songs/$songId/events');
				return parseJSONshit(songId, rawJson, metaData, rawEvents);
			}	
			else
				return parseJSONshit(songId, rawJson, metaData);	
		}
		else if (OpenFlAssets.exists(OpenFlAssets.getPath('assets/data/songs/' + songFile + '.json')))
		{
			Debug.logInfo('Loading song JSON: $songFile');
	
			var rawJson = Paths.loadJSON('songs/$songFile');
	
			var metaData:SongMeta = loadMetadata(songId);
	
			if (OpenFlAssets.exists(Paths.json('songs/$songId/events')))
			{
				var rawEvents = Paths.loadJSON('songs/$songId/events');
				return parseJSONshit(songId, rawJson, metaData, rawEvents);
			}	
			else
				return parseJSONshit(songId, rawJson, metaData);	
		}
		else
		{
			return null;
		}	
	}

	public static function conversionChecks(song:SongData):SongData
	{
		var ba = song.bpm;

		var index = 0;
		trace("conversion stuff " + song.songId + " " + song.notes.length);
		var convertedStuff:Array<Song.EventsAtPos> = [];

		if (song.eventsArray == null)
		{	
			trace('song events is null, wtf');

			var initBpm:EventsAtPos = 
			{
				position: 0,
				events: []
			};
			var firstEvent:Song.EventObject = new Song.EventObject("Init BPM", song.bpm, "BPM Change");

			initBpm.events.push(firstEvent);
			song.eventsArray = [initBpm];
		}

		for (i in song.eventsArray)
		{			
			var pos = Reflect.field(i, "position");

			var convertedPos:EventsAtPos =
			{
				position: pos,
				events: []
			};

			for (j in i.events)
			{
				var name = Reflect.field(j, "name");
				var type = Reflect.field(j, "type");
				var value = Reflect.field(j, "value");

				var event:Song.EventObject = new Song.EventObject(name, value, type);

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

		if (song.noteStyle == null)
			song.noteStyle = "normal";

		if (song.gfVersion == null)
			song.gfVersion = "gf";

		if (song.hideGF == null)
			song.hideGF = false;

		if (song.diffSoundAssets == null)
			song.diffSoundAssets = false;

		if (song.specialSongNoteSkin == null)
			song.specialSongNoteSkin = NoteskinHelpers.getNoteskinByID(FlxG.save.data.noteskin);

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

		if (song.events != null)
		{
			convertPsychEvents(song, checkedPositions);
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
				trace("converting changebpm for section " + index);
				ba = i.bpm;

				var eventAtPos:EventsAtPos = 
				{
					position: beat,
					events: [new Song.EventObject("FNF BPM Change " + index, i.bpm, "BPM Change")]
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

				var altNote = ((i.altAnim || i.CPUAltAnim) && !gottaHitNote)
					|| (i.playerAltAnim && gottaHitNote);

				if (altNote != ii[3])
				{
					ii[3] = altNote;
				}

				//converting old types to strings
				if (Std.isOfType(ii[5], Int))
				{
					switch (ii[5])
					{
						case 4:
							ii[5] = 'No Animation';
						case 3:
							ii[5] = 'GF Sing';
						case 2:
							ii[5] = 'Bullet Note';
						case 1:
							ii[5] = 'Hurt Note';
						default:
							ii[5] = 'Default Note';
					}
				}

				//renaming the type names
				if (ii[5] == 'GF Sing Note')
					ii[5] = 'GF Sing';
				
				if (ii[5] == 'No Anim Note')
					ii[5] = 'No Animation';

				if (ii[5] == null)
					ii[5] = 'Default Note';
			}

			index++;
		}

		song.eventsArray.sort(sortByBeat);

		song.chartVersion = latestChart;

		return song;
	}

	static function convertPsychEvents(song:SongData, checkedPositions:Array<Float>)
	{
		for (event in song.events)
		{
			var eventBeat:Float = HelperFunctions.truncateFloat(TimingStruct.getBeatFromTime(event[0]), 3);

			if (checkedPositions.contains(eventBeat))
			{
				for (i in song.eventsArray)
				{
					if (i.position == eventBeat)
					{
						for (j in 0...event[1].length)
						{
							var eventType:String;

							switch (event[1][j][0])
							{
								case 'Add Camera Zoom':
									eventType = 'Camera zoom';
								case 'Change Scroll Speed':
									eventType = 'Scroll Speed Change';
								case 'Alt Idle Animation':
									eventType = 'Toggle Alt Idle';
								case 'Play Animation':
									eventType = 'Character play animation';
								default:
									eventType = event[1][j][0];
							}

							var eventValue:Dynamic = '';

							if (event[1][j][1] != '')
							{
								eventValue = event[1][j][1];
								if (event[1][j][2] != '')
									eventValue += ', ' + event[1][j][2];
							}

							i.events.push(new Song.EventObject('Psych Event ' + eventBeat, eventValue, eventType));
						}
					}
				}
			}
			else
			{
				var eventAtPos:Song.EventsAtPos = {
					position: eventBeat,
					events: []
				}
				for (j in 0...event[1].length)
				{
					var eventType:String;

					switch (event[1][j][0])
					{
						case 'Add Camera Zoom':
							eventType = 'Camera zoom';
						case 'Change Scroll Speed':
							eventType = 'Scroll Speed Change';
						case 'Alt Idle Animation':
							eventType = 'Toggle Alt Idle';
						case 'Play Animation':
							eventType = 'Character play animation';
						default:
							eventType = event[1][j][0];
					}

					var eventValue:Dynamic = '';

					if (event[1][j][1] != '')
					{
						eventValue = event[1][j][1];
						if (event[1][j][2] != '')
							eventValue += ', ' + event[1][j][2];
					}

					checkedPositions.push(eventBeat);

					eventAtPos.events.push(new Song.EventObject('Psych Event ' + eventBeat, eventValue, eventType));
				}
				song.eventsArray.push(eventAtPos);
			}
		}

		song.events = null;
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
						j.events.push(new Song.EventObject(name, value, type));
				}
			}
			else
			{
				var eventAtPos:EventsAtPos = {
					position: pos,
					events: [new Song.EventObject(name, value, type)]
				};

				checkedPositions.push(i.position);

				song.eventsArray.push(eventAtPos);
			}
		}
		song.eventObjects = null;
	}
	
	static function sortByBeat(Obj1:EventsAtPos, Obj2:EventsAtPos):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, HelperFunctions.truncateFloat(Obj1.position, 3), HelperFunctions.truncateFloat(Obj2.position, 3));
	}

	public static function picospeakerLoad(jsonInput:String, ?folder:String):SongData
	{
		var folderLowercase = StringTools.replace(folder, " ", "-").toLowerCase();
	
		var rawJson = OpenFlAssets.getText(Paths.json('songs/' + folderLowercase + '/' + jsonInput.toLowerCase())).trim();
	
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}
	
		var swagShit:SongData = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}

	public static function parseJSONshit(songId:String, jsonData:Dynamic, jsonMetaData:Dynamic, jsonEvents:Dynamic = null):SongData
	{
		if (jsonData == null)
			return null;	
		var songData:SongData = cast jsonData.song;

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
		}
		else
		{
			songData.songName = songId.split('-').join(' ');
		}

		if (jsonEvents != null)
		{
			var events = cast jsonEvents;

			if (events.events != null)
				songData.events = events.events;

			if (events.eventObjects != null)
				songData.eventObjects = events.eventObjects;

			songData.eventsArray = events.eventsArray;
		}

		return Song.conversionChecks(songData);
	}
	public static function parseAutosaveshit(rawJson:String):SongData
	{
		var swagShit:SongData = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return Song.conversionChecks(swagShit);
	}
}
