package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class NoteSplash extends FlxSprite
{
	var curNoteskinSprite:String = 'Default';

	private var idleAnim:String;
	private var textureLoaded:String = null;

    override public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
    {
		super(x, y);

		if (OpenFlAssets.exists(Paths.image("notesplashes/" + NoteskinHelpers.getNoteskinByID(FlxG.save.data.noteskin))))
			curNoteskinSprite = NoteskinHelpers.getNoteskinByID(FlxG.save.data.noteskin);
		else
			curNoteskinSprite = 'Default';

		loadAnims(curNoteskinSprite);
		
		setupNoteSplash(x, y, note);
		antialiasing = FlxG.save.data.antialiasing;
    }

    public function setupNoteSplash(x:Float, y:Float, note:Int = 0, noteType:Int = 0)
    {
		var texture:String;
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
    	alpha = 0.6;

		switch (noteType)
		{
			case 2:
				texture = 'BulletNoteSplashes';

			case 1:
				texture = 'HURTnoteSplashes';

			default:
				texture = curNoteskinSprite;
		}

		if(textureLoaded != texture) {
			loadAnims(texture);
		}
		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
    }

	function loadAnims(skin:String = 'default')
	{
		frames = Paths.getSparrowAtlas("notesplashes/" + skin);
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
	}

    override public function update(elapsed:Float)
    {
		if(animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
    }
}