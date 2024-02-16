package funkin.stages;

import flixel.group.FlxGroup.FlxTypedGroup;

class WarzoneStage extends BaseStage{
    var steve:FlxSprite;
    var tankWatchtower:FlxSprite;
	var foregroundSprites:FlxTypedGroup<FlxSprite>;
    
    override function create(){
        camZoom = 0.9;

        var tankSky:FlxSprite = new FlxSprite(-400, -400).loadGraphic(Paths.loadImage('weeks/assets/week7/images/tankSky', 'gameplay'));
        tankSky.antialiasing = true;
        tankSky.scrollFactor.set(0, 0);
        add(tankSky);

        var tankClouds:FlxSprite = new FlxSprite(-700, -100).loadGraphic(Paths.loadImage('weeks/assets/week7/images/tankClouds', 'gameplay'));
        tankClouds.antialiasing = true;
        tankClouds.scrollFactor.set(0.1, 0.1);
        add(tankClouds);

        var tankMountains:FlxSprite = new FlxSprite(-300, -20).loadGraphic(Paths.loadImage('weeks/assets/week7/images/tankMountains', 'gameplay'));
        tankMountains.antialiasing = true;
        tankMountains.setGraphicSize(Std.int(tankMountains.width * 1.1));
        tankMountains.scrollFactor.set(0.2, 0.2);
        tankMountains.updateHitbox();
        add(tankMountains);

        var tankBuildings:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.loadImage('weeks/assets/week7/images/tankBuildings', 'gameplay'));
        tankBuildings.antialiasing = true;
        tankBuildings.setGraphicSize(Std.int(tankBuildings.width * 1.1));
        tankBuildings.scrollFactor.set(0.3, 0.3);
        tankBuildings.updateHitbox();
        add(tankBuildings);

