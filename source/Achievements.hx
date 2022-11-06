package;

import flixel.FlxSprite;
#if desktop
import GameJolt.GameJoltAPI;
#end
import states.AchievementsState;

//TODO Custom achievements
typedef AchievementData = {
	var displayedName:String;
	var displayedDescription:String;
	var saveId:String;
	var ?GJId:Int; //Not usable for custom achievements
	var isHidden:Bool;
	var imageName:String;
	var ?isCustom:Bool; //Need to know is achievement custom or not. Only for usage in source code
}

class Achievements
{  
	public static function getWeekSaveId(weekid:Int):String
	{
		switch (weekid)
		{
			case 1:
				return 'week1_nomiss';
			case 2:
				return 'week2_nomiss';
			case 3:
				return 'week3_nomiss';
			case 4:
				return 'week4_nomiss';
			case 5:
				return 'week5_nomiss';
			case 6:
				return 'week6_nomiss';
			case 7:
				return 'week7_nomiss';
			default:
				return 'null';
		}
	}

	public static function findDescById(id:Int):String
	{
		for (achievement in achievementsArray)
		{
			if (achievement.GJId == id)
				return achievement.displayedDescription;
			else
				continue;
		}
		return 'Unidentified achievement';
	}

	public static function findNameById(id:Int):String
	{
		for (achievement in achievementsArray)
		{
			if (achievement.GJId == id)
				return achievement.displayedName;
			else
				continue;
		}
		return 'Unidentified achievement';
	}

	public static function findSaveIdById(id:Int):String
	{
		for (achievement in achievementsArray)
		{
			if (achievement.GJId == id)
				return achievement.saveId;
			else
				continue;
		}
		return 'null';
	}

	public static function findImageById(id:Int):String
	{
		for (achievement in achievementsArray)
		{
			if (achievement.GJId == id)
				return achievement.imageName;
			else
				continue;
		}
		return 'pattern';
	}

	public static function getSaveTagByName(name:String):String
	{
		for (achievement in achievementsArray)
		{
			if (achievement.displayedName == name)
				return achievement.saveId;
			else
				continue;
		}
		return 'null';
	}

	public static function getDescByName(name:String):String
	{
		for (achievement in achievementsArray)
		{
			if (achievement.displayedName == name)
				return achievement.displayedDescription;
			else
				continue;
		}
		return 'Unidentified achievement';
	}

	public static function getImageByName(name:String):String
	{
		for (achievement in achievementsArray)
		{
			if (achievement.displayedName == name)
				return achievement.imageName;
			else
				continue;
		}
		return 'Unidentified achievement';
	}

    public static function getAchievement(id:Int, imagePath:String = null)
    {
		var savedAchievements:Array<String> = Main.save.data.savedAchievements;

		if (!savedAchievements.contains(findSaveIdById(id)))
        {
			#if desktop
            if (imagePath == null)
				GameJoltAPI.getTrophy(id, findImageById(id));
            else
				GameJoltAPI.getTrophy(id, imagePath);
			#end
			savedAchievements.push(findSaveIdById(id));
			Main.save.data.savedAchievements = savedAchievements;
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

	public static function listAllAchievements() {
		achievementsArray = [];
		Debug.logInfo('Loading engine achievements!');
		achievementsArray = EngineConstants.defaultAchievementsArray.copy();

		Debug.logInfo('Loading custom achievements!');
		var customAchArray = Paths.listJsonInPath('assets/custom_achievements');

		if (customAchArray.length > 0)
			for (achievement in customAchArray)
			{
				var achievementInfo:AchievementData = cast Paths.loadJSON(achievement, 'custom_achievements');
				achievementInfo.isCustom = true;
				achievementsArray.push(achievementInfo);
			}
	}

	public static var achievementsArray:Array<AchievementData> = [];
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
		antialiasing = Main.save.data.antialiasing;
	}

	public function reloadAchievementImage()
	{
		var savedAchievements:Array<String> = Main.save.data.savedAchievements;

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