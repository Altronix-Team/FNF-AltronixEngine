import flixel.util.FlxColor;
import flixel.FlxG;
import openfl.geom.Rectangle;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;
import sys.thread.Thread;

/*
*	@see https://github.com/gedehari/HaxeFlixel-Waveform-Rendering/blob/master/source/PlayState.hx
*	by gedehari
*/

class Waveform extends FlxSprite
{
	
	public var buffer:AudioBuffer;
	public var data:Bytes;

	public var length:Int;

	public function new(x:Int, y:Int, audioPath:String, height:Int)
	{
		super(x, y);

		var path = StringTools.replace(audioPath, "songs:", "");

		buffer = AudioBuffer.fromFile(path);

		if (buffer == null)
		{
			buffer = AudioBuffer.fromFile(OpenFlAssets.getPath(path));

			if (buffer == null)
			{
				Debug.logTrace('Error on waveform.');
				return;
			}
			else
			{
				Debug.logTrace('Lets go');
			}
		}

		Debug.logTrace("Channels: " + buffer.channels + "\nBits per sample: " + buffer.bitsPerSample);


		data = buffer.data.toBytes();

		length = height;

		makeGraphic(320, height, 0x00FFFFFF);
	}

	public function drawWaveform()
	{
		Thread.create(function()
		{
			var index:Int = 0;
			var drawIndex:Int = 0;
			var samplesPerCollumn:Int = 600;
	
			var min:Float = 0;
			var max:Float = 0;
	
			while ((index * 4) < (data.length - 1))
			{
				var byte:Int = data.getUInt16(index * 4);
	
				if (byte > 65535 / 2)
					byte -= 65535;
	
				var sample:Float = (byte / 65535);
	
				if (sample > 0)
				{
					if (sample > max)
						max = sample;
				}
				else if (sample < 0)
				{
					if (sample < min)
						min = sample;
				}
	
				if ((index % samplesPerCollumn) == 0)
				{
	
					if (drawIndex > length)
					{
						drawIndex = 0;
					}
	
					var pixelsMin:Float = Math.abs(min * 300);
					var pixelsMax:Float = max * 300;
	
					pixels.fillRect(new Rectangle(0, drawIndex, 1, length), 0x00000000);
					pixels.fillRect(new Rectangle(160 - pixelsMin, drawIndex, pixelsMin + pixelsMax, 1), FlxColor.BLUE);
					drawIndex += 1;
	
					min = 0;
					max = 0;
				}
	
				index += 1;
			}
		});
	}
}
