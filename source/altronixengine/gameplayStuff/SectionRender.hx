package altronixengine.gameplayStuff;

import altronixengine.editors.ChartingState;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;
import altronixengine.gameplayStuff.Section.SwagSection;

class SectionRender extends FlxTypedSpriteGroup<FlxSprite>
{
	public var section:SwagSection;
	public var icon:FlxSprite;
	public var lastUpdated:Bool;
	public var sectionSprite:FlxSprite;

	public var sectionColors:Array<FlxColor> = [0x88e7e6e6, 0x88d9d5d5];

	var GRID_SIZE = 16;

	public function new(x:Float, y:Float, GRID_SIZE:Int, ?vocals:FlxSound, ?section:SwagSection, ?Height:Int = 16)
	{
		super();

		sectionSprite = new FlxSprite(x, y);
		sectionSprite.makeGraphic(GRID_SIZE * 8, GRID_SIZE * Height, 0xffe7e6e6);

		this.GRID_SIZE = GRID_SIZE;

		var h = GRID_SIZE;
		if (Math.floor(h) != h)
			h = GRID_SIZE;

		if (Main.save.data.editorBG)
			FlxGridOverlay.overlay(sectionSprite, GRID_SIZE, Std.int(h), GRID_SIZE * 8, Std.int(GRID_SIZE * Height), true, sectionColors[0], sectionColors[1]);

		add(sectionSprite);
	}
}
