package gameplayStuff;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class BackgroundDancers extends FlxTypedGroup<BackgroundDancer>
{
	public function new()
	{
		super();
		for (i in 0...5)
		{
			var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, 80);
			dancer.scrollFactor.set(0.4, 0.4);
			add(dancer);
		}
	}
}
class BackgroundDancer extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas("limo/limoDancer", 'week4');
		animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		animation.play('danceLeft');
		antialiasing = FlxG.save.data.antialiasing;
	}

	var danceDir:Bool = false;

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}
