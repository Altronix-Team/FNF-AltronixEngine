package states;

import scriptStuff.ScriptHelper;
import flixel.FlxG;
import polymod.hscript.HScriptedClass;

@:hscriptClass
class PolymodHscriptState extends flixel.FlxState implements HScriptedClass
{}

class ScriptedSubstate extends MusicBeatSubstate
{
	public static var instance:ScriptedSubstate;

	override function create()
	{
		instance = this;

		ScriptHelper.callOnScripts('substateCreate', []);
		ScriptHelper.setOnScripts('close', close);

		super.create();
		ScriptHelper.callOnScripts('substatePostCreate', []);
	}

	public function new()
	{
		ScriptHelper.callOnScripts('newSubstate', []);
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		ScriptHelper.callOnScripts('substateUpdate', [elapsed]);
		super.update(elapsed);
		ScriptHelper.callOnScripts('substatePostUpdate', [elapsed]);
	}

	override function destroy()
	{
		ScriptHelper.callOnScripts('substateDestroy', []);
		super.destroy();
	}
}

class ScriptedState extends MusicBeatState
{
	public static var instance:ScriptedState;

	override function create()
	{
		instance = this;

		ScriptHelper.callOnScripts('stateCreate', []);

		super.create();
		ScriptHelper.callOnScripts('statePostCreate', []);
	}

	public function new()
	{
		ScriptHelper.callOnScripts('newState', []);
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		ScriptHelper.callOnScripts('stateUpdate', [elapsed]);
		super.update(elapsed);
		ScriptHelper.callOnScripts('statePostUpdate', [elapsed]);
	}

	override function destroy()
	{
		ScriptHelper.callOnScripts('stateDestroy', []);
		super.destroy();
	}
}