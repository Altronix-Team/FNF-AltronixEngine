package;

import flixel.FlxCamera;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard", "Hard P"];

	public static var defaultDifficulties:Array<String> = ['Easy', "Normal", "Hard", "Hard P"];

	public static var difficultyPrefixes:Array<String> = ['-easy', '', '-hard', '-hardplus'];

	public static var songDiffs:Map<String, Array<String>> = [];
	
	public static var songDiffsPrefix:Map<String, Array<String>> = [];

	public static var daPixelZoom:Float = 6;

	public static var daCam:FlxCamera;

	public static function difficultyFromInt(difficulty:Int):String
	{
		return difficultyArray[difficulty];
	}

	public static function clearDifficultyArray(difficulty:Int)
	{
		difficultyArray = defaultDifficulties;
	}

	public static function coolTextFile(path:String):Array<String>
		{
			var daList:Array<String> = [];
			#if sys
			if(FileSystem.exists(path)) daList = File.getContent(path).trim().split('\n');
			else if (OpenFlAssets.exists(path)) daList = OpenFlAssets.getText(path).trim().split('\n');
			#else
			if(OpenFlAssets.exists(path)) daList = OpenFlAssets.getText(path).trim().split('\n');
			#end

			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}

			return daList;
		}

	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function coolStringFile(path:String):Array<String>
	{
		var daList:Array<String> = path.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function precacheSound(sound:String, ?library:String = null):Void {
		precacheSoundFile(Paths.sound(sound, library));
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void {
		precacheSoundFile(Paths.music(sound, library));
	}

	private static function precacheSoundFile(file:Dynamic):Void {
		if (OpenFlAssets.exists(file, SOUND) || OpenFlAssets.exists(file, MUSIC))
			OpenFlAssets.getSound(file, true);
	}
}
