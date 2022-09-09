package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;
import flixel.FlxG;

class CustomButton extends FlxSprite
{
	public var doOnClick:Void->Void;

	var originalWidth:Float = 1;

	var originalHeight:Float = 1;

	public function new(x:Float = 0, y:Float = 0, ?graphic:FlxGraphicAsset)
	{
		super(x, y, graphic);

		originalWidth = width;
		originalHeight = height;
	}

	var twenned:Bool = false;

	override public function update(elapsed:Float)
	{
		if (FlxG.mouse.overlaps(this))
		{
			if (!twenned)
			{
				FlxTween.tween(this, {width: width * 1.4, height: height * 1.4}, 0.5, {
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween)
					{
						twenned = true;
					}
				});
			}

			if (FlxG.mouse.justPressed)
			{
				if (doOnClick != null)
					doOnClick();
			}
		}
		else
		{
			if (twenned)
			{
				FlxTween.tween(this, {width: originalWidth, height: originalHeight}, 0.5, {
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween)
					{
						twenned = false;
					}
				});
			}
		}
		super.update(elapsed);
	}
}