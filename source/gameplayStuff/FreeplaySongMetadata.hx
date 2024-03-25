package gameplayStuff;

class FreeplaySongMetadata
{
	public static var preloaded:Bool = false;

	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public var diffs = [];

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
