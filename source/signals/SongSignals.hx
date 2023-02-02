package signals;

import gameplayStuff.Note;
import flixel.util.FlxSignal;

class SongSignals
{
	public var createPost(default, null):FlxTypedSignal<()->Void> = new FlxTypedSignal<()->Void>();

	public var onStartCountdown(default, null):FlxTypedSignal<()->Void> = new FlxTypedSignal<()->Void>();

	public var onCountdownStarted(default, null):FlxTypedSignal<()->Void> = new FlxTypedSignal<()->Void>();

	public var onCountdownTick(default, null):FlxTypedSignal<Int -> Void> = new FlxTypedSignal<Int -> Void>();

	public var onKeyRelease(default, null):FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

	public var onKeyPress(default, null):FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

	public var noteMissPress(default, null):FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

	public var onNextDialogue(default, null):FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	public var onSkipDialogue(default, null):FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	public var onSongStart(default, null):FlxTypedSignal<()->Void> = new FlxTypedSignal<()->Void>();

	public var onResume(default, null):FlxTypedSignal<()->Void> = new FlxTypedSignal<()->Void>();

	public var onPause(default, null):FlxTypedSignal<()->Void> = new FlxTypedSignal<()->Void>();

	public var onGameOver(default, null):FlxTypedSignal<()->Void> = new FlxTypedSignal<()->Void>();
    
	public var onEndSong(default, null):FlxTypedSignal<() -> Void> = new FlxTypedSignal<() -> Void>();

	public var onAttack(default, null):FlxTypedSignal<() -> Void> = new FlxTypedSignal<() -> Void>();

	public var onMoveCamera(default, null):FlxTypedSignal<String -> Void> = new FlxTypedSignal<String -> Void>();

	public var onHealthChange(default, null):FlxTypedSignal<Float -> Void> = new FlxTypedSignal<Float -> Void>();

	public var startCutscene(default, null):FlxTypedSignal<() -> Void> = new FlxTypedSignal<() -> Void>();

	@:allow(states.PlayState)
	function new()
	{
	}
}