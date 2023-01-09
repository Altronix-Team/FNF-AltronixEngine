package utils;

import haxe.macro.Compiler;

class MusicBeatMacro
{
    //Super implementer shit
	public static function init()
	{
		Compiler.addGlobalMetadata('flixel.FlxObject', '@:autoBuild(utils.MusicBeatMacro.buildFNFFields())');
	}

	public static macro function buildFNFFields():Array<Field>
	{
		var cls:haxe.macro.Type.ClassType = Context.getLocalClass().get();
		var fields:Array<Field> = Context.getBuildFields();

		Context.info(cls.name, Context.currentPos());

		fields = fields.concat(MacroUtil.buildProperty("curStep", macro:Int, null, [], [], true));
		fields = fields.concat(MacroUtil.buildProperty("curBeat", macro:Int, null, [], [], true));
		fields = fields.concat(MacroUtil.buildProperty("curDecimalBeat", macro:Float, null, [], [], true));
		fields = fields.concat(MacroUtil.buildProperty("curSection", macro:gameplayStuff.Section.SwagSection, null, [], [], true));

		var stepHit = macro{};
		var beatHit = macro{};
		var sectionHit = macro{};
		fields.push(MacroUtil.buildFunction("stepHit", [stepHit], true, false));
		fields.push(MacroUtil.buildFunction("beatHit", [beatHit], true, false));
		fields.push(MacroUtil.buildFunction("sectionHit", [sectionHit], true, false));

		return fields;
	}
}