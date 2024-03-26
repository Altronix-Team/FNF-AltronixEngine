package altronixengine.utils;

import flixel.FlxG;
import flixel.graphics.frames.FlxFramesCollection;
import haxe.Json;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import altronixengine.states.playState.GameData;

class Paths
{
	public static var SOUND_EXT(get, null):String = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	static function get_SOUND_EXT():String
	{
		#if web
		return "mp3";
		#else
		return "ogg";
		#end
	}

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType = null, ?library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		// if (currentLevel != null)
		// {
		var levelPath = getLibraryPathForce(file, 'core');
		if (OpenFlAssets.exists(levelPath, type))
			return levelPath;

		levelPath = getLibraryPathForce(file, "gameplay");
		if (OpenFlAssets.exists(levelPath, type))
			return levelPath;
		// }

		return getPreloadPath(file);
	}

	public static inline function songMeta(key:String)
	{
		return getPath('songs/$key/_meta.json', TEXT, 'gameplay');
	}

	static public function getLibraryPath(file:String, library = "core")
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

	inline public static function getUIImagePath(key:String, isPixel:Bool = false)
	{
		return getPath("ui/" + (isPixel ? "pixel/" : "normal/") + '$key.png', 'core');
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

	static public function sound(key:String, ?library:String = "core")
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function music(key:String, ?library:String = "core")
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
		return 'assets/core/fonts/$key';
	}

	inline static public function video(key:String, ?library:String)
	{
		return getPath('videos/$key.mp4', BINARY, library);
	}

	static public function formatToDialoguePath(file:String):Dynamic
	{
		var retPath:String = '';
		var lang:String = '';
		if (LanguageStuff.locale != 'en-US')
			lang = LanguageStuff.locale;

		retPath = Paths.json("songs/" + file + '-' + lang, 'gameplay');

		if (OpenFlAssets.exists(retPath))
		{
			Debug.logInfo('Found dialogue file at path ' + retPath);
		}
		else
		{
			Debug.logInfo('Failed found dialogue file with engine language. Trying to load dialogue with default language');

			retPath = Paths.json("songs/" + file, 'gameplay');

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
			switch (GameData.storyDifficulty)
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
					diff = '-' + CoolUtil.difficultyArray[GameData.storyDifficulty].toLowerCase();
			}
			result = Paths.getPath('songs/${songLowercase}/Voices$diff.$SOUND_EXT', null, "gameplay");
		}
		else
			result = Paths.getPath('songs/${songLowercase}/Voices.$SOUND_EXT', null, "gameplay");

		return AssetsUtil.doesAssetExists(result, SOUND) ? result : null;
	}

	inline static public function inst(song:String, useDiffSongAssets:Bool = false)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();

		var diff = '';
		if (useDiffSongAssets)
		{
			switch (GameData.storyDifficulty)
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
					diff = '-' + CoolUtil.difficultyArray[GameData.storyDifficulty].toLowerCase();
			}
			return Paths.getPath('songs/${songLowercase}/Inst$diff.$SOUND_EXT', null, "gameplay");
		}
		else
			return Paths.getPath('songs/${songLowercase}/Inst.$SOUND_EXT', null, "gameplay");
	}

	public inline static function getHscriptPath(script:String, folder:String = '', isCharScript:Bool = false):String
	{
		if (isCharScript)
		{
			if (OpenFlAssets.exists(getPath('characters/$folder/$script.hscript', null, 'gameplay')))
				return getPath('characters/$folder/$script.hscript', null, 'gameplay');
			else if (OpenFlAssets.exists(getPath('scripts/$folder/$script.hx', null, 'gameplay')))
				return getPath('characters/$folder/$script.hx', null, 'gameplay');
			else
				return null;
		}
		else
		{
			if (OpenFlAssets.exists(getPath('scripts/$folder/$script.hscript', null, 'gameplay')))
				return getPath('scripts/$folder/$script.hscript', null, 'gameplay');
			else if (OpenFlAssets.exists(getPath('scripts/$folder/$script.hx', null, 'gameplay')))
				return getPath('scripts/$folder/$script.hx', null, 'gameplay');
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
