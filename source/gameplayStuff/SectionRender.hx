package gameplayStuff;

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
class SectionRender extends FlxTypedGroup<FlxSprite>
{
	public var section:SwagSection;
	public var icon:FlxSprite;
	public var lastUpdated:Bool;
	public var waveformSprite:FlxSprite;
	public var sectionSprite:FlxSprite;

	public var sectionColors:Array<FlxColor> = [0x88e7e6e6, 0x88d9d5d5];
	public var waveformColor:FlxColor = FlxColor.BLUE;

	public var vocals:FlxSound;

	var GRID_SIZE = 16;
	var height = 16;

	public function new(x:Float, y:Float, GRID_SIZE:Int, vocals:FlxSound, section:SwagSection, ?Height:Int = 16)
	{
		super();

		sectionSprite = new FlxSprite(x, y);
		sectionSprite.makeGraphic(GRID_SIZE * 8, GRID_SIZE * Height, 0xffe7e6e6);

		var h = GRID_SIZE;
		if (Math.floor(h) != h)
			h = GRID_SIZE;

		this.GRID_SIZE = GRID_SIZE;
		this.vocals = vocals;
		this.section = section;

		if (FlxG.save.data.editorBG)
			FlxGridOverlay.overlay(sectionSprite, GRID_SIZE, Std.int(h), GRID_SIZE * 8, GRID_SIZE * Height, true, sectionColors[0], sectionColors[1]);

		add(sectionSprite);

		//generateWaveformSprite();

		//if (FlxG.save.data.chart_waveform && vocals != null)
			//updateWaveform();
	}

	override function update(elapsed)
	{
		//if (waveformPrinted != FlxG.save.data.chart_waveform && vocals != null)
			//updateWaveform();
	}

	function generateWaveformSprite() {
		waveformSprite = new FlxSprite(GRID_SIZE, 0).makeGraphic(FlxG.width, FlxG.height, 0x00FFFFFF);
		add(waveformSprite);
	}

	var waveformPrinted:Bool = true;
	var wavData:Array<Array<Array<Float>>> = [[[0], [0]], [[0], [0]]];

