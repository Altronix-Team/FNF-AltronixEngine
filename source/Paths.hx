package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
#if FEATURE_MODCORE
import polymod.Polymod.ModMetadata;
#end
import flash.media.Sound;
import openfl.display.BitmapData;
import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import states.PlayState;

using StringTools;
using hx.strings.Strings;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String>)
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

	static public function getTextFromFile(key:String):String
	{
		return Assets.getText(getPath(key, TEXT));
	}
	
	inline static public function atlasImage(key:String, ?library:String):FlxGraphic
		{
			// streamlined the assets process more
			var returnAsset:FlxGraphic = returnGraphic(key, library);
			return returnAsset;
		}

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static function returnGraphic(key:String, ?library:String)
		{
			var path = getPath('images/$key.png', IMAGE, library);
			if (OpenFlAssets.exists(path, IMAGE)) {
				if(!currentTrackedAssets.exists(path)) {
					var newGraphic:FlxGraphic = FlxG.bitmap.add(path, false, path);
					currentTrackedAssets.set(path, newGraphic);
				}
				return currentTrackedAssets.get(path);
			}
			trace('oh no its returning null NOOOO');
			return null;
		}

	public static inline function songMeta(key:String, ?library:String)
		{
			return getPath('data/songs/$key/_meta.json', TEXT, library);
		}

	/**
	 * For a given key and library for an image, returns the corresponding BitmapData.
	 		* We can probably move the cache handling here.
	 * @param key 
	 * @param library 
	 * @return BitmapData
	 */
	static public function loadImage(key:String, ?library:String):FlxGraphic
	{
		var path = image(key, library);

		if (OpenFlAssets.exists(path, IMAGE))
		{
			var bitmap = OpenFlAssets.getBitmapData(path);
			return FlxGraphic.fromBitmapData(bitmap);
		}
		else
		{
			Debug.logWarn('Could not find image at path $path');
			return null;
		}
	}

	public static function getScriptFile(key:String, category:String = ''):String
	{
		if (category != '')
			return 'assets/scripts/' + category + '/' + key + '.hscript';
		return 'assets/scripts/' + key + '.hscript';
	}

	public static function getAssetPath(path:String, type:AssetType, group:String = ""):String
	{
		switch (type)
		{
			case IMAGE:
				return "assets/" + group + "/images/" + path;
			case SOUND:
				return "assets/" + group + "/sounds/" + path;
			case MUSIC:
				return "assets/" + group + "/music/" + path;
			default:
				return "";
		}
	}

	public static function getAsset(path:String, type:AssetType, group:String = ""):Dynamic
	{
		var actualPath:String = getAssetPath(path, type, group);

		if (OpenFlAssets.exists(actualPath))
		{
			if (FlxG.bitmap.checkCache(actualPath) || OpenFlAssets.cache.hasSound(actualPath))
			{
				switch (type)
				{
					case IMAGE:
						return FlxG.bitmap.get(actualPath);
					case SOUND, MUSIC:
						return OpenFlAssets.cache.getSound(actualPath);
					default:
						return null;
				}
			}
			else if (OpenFlAssets.exists(actualPath))
			{
				switch (type)
				{
					case IMAGE:
						return FlxGraphic.fromAssetKey(actualPath);
					case SOUND:
						return OpenFlAssets.getSound(actualPath);
					case MUSIC:
						return OpenFlAssets.getMusic(actualPath);
					default:
						return null;
				}
			}
			else
			{
				actualPath = "./" + actualPath;
				switch (type)
				{
					case IMAGE:
						return FlxGraphic.fromBitmapData(BitmapData.fromFile(actualPath));
					case SOUND, MUSIC:
						if (!OpenFlAssets.cache.hasSound(actualPath))
						{
							var sound:Sound = Sound.fromFile(actualPath);
							OpenFlAssets.cache.setSound(actualPath, sound);
						}
						return OpenFlAssets.cache.getSound(actualPath);
					default:
						return null;
				}
			}
		}
		
		return null;
	}

	static public function isFileReplaced(path:String):Bool //Check for replaced files by polymod
	{
		if (ModCore.replacedFiles.contains(path))
		{
			return true;
		}
		return false;
	}

	static public function loadStageJSON(key:String, ?library:String):Dynamic
		{
			var rawJson = OpenFlAssets.getText(Paths.stageJson(key, library)).trim();
	
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

	static public function loadWeeksJSON(key:String, ?library:String):Dynamic
		{
			if (OpenFlAssets.exists(Paths.weeksJson(key, library)))
			{
				var rawJson = OpenFlAssets.getText(Paths.weeksJson(key, library)).trim();
			
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
			else
				return null;
		}

	static public function loadImagesJSON(key:String, ?library:String):Dynamic
	{
		var rawJson = OpenFlAssets.getText(Paths.imagesJson(key, library)).trim();

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

	static public function loadJSON(key:String, ?library:String):Dynamic
	{
		var rawJson = OpenFlAssets.getText(Paths.json(key, library)).trim();

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

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
		{		
			if(OpenFlAssets.exists(getPath(key, type, library))) {
				return true;
			}
			return false;
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
		return getPath(file, type, library);
	}

	inline static public function lua(key:String, ?library:String)
	{
		return getPath('data/$key.lua', TEXT, library);
	}

	inline static public function luaImage(key:String, ?library:String)
	{
		return getPath('data/$key.png', IMAGE, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function imagesJson(key:String, ?library:String)
	{
		return getPath('images/$key.json', TEXT, library);
	}

	inline static public function weeksJson(key:String, ?library:String)
	{
		return getPath('weeks/$key', TEXT, library);
	}

	inline static public function stageJson(key:String, ?library:String)
	{
		return getPath('stages/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function formatToSongPath(path:String) {
		return path.toLowerCase().replace(' ', '-');
	}

	static public function dialogueSound(key:String, ?library:String):Sound
		{
			var sound:Sound = returnSound('sounds', key, library);
			return sound;
		}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String, useDiffSongAssets:Bool = false)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
			case 'm.i.l.f':
				songLowercase = 'milf';
		}

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

		return doesSoundAssetExist(result) ? result : null;
	}

	inline static public function inst(song:String, useDiffSongAssets:Bool = false)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
			case 'm.i.l.f':
				songLowercase = 'milf';
		}

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

	static public function listSongsToCache()
	{
		// We need to query OpenFlAssets, not the file system, because of Polymod.
		var soundAssets = OpenFlAssets.list(AssetType.MUSIC).concat(OpenFlAssets.list(AssetType.SOUND));

		// TODO: Maybe rework this to pull from a text file rather than scan the list of assets.
		var songNames = [];

		for (sound in soundAssets)
		{
			// Parse end-to-beginning to support mods.
			var path = sound.split('/');
			path.reverse();

			var fileName = path[0];
			var songName = path[1];

			if (path[2] != 'songs')
				continue;

			// Remove duplicates.
			if (songNames.indexOf(songName) != -1)
				continue;

			songNames.push(songName);
		}

		return songNames;
	}

	static public function doesSoundAssetExist(path:String)
	{
		if (path == null || path == "")
			return false;
		return OpenFlAssets.exists(path, AssetType.SOUND) || OpenFlAssets.exists(path, AssetType.MUSIC) 
		|| OpenFlAssets.exists(OpenFlAssets.getPath(path), AssetType.SOUND) || OpenFlAssets.exists(OpenFlAssets.getPath(path), AssetType.MUSIC);
	}

	inline static public function doesTextAssetExist(path:String)
	{
		if (OpenFlAssets.exists(path, TEXT))
			return OpenFlAssets.exists(path, TEXT);
		else
			return false;
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function video(key:String, ?library:String)
	{
		trace('assets/videos/$key.mp4');
		return getPath('videos/$key.mp4', BINARY, library);
	}


	/**
	 * List all the data hscript files under a given subdirectory.
	 * @param path The path to look under.
	 * @return The list of hscript files under that path.
	 */
	public static function listHscriptInPath(path:String)
	{
		var dataAssets = OpenFlAssets.list(TEXT);

		var queryPath = '${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			if (data.indexOf(queryPath) != -1
				&& data.endsWith('.hscript')
				&& (!results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll('.hscript', ''))))
			{
				var suffixPos = data.indexOf(queryPath) + queryPath.length;
				results.push(data.substr(suffixPos).replaceAll('.hscript', ''));
			}
		}

		return results;
	}

	/**
	 * List all the data lua files under a given subdirectory.
	 * @param path The path to look under.
	 * @return The list of lua files under that path.
	 */
	 public static function listLuaInPath(path:String)
		{
			var dataAssets = OpenFlAssets.list(TEXT);
	
			var queryPath = '${path}';
	
			var results:Array<String> = [];
	
			for (data in dataAssets)
			{
				if (data.indexOf(queryPath) != -1 && data.endsWith('.lua') && 
					(!results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll('.lua', ''))))
				{
					var suffixPos = data.indexOf(queryPath) + queryPath.length;
					results.push(data.substr(suffixPos).replaceAll('.lua', ''));
				}
			}
	
			return results;
		}

	/**
	 * List all the data txt files under a given subdirectory.
	 * @param path The path to look under.
	 * @return The list of txt files under that path.
	 */
	 public static function listTxtInPath(path:String)
		{
			var dataAssets = OpenFlAssets.list(TEXT);
	
			var queryPath = '${path}';
	
			var results:Array<String> = [];
	
			for (data in dataAssets)
			{
				if (data.indexOf(queryPath) != -1 && data.endsWith('.txt') && 
					(!results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll('.txt', ''))))
				{
					var suffixPos = data.indexOf(queryPath) + queryPath.length;
					results.push(data.substr(suffixPos).replaceAll('.txt', ''));
				}
			}
	
			return results;
		}

	/**
	 * List all the data JSON files under a given subdirectory.
	 * @param path The path to look under.
	 * @return The list of JSON files under that path.
	 */
	public static function listJsonInPath(path:String)
		{
			var dataAssets = OpenFlAssets.list(TEXT);
	
			var queryPath = '${path}';
	
			var results:Array<String> = [];
	
			for (data in dataAssets)
			{
				if (data.indexOf(queryPath) != -1 && data.endsWith('.json')
					 && !results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll('.json', '')))
				{
					var suffixPos = data.indexOf(queryPath) + queryPath.length;
					results.push(data.substr(suffixPos).replaceAll('.json', ''));
				}
			}
	
			return results;
		}

	/**
	 * List all the image files under a given subdirectory.
	 * @param path The path to look under.
	 * @return The list of image files under that path.
	 */
	 public static function listImagesInPath(path:String)
		{
			// We need to query OpenFlAssets, not the file system, because of Polymod.
			var imageAssets = OpenFlAssets.list(IMAGE);
	
			var queryPath = 'images/${path}';
	
			var results:Array<String> = [];
	
			for (image in imageAssets)
			{
				// Parse end-to-beginning to support mods.
				var path = image.split('/');
				if (image.indexOf(queryPath) != -1)
				{
					var suffixPos = image.indexOf(queryPath) + queryPath.length;
					results.push(image.substr(suffixPos).replaceAll('.json', ''));
				}
			}
	
			return results;
		}

	/**
	 * List all the data Music files under a given subdirectory.
	 * @param path The path to look under.
	 * @return The list of Music files under that path.
	 */
	public static function listMusicInPath(path:String)
		{
			var dataAssets = OpenFlAssets.list(MUSIC).concat(OpenFlAssets.list(SOUND));
	
			var queryPath = '${path}';
	
			var results:Array<String> = [];
	
			for (data in dataAssets)
			{
				if (data.indexOf(queryPath) != -1)
				{
					var suffixPos = data.indexOf(queryPath) + queryPath.length;
					results.push(data.substr(suffixPos));
				}
			}
	
			return results;
		}

	public static function isAnimated(key:String, ?library:String)
	{
		return doesTextAssetExist(Paths.file('images/$key.xml', library));
	}

	static public function getSparrowAtlas(key:String, ?library:String, ?isCharacter:Bool = false)
	{
		if (isCharacter)
		{
			return FlxAtlasFrames.fromSparrow(loadImage('characters/$key', library), file('images/characters/$key.xml', library));
		}
		return FlxAtlasFrames.fromSparrow(loadImage(key, library), file('images/$key.xml', library));
	}

	public static var localTrackedAssets:Array<String> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static function returnSound(path:String, key:String, ?library:String) {
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);	
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if(!currentTrackedSounds.exists(gottenPath)) 
			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(getPath('$path/$key.$SOUND_EXT', SOUND, library)));
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}

	/**
	 * Senpai in Thorns uses this instead of Sparrow and IDK why.
	 */
	inline static public function getPackerAtlas(key:String, ?library:String, ?isCharacter:Bool = false)
	{
		if (isCharacter)
		{
			return FlxAtlasFrames.fromSpriteSheetPacker(loadImage('characters/$key', library), file('images/characters/$key.txt', library));
		}
		return FlxAtlasFrames.fromSpriteSheetPacker(loadImage(key, library), file('images/$key.txt', library));
	}
}
