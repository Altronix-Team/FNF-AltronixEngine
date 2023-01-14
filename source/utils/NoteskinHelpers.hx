package utils;

import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import openfl.utils.Assets as OpenFlAssets;
import gameplayStuff.Note;
import haxe.xml.Access;

class NoteskinHelpers
{
	public static var noteskinArray = [];

	public static function updateNoteskins()
	{
		noteskinArray = [];
		for (i in AssetsUtil.listAssetsInPath('noteskins/', IMAGE))
		{
			if (OpenFlAssets.exists(Paths.json('images/noteskins/${i.replace(".png", "")}', 'shared')))
			{
				var noteMetaData:NoteMeta = cast Paths.loadJSON('images/noteskins/${i.replace(".png", "")}', 'shared');
				if (!noteMetaData.listInSettings)
					continue;
			}			

			if (i.contains("-pixel"))
				continue;

			if (!i.endsWith(".png"))
				continue;
			
			noteskinArray.push(i.replace(".png", ""));	
		}

		return noteskinArray;
	}

	public static function getNoteskins()
	{
		return noteskinArray;
	}

	public static function getIDByNoteskin(skin:String)
	{
		return noteskinArray.indexOf(skin);
	}

	public static function getNoteskinByID(id:Int)
	{
		return noteskinArray[id];
	}

	static public function generateNoteskinSprite(id:String)
	{
		return Paths.getSparrowAtlas('noteskins/' + id);	
	}

	public static function getPrefixesList(id:String):Array<String>
	{
		var retValue:Array<String> = [];

		var path = Paths.xml('images/noteskins/' + id);

		if (OpenFlAssets.exists(path))
		{
			var data:Access = new Access(Xml.parse(OpenFlAssets.getText(path)).firstElement());

			for (texture in data.nodes.SubTexture)
			{
				var name = texture.att.name.removeAfter('0').replaceAll('0', '');
				if (!retValue.contains(name))
					retValue.push(name);
			}
		}
		return retValue;
	}

	static public function generatePixelSprite(id:String, ends:Bool = false)
	{
		var path = Paths.image("noteskins/" + id + "-pixel" + (ends ? "-ends" : ""));

		var defaultBitmap = OpenFlAssets.getBitmapData(Paths.image('noteskins/Arrows-pixel' + (ends ? "-ends" : ""), 'core'));

		if (!OpenFlAssets.exists(path))
		{
			return defaultBitmap;
		}
		else
		{
			if (OpenFlAssets.getBitmapData(path) != null) //It can return null, lol
				return OpenFlAssets.getBitmapData(path);
			else
				return defaultBitmap;
		}
	}
}	
