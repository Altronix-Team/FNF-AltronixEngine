package scriptStuff;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import Paths;
import scriptStuff.ScriptHelper;
import states.PlayState;

@:access(states.PlayState)
class ModchartHelper extends FlxTypedGroup<FlxBasic>
{
	var scriptHelper:ScriptHelper;
	var playState:PlayState;

	public function new(path:String, state:PlayState)
	{
		super();
		
		this.playState = state;

		if (scriptHelper == null)
			scriptHelper = new ScriptHelper();

		if (!scriptHelper.expose.exists("PlayState"))
			scriptHelper.expose.set("PlayState", playState);
		
		if (!scriptHelper.expose.exists("stage"))
			scriptHelper.expose.set("stage", playState.hscriptStage);
		
		if (!scriptHelper.expose.exists("gf") && playState.gf != null)
			scriptHelper.expose.set("gf", playState.gf);
		if (!scriptHelper.expose.exists("enemy") && playState.dad != null)
			scriptHelper.expose.set("enemy", playState.dad);
		if (!scriptHelper.expose.exists("player") && playState.boyfriend != null)
			scriptHelper.expose.set("player", playState.boyfriend);

		scriptHelper.expose.set("gameCamera", playState.camGame);
		scriptHelper.expose.set("hudCamera", playState.camHUD);
		scriptHelper.expose.set("enemyStrumLine", playState.opponentStrums);
		scriptHelper.expose.set("playerStrumLine", playState.playerStrums);

		scriptHelper.loadScript(path);

		if (scriptHelper.get("onCreate") != null)
			scriptHelper.get("onCreate")();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (scriptHelper.get("onUpdate") != null)
			scriptHelper.get("onUpdate")(elapsed);
	}

	public function opponentNoteHit(noteIndex:Float, noteData:Float, noteType:String, sustainNote:Bool)
	{
		if (scriptHelper.get("opponentNoteHit") != null)
			scriptHelper.get("opponentNoteHit")(noteIndex, noteData, noteType, sustainNote);
	}

	public function goodNoteHit(noteIndex:Float, noteData:Float, noteType:String, sustainNote:Bool)
	{
		if (scriptHelper.get("goodNoteHit") != null)
			scriptHelper.get("goodNoteHit")(noteIndex, noteData, noteType, sustainNote);
	}

	public function onBeat(beat:Int)
	{
		if (scriptHelper.get("onBeat") != null)
			scriptHelper.get("onBeat")(beat);
	}

	public function onStep(step:Int)
	{
		if (scriptHelper.get("onStep") != null)
			scriptHelper.get("onStep")(step);
	}

	public function onTick(tick:Int)
	{
		if (scriptHelper.get("onTick") != null)
			scriptHelper.get("onTick")(tick);
	}
}
