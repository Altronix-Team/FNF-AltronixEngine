package scriptStuff.scriptBodies;

#if FEATURE_MODCORE
import polymod.hscript.HScriptable;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import gameplayStuff.Section.SwagSection;

@:hscriptClass()
class StageScript extends StageScriptBody implements polymod.hscript.HScriptedClass{}

class StageScriptBody extends FlxTypedGroup<FlxBasic> implements IScript
{
    public static var scriptFile:StageScriptBody;
	public static var scriptFileId:String;
	public var isGlobal:Bool;

	public function new(id:String)
	{
		super();

		scriptFileId = id;
		scriptFile = this;

		ScriptHelper.allHscriptFiles.push(this);
		
		isGlobal = false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function beatHit(beat:Int)
	{
	}

	public function stepHit(step:Int)
	{
	}

	public function sectionHit(section:SwagSection)
	{
	}

	public function buildCallbacks()
	{
		Main.fnfSignals.beatHit.add(beatHit);
		Main.fnfSignals.stepHit.add(stepHit);
		Main.fnfSignals.sectionHit.add(sectionHit);
	}

	override public function destroy()
	{
		Main.fnfSignals.beatHit.remove(beatHit);
		Main.fnfSignals.stepHit.remove(stepHit);
		Main.fnfSignals.sectionHit.remove(sectionHit);

		super.destroy();
	}
}
#end