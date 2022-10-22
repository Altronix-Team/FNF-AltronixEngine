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
//TODO Deal with animated icons
class HealthIcon extends FlxSprite
{
	public var character:String = 'bf';
	public var filename:String;
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	public var sprTracker:FlxSprite;

	public var defaultAnim:String;
	public var nearToDieAnim:String;

	public function new(character:String, filename:String, ?isPlayer:Bool = false)
	{
		super();

		this.character = character;
		this.isPlayer = isPlayer;
		this.filename = filename;

		isPlayer = isOldIcon = false;
			
		changeIcon(character, filename);

		scrollFactor.set();
	}

	public function swapOldIcon()
	{
		(isOldIcon = !isOldIcon) ? changeIcon(character, "bf-old") : changeIcon(character, filename);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String, filename:String)
	{
		/*if (Paths.isAnimated('characters/$char/$filename'))
		{
			loadIcon(char, filename);
		}
		else
		{*/
			loadIconLegacy(char, filename);
		//}
	}

	function loadIcon(char:String, filename:String)
	{
		if (!OpenFlAssets.exists(image(char != '' ? '/$char' : '', filename)))
		{
			Debug.logError('Error loading graphic for health icon ${char}');

			loadIconLegacy('', 'face');
			return;
		}

		var data:IconData = Paths.loadJSON('characters${(char != '' ? '/$char' : '')}/$filename'); //Json.parse(OpenFlAssets.getText(Paths.json('characters/$char/$filename')).trim());

		defaultAnim = data.defaultAnim;
		nearToDieAnim = data.nearToDieAnim;

		frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(OpenFlAssets.getBitmapData(image(char != '' ? '/$char' : '', filename))),
			OpenFlAssets.getPath(Paths.file('characters${(char != '' ? '/$char' : '')}/$filename.xml')));
	
		for (i in data.animations)
		{
			animation.addByPrefix(i.name, i.prefix, 24, true, isPlayer);
		}
	
		animation.play(data.defaultAnim);
	}
	
	function loadIconLegacy(char:String, filename:String)
	{
		var image = image(char != '' ? '/$char' : '', filename);
		if (image == null)
		{
			Debug.logError('Error loading graphic for health icon ${char}');

			loadGraphic(loadImage('', 'face'), true, 150, 150);

			antialiasing = FlxG.save.data.antialiasing;
			animation.add('face', [0, 1], 0, false, isPlayer);
			animation.play('face');
			return;
		}
	
		loadGraphic(loadImage(char, filename));
		if (width <= 150)
			loadGraphic(loadImage(char, filename), true, Math.floor(width), Math.floor(height));
		else
			loadGraphic(loadImage(char, filename), true, Math.floor(width / 2), Math.floor(height));

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

	inline static public function image(character:String = '', key:String, ?library:String)
	{
		return Paths.getPath('characters$character/$key.png', IMAGE, library);
	}

	static public function loadImage(character:String = '', key:String, ?library:String):FlxGraphic
	{
		var path = image(character != '' ? '/$character': '', key, library);

		if (OpenFlAssets.exists(path, IMAGE))
		{
			var bitmap = OpenFlAssets.getBitmapData(path);
			return FlxGraphic.fromBitmapData(bitmap);
		}
		else
		{
			return loadImage('', 'face');
		}
	}
}
