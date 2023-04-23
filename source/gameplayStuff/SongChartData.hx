package gameplayStuff;

//Oh, that will be EPIC
typedef SongChart = {

	var songMeta:SongMetadata;

    var songCharacters:SongCharacters;

    var songSettings:SongSettings;

    var songSections:Array<SectionData>;

    var songEvents:Array<EventsAtPos>;
}

typedef SongMetadata = {
    
    var songId:String;

    var songName:String;

	var songComposer:String;

	var songPosBarColor:Int;

	var chartVersion:String;

    var stageId:String;
}

typedef SongCharacters = {

	var opponents:Array<CharacterData>;

	var players:Array<CharacterData>;

	var girlfriends:Array<CharacterData>;
}

typedef CharacterData = {

    var charId:String;

    var charNotes:Array<NoteData>;
}

typedef NoteData = {

	var strumTime:Float;

	var noteData:Int;

	var sustainLength:Float;

	var isAlt:Bool;

	var beat:Float;

	var noteType:String;

	var noteStyle:String;
}

typedef SongSettings = {

    var bpm:Float;

    var speed:Float;

    var needsVoices:Bool;

    var separateVoices:Bool;

    var diffSoundAssets:Bool;

    var hideGFs:Bool;

    var validScore:Bool;
}

typedef SectionData = {

	var startTime:Float;

	var endTime:Float;

	var lengthInSteps:Int;

	var typeOfSection:Int;

	var mustHitSection:Bool;

	var opponentsAltAnim:Bool;

	var playersAltAnim:Bool;

	var gfsAltAnim:Bool;

	var gfsSection:Bool;

	var activeCharacters:Array<String>;
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

typedef EventsAtPos = {

	var position:Float;

	var events:Array<EventObject>;
}
