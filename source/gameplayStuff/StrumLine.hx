package gameplayStuff;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import states.PlayState;
import flixel.group.FlxGroup.FlxTypedGroup;

//Simple class to work with strum line and note splashes
class StrumLine extends FlxTypedGroup<StaticArrow>
{
	public var grpNoteSplashes:SplashGroup;

    public var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public var opponentStrums:FlxTypedGroup<StaticArrow> = null;

    public function new()
    {
		super();

		playerStrums = new FlxTypedGroup<StaticArrow>();
		opponentStrums = new FlxTypedGroup<StaticArrow>();    
              
		generateStrumLineArrows();		
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
                babyArrow.texture = PlayState.noteskinTexture;

                if (PlayStateChangeables.Optimize && player == 0)
                    continue;
                
                babyArrow.updateHitbox();
                babyArrow.scrollFactor.set();

                if (tweenShit)
                    babyArrow.alpha = 0;
                
                if (!PlayState.isStoryMode)
                {
                    babyArrow.y -= 10;
                    // babyArrow.alpha = 0;
                    if (tweenShit)
                        if (!PlayStateChangeables.useMiddlescroll || PlayState.instance.executeModchart || player == 1)
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

                if (PlayStateChangeables.Optimize
                    || (PlayStateChangeables.useMiddlescroll && !PlayState.instance.executeModchart && player == 1))
                    babyArrow.x -= 320;
                else if (PlayStateChangeables.Optimize
                    || (PlayStateChangeables.useMiddlescroll && !PlayState.instance.executeModchart && player == 0))
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

    public function spawnNoteSplashOnNote(note:Note) {
		if(FlxG.save.data.notesplashes && note != null) {
			if (note.sprTracker != null) {
				grpNoteSplashes.spawnNoteSplash(note.sprTracker.x, note.sprTracker.y, note.noteData, note);
			}
		}
        else
        {
            Debug.logTrace('Trying to spawn note splash, but they`re disabled in engine settings');
            return;
        }
	}
}

class SplashGroup extends FlxTypedGroup<NoteSplash>
{
    public function new()
    {
        super();

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		splash.scrollFactor.set();
		add(splash);
    }

    public function spawnNoteSplash(x:Float, y:Float, data:Int, note:Note) {
		var type:String = note.noteType;

		var splash:NoteSplash = recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, type);
		add(splash);
	}
}