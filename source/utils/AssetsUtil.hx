package utils;

import flixel.system.FlxSound;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetType;
import openfl.Assets as OpenFlAssets;

class AssetsUtil 
{
    public static function listAssetsInPath(path:String, type:AssetTypes = UNKNOWN):Array<String>
    {
		var results:Array<String> = [];

        switch (type)
        {
            case SOUND | MUSIC:
                results = listMusicInPath(path);
            case TEXT:
                results = listTxtInPath(path);
            case IMAGE:
                results = listImagesInPath(path);
            case JSON:
                results = listJsonInPath(path);
            case HSCRIPT:
                results = listHscriptInPath(path);
            case LUA:
                results = listLuaInPath(path);
            case FONT:
                results = listFontsInPath(path);
            case DIRECTORY:
                results = listFoldersInPath(path);
            case XML:
				results = listXmlInPath(path);
            case VIDEOS:
				results = listVideosInPath(path);
            default: //UNKNOWN type
                results = listFilesInPath(path, BINARY, ''); //List everything, lol
        }
        return results;
    }

    public static function loadAsset(key:String, type:AssetTypes = UNKNOWN, ?library:String):Dynamic
    {
        switch (type)
        {
            case IMAGE:
                return loadImage(key, library);
            case JSON:
                return loadJSON(key, library);
            case TEXT:
				return OpenFlAssets.getText(Paths.getPath(key, TEXT, library));
            case SOUND | MUSIC:
				return loadSoundAsset(key, type, library);
            default:
                return null;
        }
    }

	static public function getSparrowAtlas(key:String, ?library:String)
	{
		if (LanguageStuff.getSparrowAtlas(key) != null)
		{
			return LanguageStuff.getSparrowAtlas(key);
		}
		else
		{
			return FlxAtlasFrames.fromSparrow(loadImage(key, library), Paths.file('images/$key.xml', library));
		}
	}

	inline static public function getCharacterFrames(charName:String, key:String):FlxFramesCollection
	{
		var filePath = 'characters/$charName/$key';
		if (OpenFlAssets.exists('assets/characters/$charName/$key.txt'))
			return FlxAtlasFrames.fromSpriteSheetPacker(loadCharacterImage(charName, key), Paths.file('$filePath.txt'));
		else
		{
			if (OpenFlAssets.exists('assets/characters/$charName/$key.xml'))
			{
				return FlxAtlasFrames.fromSparrow(loadCharacterImage(charName, key), Paths.file('$filePath.xml'));
			}
			else
				return null;
		}
	}

	inline static public function characterImage(charName:String, key:String, ?library:String)
	{
		return Paths.getPath('characters/$charName/$key.png', IMAGE, library);
	}

