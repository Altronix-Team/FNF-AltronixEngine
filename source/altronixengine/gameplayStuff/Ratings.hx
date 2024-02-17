package altronixengine.gameplayStuff;

import altronixengine.gameplayStuff.Conductor;
import altronixengine.states.playState.GameData as Data;

class Ratings
{
	public static function GenerateLetterRank(accuracy:Float) // generate a letter ranking
	{
		var ranking:String = LanguageStuff.getPlayState("$NA");
		if (Main.save.data.botplay)
		{
			ranking = LanguageStuff.getPlayState("$BOTPLAY_TEXT");
		}

		if (Data.misses == 0 && Data.bads == 0 && Data.shits == 0 && Data.goods == 0) // Marvelous (SICK) Full Combo
		{
			ranking = "(MFC)";
		}
		else if (Data.misses == 0 && Data.bads == 0 && Data.shits == 0 && Data.goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
		{
			ranking = "(GFC)";
		}
		else if (Data.misses == 0) // Regular FC
		{
			ranking = "(FC)";
		}
		else if (Data.misses < 10) // Single Digit Combo Breaks
		{
			ranking = "(SDCB)";
		}
		else
		{
			ranking = "(Clear)";
		}

		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935, // AAAAA
			accuracy >= 99.980, // AAAA:
			accuracy >= 99.970, // AAAA.
			accuracy >= 99.955, // AAAA
			accuracy >= 99.90, // AAA:
			accuracy >= 99.80, // AAA.
			accuracy >= 99.70, // AAA
			accuracy >= 99, // AA:
			accuracy >= 96.50, // AA.
			accuracy >= 93, // AA
			accuracy >= 90, // A:
			accuracy >= 85, // A.
			accuracy >= 80, // A
			accuracy >= 70, // B
			accuracy >= 60, // C
			accuracy < 60 // D
		];

		for (i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch (i)
				{
					case 0:
						ranking += " AAAAA";
					case 1:
						ranking += " AAAA:";
					case 2:
						ranking += " AAAA.";
					case 3:
						ranking += " AAAA";
					case 4:
						ranking += " AAA:";
					case 5:
						ranking += " AAA.";
					case 6:
						ranking += " AAA";
					case 7:
						ranking += " AA:";
					case 8:
						ranking += " AA.";
					case 9:
						ranking += " AA";
					case 10:
						ranking += " A:";
					case 11:
						ranking += " A.";
					case 12:
						ranking += " A";
					case 13:
						ranking += " B";
					case 14:
						ranking += " C";
					case 15:
						ranking += " D";
				}
				break;
			}
		}

		if (accuracy == 0)
		{
			ranking = LanguageStuff.getPlayState("$NA");
		}
		else if (Main.save.data.botplay)
		{
			ranking = LanguageStuff.getPlayState("$BOTPLAY_TEXT");
		}

		return ranking;
	}

	public static var timingWindows = [];

	public static function judgeNote(noteDiff:Float)
	{
		var diff = Math.abs(noteDiff);
		for (index in 0...timingWindows.length) // based on 4 timing windows, will break with anything else
		{
			var time = timingWindows[index];
			var nextTime = index + 1 > timingWindows.length - 1 ? 0 : timingWindows[index + 1];
			if (diff < time && diff >= nextTime)
			{
				switch (index)
				{
					case 0: // shit
						return "shit";
					case 1: // bad
						return "bad";
					case 2: // good
						return "good";
					case 3: // sick
						return "sick";
				}
			}
		}
		return "good";
	}

	public static function CalculateRanking(score:Int, scoreDef:Int, nps:Int, maxNPS:Int, accuracy:Float):String
	{
		if (Main.save.data.accuracyDisplay)
		{
			if (Main.save.data.npsDisplay)
			{
				return LanguageStuff.replaceFlagsAndReturn("$KADE_RATING_WITH_AC_WITH_NPC", "playState",
					["<nps>", "<maxnps>", "<score>", "<misses>", "<accuracyPers>", "<accuracyStr>"], [
						Std.string(nps),
						Std.string(maxNPS),
						(Conductor.safeFrames != 10 ? Std.string(score) + " (" + Std.string(scoreDef) + ")" : "" + Std.string(score)),
						Std.string(Data.misses),
						Std.string(CoolUtil.truncateFloat(accuracy, 2)),
						GenerateLetterRank(accuracy)
					]);
			}
			else
			{
				return LanguageStuff.replaceFlagsAndReturn("$KADE_RATING_WITH_AC_WITHOUT_NPC", "playState",
					["<score>", "<misses>", "<accuracyPers>", "<accuracyStr>"], [
						(Conductor.safeFrames != 10 ? Std.string(score) + " (" + Std.string(scoreDef) + ")" : "" + Std.string(score)),
						Std.string(Data.misses),
						Std.string(CoolUtil.truncateFloat(accuracy, 2)),
						GenerateLetterRank(accuracy)
					]);
			}
		}
		else
		{
			if (Main.save.data.npsDisplay)
			{
				return LanguageStuff.replaceFlagsAndReturn("$KADE_RATING_WITHOUT_AC_WITH_NPC", "playState", ["<nps>", "<maxnps>", "<score>"],
					[Std.string(nps), Std.string(maxNPS), Std.string(score)]);
			}
			else
			{
				return LanguageStuff.replaceFlagsAndReturn("$KADE_RATING_WITHOUT_AC_WITHOUT_NPC", "playState", ["<score>"], [Std.string(score)]);
			}
		}
	}
}
