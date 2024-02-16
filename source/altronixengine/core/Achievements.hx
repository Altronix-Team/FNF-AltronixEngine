package altronixengine.core;

import flixel.FlxSprite;
import altronixengine.states.AchievementsState;

// TODO Custom achievements
typedef AchievementData =
{
	var displayedName:String;
	var displayedDescription:String;
	var saveId:String;
	var isHidden:Bool;
	var imageName:String;
	var ?isCustom:Bool; // Need to know is achievement custom or not. Only for usage in source code
}

class Achievements
{
	public static function getWeekSaveId(weekId:Int):String
	{
		if (weekId >= 1 && weekId <= 7)
			return 'week${weekId}_nomiss';
		return 'null';
	}

	public static function checkWeekAchievement(weekId:Int = 0)
	{
		if (weekId > 0 && weekId <= 7)
			getAchievement(getWeekSaveId(weekId), 'week${weekId}');
	}

	public static function findDescById(id:String):String
	{
		for (achievement in achievementsArray)
		{
			if (achievement.saveId == id)
				return achievement.displayedDescription;
			else
				continue;
		}
		return 'Unidentified achievement';
	}

	public static function findNameById(id:String):String
	{
		for (achievement in achievementsArray)
		{
			if (achievement.saveId == id)
				return achievement.displayedName;
			else
				continue;
		}
		return 'Unidentified achievement';
	}

	public static function findSaveIdById(id:String):String
	{
		for (achievement in achievementsArray)
		{
			if (achievement.saveId == id)
				return achievement.saveId;
			else
				continue;
		}
		return 'null';
	}

	public static function findImageById(id:String):String
	{
		for (achievement in achievementsArray)
		{
			if (achievement.saveId == id)
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

	public static function getAchievement(id:String, imagePath:String = null)
	{
		var savedAchievements:Array<String> = Main.save.data.savedAchievements;

		if (!savedAchievements.contains(findSaveIdById(id)))
		{
			savedAchievements.push(findSaveIdById(id));
			Main.save.data.savedAchievements = savedAchievements;
		}
	}

	public static function listAllAchievements()
	{
		achievementsArray = [];
		Debug.logInfo('Loading engine achievements!');
		achievementsArray = EngineConstants.defaultAchievementsArray.copy();

		Debug.logInfo('Loading custom achievements!');
		var customAchArray = AssetsUtil.listAssetsInPath('assets/custom_achievements', JSON);

		if (customAchArray.length > 0)
			for (achievement in customAchArray)
			{
				var achievementInfo:AchievementData = cast AssetsUtil.loadAsset(achievement, JSON, 'custom_achievements');
				achievementInfo.isCustom = true;
				achievementsArray.push(achievementInfo);
			}
	}

	public static var achievementsArray:Array<AchievementData> = [];
}

class AchievementSprite extends FlxSprite
{
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
			loadGraphic(AssetsUtil.loadAsset('achievements/normal/' + image, IMAGE));
		}
		else
		{
			loadGraphic(AssetsUtil.loadAsset('achievements/normal/locked', IMAGE));
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
