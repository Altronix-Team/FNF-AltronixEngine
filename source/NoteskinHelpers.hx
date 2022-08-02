import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class NoteskinHelpers
{
	public static var noteskinArray = [];

	public static function updateNoteskins()
	{
		noteskinArray = [];
		for (i in Paths.listImagesInPath('noteskins/'))
		{
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
		return Paths.getSparrowAtlas('noteskins/' + id, "shared");	
	}

	static public function generateSpecialPixelSprite(id:String, ends:Bool = false)
	{
		var path = "assets/shared/images/specialnotes" + "/" + id + "-pixel" + (ends ? "-ends" : "");
		return BitmapData.fromFile(path + ".png");
	}

	static public function generatePixelSprite(id:String, ends:Bool = false)
	{
		var path = "assets/shared/images/noteskins/" + id + "-pixel" + (ends ? "-ends" : "");

		if (!OpenFlAssets.exists(path + '.png'))
		{
			Debug.logTrace("getting default pixel skin");
			return BitmapData.fromFile("assets/shared/images/noteskins/Arrows-pixel" + (ends ? "-ends" : "") + ".png");
		}
		return BitmapData.fromFile(path + '.png');
	}
}	
