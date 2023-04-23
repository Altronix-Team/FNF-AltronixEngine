package gameplayStuff;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import editors.ChartingState;
import lime.media.AudioBuffer;
import lime.utils.Bytes;
import flixel.math.FlxMath;
import flash.geom.Rectangle;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import gameplayStuff.Section.SwagSection;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxSprite;

@:access(flixel.system.FlxSound._sound)
@:access(openfl.media.Sound.__buffer)
class SectionRender extends FlxTypedSpriteGroup<FlxSprite>
{
	public var section:SwagSection;
	public var icon:FlxSprite;
	public var lastUpdated:Bool;
	public var waveformSprite:WaveformSprite;
	public var sectionSprite:FlxSprite;

	public var sectionColors:Array<FlxColor> = [0x88e7e6e6, 0x88d9d5d5];

	public var vocals:FlxSound;

	var GRID_SIZE = 16;

	public function new(x:Float, y:Float, GRID_SIZE:Int, vocals:FlxSound, section:SwagSection, ?Height:Int = 16)
	{
		super();

		sectionSprite = new FlxSprite(x, y);
		sectionSprite.makeGraphic(GRID_SIZE * 8, GRID_SIZE * Height, 0xffe7e6e6);

		this.GRID_SIZE = GRID_SIZE;
		this.vocals = vocals;
		this.section = section;

		var h = GRID_SIZE;
		if (Math.floor(h) != h)
			h = GRID_SIZE;

		if (Main.save.data.editorBG)
			FlxGridOverlay.overlay(sectionSprite, GRID_SIZE, Std.int(h), GRID_SIZE * 8, Std.int(GRID_SIZE * Height), true, sectionColors[0], sectionColors[1]);

		add(sectionSprite);

		waveformSprite = new WaveformSprite(x, y, vocals, GRID_SIZE * 8, GRID_SIZE * Height);
		waveformSprite.generateFlixel(section.startTime, section.endTime);
		add(waveformSprite);
		waveformSprite.y = y;
		waveformSprite.visible = Main.save.data.chart_waveform;
	}
}
