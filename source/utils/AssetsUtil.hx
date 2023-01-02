package utils;

import lime.tools.AssetType;
import openfl.net.FileFilter;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
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
	public var _file:FileReference;
	
    public static function listAssetsInPath(path:String, type:AssetTypes = UNKNOWN):Array<String>
    {
		if (type == DIRECTORY) return listFoldersInPath(path);
		var dataAssets = if (type == SOUND || type == MUSIC) OpenFlAssets.list(SOUND).concat(OpenFlAssets.list(MUSIC)) else OpenFlAssets.list(AssetTypes.toOpenFlType(type));

		var queryPath = '${path}';

		var results:Array<String> = [];

		var ends:Array<String> = AssetTypes.returnExts(type);

		for (data in dataAssets)
		{
			for (end in ends)
			{
				if (data.indexOf(queryPath) != -1
					&& data.endsWith('.$end')
					&& (!results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll('.$end', ''))))
				{
					var suffixPos = data.indexOf(queryPath) + queryPath.length;
					results.push(data.substr(suffixPos).replaceAll('.$end', ''));
				}
			}
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
			case YAML:
				return loadYAML(key, library);
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
            case TEXT | XML | LUA | JSON | HSCRIPT | YAML:
                return doesTextAssetExist(path);
            default:
                return OpenFlAssets.exists(path, BINARY);
        }
    }

	public static function returnAssetType(path:String, fileName:String):Array<AssetTypes>
	{
		var checkExts = AssetTypes.returnAllExts();
		
		for (ext in checkExts)
		{
			if (OpenFlAssets.exists('$path/$fileName.$ext'))
			{
				return AssetTypes.returnTypeByExt(ext);
			}
		}
		return [UNKNOWN];
	}

	public function saveFile(fileContent:Dynamic = '', type:AssetTypes = UNKNOWN, fileName:String = 'file')
	{
		if (type == IMAGE || type == DIRECTORY || type == UNKNOWN || type == FONT || type == SOUND || type == MUSIC || type == VIDEOS) return;

		var data:Dynamic = '';
		switch (type)
		{
			case JSON:
				data = Json.stringify(fileContent, null, ' ');
			case XML:
				data = Xml.parse(fileContent);
			default:
				data = fileContent;
		}

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(openfl.events.Event.COMPLETE, onSaveComplete);
			_file.addEventListener(openfl.events.Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), fileName + '.${AssetTypes.returnExts(type)}');
		}
	}

	/*public function loadFile(type:AssetTypes = UNKNOWN)
	{
		if (type == IMAGE || type == DIRECTORY || type == UNKNOWN || type == FONT || type == SOUND || type == MUSIC || type == VIDEOS) return;

		var ext = '';

		for (i in AssetTypes.returnEnds(type))
			ext += i;

		var fileFilter:FileFilter = new FileFilter(type, ext);
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([fileFilter]);
	}*/

	/*private function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		var fullPath:String = null;
		@:privateAccess
		if (_file.__path != null)
			fullPath = _file.__path;

		if (fullPath != null)
		{
			
		}
		#else
		Debug.logError("File couldn't be loaded! You aren't on Desktop, are you?");
		#end
	}*/

	/**
	 * Called when the save file dialog is cancelled.
	 */
	/*private function onLoadCancel(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Cancelled file loading.");
	}*/

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	/*private function onLoadError(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}*/
	
	private function onSaveComplete(_):Void
	{
		_file.removeEventListener(openfl.events.Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(openfl.events.Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	private function onSaveCancel(_):Void
	{
		_file.removeEventListener(openfl.events.Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(openfl.events.Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	private function onSaveError(_):Void
	{
		_file.removeEventListener(openfl.events.Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(openfl.events.Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
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
			retVal = new BitmapData(100, 100, true, 0xFFEA00FF);
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

	static private function loadYAML(key:String, ?library:String):Dynamic
	{
		var rawYaml = OpenFlAssets.getText(Paths.yaml(key, library)).trim();

		try
		{
			return Yaml.parse(rawYaml);
		}
		catch (e)
		{
			Debug.logError("AN ERROR OCCURRED parsing a Yaml file.");
			Debug.logError(e.message);
			Debug.logError(e.stack);

			// Return null.
			return null;
		}
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
}

enum abstract AssetTypes(String) from (String) to (String)
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
	var YAML:AssetTypes = 'yaml';

	public static function toOpenFlType(type:AssetTypes):AssetType
	{
		switch (type)
		{
			case FONT:
				return AssetType.FONT;
			case IMAGE:
				return AssetType.IMAGE;
			case MUSIC:
				return AssetType.MUSIC;
			case SOUND:
				return AssetType.SOUND;
			case XML | HSCRIPT | JSON | LUA | TEXT | YAML:
				return AssetType.TEXT;
			default:
				return AssetType.BINARY;		
		}
	}

	public static function returnExts(type:AssetTypes):Array<String>
	{
		switch (type)
		{
			case SOUND | MUSIC:
				return [#if web "mp3" #else "ogg" #end];
			case IMAGE:
				return ['png'];
			case TEXT:
				return ['txt'];
			case JSON:
				return ['json'];
			case XML:
				return ['xml'];
			case HSCRIPT:
				return ['hscript', 'hx'];
			case LUA:
				return ['lua'];
			case VIDEOS:
				return ['mp4'];
			case FONT:
				return ['otf', 'ttf'];
			case YAML:
				return ['yaml'];
			default:
				return [''];
		}
	}

	public static function returnTypeByExt(ext:String):Array<AssetTypes>
	{
		switch (ext)
		{
			case #if web "mp3" #else "ogg" #end:
				return [SOUND, MUSIC];
			case 'png':
				return [IMAGE];
			case 'json':
				return [JSON];
			case 'txt':
				return [TEXT];
			case 'xml':
				return [XML];
			case 'hscript' | 'hx':
				return [HSCRIPT];
			case 'lua':
				return [LUA];
			case 'mp4':
				return [VIDEOS];
			case 'otf' | 'ttf':
				return [FONT];
			case 'yaml':
				return [YAML];
			default:
				return [UNKNOWN];
		}
	}

	public static function returnAllExts():Array<String>
	{
		return [
			#if web "mp3" #else "ogg" #end,
			'png',
			'txt',
			'json',
			'xml',
			'hscript',
			'hx',
			'lua',
			'mp4',
			'otf',
			'ttf'];
	}
}