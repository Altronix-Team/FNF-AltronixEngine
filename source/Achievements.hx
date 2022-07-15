package;

import flixel.FlxSprite;
import GameJolt.GameJoltAPI;
import GameJolt.GameJoltLogin;

class Achievements
{  
    public static function getAchievement(id:Int, imagePath:String = null)
    {
		var savedAchievements:Array<String> = FlxG.save.data.savedAchievements;

		if (!savedAchievements.contains(AchievementsState.findSaveIdById(id)))
        {
            if (imagePath == null)
				GameJoltAPI.getTrophy(id, AchievementsState.findImageById(id));
            else
				GameJoltAPI.getTrophy(id, imagePath);
			savedAchievements.push(AchievementsState.findSaveIdById(id));
			FlxG.save.data.savedAchievements = savedAchievements;
        }
    }

    public static function checkWeekAchievement(weekId:Int = 0)
    {
        switch (weekId)
        {
            case 0: 
                //Tutorial (Do nothing)
            case 1:
                getAchievement(167265, 'week1');
            case 2:
                getAchievement(167266, 'week2');
            case 3:
                getAchievement(167267, 'week3');
            case 4:
                getAchievement(167268, 'week4');
            case 5:
                getAchievement(167269, 'week5');
            case 6:
                getAchievement(167270, 'week6');
            case 7:
                getAchievement(167271, 'week7');
            default:
                Debug.logTrace('Lol, we dont have achievement for this week');         
        }
    }
}

class AchievementSprite extends FlxSprite{
	public var sprTracker:FlxSprite;

	private var tag:String;
    private var image:String;

	public function new(x:Float = 0, y:Float = 0, image:String, saveTag:String)
	{
		super(x, y);

		this.tag = saveTag;
        this.image = image;

		reloadAchievementImage();
		antialiasing = FlxG.save.data.antialiasing;
	}

	public function reloadAchievementImage()
	{
		var savedAchievements:Array<String> = FlxG.save.data.savedAchievements;

		if (savedAchievements.contains(tag))
		{
			loadGraphic(Paths.loadImage('achievements/normal/' + image));
		}
		else
		{
			loadGraphic(Paths.loadImage('achievements/normal/locked'));
		}
		scale.set(0.7, 0.7);
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		if (sprTracker != null)
			setPosition(sprTracker.x - 130, sprTracker.y - 25);

		super.update(elapsed);
	}
}