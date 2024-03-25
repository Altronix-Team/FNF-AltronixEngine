package gameplayStuff;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import openfl.utils.Assets as OpenFlAssets;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

typedef IconData =
{
	var image:String;
	var defaultAnim:String;
	var nearToDieAnim:String;
	var animations:Array<IconAnims>;
}

typedef IconAnims =
{
	var name:String;
	var prefix:String;
}

// TODO Deal with animated icons
class HealthIcon extends FlxSprite
{
	public var character:String = 'bf';
	public var filename:String;
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	public var sprTracker:FlxSprite;

	public var defaultAnim:String = null;
	public var nearToDieAnim:String = null;

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
		Debug.logInfo('Loading icon for ${char}. \n $char icon file is $filename');
		/*if (char != filename && OpenFlAssets.exists(Paths.json('characters${char != '' ? '/$char' : ''}/$filename', 'gameplay'), TEXT))
			{
				loadIcon(char, filename);
			}
			else
			{ */
		loadIconLegacy(char, filename);
		// }
	}

	/*
		var tut_byl_ya:String = 'gay';
		tut_byl_ya ?? gay
	 */
	function loadIcon(char:String, filename:String)
	{
		var data:IconData = cast Paths.loadJSON('characters${(char != '' ? '/$char' : '')}/$filename');

		if (data == null)
		{
			Debug.logError('Error loading animated icon for ${char}');

			loadIconLegacy('', 'face');
			return;
		}

		Debug.logTrace(image(char != '' ? '/$char' : '', data.image ?? filename));
		if (!OpenFlAssets.exists(image(char != '' ? '/$char' : '', data.image ?? filename)))
		{
			Debug.logError('Error loading graphic for health icon ${char}');

			loadIconLegacy('', 'face');
			return;
		}

		defaultAnim = data.defaultAnim;
		nearToDieAnim = data.nearToDieAnim;

		frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(OpenFlAssets.getBitmapData(image(char != '' ? '/$char' : '', data.image ?? filename))),
			OpenFlAssets.getPath(Paths.xml('characters${(char != '' ? '/$char' : '')}/${data.image ?? filename /*POG Haxe 4.3 feature!!!!!!!!*/}')));

		for (i in data.animations)
		{
			animation.addByPrefix(i.name, i.prefix, 24, true, isPlayer);
		}

		animation.play(data.defaultAnim);
	}

	function loadIconLegacy(char:String, filename:String)
	{
		var image = image(char != '' ? '/$char' : '', filename);
		if (!OpenFlAssets.exists(image))
		{
			Debug.logError('Error loading graphic for health icon ${char} file $filename');

			loadGraphic(loadImage('', 'face'), true, 150, 150);

			antialiasing = Main.save.data.antialiasing;
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
			antialiasing = Main.save.data.antialiasing;

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

	inline static public function image(character:String = '', key:String)
	{
		return Paths.getPath('characters$character/$key.png', IMAGE, "gameplay");
	}

	static public function loadImage(character:String = '', key:String):FlxGraphic
	{
		var path = image(character != '' ? '/$character' : '', key);
		if (OpenFlAssets.exists(path, IMAGE))
		{
			var bitmap = OpenFlAssets.getBitmapData(path);
			return FlxGraphic.fromBitmapData(bitmap);
		}
		else
		{
			var bitmap = OpenFlAssets.getBitmapData(image('', 'face'));
			return FlxGraphic.fromBitmapData(bitmap);
		}
	}
}
