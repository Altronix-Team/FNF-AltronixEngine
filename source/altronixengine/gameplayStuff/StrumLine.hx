package altronixengine.gameplayStuff;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import altronixengine.states.playState.PlayState;
import altronixengine.states.playState.GameData as Data;

// Simple class to work with strum line and note splashes
class StrumLine extends FlxTypedGroup<StaticArrow>
{
	public var grpNoteSplashes:SplashGroup;

	public var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public var opponentStrums:FlxTypedGroup<StaticArrow> = null;

	public var useMiddlescroll(default, set):Bool = false;

	public function new()
	{
		super();

		playerStrums = new FlxTypedGroup<StaticArrow>();
		opponentStrums = new FlxTypedGroup<StaticArrow>();

		generateStrumLineArrows();

		PlayState.instance.add(this);

		if (Main.save.data.notesplashes)
			setupNoteSplashes();
	}

	public function setupNoteSplashes()
	{
		grpNoteSplashes = new SplashGroup();
		PlayState.instance.add(grpNoteSplashes);
		grpNoteSplashes.cameras = [PlayState.instance.camHUD];
	}

	override public function clear()
	{
		super.clear();

		playerStrums.clear();
		opponentStrums.clear();
	}

	public function generateStrumLineArrows(tweenShit:Bool = true)
	{
		for (player in 0...2)
		{
			var index = 0;
			for (i in 0...4)
			{
				var babyArrow:StaticArrow = new StaticArrow(-10, PlayState.instance.strumLine.y);
				babyArrow.noteData = i;
				babyArrow.texture = Data.noteskinTexture;

				if (PlayStateChangeables.Optimize && player == 0)
					continue;

				babyArrow.updateHitbox();
				babyArrow.scrollFactor.set();

				if (tweenShit)
					babyArrow.alpha = 0;

				if (!Data.isStoryMode)
				{
					babyArrow.y -= 10;
					// babyArrow.alpha = 0;
					if (tweenShit)
						if (!PlayStateChangeables.useMiddlescroll || player == 1)
							FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				}

				babyArrow.ID = i;

				switch (player)
				{
					case 0:
						babyArrow.x += 20;
						opponentStrums.add(babyArrow);
					case 1:
						playerStrums.add(babyArrow);
				}

				babyArrow.playAnim('static');
				babyArrow.x += 110;
				babyArrow.x += ((FlxG.width / 2) * player);

				if (PlayStateChangeables.Optimize || (PlayStateChangeables.useMiddlescroll && player == 1))
					babyArrow.x -= 320;
				else if (PlayStateChangeables.Optimize || (PlayStateChangeables.useMiddlescroll && player == 0))
				{
					if (index < 2)
						babyArrow.x -= 75;
					else
						babyArrow.x += FlxG.width / 2 + 25;

					index++;
				}

				opponentStrums.forEach(function(spr:StaticArrow)
				{
					spr.centerOffsets(); // CPU arrows start out slightly off-center
				});

				add(babyArrow);
			}
		}
	}

	public function tweenArrowsY(yPos:Int)
	{
		forEach(function(note:StaticArrow)
		{
			FlxTween.tween(note, {y: yPos}, 0.5);
		});
	}

	public function toggleMiddlescroll()
	{
		if (useMiddlescroll)
		{
			playerStrums.forEach(function(note:StaticArrow)
			{
				FlxTween.tween(note, {x: note.x - 320}, 0.5);
			});
			for (index in 0...opponentStrums.members.length)
			{
				if (opponentStrums.members[index] != null)
				{
					if (index < 2)
						FlxTween.tween(opponentStrums.members[index], {x: opponentStrums.members[index].x - 75}, 0.5);
					else
						FlxTween.tween(opponentStrums.members[index], {x: opponentStrums.members[index].x + FlxG.width / 2 + 25}, 0.5);
					FlxTween.tween(opponentStrums.members[index], {alpha: 0.5}, 0.5);
				}
			}
		}
		else
		{
			playerStrums.forEach(function(note:StaticArrow)
			{
				FlxTween.tween(note, {x: -10 + 110 + ((FlxG.width / 2) * 1) + Note.swagWidth * note.noteData}, 0.5);
			});
			opponentStrums.forEach(function(note:StaticArrow)
			{
				FlxTween.tween(note, {x: -10 + 20 + 110 + Note.swagWidth * note.noteData}, 0.5);
				FlxTween.tween(note, {alpha: 1}, 0.5);
			});
		}
	}

	public function spawnNoteSplashOnNote(note:Note)
	{
		if (Main.save.data.notesplashes && note != null)
		{
			if (note.sprTracker != null)
			{
				grpNoteSplashes.spawnNoteSplash(note.sprTracker.x, note.sprTracker.y, note);
			}
		}
	}

	function set_useMiddlescroll(value:Bool):Bool
	{
		useMiddlescroll = value;
		toggleMiddlescroll();
		return value;
	}
}

class SplashGroup extends FlxTypedGroup<NoteSplash>
{
	public function new()
	{
		super();

		var splash:NoteSplash = new NoteSplash(100, 100);
		splash.scrollFactor.set();
		add(splash);
	}

	public function spawnNoteSplash(x:Float, y:Float, note:Note)
	{
		var splash:NoteSplash = recycle(NoteSplash);
		splash.setupNoteSplash(x, y, note);
		add(splash);
	}
}
