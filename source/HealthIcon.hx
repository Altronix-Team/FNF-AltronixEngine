package;

import flixel.FlxG;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef IconData =
{
	var defaultAnim:String;
	var nearToDieAnim:String;
	var animations:Array<IconAnims>;
}

typedef IconAnims =
{
	var name:String;
	var prefix:String;
}
class HealthIcon extends FlxSprite
{
	public var char:String = 'bf';
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public var defaultAnim:String;
	public var nearToDieAnim:String;

	public function new(?char:String = "bf", ?isPlayer:Bool = false)
	{
		super();

		this.char = char;
		this.isPlayer = isPlayer;

		isPlayer = isOldIcon = false;

		changeIcon(char);
		scrollFactor.set();
	}

	public function swapOldIcon()
	{
		(isOldIcon = !isOldIcon) ? changeIcon("bf-old") : changeIcon(char);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String)
	{
		if (OpenFlAssets.exists(Paths.image('icons/' + char)))
			{
				loadGraphic(Paths.loadImage('icons/' + char));
				if (width <= 150)
					loadGraphic(Paths.loadImage('icons/' + char), true, Math.floor(width), Math.floor(height));
				else
					loadGraphic(Paths.loadImage('icons/' + char), true, Math.floor(width / 2), Math.floor(height));

				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = (width - 150) / 2;
				updateHitbox();

				if (char.contains('pixel') || char.startsWith('senpai') || char.startsWith('spirit'))
					antialiasing = false
				else
					antialiasing = FlxG.save.data.antialiasing;

				animation.add(char, [0, 1], 0, false, isPlayer);
				animation.play(char);
			}
		else
			{
				loadGraphic(Paths.loadImage('icons/face'), true, 150, 150);

				antialiasing = FlxG.save.data.antialiasing;
				animation.add('face', [0, 1], 0, false, isPlayer);
				animation.play('face');
			}
	}

	override function updateHitbox()
		{
			super.updateHitbox();
			offset.x = iconOffsets[0];
			offset.y = iconOffsets[1];
		}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
