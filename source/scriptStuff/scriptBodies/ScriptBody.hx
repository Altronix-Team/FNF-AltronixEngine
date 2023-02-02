package scriptStuff.scriptBodies;

#if FEATURE_MODCORE
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import gameplayStuff.Section.SwagSection;
import flixel.FlxBasic;
import states.MusicBeatState;

//The main class of all hscript files (except stage)
class ScriptBody extends FlxBasic implements IScript
{
	public var isGlobal:Bool;

    public function new()
    {
        super();

        ScriptHelper.allHscriptFiles.push(this);

		buildDefaultSignals();

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

    override public function destroy()
    {
		Main.fnfSignals.beatHit.remove(beatHit);
		Main.fnfSignals.stepHit.remove(stepHit);
		Main.fnfSignals.sectionHit.remove(sectionHit);
		Main.fnfSignals.update.remove(update);

        super.destroy();
    }


	private function buildDefaultSignals() {
		Main.fnfSignals.beatHit.add(beatHit);
		Main.fnfSignals.stepHit.add(stepHit);
		Main.fnfSignals.sectionHit.add(sectionHit);
		Main.fnfSignals.update.add(update);
	}
}

interface IScript extends IFlxDestroyable
{
	public var isGlobal:Bool;	

	public function beatHit(beat:Int):Void;

	public function stepHit(step:Int):Void;

	public function sectionHit(section:SwagSection):Void;

    public function update(elapsef:Float):Void;
}
#end