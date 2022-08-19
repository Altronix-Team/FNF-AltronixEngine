package scriptStuff;

import states.PlayState;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import polymod.hscript.HScriptable;
import flixel.FlxG;
import gameplayStuff.Character;
import gameplayStuff.Boyfriend;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

class PolymodHscriptStageHandler extends FlxTypedGroup<FlxBasic> //I wish it could work at some time
{
	public var gf:Character = null;
	public var dad:Character = null;
	public var boyfriend:Boyfriend = null;

	public var gfGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var boyfriendGroup:FlxSpriteGroup;

	public var addedCharacters:Array<Character> = [];
	public var addedCharacterGroups:Array<FlxSpriteGroup> = [];

	public function new(id:String)
	{
		super();

		gf = PlayState.instance.gf;
		dad = PlayState.instance.dad;
		boyfriend = PlayState.instance.boyfriend;

		gfGroup = PlayState.instance.gfGroup;
		dadGroup = PlayState.instance.dadGroup;
		boyfriendGroup = PlayState.instance.boyfriendGroup;
	}

	override public function update(elapsed:Float)
	{
		if (gf != PlayState.instance.gf)
			gf = PlayState.instance.gf;

		if (dad != PlayState.instance.dad)
			dad = PlayState.instance.dad;

		if (boyfriend != PlayState.instance.boyfriend)
			boyfriend = PlayState.instance.boyfriend;

		if (gfGroup != PlayState.instance.gfGroup)
			gfGroup = PlayState.instance.gfGroup;

		if (dadGroup != PlayState.instance.dadGroup)
			dadGroup = PlayState.instance.dadGroup;

		if (boyfriendGroup != PlayState.instance.boyfriendGroup)
			boyfriendGroup = PlayState.instance.boyfriendGroup;
	}

	public function addGf()
	{
		add(gf);
		addedCharacters.push(gf);
	}

	public function addDad()
	{
		add(dad);
		addedCharacters.push(dad);
	}

	public function addBoyfriend()
	{
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
}