package funkin.stages;

class MallEvilStage extends BaseStage
{
	override function create()
	{
		var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.loadImage('weeks/assets/week5/images/christmas/evilBG', 'gameplay'));
		bg.antialiasing = Main.save.data.antialiasing;
		bg.scrollFactor.set(0.2, 0.2);
		bg.active = false;
		bg.setGraphicSize(Std.int(bg.width * 0.8));
		bg.updateHitbox();
		add(bg);

		var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.loadImage('weeks/assets/week5/images/christmas/evilTree', 'gameplay'));
		evilTree.antialiasing = Main.save.data.antialiasing;
		evilTree.scrollFactor.set(0.2, 0.2);
		add(evilTree);

		var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.loadImage("weeks/assets/week5/images/christmas/evilSnow", 'gameplay'));
		evilSnow.antialiasing = Main.save.data.antialiasing;
		add(evilSnow);

		add(gfGroup);
		add(dadGroup);
		add(boyfriendGroup);
	}
}
