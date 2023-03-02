package gameplayStuff;

import flixel.util.FlxColor;
import gameplayStuff.Section.SwagSection;
import haxe.Json;
import openfl.utils.Assets as OpenFlAssets;
import flixel.util.FlxSort;
import gameplayStuff.Section.SectionNoteData;

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

	/**
	 * Song composer nickname displayed in pause menu
	 */
	var songComposer:String;

	/**
	 * Song position bar color in play state
	 */
	var songPosBarColor:Int;

	/**
	* Used this to know on which version of the engine was the chart generated.
	**/
	var chartVersion:String;

	/**
	* Information about notes in this chart.
	**/
	var notes:Array<SwagSection>;

	/**
	* Altronix Engine events array.
	* Always contains Init BPM event.
	**/
	var eventsArray:Array<EventsAtPos>;

	/**
	* Song BPM.
	**/
	var bpm:Float;

	/**
	* Should game use voices sound file.
	**/
	var needsVoices:Bool;

	/**
	* Speed of notes while playing this song.
	**/
	var speed:Float;

	/**
	* Player.
	**/
	var player1:String;

	/**
	* Opponent.
	**/
	var player2:String;

	/**
	* Which character will be used as gf.
	**/
	var gfVersion:String;

	/**
	* If true, toggles GF visibility to false.
	**/
	var ?hideGF:Bool;

	/**
	* Song note style, like "normal" or "pixel".
	* Also affects to rating and countdown sprites and sounds.
	**/
	var noteStyle:String;

	/**
	* Name of stage, that will be used in song, while playing.
	**/
	var stage:String;

	/**
	* Name of sprite file of notes, that will be appear in this song.
	**/
	var specialSongNoteSkin:String;

	/**
	* Should game saves song result after playing.
	**/
	var ?validScore:Bool;

	/**
	* Makes senpai fans scared.
	* Note: Works only on scholl stage.
	**/
	var ?scaredbgdancers:Bool;

	/**
	* Toggles visibility of senpai fans.
	* Note: Works only on scholl stage.
	**/
	var ?showbgdancers:Bool;

	/**
	* Should game use special sound assets for this difficulty of song.
	* (Example: Inst-hard, Voices-hard).
	**/
	var ?diffSoundAssets:Bool;

	/** Do not use this in your code.
	* Use eventsArray instead.
	* Used to convert Kade Engine events to Altronix Engine events.
	*/
	var ?eventObjects:Array<Event>; // Kade Engine events kekw

	/** Do not use this in your code.
	* Use eventsArray instead.
	* Used to convert Psych Engine events to Altronix Engine events.
	*/
	var ?events:Array<Dynamic>; // Psych Engine events
}

typedef SongMeta =
{
	/**
	* Changes the displayed song name.
	**/
	var ?name:String;

	/**
	 * Song composer nickname displayed in pause menu
	 */
	var ?composer:String;

	/**
	 * Song position bar color
	 */
	var ?barColor:String;
}

typedef OldNoteStoringCheck = Array<SectionNoteData>;

class Song
{
	public static function loadFromJsonRAW(rawJson:String)
	{
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		var jsonData = Json.parse(rawJson);
		return ChartUtil.parseJSONshit("rawsong", jsonData, ["name" => jsonData.name]);
	}

	public static function loadMetadata(songId:String):SongMeta
	{
		var rawMetaJson = null;
		if (OpenFlAssets.exists(Paths.songMeta(songId)))
		{
			rawMetaJson = Paths.loadJSON('songs/$songId/_meta', 'gameplay');
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
		var songFile = 'songs/$songId/$songId$difficulty';

		if (OpenFlAssets.exists(Paths.json('$songFile', 'gameplay')))
		{
			var rawJson = Paths.loadJSON('$songFile', 'gameplay');

			var metaData:SongMeta = loadMetadata(songId);

			if (OpenFlAssets.exists(Paths.json('songs/$songId/events', 'gameplay')))
			{
				var rawEvents = Paths.loadJSON('songs/$songId/events', 'gameplay');
				return ChartUtil.parseJSONshit(songId, rawJson, metaData, rawEvents);
			}	
			else
				return ChartUtil.parseJSONshit(songId, rawJson, metaData);	
		}
		else
		{
			return null;
		}	
	}

	public static function picospeakerLoad():SongData
	{
		var rawJson = Paths.loadJSON('songs/stress/picospeaker', 'gameplay');
	
		var swagShit:SongData = (cast rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}

	public static function parseAutosaveshit(rawJson:String):SongData
	{
		var swagShit:SongData = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return ChartUtil.conversionChecks(swagShit);
	}
}

class Event // Kade Engine events
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