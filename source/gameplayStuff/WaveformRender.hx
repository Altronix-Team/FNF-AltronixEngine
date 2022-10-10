package gameplayStuff;

import gameplayStuff.Song.SongData;
import flixel.FlxSprite;
import editors.ChartingState;
import gameplayStuff.Section.SwagSection;
import flixel.util.FlxColor;
import lime.media.AudioBuffer;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import haxe.io.Bytes;
import openfl.geom.Rectangle;
import flixel.math.FlxMath;
import flixel.system.FlxSound;

class WaveformRender extends FlxSprite
{
	var waveformPrinted:Bool = true;
	var audioBuffers:Array<AudioBuffer> = [null, null];

	public function new(x:Float, y:Float, _song:SongData, GRID_SIZE:Int, height:Int = 16, curSection:Int = 0)
	{
        super(x, y);

		loadAudioBuffer(_song.songId);

		if (waveformPrinted)
		{
			makeGraphic(Std.int(GRID_SIZE * 8), Std.int(GRID_SIZE * height), 0x00FFFFFF);
			pixels.fillRect(new Rectangle(0, 0, Std.int(GRID_SIZE * 8), Std.int(GRID_SIZE * height)), 0x00FFFFFF);
		}
		waveformPrinted = false;

		var checkForVoices:Int = 1;
		/*if (waveformUseInstrumental.checked)
			checkForVoices = 0;*/

		if (!FlxG.save.data.chart_waveform.checked || audioBuffers[checkForVoices] == null)
		{
			return;
		}

		var sampleMult:Float = audioBuffers[checkForVoices].sampleRate / 44100;
		var index:Int = Std.int(_song.notes[curSection].startTime * 44.0875 * sampleMult);
		var drawIndex:Int = 0;

		var steps:Int = _song.notes[curSection].lengthInSteps;
		if (Math.isNaN(steps) || steps < 1)
			steps = 16;
		var samplesPerRow:Int = Std.int(((Conductor.stepCrochet * steps * 1.1 * sampleMult) / 16));
		if (samplesPerRow < 1)
			samplesPerRow = 1;
		var waveBytes:Bytes = audioBuffers[checkForVoices].data.toBytes();

		var min:Float = 0;
		var max:Float = 0;
		while (index < (waveBytes.length - 1))
		{
			var byte:Int = waveBytes.getUInt16(index * 4);

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

			if ((index % samplesPerRow) == 0)
			{
				var pixelsMin:Float = Math.abs(min * (GRID_SIZE * 9));
				var pixelsMax:Float = max * (GRID_SIZE * 9);
				if (checkForVoices == 1)
					pixels.fillRect(new Rectangle(Std.int((GRID_SIZE * 4) - pixelsMin), drawIndex, pixelsMin + pixelsMax, 1), FlxColor.BLUE);
				else
					pixels.fillRect(new Rectangle(Std.int((GRID_SIZE * 4) - pixelsMin), drawIndex, pixelsMin + pixelsMax, 1), FlxColor.RED);
				drawIndex++;

				min = 0;
				max = 0;

				if (drawIndex > Std.int(GRID_SIZE * height))
					break;
			}

			index++;
		}
		waveformPrinted = true;
	}

	function loadAudioBuffer(songId:String)
	{
		audioBuffers[0] = AudioBuffer.fromFile(Paths.inst(songId));
		audioBuffers[1] = AudioBuffer.fromFile(Paths.voices(songId));
	}
}