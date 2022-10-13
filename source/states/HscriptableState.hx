package states;

import scriptStuff.ScriptHelper;
import flixel.FlxG;

class ScriptedSubstate extends MusicBeatSubstate
{
	public static var stateName:Null<String>;
	public static var instance:ScriptedSubstate;

	override function create()
	{
		instance = this;

		ScriptHelper.callOnScripts('substateCreate', []);
		ScriptHelper.setOnScripts('close', close);

		super.create();
		ScriptHelper.callOnScripts('substatePostCreate', []);
	}

	public function new(stateName:Null<String>)
	{
		ScriptedSubstate.stateName = stateName;
		ScriptHelper.callOnScripts('newSubstate', [stateName]);
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		ScriptHelper.callOnScripts('substateUpdate', [stateName, elapsed]);
		super.update(elapsed);
		ScriptHelper.callOnScripts('substatePostUpdate', [stateName, elapsed]);
	}

	override function destroy()
	{
		ScriptHelper.callOnScripts('substateDestroy', [stateName]);
		super.destroy();
	}
}

class ScriptedState extends MusicBeatState
{
	public static var stateName:Null<String>;
	public static var instance:ScriptedState;

	override function create()
	{
		instance = this;

		ScriptHelper.callOnScripts('stateCreate', []);

		super.create();
		ScriptHelper.callOnScripts('statePostCreate', []);
	}

	public function new(stateName:Null<String>)
	{
		ScriptedSubstate.stateName = stateName;
		ScriptHelper.callOnScripts('newState', [stateName]);
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		ScriptHelper.callOnScripts('stateUpdate', [stateName, elapsed]);
		super.update(elapsed);
		ScriptHelper.callOnScripts('statePostUpdate', [stateName, elapsed]);
	}

	override function destroy()
	{
		ScriptHelper.callOnScripts('stateDestroy', [stateName]);
		super.destroy();
	}
}