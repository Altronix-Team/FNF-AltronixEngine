package scriptStuff;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import Paths;
import scriptStuff.ScriptHelper;
import states.PlayState;

class HscriptStage extends ModchartHelper
{
	var state:PlayState;

	public function new(path:String, state:PlayState)
	{
		scriptHelper = new ScriptHelper();
		
		scriptHelper.expose.set("stage", this);
		scriptHelper.expose.set("gf", state.gf);
		scriptHelper.expose.set("dad", state.dad);
		scriptHelper.expose.set("boyfriend", state.boyfriend);

		this.state = state;
		super(path, state);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override public function onBeat(beat:Int)
	{
		super.onBeat(beat);
	}

	override public function onStep(step:Int)
	{
		super.onStep(step);
	}

	override public function opponentNoteHit(noteIndex:Float, noteData:Float, noteType:String, sustainNote:Bool)
	{
		super.opponentNoteHit(noteIndex, noteData, noteType, sustainNote);
	}

	override public function goodNoteHit(noteIndex:Float, noteData:Float, noteType:String, sustainNote:Bool)
	{
		super.goodNoteHit(noteIndex, noteData, noteType, sustainNote);
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
