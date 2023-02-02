package scriptStuff.scriptBodies;

import states.PlayState;

@:hscriptClass()
class SongScript extends SongScriptBody implements polymod.hscript.HScriptedClass{}

class SongScriptBody extends ScriptBody implements IScript
{
	public function new() {
		super();
	}

	override private function buildDefaultSignals() {
		super.buildDefaultSignals();

		PlayState.songSignals.createPost.add(createPost);
		PlayState.songSignals.onStartCountdown.add(onStartCountdown);
		PlayState.songSignals.noteMissPress.add(noteMissPress);
		PlayState.songSignals.onAttack.add(onAttack);
		PlayState.songSignals.onCountdownStarted.add(onCountdownStarted);
		PlayState.songSignals.onCountdownTick.add(onCountdownTick);
		PlayState.songSignals.onEndSong.add(onEndSong);
		PlayState.songSignals.onGameOver.add(onGameOver);
		PlayState.songSignals.onHealthChange.add(onHealthChange);
		PlayState.songSignals.onKeyPress.add(onKeyPress);
		PlayState.songSignals.onKeyRelease.add(onKeyRelease);
		PlayState.songSignals.onMoveCamera.add(onMoveCamera);
		PlayState.songSignals.onNextDialogue.add(onNextDialogue);
		PlayState.songSignals.onPause.add(onPause);
		PlayState.songSignals.onResume.add(onResume);
		PlayState.songSignals.onSkipDialogue.add(onSkipDialogue);
		PlayState.songSignals.onSongStart.add(onSongStart);
	}

	override public function destroy()
	{
		PlayState.songSignals.createPost.remove(createPost);
		PlayState.songSignals.onStartCountdown.remove(onStartCountdown);
		PlayState.songSignals.noteMissPress.remove(noteMissPress);
		PlayState.songSignals.onAttack.remove(onAttack);
		PlayState.songSignals.onCountdownStarted.remove(onCountdownStarted);
		PlayState.songSignals.onCountdownTick.remove(onCountdownTick);
		PlayState.songSignals.onEndSong.remove(onEndSong);
		PlayState.songSignals.onGameOver.remove(onGameOver);
		PlayState.songSignals.onHealthChange.remove(onHealthChange);
		PlayState.songSignals.onKeyPress.remove(onKeyPress);
		PlayState.songSignals.onKeyRelease.remove(onKeyRelease);
		PlayState.songSignals.onMoveCamera.remove(onMoveCamera);
		PlayState.songSignals.onNextDialogue.remove(onNextDialogue);
		PlayState.songSignals.onPause.remove(onPause);
		PlayState.songSignals.onResume.remove(onResume);
		PlayState.songSignals.onSkipDialogue.remove(onSkipDialogue);
		PlayState.songSignals.onSongStart.remove(onSongStart);

		super.destroy();
	}

	public function createPost() {}

	public function onStartCountdown() {}

	public function onCountdownStarted() {}

	public function onCountdownTick(tick:Int) {}

	public function onKeyRelease(key:String) {}

	public function onKeyPress(key:String) {}

	public function noteMissPress(key:String) {}

	public function onNextDialogue(line:Int) {}

	public function onSkipDialogue(line:Int) {}

	public function onSongStart() {}

	public function onResume() {}

	public function onPause() {}

	public function onGameOver() {}

	public function onEndSong() {}

	public function onAttack() {}

	public function onMoveCamera(char:String) {};

	public function onHealthChange(health:Float) {}
}