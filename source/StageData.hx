package;


import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
import Song;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef StageFile = {
	var defaultZoom:Float;
	var isPixelStage:Bool;
	var hideGF:Bool;

	var boyfriend:Array<Float>;
	var gf:Array<Float>;
	var dad:Array<Float>;

	var camera_boyfriend:Array<Float>;
	var camera_opponent:Array<Float>;
	var camera_girlfriend:Array<Float>;
	var camera_speed:Null<Float>;
}

class StageData {
	public static var forceNextDirectory:String = null;

	public static function getStageFile(stage:String):StageFile {
		var rawJson:String = null;
		var path:String = Paths.getPreloadPath('stages/' + stage + '.json');
		
		if (Assets.exists(path)){
			rawJson = Assets.getText(path);
		}
		else
		{
			return null;
		}
		return cast Json.parse(rawJson);
	}
}