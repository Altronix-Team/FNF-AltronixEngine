package scriptStuff.scriptBodies;

#if FEATURE_MODCORE
import gameplayStuff.Note;
import states.PlayState;

@:hscriptClass()
class NoteScript extends NoteScriptBody implements polymod.hscript.HScriptedClass{}

class NoteScriptBody extends ScriptBody implements IScript
{
	public function new() {
		super();
	}

	override private function buildDefaultSignals() {
		super.buildDefaultSignals();

		PlayState.songSignals.noteMissPress.add(noteMissPress);
		PlayState.noteSignals.playerNoteHit.add(playerNoteHit);
		PlayState.noteSignals.opponentNoteHit.add(opponentNoteHit);
		PlayState.noteSignals.noteMiss.add(noteMiss);
	}

	override public function destroy()
	{
		PlayState.songSignals.noteMissPress.remove(noteMissPress);
		PlayState.noteSignals.playerNoteHit.remove(playerNoteHit);
		PlayState.noteSignals.opponentNoteHit.remove(opponentNoteHit);
		PlayState.noteSignals.noteMiss.remove(noteMiss);

		super.destroy();
	}

	public function playerNoteHit(note:Note):Void {}

	public function opponentNoteHit(note:Note):Void {}

	public function noteMiss(note:Null<Note>):Void {}

	public function noteMissPress(key:String):Void{}
}
#end