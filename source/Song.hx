package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Event
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

typedef SongData =
{
	@:deprecated
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
	var eventObjects:Array<Event>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var player1:String;
	var player2:String;
	var gfVersion:String;
	var ?hideGF:Bool;
	var noteStyle:String;
	var stage:String;
	var ?validScore:Bool;
	var ?offset:Int;
	var ?scaredbgdancers:Bool;
	var ?showbgdancers:Bool;
}

typedef SongMeta =
{
	var ?offset:Int;
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
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
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

	public static function conversionChecks(song:SongData):SongData
	{
		var ba = song.bpm;

		var index = 0;
		trace("conversion stuff " + song.songId + " " + song.notes.length);
		var convertedStuff:Array<Song.Event> = [];

		if (song.eventObjects == null)
			song.eventObjects = [new Song.Event("Init BPM", 0, song.bpm, "BPM Change")];

		for (i in song.eventObjects)
		{
			var name = Reflect.field(i, "name");
			var type = Reflect.field(i, "type");
			var pos = Reflect.field(i, "position");
			var value = Reflect.field(i, "value");

			convertedStuff.push(new Song.Event(name, pos, value, type));
		}

		song.eventObjects = convertedStuff;

		if (song.noteStyle == null)
			song.noteStyle = "normal";

		if (song.gfVersion == null)
			song.gfVersion = "gf";

		if (song.hideGF == null)
			song.hideGF = false;

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

		for (i in song.eventObjects)
		{
			switch (i.type)
			{
				case "BPM Change":
					var beat:Float = i.position;

					var endBeat:Float = Math.POSITIVE_INFINITY;

					TimingStruct.addTiming(beat, i.value, endBeat, 0); // offset in this case = start time since we don't have a offset

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

		for (i in song.notes)
		{
			if (i.altAnim)
				i.CPUAltAnim = i.altAnim;

			var currentBeat = 4 * index;

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				continue;

			var beat:Float = currentSeg.startBeat + (currentBeat - currentSeg.startBeat);

			if (i.changeBPM && i.bpm != ba)
			{
				trace("converting changebpm for section " + index);
				ba = i.bpm;
				song.eventObjects.push(new Song.Event("FNF BPM Change " + index, beat, i.bpm, "BPM Change"));
			}

			for (ii in i.sectionNotes)
			{
				if (song.chartVersion == null)
				{
					ii[3] = false;
					ii[4] = TimingStruct.getBeatFromTime(ii[0]);
				}

				if (ii[3] == 0)
					ii[3] == false;
			}

			index++;
		}

		song.chartVersion = latestChart;

		return song;
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

	public static function parseJSONshit(songId:String, jsonData:Dynamic, jsonMetaData:Dynamic, ?jsonEvents:Dynamic):SongData
	{
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

			songData.offset = songMetaData.offset != null ? songMetaData.offset : 0;
		}
		else
		{
			songData.songName = songId.split('-').join(' ');
		}

		if (jsonEvents != null)
		{
			var events = cast jsonEvents;

			songData.eventObjects = events.eventObjects;
		}

		return Song.conversionChecks(songData);
	}
}
