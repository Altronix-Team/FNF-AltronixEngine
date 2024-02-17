package funkin.stages;

import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;

class LimoStage extends BaseStage
{
	var grpLimoDancers:FlxTypedGroup<funkin.gameplayStuff.BackgroundDancer>;
	var fastCar:FlxSprite;

	override function create()
	{
		camZoom = 0.90;

		var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.loadImage('weeks/assets/week4/images/limo/limoSunset', 'gameplay'));
		skyBG.scrollFactor.set(0.1, 0.1);
		skyBG.antialiasing = Main.save.data.antialiasing;
		add(skyBG);

		var bgLimo:FlxSprite = new FlxSprite(-200, 480);
		bgLimo.frames = Paths.getSparrowAtlas('weeks/assets/week4/images/limo/bgLimo', 'gameplay');
		bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		bgLimo.animation.play('drive');
		bgLimo.scrollFactor.set(0.4, 0.4);
		bgLimo.antialiasing = Main.save.data.antialiasing;
		add(bgLimo);

		fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.loadImage('weeks/assets/week4/images/limo/fastCarLol', 'gameplay'));
		fastCar.antialiasing = Main.save.data.antialiasing;
		fastCar.visible = false;

		if (Main.save.data.distractions)
		{
			grpLimoDancers = new FlxTypedGroup<funkin.gameplayStuff.BackgroundDancer>();
			add(grpLimoDancers);

			for (i in 0...5)
			{
				var dancer:funkin.gameplayStuff.BackgroundDancer = new funkin.gameplayStuff.BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
				dancer.scrollFactor.set(0.4, 0.4);
				grpLimoDancers.add(dancer);
			}
			resetFastCar();
		}

		var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.loadImage('weeks/assets/week4/images/limo/limoOverlay', 'gameplay'));
		overlayShit.alpha = 0.5;

		var limoTex = Paths.getSparrowAtlas('weeks/assets/week4/images/limo/limoDrive', 'gameplay');

		add(gfGroup);

		var limo = new FlxSprite(-120, 550);
		limo.frames = limoTex;
		limo.animation.addByPrefix('drive', "Limo stage", 24);
		limo.animation.play('drive');
		limo.antialiasing = Main.save.data.antialiasing;
		add(limo);

		add(dadGroup);
		add(boyfriendGroup);

		add(fastCar);
	}

	override function beatHit()
	{
		if (Main.save.data.distractions)
		{
			grpLimoDancers.forEach(function(dancer:funkin.gameplayStuff.BackgroundDancer)
			{
				dancer.dance();
			});

			if (FlxG.random.bool(10) && fastCarCanDrive)
				fastCarDrive();
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if (Main.save.data.distractions)
		{
			var fastCar = fastCar;
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCar.visible = false;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if (Main.save.data.distractions)
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1, 'core'), 0.7);

			fastCar.visible = true;
			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}
}