	static public function loadCharacterImage(charName:String, key:String, ?library:String):FlxGraphic
	{
		var path = characterImage(charName, key, library);

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

	/**
	 * Function which wants to help find you this file all around the engine!
	 * - and mods ;)
	 * @param fileName name of file to find with extension
	 * @return File path
	 */
	static public function findMatchingFiles(fileName:String):String
	{
		var files = OpenFlAssets.list();

		for (file in files)
		{
			if (file.endsWith(fileName))
				return file.replaceAll('assets/', '');
		}
		return null;
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		if (LanguageStuff.getPackerAtlas(key) != null)
		{
			return LanguageStuff.getPackerAtlas(key);
		}
		else
		{
			return FlxAtlasFrames.fromSpriteSheetPacker(loadImage(key, library), Paths.file('images/$key.txt', library));
		}
	}

    inline static public function doesAssetExists(path:String, type:AssetTypes = UNKNOWN):Bool
    {
        switch (type)
        {
            case SOUND | MUSIC:
                return doesSoundAssetExist(path);
            case TEXT | XML | LUA | JSON | HSCRIPT:
                return doesTextAssetExist(path);
            default:
                return OpenFlAssets.exists(path, BINARY);
        }
    }

    private static function loadSoundAsset(key:String, type:AssetTypes = SOUND, ?library:String)
    {
        var retSound:FlxSound = null;
        if (type == SOUND)
        {
            retSound = new FlxSound().loadEmbedded(Paths.sound(key, library), true);
			FlxG.sound.list.add(retSound);
        }
        else if (type == MUSIC)
        {
			retSound = new FlxSound().loadEmbedded(Paths.music(key, library), true);
			FlxG.sound.list.add(retSound);
        }
        return retSound;
    }

	inline static private function doesSoundAssetExist(path:String)
	{
		if (path == null || path == "")
			return false;
		return OpenFlAssets.exists(path, AssetType.SOUND)
			|| OpenFlAssets.exists(path, AssetType.MUSIC)
			|| OpenFlAssets.exists(OpenFlAssets.getPath(path), AssetType.SOUND)
			|| OpenFlAssets.exists(OpenFlAssets.getPath(path), AssetType.MUSIC);
	}

	inline static private function doesTextAssetExist(path:String)
	{
		if (OpenFlAssets.exists(path, TEXT))
			return OpenFlAssets.exists(path, TEXT);
		else
			return false;
	}

	static private function loadImage(key:String, ?library:String):FlxGraphic
	{
		var retVal:BitmapData;
		var path = Paths.image(key, library);
		if (OpenFlAssets.exists(path, IMAGE))
		{
			retVal = OpenFlAssets.getBitmapData(path);
		}
		else
		{
			Debug.logWarn('Could not find image at path $path');
			retVal = flixel.addons.display.FlxGridOverlay.createGrid(50, 50, 100, 100, true, 0xFFFF00FF, 0xFF000000);
		}
		return FlxGraphic.fromBitmapData(retVal);
	}

	static private function loadJSON(key:String, ?library:String):Dynamic
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

	private static function listFontsInPath(path:String)
	{
		var dataAssets = OpenFlAssets.list(BINARY);

		var queryPath = '${path}';

		var results:Array<String> = [];

		var ends:Array<String> = ['.otf', '.ttf'];

		for (data in dataAssets)
		{
			for (end in ends)
			{
				if (data.indexOf(queryPath) != -1
					&& data.endsWith(end)
					&& (!results.contains(data.substr(data.indexOf(queryPath) + queryPath.length))))
				{
					var suffixPos = data.indexOf(queryPath) + queryPath.length;
					results.push(data.substr(suffixPos));
				}
			}
		}

		return results;
	}

	private static function listHscriptInPath(path:String)
	{
		var dataAssets = OpenFlAssets.list(TEXT);

		var queryPath = '${path}';

		var results:Array<String> = [];

		var ends:Array<String> = ['.hscript', '.hx'];

		for (data in dataAssets)
		{
			for (end in ends)
			{
				if (data.indexOf(queryPath) != -1
					&& data.endsWith(end)
					&& (!results.contains(data.substr(data.indexOf(queryPath) + queryPath.length))))
				{
					var suffixPos = data.indexOf(queryPath) + queryPath.length;
					results.push(data.substr(suffixPos));
				}
			}
		}

		return results;
	}

	private static function listLuaInPath(path:String)
	{
		var dataAssets = OpenFlAssets.list(TEXT);

		var queryPath = '${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			if (data.indexOf(queryPath) != -1
				&& data.endsWith('.lua')
				&& (!results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll('.lua', ''))))
			{
				var suffixPos = data.indexOf(queryPath) + queryPath.length;
				results.push(data.substr(suffixPos).replaceAll('.lua', ''));
			}
		}

		return results;
	}

	private static function listVideosInPath(path:String)
	{
		var dataAssets = OpenFlAssets.list(BINARY);

		var queryPath = '${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			if (data.indexOf(queryPath) != -1
				&& data.endsWith('.mp4')
				&& (!results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll('.mp4', ''))))
			{
				var suffixPos = data.indexOf(queryPath) + queryPath.length;
				results.push(data.substr(suffixPos).replaceAll('.mp4', ''));
			}
		}

		return results;
	}

	private static function listTxtInPath(path:String)
	{
		var dataAssets = OpenFlAssets.list(TEXT);

		var queryPath = '${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			if (data.indexOf(queryPath) != -1
				&& data.endsWith('.txt')
				&& (!results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll('.txt', ''))))
			{
				var suffixPos = data.indexOf(queryPath) + queryPath.length;
				results.push(data.substr(suffixPos).replaceAll('.txt', ''));
			}
		}

		return results;
	}

	private static function listXmlInPath(path:String)
	{
		var dataAssets = OpenFlAssets.list(TEXT);

		var queryPath = '${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			if (data.indexOf(queryPath) != -1
				&& data.endsWith('.xml')
				&& (!results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll('.xml', ''))))
			{
				var suffixPos = data.indexOf(queryPath) + queryPath.length;
				results.push(data.substr(suffixPos).replaceAll('.xml', ''));
			}
		}

		return results;
	}

	private static function listFilesInPath(path:String, fileType:AssetType = TEXT, fileEnd:String = '.txt')
	{
		var dataAssets = OpenFlAssets.list(fileType);

		var queryPath = '${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			if (data.indexOf(queryPath) != -1
				&& data.endsWith(fileEnd)
				&& !results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll(fileEnd, '')))
			{
				var suffixPos = data.indexOf(queryPath) + queryPath.length;
				results.push(data.substr(suffixPos).replaceAll(fileEnd, ''));
			}
		}

		return results;
	}

	private static function listFoldersInPath(path:String)
	{
		var dataAssets = OpenFlAssets.list();

		var queryPath = '${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			if (data.indexOf(queryPath) != -1
				&& !results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replace(queryPath, '').removeAfter('/')))
			{
				var suffixPos = data.indexOf(queryPath) + queryPath.length;
				results.push(data.substr(suffixPos).replace(queryPath, '').removeAfter('/'));
			}
		}
		return results;
	}

	private static function listJsonInPath(path:String)
	{
		var dataAssets = OpenFlAssets.list(TEXT);

		var queryPath = '${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			if (data.indexOf(queryPath) != -1
				&& data.endsWith('.json')
				&& !results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll('.json', '')))
			{
				var suffixPos = data.indexOf(queryPath) + queryPath.length;
				results.push(data.substr(suffixPos).replaceAll('.json', ''));
			}
		}

		return results;
	}

	private static function listImagesInPath(path:String)
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

	private static function listMusicInPath(path:String)
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
}

@:enum abstract AssetTypes(String) from (String) to (String)
{
    var SOUND:AssetTypes = 'sound';
    var MUSIC:AssetTypes = 'music';
    var IMAGE:AssetTypes = 'image';
    var TEXT:AssetTypes = 'text';
    var JSON:AssetTypes = 'json';
    var XML:AssetTypes = 'xml';
    var HSCRIPT:AssetTypes = 'hscript';
    var LUA:AssetTypes = 'lua';
    var VIDEOS:AssetTypes = 'videos';
    var DIRECTORY:AssetTypes = 'directory';
	var FONT:AssetTypes = "font";
    var UNKNOWN:AssetTypes = 'unknown';
}