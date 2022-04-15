package;

import flixel.FlxObject;
import flixel.addons.ui.FlxUIText;

class RelativeText extends FlxUIText implements IRelative
{
	public function new(X:Float = 0, Y:Float = 0, Parent:FlxObject = null, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		super(0, 0, FieldWidth, Text, Size, EmbeddedFont);

		this.parent = Parent;
		this.relativeX = X;
		this.relativeY = Y;
	}
}