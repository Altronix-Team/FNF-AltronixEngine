package gameplayStuff;

import flixel.FlxG;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
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
		/*if (Paths.isAnimated('icons/$char'))
		{
			loadIcon(char);
		}
		else
		{*/
			loadIconLegacy(char);
		//}
	}

	function loadIcon(char:String)
	{
		if (!OpenFlAssets.exists(Paths.image('icons/' + char)))
		{
			loadIconLegacy('face');
			return;
		}

		var data:IconData = Json.parse(OpenFlAssets.getText('assets/images/icons/' + char + '.json').trim());

		defaultAnim = data.defaultAnim;
		nearToDieAnim = data.nearToDieAnim;

		frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(OpenFlAssets.getBitmapData(OpenFlAssets.getPath('assets/images/icons/' + char + '.png'))), OpenFlAssets.getPath('assets/images/icons/' + char + '.xml'));
	
		for (i in data.animations)
		{
			animation.addByPrefix(i.name, i.prefix, 24, true, isPlayer);
		}
	
		animation.play(data.defaultAnim);
	}
	
	function loadIconLegacy(char:String)
	{
		var image = Paths.image('icons/' + char);
		if (image == null)
		{
			Debug.logError('Error loading graphic for health icon ${char}');

			loadGraphic(Paths.loadImage('icons/face'), true, 150, 150);

			antialiasing = FlxG.save.data.antialiasing;
			animation.add('face', [0, 1], 0, false, isPlayer);
			animation.play('face');
		}
	
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
