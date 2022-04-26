package;

import polymod.hscript.HScriptable;

@:autoBuild(HaxeHScriptFixer.build()) // This macro adds a `Debug.logError` call that occurs if a script error occurs.
// ALL of these values are added to ALL scripts in the child classes.
@:hscript({
	context: [Debug, FlxG, FlxSprite, Math, Paths, Std]
})
interface IHook extends HScriptable
{
}