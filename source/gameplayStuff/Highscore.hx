package gameplayStuff;

import flixel.FlxG;

using StringTools;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map();
	public static var songCombos:Map<String, String> = new Map();
	#else
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songCombos:Map<String, String> = new Map<String, String>();
	#end

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (!Main.save.data.botplay)
		{
			if (songScores.exists(daSong))
			{
				if (songScores.get(daSong) < score)
					setScore(daSong, score);
			}
			else
				setScore(daSong, score);
		}
		else
			trace('BotPlay detected. Score saving is disabled.');
	}

	public static function saveCombo(song:String, combo:String, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		var finalCombo:String = combo.split(')')[0].replace('(', '');

		if (!Main.save.data.botplay)
		{
			if (songCombos.exists(daSong))
			{
				if (getComboInt(songCombos.get(daSong)) < getComboInt(finalCombo))
					setCombo(daSong, finalCombo);
			}
			else
				setCombo(daSong, finalCombo);
		}
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		if (!Main.save.data.botplay)
		{
			var daWeek:String = formatSong('week' + week, diff);

			if (songScores.exists(daWeek))
			{
				if (songScores.get(daWeek) < score)
					setScore(daWeek, score);
			}
			else
				setScore(daWeek, score);
		}
		else
			trace('BotPlay detected. Score saving is disabled.');
	}

	static function setWeekScore(week:String, score:Int):Void
		{
			// Reminder that I don't need to format this song, it should come formatted!
			weekScores.set(week, score);
			Main.save.data.weekScores = weekScores;
			Main.save.flush();
		}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		Main.save.data.songScores = songScores;
		Main.save.flush();
	}

	static function setCombo(song:String, combo:String):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songCombos.set(song, combo);
		Main.save.data.songCombos = songCombos;
		Main.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song;

		if (diff == 0)
			daSong += '-easy';
		else if (diff == 2)
			daSong += '-hard';
		else if (diff == 3)
			daSong += '-hardplus';
		else if (diff == 1)
			daSong += '';
		else
			daSong += '-' + CoolUtil.difficultyFromInt(diff).toLowerCase();

		return daSong;
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if(decimals < 1)
		{
			return Math.floor(value);
		}

		var tempMult:Float = 1;
		for (i in 0...decimals)
		{
			tempMult *= 10;
		}
		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}
		
	public static function formatSongDiff(song:String, diff:Int):String
	{
		var songDiffEnd:String = song;

		if (diff == 0)
			songDiffEnd = '-easy';
		else if (diff == 2)
			songDiffEnd = '-hard';
		else if (diff == 3)
			songDiffEnd = '-hardplus';
		else if (diff == 1)
			songDiffEnd = '';
		else
			songDiffEnd = '-' + CoolUtil.difficultyFromInt(diff).toLowerCase();

		return songDiffEnd;
	}

	static function getComboInt(combo:String):Int
	{
		switch (combo)
		{
			case 'SDCB':
				return 1;
			case 'FC':
				return 2;
			case 'GFC':
				return 3;
			case 'MFC':
				return 4;
			default:
				return 0;
		}
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getCombo(song:String, diff:Int):String
	{
		if (!songCombos.exists(formatSong(song, diff)))
			setCombo(formatSong(song, diff), '');

		return songCombos.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:String, diff:Int):Int
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekScores.exists(daWeek))
			setWeekScore(daWeek, 0);
		
		return weekScores.get(daWeek);
	}

	public static function load():Void
	{
		if (Main.save.data.songScores != null)
		{
			songScores = Main.save.data.songScores;
		}
		if (Main.save.data.songCombos != null)
		{
			songCombos = Main.save.data.songCombos;
		}
	}
}