	//I want to die with this fucking waveforms
	//TODO MAKE IT WORK!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	function updateWaveform()
	{
		#if desktop
		if (waveformPrinted)
		{
			waveformSprite.makeGraphic(Std.int(GRID_SIZE * 8), Std.int(sectionSprite.height), 0x00FFFFFF);
			waveformSprite.pixels.fillRect(new Rectangle(0, 0, sectionSprite.width, sectionSprite.height), 0x00FFFFFF);
		}
		waveformPrinted = false;

		/*if (!FlxG.save.data.chart_waveformInst && !FlxG.save.data.chart_waveformVoices)
		{
			return;
		}*/

		if (!FlxG.save.data.chart_waveform || vocals == null)
			return;

		wavData[0][0] = [];
		wavData[0][1] = [];
		wavData[1][0] = [];
		wavData[1][1] = [];

		var steps:Int = 16;
		var st:Float = section.startTime;
		var et:Float = section.endTime;

		/*if (FlxG.save.data.chart_waveformInst)
		{
			var sound:FlxSound = FlxG.sound.music;
			if (sound._sound != null && sound._sound.__buffer != null)
			{
				var bytes:Bytes = sound._sound.__buffer.data.toBytes();

				wavData = waveformData(sound._sound.__buffer, bytes, st, et, 1, wavData, Std.int(sectionSprite.height));
			}
		}*/

		if (/*FlxG.save.data.chart_waveformVoices*/ FlxG.save.data.chart_waveform)
		{
			var sound:FlxSound = vocals;
			if (sound._sound != null && sound._sound.__buffer != null)
			{
				var bytes:Bytes = sound._sound.__buffer.data.toBytes();

				wavData = waveformData(sound._sound.__buffer, bytes, st, et, 1, wavData, Std.int(sectionSprite.height));
			}
		}

		// Draws
		var gSize:Int = Std.int(GRID_SIZE * 8);
		var hSize:Int = Std.int(gSize / 2);

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var size:Float = 1;

		var leftLength:Int = (wavData[0][0].length > wavData[0][1].length ? wavData[0][0].length : wavData[0][1].length);

		var rightLength:Int = (wavData[1][0].length > wavData[1][1].length ? wavData[1][0].length : wavData[1][1].length);

		var length:Int = leftLength > rightLength ? leftLength : rightLength;

		var index:Int;
		for (i in 0...length)
		{
			index = i;

			lmin = FlxMath.bound(((index < wavData[0][0].length && index >= 0) ? wavData[0][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			lmax = FlxMath.bound(((index < wavData[0][1].length && index >= 0) ? wavData[0][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			rmin = FlxMath.bound(((index < wavData[1][0].length && index >= 0) ? wavData[1][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			rmax = FlxMath.bound(((index < wavData[1][1].length && index >= 0) ? wavData[1][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			waveformSprite.pixels.fillRect(new Rectangle(hSize - (lmin + rmin), i * size, (lmin + rmin) + (lmax + rmax), size), waveformColor);
		}

		waveformPrinted = true;
		#end
	}

	function waveformData(buffer:AudioBuffer, bytes:Bytes, time:Float, endTime:Float, multiply:Float = 1, ?array:Array<Array<Array<Float>>>,
			?steps:Float):Array<Array<Array<Float>>>
	{
		#if (lime_cffi && !macro)
		if (buffer == null || buffer.data == null)
			return [[[0], [0]], [[0], [0]]];

		var khz:Float = (buffer.sampleRate / 1000);
		var channels:Int = buffer.channels;

		var index:Int = Std.int(time * khz);

		var samples:Float = ((endTime - time) * khz);

		if (steps == null)
			steps = 1280;

		var samplesPerRow:Float = samples / steps;
		var samplesPerRowI:Int = Std.int(samplesPerRow);

		var gotIndex:Int = 0;

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var rows:Float = 0;

		var simpleSample:Bool = true; // samples > 17200;
		var v1:Bool = false;

		if (array == null)
			array = [[[0], [0]], [[0], [0]]];

		while (index < (bytes.length - 1))
		{
			if (index >= 0)
			{
				var byte:Int = bytes.getUInt16(index * channels * 2);

				if (byte > 65535 / 2)
					byte -= 65535;

				var sample:Float = (byte / 65535);

				if (sample > 0)
				{
					if (sample > lmax)
						lmax = sample;
				}
				else if (sample < 0)
				{
					if (sample < lmin)
						lmin = sample;
				}

				if (channels >= 2)
				{
					byte = bytes.getUInt16((index * channels * 2) + 2);

					if (byte > 65535 / 2)
						byte -= 65535;

					sample = (byte / 65535);

					if (sample > 0)
					{
						if (sample > rmax)
							rmax = sample;
					}
					else if (sample < 0)
					{
						if (sample < rmin)
							rmin = sample;
					}
				}
			}

			v1 = samplesPerRowI > 0 ? (index % samplesPerRowI == 0) : false;
			while (simpleSample ? v1 : rows >= samplesPerRow)
			{
				v1 = false;
				rows -= samplesPerRow;

				gotIndex++;

				var lRMin:Float = Math.abs(lmin) * multiply;
				var lRMax:Float = lmax * multiply;

				var rRMin:Float = Math.abs(rmin) * multiply;
				var rRMax:Float = rmax * multiply;

				if (gotIndex > array[0][0].length)
					array[0][0].push(lRMin);
				else
					array[0][0][gotIndex - 1] = array[0][0][gotIndex - 1] + lRMin;

				if (gotIndex > array[0][1].length)
					array[0][1].push(lRMax);
				else
					array[0][1][gotIndex - 1] = array[0][1][gotIndex - 1] + lRMax;

				if (channels >= 2)
				{
					if (gotIndex > array[1][0].length)
						array[1][0].push(rRMin);
					else
						array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + rRMin;

					if (gotIndex > array[1][1].length)
						array[1][1].push(rRMax);
					else
						array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + rRMax;
				}
				else
				{
					if (gotIndex > array[1][0].length)
						array[1][0].push(lRMin);
					else
						array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + lRMin;

					if (gotIndex > array[1][1].length)
						array[1][1].push(lRMax);
					else
						array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + lRMax;
				}

				lmin = 0;
				lmax = 0;

				rmin = 0;
				rmax = 0;
			}

			index++;
			rows++;
			if (gotIndex > steps)
				break;
		}

		return array;
		#else
		return [[[0], [0]], [[0], [0]]];
		#end
	}
}
