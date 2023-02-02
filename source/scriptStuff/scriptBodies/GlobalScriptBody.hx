package scriptStuff.scriptBodies;

import flixel.FlxState;

#if FEATURE_MODCORE
@:hscriptClass()
class GlobalScript extends GlobalScriptBody implements polymod.hscript.HScriptedClass{}

class GlobalScriptBody extends ScriptBody
{
	public function new()
	{
		super();
        isGlobal = true;
	}

	override public function destroy()
	{
		FlxG.signals.focusGained.remove(function()
		{
			onFocusGained();
		});
		FlxG.signals.focusLost.remove(function()
		{
			onFocusLost();
		});
		FlxG.signals.gameResized.remove(function(w:Int, h:Int)
		{
			onGameResized(w, h);
		});
		FlxG.signals.postDraw.remove(function()
		{
			onPostDraw();
		});
		FlxG.signals.postGameReset.remove(function()
		{
			onPostGameReset();
		});
		FlxG.signals.postGameStart.remove(function()
		{
			onPostGameStart();
		});
		FlxG.signals.postStateSwitch.remove(function()
		{
			onPostStateSwitch();
		});
		FlxG.signals.postUpdate.remove(function()
		{
			onPostUpdate(FlxG.elapsed);
		});
		FlxG.signals.preDraw.remove(function()
		{
			onPreDraw();
		});
		FlxG.signals.preGameReset.remove(function()
		{
			onPreGameReset();
		});
		FlxG.signals.preGameStart.remove(function()
		{
			onPreGameStart();
		});
		FlxG.signals.preStateCreate.remove(function(state:FlxState)
		{
			onPreStateCreate(state);
		});
		FlxG.signals.preStateSwitch.remove(function()
		{
			onPreStateSwitch();
		});
		FlxG.signals.preUpdate.remove(function()
		{
			onPreUpdate(FlxG.elapsed);
		});

		Main.fnfSignals.beatHit.remove(beatHit);
		Main.fnfSignals.stepHit.remove(stepHit);
		Main.fnfSignals.sectionHit.remove(sectionHit);
		Main.fnfSignals.update.remove(update);

		super.destroy();
	}
	function onPreUpdate(elapsed:Float) {}

	function onPreStateSwitch() {}

	function onPreStateCreate(state:FlxState) {}

	function onPreGameStart() {}

	function onPreGameReset() {}

	function onPreDraw() {}

	function onPostUpdate(elapsed:Float) {}

	function onPostStateSwitch() {}

	function onPostGameStart() {}

	function onPostGameReset() {}

	function onPostDraw() {}

	function onGameResized(w:Int, h:Int) {}

	function onFocusLost() {}

	function onFocusGained() {}

	override private function buildDefaultSignals()
	{
		super.buildDefaultSignals();

		FlxG.signals.focusGained.add(function()
		{
			onFocusGained();
		});
		FlxG.signals.focusLost.add(function()
		{
			onFocusLost();
		});
		FlxG.signals.gameResized.add(function(w:Int, h:Int)
		{
			onGameResized(w, h);
		});
		FlxG.signals.postDraw.add(function()
		{
			onPostDraw();
		});
		FlxG.signals.postGameReset.add(function()
		{
			onPostGameReset();
		});
		FlxG.signals.postGameStart.add(function()
		{
			onPostGameStart();
		});
		FlxG.signals.postStateSwitch.add(function()
		{
			onPostStateSwitch();
		});
		FlxG.signals.postUpdate.add(function()
		{
			onPostUpdate(FlxG.elapsed);
		});
		FlxG.signals.preDraw.add(function()
		{
			onPreDraw();
		});
		FlxG.signals.preGameReset.add(function()
		{
			onPreGameReset();
		});
		FlxG.signals.preGameStart.add(function()
		{
			onPreGameStart();
		});
		FlxG.signals.preStateCreate.add(function(state:FlxState)
		{
			onPreStateCreate(state);
		});
		FlxG.signals.preStateSwitch.add(function()
		{
			onPreStateSwitch();
		});
		FlxG.signals.preUpdate.add(function()
		{
			onPreUpdate(FlxG.elapsed);
		});
	}
}
#end