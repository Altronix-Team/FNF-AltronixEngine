package signals;

import gameplayStuff.Note;
import flixel.util.FlxSignal;

class NoteSignals
{
	public var playerNoteHit(default, null):FlxTypedSignal<Note->Void> = new FlxTypedSignal<Note->Void>();

	public var opponentNoteHit(default, null):FlxTypedSignal<Note->Void> = new FlxTypedSignal<Note->Void>();

	public var noteMiss(default, null):FlxTypedSignal<Null<Note>->Void> = new FlxTypedSignal<Null<Note>->Void>();

	@:allow(states.PlayState)
	function new()
	{
	}
}