package states.playState;

import states.playState.Replay.Ana;
import states.playState.Replay.Analysis;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxAtlasFrames;
import gameplayStuff.Song.SongData;

//All static data from PlayState now here
class GameData 
{
    public static var SONG:SongData;
	public static var storyDifficulty:Int = 1;

	// Per week data
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];

	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;

	public static var campaignMisses:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;
    public static var campaignScore:Int = 0;

    //Per song data
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var misses:Int = 0;
	public static var highestCombo:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

    public static var songOffset:Float = 0;

    public static var isPixel:Bool;
	
    public static var startTime = 0.0;

    public static var stageCheck:String = 'stage';

    public static var songStats:Analysis;
	public static var songJudgements:Array<String> = [];

	public static var songMultiplier = 1.0;

    //Note variables
    public static var noteskinSprite:FlxAtlasFrames;
	public static var noteskinPixelSprite:BitmapData;
	public static var noteskinPixelSpriteEnds:BitmapData;
	public static var noteskinTexture:String;

	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

    //Cur game state
	public static var isStoryMode:Bool = false;
	public static var inResults:Bool = false;
	public static var inDaPlay:Bool = false;
    public static var isFreeplay:Bool = false;
	public static var theFunne:Bool = true;
	public static var inCutscene:Bool = false;
    public static var seenCutscene:Bool = false;
	public static var chartingMode:Bool = false;

    //Unused
    public static var offsetTesting:Bool = false;
    public static var currentSong = "noneYet";
	public static var stageTesting:Bool = false;
}