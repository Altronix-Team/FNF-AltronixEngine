package funkin.stages;

import altronixengine.shaders.Shaders.BuildingShaders;
import altronixengine.states.GameplayCustomizeState;
import flixel.util.FlxColor;
import flixel.sound.FlxSound;
import altronixengine.gameplayStuff.Conductor;

class PhillyStage extends BaseStage{
    var windowsShader:BuildingShaders;
    var light:FlxSprite;
    var phillyTrain:FlxSprite;
    
    override function create() {
        var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.loadImage('weeks/assets/week3/images/philly/sky', 'gameplay'));
        bg.scrollFactor.set(0.1, 0.1);
        bg.antialiasing = Main.save.data.antialiasing;
        add(bg);

        var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.loadImage('weeks/assets/week3/images/philly/city', 'gameplay'));
        city.scrollFactor.set(0.3, 0.3);
        city.setGraphicSize(Std.int(city.width * 0.85));
        city.updateHitbox();
        city.antialiasing = Main.save.data.antialiasing;
        add(city);

        windowsShader = new BuildingShaders();

        light = new FlxSprite(city.x).loadGraphic(Paths.loadImage('weeks/assets/week3/images/philly/window', 'gameplay'));
        light.scrollFactor.set(0.3, 0.3);
        light.setGraphicSize(Std.int(light.width * 0.85));
        light.updateHitbox();
        light.antialiasing = Main.save.data.antialiasing;
        light.shader = windowsShader.shader;
        randomColor();
        light.color = windowColor;
        add(light);
        // phillyCityLights.add(light);
        // }

        var streetBehind:FlxSprite = new FlxSprite(-40,
            50).loadGraphic(Paths.loadImage('weeks/assets/week3/images/philly/behindTrain', 'gameplay'));
        streetBehind.antialiasing = Main.save.data.antialiasing;
        add(streetBehind);

        phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.loadImage('weeks/assets/week3/images/philly/train', 'gameplay'));
        phillyTrain.antialiasing = Main.save.data.antialiasing;
        if (Main.save.data.distractions)
        {
            add(phillyTrain);
        }

        trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
        FlxG.sound.list.add(trainSound);

        // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

        var street:FlxSprite = new FlxSprite(-40,
            streetBehind.y).loadGraphic(Paths.loadImage('weeks/assets/week3/images/philly/street', 'gameplay'));
        street.antialiasing = Main.save.data.antialiasing;
        add(street);

        add(gfGroup);
        add(dadGroup);
        add(boyfriendGroup);
    } 

    override function update(elapsed:Float) {
        super.update(elapsed);

        windowsShader.update((Conductor.crochet / 1000) * FlxG.elapsed * 1.5);

        if (trainMoving)
        {
            trainFrameTiming += elapsed;

            if (trainFrameTiming >= 1 / 24)
            {
                updateTrainPos();
                trainFrameTiming = 0;
            }
        }
    } 

    override function beatHit() {
        super.beatHit();

        if (Main.save.data.distractions)
        {
            if (!trainMoving)
                trainCooldown += 1;

            if (curBeat % 4 == 0)
            {
                var phillyCityLight:FlxSprite = light;

                randomColor();

                phillyCityLight.color = windowColor;

                windowsShader.reset();
            }
        }

        if (curBeat % 8 == 4 && FlxG.random.bool(Conductor.bpm > 320 ? 150 : 30) && !trainMoving && trainCooldown > 8)
        {
            if (Main.save.data.distractions)
            {
                trainCooldown = FlxG.random.int(-4, 0);
                trainStart();
            }
        }
    }
	public var windowColor:FlxColor = FlxColor.WHITE;

	function randomColor()
	{
		windowColor = FlxG.random.color(null, null, 255);
	}

    var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (Main.save.data.distractions)
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;

				if (Data.SONG != null)
				{
					if (gf != null)
                        gf.playAnim('hairBlow');
					else
						GameplayCustomizeState.gf.playAnim('hairBlow');
				}
			}

			if (startedMoving)
			{
				var phillyTrain = phillyTrain;
				phillyTrain.x -= 400;

				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;

					if (trainCars <= 0)
						trainFinishing = true;
				}

				if (phillyTrain.x < -4000 && trainFinishing){
                    trainReset();
                }			
			}
		}
	}

	function trainReset():Void
	{
		if (Main.save.data.distractions)
		{
			if (Data.SONG != null)
			{
				if (gf != null){
                    @:privateAccess()
                    gf.danced = false;
                    gf.playAnim('hairFall');
                    gf.specialAnim = true;
                }		
				else
					GameplayCustomizeState.gf.playAnim('hairFall');
			}

			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

    var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var trainSound:FlxSound;

	function trainStart():Void
	{
		if (Main.save.data.distractions)
		{
			trainMoving = true;
			trainSound.play(true);
		}
	}
}