        var tankRuins:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.loadImage('weeks/assets/week7/images/tankRuins', 'gameplay'));
        tankRuins.antialiasing = true;
        tankRuins.setGraphicSize(Std.int(tankRuins.width * 1.1));
        tankRuins.scrollFactor.set(0.35, 0.35);
        tankRuins.updateHitbox();
        add(tankRuins);

        var smokeLeft:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('weeks/assets/week7/images/smokeLeft', 'gameplay'));
        smokeLeft.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/smokeLeft', 'gameplay');
        smokeLeft.animation.addByPrefix('idle', 'SmokeBlurLeft', 24, true);
        smokeLeft.animation.play('idle');
        smokeLeft.scrollFactor.set(0.4, 0.4);
        smokeLeft.antialiasing = true;
        add(smokeLeft);

        var smokeRight:FlxSprite = new FlxSprite(1100, -100).loadGraphic(Paths.loadImage('weeks/assets/week7/images/smokeRight', 'gameplay'));
        smokeRight.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/smokeRight', 'gameplay');
        smokeRight.animation.addByPrefix('idle', 'SmokeRight', 24, true);
        smokeRight.animation.play('idle');
        smokeRight.scrollFactor.set(0.4, 0.4);
        smokeRight.antialiasing = true;
        add(smokeRight);

        tankWatchtower = new FlxSprite(100, 50);
        tankWatchtower.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tankWatchtower', 'gameplay');
        tankWatchtower.animation.addByPrefix('idle', 'watchtower gradient color', 24, false);
        tankWatchtower.animation.play('idle');
        tankWatchtower.scrollFactor.set(0.5, 0.5);
        tankWatchtower.antialiasing = true;
        add(tankWatchtower);

        steve = new FlxSprite(300, 300);
        steve.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tankRolling', 'gameplay');
        steve.animation.addByPrefix('idle', "BG tank w lighting", 24, true);
        steve.animation.play('idle', true);
        steve.antialiasing = true;
        steve.scrollFactor.set(0.5, 0.5);
        add(steve);

        var tankmanRun:FlxTypedGroup<funkin.gameplayStuff.TankmenBG> = new FlxTypedGroup<funkin.gameplayStuff.TankmenBG>();
        if (Main.save.data.distractions)
        {
            add(tankmanRun);
        }

        var tankGround:FlxSprite = new FlxSprite(-420, -150).loadGraphic(Paths.loadImage('weeks/assets/week7/images/tankGround', 'gameplay'));
        tankGround.setGraphicSize(Std.int(tankGround.width * 1.15));
        tankGround.updateHitbox();
        tankGround.antialiasing = true;
        add(tankGround);

        foregroundSprites = new FlxTypedGroup<FlxSprite>();

        var tank0 = new FlxSprite(-500, 650);
        tank0.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tank0', 'gameplay');
        tank0.animation.addByPrefix('idle', 'fg tankhead far right', 24, false);
        tank0.scrollFactor.set(1.7, 1.5);
        tank0.antialiasing = true;
        foregroundSprites.add(tank0);

        var tank1 = new FlxSprite(-300, 750);
        tank1.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tank1', 'gameplay');
        tank1.animation.addByPrefix('idle', 'fg tankhead 5 instance 1', 24, false);
        tank1.scrollFactor.set(2, 0.2);
        tank1.antialiasing = true;
        foregroundSprites.add(tank1);

        var tank2 = new FlxSprite(450, 940);
        tank2.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tank2', 'gameplay');
        tank2.animation.addByPrefix('idle', 'foreground man 3 instance 1', 24, false);
        tank2.scrollFactor.set(1.5, 1.5);
        tank2.antialiasing = true;
        foregroundSprites.add(tank2);

        var tank4 = new FlxSprite(1300, 900);
        tank4.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tank4', 'gameplay');
        tank4.animation.addByPrefix('idle', 'fg tankman bobbin 3 instance 1', 24, false);
        tank4.scrollFactor.set(1.5, 1.5);
        tank4.antialiasing = true;
        foregroundSprites.add(tank4);

        var tank5 = new FlxSprite(1620, 700);
        tank5.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tank5', 'gameplay');
        tank5.animation.addByPrefix('idle', 'fg tankhead far right instance 1', 24, false);
        tank5.scrollFactor.set(1.5, 1.5);
        tank5.antialiasing = true;
        foregroundSprites.add(tank5);

        var tank3 = new FlxSprite(1300, 1200);
        tank3.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tank3', 'gameplay');
        tank3.animation.addByPrefix('idle', 'fg tankhead 4 instance 1', 24, false);
        tank3.scrollFactor.set(1.5, 1.5);
        tank3.antialiasing = true;
        foregroundSprites.add(tank3);

        add(gfGroup);
        add(dadGroup);
        add(boyfriendGroup);

        if (Main.save.data.distractions)
        {
            add(foregroundSprites);
        }

        if (Data.SONG != null)
        {
            if (Data.SONG.gfVersion == 'picospeaker')
            {
                var firstTank:funkin.gameplayStuff.TankmenBG = new funkin.gameplayStuff.TankmenBG(20, 500, true);
                firstTank.resetShit(20, 600, true);
                firstTank.strumTime = 10;
                tankmanRun.add(firstTank);

                for (i in 0...funkin.gameplayStuff.TankmenBG.animationNotes.length)
                {
                    if (FlxG.random.bool(16))
                    {
                        var tankBih = tankmanRun.recycle(funkin.gameplayStuff.TankmenBG);
                        tankBih.strumTime = funkin.gameplayStuff.TankmenBG.animationNotes[i][0];
                        tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), funkin.gameplayStuff.TankmenBG.animationNotes[i][1] < 2);
                        tankmanRun.add(tankBih);
                    }
                }
            }
        }
    }

    override function update(elapsed:Float){
        moveTank(elapsed);
    }

    override function beatHit(){
        if (curBeat % 2 == 0)
        {
            tankWatchtower.animation.play('idle', true);
            foregroundSprites.forEach(function(spr:FlxSprite){
                spr.animation.play('idle', true);
            });
        }
    }

    var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX = 400;

	function moveTank(?elapsed:Float = 0)
	{
		if (!Data.inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			steve.angle = tankAngle - 90 + 15;
			steve.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			steve.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}
}