package;

import GestureUtil.GestureStateData;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxAssets.FlxGraphicAsset;

//He-he new usage for mod menu stuff from Enigma Engine
class CustomButton extends InteractableSprite{
    public var doOnClick:Void -> Void;

	var gestureStateData:GestureStateData = {};

    var originalWidth:Float = 1;

	var originalHeight:Float = 1;

	public function new(x:Float = 0, y:Float = 0, ?graphic:FlxGraphicAsset) {
        super(x,y,graphic);

		GestureUtil.addGestureCallbacks(this);

		originalWidth = width;
        originalHeight = height;
    }

    var tweened:Bool = false;
    override public function update(elapsed:Float) {
		gestureStateData = GestureUtil.handleGestureState(this, gestureStateData);

		super.update(elapsed);
    }

	override public function onJustPressed(pos:FlxPoint)
	{
		if (doOnClick != null)
			doOnClick();
	}

	override public function onJustHoverEnter(pos:FlxPoint)
	{
		FlxTween.tween(this, {width: width * 1.4, height: height * 1.4}, 0.5, {
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				tweened = true;
			}
		});
	}

	override public function onJustHoverExit(pos:FlxPoint)
	{
		FlxTween.tween(this, {width: originalWidth, height: originalHeight}, 0.5, {
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				tweened = false;
			}
		});
	}
}
