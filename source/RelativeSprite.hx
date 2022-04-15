package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * This extension of FlxSprite adds the ability to set relativeX and relativeY,
 * to position itself in relation to a parent.
 */
class RelativeSprite extends FlxSprite implements IRelative
{
	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset, ?Parent:FlxObject)
	{
		super(0, 0, SimpleGraphic);

		this.relativeX = X;
		this.relativeY = Y;

		if (Parent != null)
			this.parent = Parent;

		updatePosition();
	}

	public override function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):RelativeSprite
	{
		super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
		// Override to change the return type of the function.
		return this;
	}
}