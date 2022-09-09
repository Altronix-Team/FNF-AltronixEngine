package scriptStuff;

import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import Paths;
import scriptStuff.ScriptHelper;
import states.PlayState;
import gameplayStuff.Character;
import gameplayStuff.Boyfriend;

class HscriptStage extends ModchartHelper
{
	var state:PlayState;

	public var gf:Character = null;
	public var dad:Character = null;
	public var boyfriend:Boyfriend = null;

	public var gfGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var boyfriendGroup:FlxSpriteGroup;

	public var addedCharacters:Array<Character> = [];
	public var addedCharacterGroups:Array<FlxSpriteGroup> = [];

	public var objectsMap:Map<String, FlxBasic> = new Map<String, FlxBasic>();
	public var objectsArray:Array<FlxBasic> = [];

	public function new(path:String, state:PlayState)
	{
		scriptHelper = new ScriptHelper();

		gf = state.gf;
		dad = state.dad;
		boyfriend = state.boyfriend;

		gfGroup = state.gfGroup;
		dadGroup = state.gfGroup;
		boyfriendGroup = state.boyfriendGroup;
		
		scriptHelper.expose.set("stage", this);
		scriptHelper.expose.set("gf", gf);
		scriptHelper.expose.set("dad", dad);
		scriptHelper.expose.set("boyfriend", boyfriend);
		scriptHelper.expose.set("addGf", addGf);
		scriptHelper.expose.set("addDad", addDad);
		scriptHelper.expose.set("addBoyfriend", addBoyfriend);
		scriptHelper.expose.set("addGfGroup", addGfGroup);
		scriptHelper.expose.set("addDadGroup", addDadGroup);
		scriptHelper.expose.set("addBoyfriendGroup", addBoyfriendGroup);
		scriptHelper.expose.set("addObject", addObject);
		scriptHelper.expose.set("getObject", getObject);

		this.state = state;
		super(path, state);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	override public function add(object:FlxBasic):FlxBasic {
		if (!objectsArray.contains(object))
			Debug.logWarn('Use addObject(object, objectName) instead of add');

		super.add(object);
		return object;
	}

	public function addObject(object:FlxBasic, objectName:String) {
		if (object != null)
		{
			if (objectName != null)
				objectsMap.set(objectName, object);
			objectsArray.push(object);
			this.add(object);
		}
		else
		{
			Debug.logError('Failed to add object to stage');
		} 	
	}

	public function getObject(objectName:String):FlxBasic
	{
		if (objectName != null)
		{
			return objectsMap.get(objectName);
		}
		else
		{
			Debug.logError('Failed to get object from stage');
			return null;
		}
	}

	public function addGf() {
		add(gf);
		addedCharacters.push(gf);
	}

	public function addDad(){
		add(dad);
		addedCharacters.push(dad);
	}

	public function addBoyfriend(){
		add(boyfriend);
		addedCharacters.push(boyfriend);
	}

	public function addGfGroup()
	{
		add(gfGroup);
		addedCharacterGroups.push(gfGroup);
	}

	public function addDadGroup()
	{
		add(dadGroup);
		addedCharacterGroups.push(dadGroup);
	}

	public function addBoyfriendGroup()
	{
		add(boyfriendGroup);
		addedCharacterGroups.push(boyfriendGroup);
	}

	public function getCharacterByIndex(whose:Int):gameplayStuff.Character
	{
		switch (whose)
		{
			case 0:
				return state.dad;
			case 1:
				return state.boyfriend;
			case 2:
				return state.gf;
			default:
				return null;
		}
		return null;
	}
}
