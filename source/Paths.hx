package;

#if FEATURE_FILESYSTEM
import sys.FileSystem;
#end

import flixel.graphics.frames.FlxFramesCollection;
import animateatlas.AtlasFrameMaker;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import flash.media.Sound;
import openfl.display.BitmapData;
import haxe.Json;
import states.PlayState;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType = null, ?library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	public static inline function songMeta(key:String)
	{
		return getPath('$key/_meta.json', TEXT, 'songs');
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	public static function getPreloadPath(file:String = '')
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, ?library:String, type:AssetType = TEXT)
	{
		if (LanguageStuff.getFilePath(file, type) != null)
			return LanguageStuff.getFilePath(file, type);
		else
			return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('$key.json', TEXT, library);
	}

	inline static public function yaml(key:String, ?library:String)
	{
		return getPath('$key.yaml', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function image(key:String, ?library:String)
	{
		if (LanguageStuff.getImagePath(key) != null)
			return LanguageStuff.getImagePath(key);
		else
			return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function video(key:String, ?library:String)
	{
		return getPath('videos/$key.mp4', BINARY, library);
	}

	static public function formatToDialoguePath(file:String):Dynamic {
		var retPath:String ='';
		var lang:String = '';
		if (LanguageStuff.locale != 'en-US')
			lang = LanguageStuff.locale;

		retPath = Paths.json(file + '-' + lang, 'songs');
			
		if (OpenFlAssets.exists(retPath))
		{
			Debug.logInfo('Found dialogue file at path ' + retPath);
		}
		else{
			Debug.logInfo('Failed found dialogue file with engine language. Trying to load dialogue with default language');

			retPath = Paths.json(file, 'songs');

			if (OpenFlAssets.exists(retPath))
			{ 
				Debug.logInfo('Found dialogue file at path ' + retPath);
			}
			else 
			{
				Debug.logInfo('Failed found dialogue files, is they exists?');
				return null;
			}
		}

		var rawJson = OpenFlAssets.getText(retPath).trim();

		// Perform cleanup on files that have bad data at the end.
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		try
		{
			// Attempt to parse and return the JSON data.
			return Json.parse(rawJson);
		}
		catch (e)
		{
			Debug.logError("AN ERROR OCCURRED parsing a JSON file.");
			Debug.logError(e.message);
			Debug.logError(e.stack);

			// Return null.
			return null;
		}
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function voices(song:String, useDiffSongAssets:Bool = false)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();

		var result = '';

		var diff = '';
		if (useDiffSongAssets)
		{
			switch (PlayState.storyDifficulty)
			{
				case 0:
					diff = '-easy';
				case 1:
					diff = '';
				case 2:
					diff = '-hard';
				case 3:
					diff = '-hardplus';
				default:
					diff = '-' + CoolUtil.difficultyArray[PlayState.storyDifficulty].toLowerCase();
			}
			result = 'songs:assets/songs/${songLowercase}/Voices$diff.$SOUND_EXT';
		}
		else
			result = 'songs:assets/songs/${songLowercase}/Voices.$SOUND_EXT';

		return AssetsUtil.doesAssetExists(result, SOUND) ? result : null;
	}

	inline static public function inst(song:String, useDiffSongAssets:Bool = false)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();

		var diff = '';
		if (useDiffSongAssets)
		{
			switch (PlayState.storyDifficulty)
			{
				case 0:
					diff = '-easy';
				case 1:
					diff = '';
				case 2:
					diff = '-hard';
				case 3:
					diff = '-hardplus';
				default:
					diff = '-' + CoolUtil.difficultyArray[PlayState.storyDifficulty].toLowerCase();
			}
			return 'songs:assets/songs/${songLowercase}/Inst$diff.$SOUND_EXT';
		}
		else
			return 'songs:assets/songs/${songLowercase}/Inst.$SOUND_EXT';
	}

	public inline static function getHscriptPath(script:String, folder:String = '', isCharScript:Bool = false, ?library:String):String
	{
		if (isCharScript)
		{
			if (OpenFlAssets.exists(getPath('characters/$folder/$script.hscript', BINARY, library)))
				return getPath('characters/$folder/$script.hscript', BINARY, library);
			else if (OpenFlAssets.exists(getPath('scripts/$folder/$script.hx', BINARY, library)))
				return getPath('characters/$folder/$script.hx', BINARY, library);
			#if FEATURE_FILESYSTEM
			else if (FileSystem.exists(getPath('characters/$folder/$script.hscript', BINARY, library)))
				return getPath('characters/$folder/$script.hscript', BINARY, library);
			else if (FileSystem.exists(getPath('characters/$folder/$script.hx', BINARY, library)))
				return getPath('characters/$folder/$script.hx', BINARY, library);
			#end
			else
				return null;
		}
		else
		{
			if (OpenFlAssets.exists(getPath('scripts/$folder/$script.hscript', BINARY, library)))
				return getPath('scripts/$folder/$script.hscript', BINARY, library);
			else if (OpenFlAssets.exists(getPath('scripts/$folder/$script.hx', BINARY, library)))
				return getPath('scripts/$folder/$script.hx', BINARY, library);
			#if FEATURE_FILESYSTEM
			else if (FileSystem.exists(getPath('scripts/$folder/$script.hscript', BINARY, library)))
				return getPath('scripts/$folder/$script.hscript', BINARY, library);
			else if (FileSystem.exists(getPath('scripts/$folder/$script.hx', BINARY, library)))
				return getPath('scripts/$folder/$script.hx', BINARY, library);
			#end
			else
				return null;
		}
	}

	static public function getSparrowAtlas(key:String, ?library:String)
	{
		return AssetsUtil.getSparrowAtlas(key, library);
	}

	inline static public function getCharacterFrames(charName:String, key:String):FlxFramesCollection
	{
		return AssetsUtil.getCharacterFrames(charName, key);	
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return AssetsUtil.getPackerAtlas(key, library);		
	}

	static public function loadImage(key:String, ?library:String)
	{
		return AssetsUtil.loadAsset(key, IMAGE, library);
	}

	static public function loadJSON(key:String, ?library:String)
	{
		return AssetsUtil.loadAsset(key, JSON, library);
	}
}
