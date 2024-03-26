package funkin.stages;

class MallStage extends BaseStage
{
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	override function create()
	{
		camZoom = 0.80;

		var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.loadImage('weeks/assets/week5/images/christmas/bgWalls', 'gameplay'));
		bg.antialiasing = Main.save.data.antialiasing;
		bg.scrollFactor.set(0.2, 0.2);
		bg.active = false;
		bg.setGraphicSize(Std.int(bg.width * 0.8));
		bg.updateHitbox();
		add(bg);

		upperBoppers = new FlxSprite(-240, -90);
		upperBoppers.frames = Paths.getSparrowAtlas('weeks/assets/week5/images/christmas/upperBop', 'gameplay');
		upperBoppers.animation.addByPrefix('idle', "Upper Crowd Bob", 24, false);
		upperBoppers.antialiasing = Main.save.data.antialiasing;
		upperBoppers.scrollFactor.set(0.33, 0.33);
		upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		upperBoppers.updateHitbox();
		if (Main.save.data.distractions)
		{
			add(upperBoppers);
		}

		var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.loadImage('weeks/assets/week5/images/christmas/bgEscalator', 'gameplay'));
		bgEscalator.antialiasing = Main.save.data.antialiasing;
		bgEscalator.scrollFactor.set(0.3, 0.3);
		bgEscalator.active = false;
		bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		bgEscalator.updateHitbox();
		add(bgEscalator);

		var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.loadImage('weeks/assets/week5/images/christmas/christmasTree', 'gameplay'));
		tree.antialiasing = Main.save.data.antialiasing;
		tree.scrollFactor.set(0.40, 0.40);
		add(tree);

		bottomBoppers = new FlxSprite(-300, 140);
		bottomBoppers.frames = Paths.getSparrowAtlas('weeks/assets/week5/images/christmas/bottomBop', 'gameplay');
		bottomBoppers.animation.addByPrefix('idle', 'Bottom Level Boppers', 24, false);
		bottomBoppers.antialiasing = Main.save.data.antialiasing;
		bottomBoppers.scrollFactor.set(0.9, 0.9);
		bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		bottomBoppers.updateHitbox();
		if (Main.save.data.distractions)
		{
			add(bottomBoppers);
		}

		var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.loadImage('weeks/assets/week5/images/christmas/fgSnow', 'gameplay'));
		fgSnow.active = false;
		fgSnow.antialiasing = Main.save.data.antialiasing;
		add(fgSnow);

		santa = new FlxSprite(-840, 150);
		santa.frames = Paths.getSparrowAtlas('weeks/assets/week5/images/christmas/santa', 'gameplay');
		santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		santa.antialiasing = Main.save.data.antialiasing;
		if (Main.save.data.distractions)
		{
			add(santa);
		}

		add(gfGroup);
		add(dadGroup);
		add(boyfriendGroup);
	}

	override function beatHit()
	{
		super.beatHit();

		santa.animation.play('idle', true);
		bottomBoppers.animation.play('idle', true);
		upperBoppers.animation.play('idle', true);
	}
}
