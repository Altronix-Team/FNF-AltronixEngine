package data;

#if sys
import sys.FileSystem;
import sys.io.File;
#end
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

typedef WeekFile =
{
	var songs:Array<String>;
	var weekCharacters:Array<String>;
	var weekBackground:String;
	var weekBefore:String;
	var storyName:String;
	var difficulties:String;
	var ?weekImage:String;
}

class WeekData {
	public static var weeksLoaded:Map<String, WeekData> = new Map<String, WeekData>();
	public static var weeksList:Array<String> = [];
	public var folder:String = '';
	
	// JSON variables
	public var songs:Array<String>;
	public var weekCharacters:Array<String>;
	public var weekBackground:String;
	public var weekBefore:String;
	public var storyName:String;
	public var difficulties:String;
	public var weekImage:String;

	public var fileName:String;

	public static function createWeekFile():WeekFile {
		var weekFile:WeekFile = {
			songs: ["Bopeebo", "Fresh", "Dad Battle"],
			weekCharacters: ['dad', 'bf', 'gf'],
			weekBackground: 'Dad',
			weekBefore: 'tutorial',
			weekImage: 'week1',
			storyName: 'Your New Week',
			difficulties: 'Easy, Normal, Hard, Hard P'
		};
		return weekFile;
	}

	// HELP: Is there any way to convert a WeekFile to WeekData without having to put all variables there manually? I'm kind of a noob in haxe lmao
	public function new(weekFile:WeekFile, fileName:String) {
		songs = weekFile.songs;
		weekCharacters = weekFile.weekCharacters;
		weekBackground = weekFile.weekBackground;
		weekBefore = weekFile.weekBefore;
		storyName = weekFile.storyName;
		difficulties = weekFile.difficulties;
		weekImage = weekFile.weekImage;

		this.fileName = fileName;
	}
	
	static var defaultWeeks:Array<String> = ['tutorial', 'week1', 'week2', 'week3', 'week4', 'week5', 'week6', 'week7'];
	public static function reloadWeekFiles(isStoryMode:Null<Bool> = false)
	{
		weeksList = [];
		weeksLoaded.clear();

		var sexList:Array<String> = listWeeks();
		for (i in 0...sexList.length) {
			var fileToCheck:String = Paths.json('weeks/${sexList[i]}', 'gameplay');
			if(!weeksLoaded.exists(sexList[i])) {
				var week:WeekFile = getWeekFile(fileToCheck);
				if(week != null) {
					var weekFile:WeekData = new WeekData(week, sexList[i]);
					if(weekFile != null) {
						weeksLoaded.set(sexList[i], weekFile);
						weeksList.push(sexList[i]);
					}
				}
			}
		}
	}

	static function listWeeks():Array<String>
	{
		var returnArr:Array<String> = [];
		var mods:Array<String> = listWeeksInPath('weeks/');

		returnArr = defaultWeeks;

		for (i in mods)
		{
			returnArr.push(i);
		}

		return returnArr;
	}

	/**
	 * List all the data JSON files under a given subdirectory.
	 * @param path The path to look under.
	 * @return The list of JSON files under that path.
	 */
	static function listWeeksInPath(path:String)
		{
			var library = OpenFlAssets.getLibrary("gameplay");
			var dataAssets = library.list(null);
	
			var queryPath = '${path}';
	
			var results:Array<String> = [];
	
			for (data in dataAssets)
			{
				if (data.contains("/assets/")) continue;

				if (data.indexOf(queryPath) != -1 && data.endsWith('.json')
					 && !results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll('.json', '')))
				{
					var suffixPos = data.indexOf(queryPath) + queryPath.length;
					if (!defaultWeeks.contains(data.substr(suffixPos).replaceAll('.json', '')))
						results.push(data.substr(suffixPos).replaceAll('.json', ''));
				}
			}
			return results;
		}

	private static function addWeek(weekToCheck:String, path:String, directory:String, i:Int, originalLength:Int)
	{
		if(!weeksLoaded.exists(weekToCheck))
		{
			var week:WeekFile = getWeekFile(path);
			if(week != null)
			{
				var weekFile:WeekData = new WeekData(week, weekToCheck);
				weeksLoaded.set(weekToCheck, weekFile);
				weeksList.push(weekToCheck);
			}
		}
	}

	private static function getWeekFile(path:String):WeekFile {
		var rawJson:String = null;
		if(OpenFlAssets.exists(path)) {
			rawJson = Assets.getText(path);
		}

		if(rawJson != null && rawJson.length > 0) {
			return cast Json.parse(rawJson);
		}
		return null;
	}
}