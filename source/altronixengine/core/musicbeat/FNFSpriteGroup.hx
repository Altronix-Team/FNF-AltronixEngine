package altronixengine.core;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import altronixengine.gameplayStuff.Conductor;

class FNFSpriteGroup<T:MusicBeatSprite> extends FlxTypedSpriteGroup<T> implements IMusicBeat{
    
    public var curBeat:Int;
	public var curStep:Int;
	public var curDecimalBeat:Float;
	public var curSection:SwagSection;

	public function new(X:Float = 0, Y:Float = 0, MaxSize:Int = 0)
	{
		super(X, Y, MaxSize);
	
		Main.fnfSignals.beatHit.add(_beatHit);
		Main.fnfSignals.sectionHit.add(_sectionHit);
		Main.fnfSignals.stepHit.add(_stepHit);
		Main.fnfSignals.decimalBeatHit.add(_decimalBeatHit);
	}
	
	override function destroy() 
	{
		Main.fnfSignals.beatHit.remove(_beatHit);
		Main.fnfSignals.sectionHit.remove(_sectionHit);
		Main.fnfSignals.stepHit.remove(_stepHit);
		Main.fnfSignals.decimalBeatHit.remove(_decimalBeatHit);
	
		super.destroy();
	}

	public function stepHit() {
		forEach(function(obj:T){
			if (obj is IMusicBeat)
				obj.stepHit(step);
		});
	}

	public function beatHit() {
		forEach(function(obj:T){
			if (obj is IMusicBeat)
				obj.beatHit(beat);
		});
	}

	public function decimalBeatHit() {
		forEach(function(obj:T){
			if (obj is IMusicBeat)
				obj.decimalBeatHit(decBeat);
		});
	}

	public function sectionHit()
	{
		forEach(function(obj:T){
			if (obj is IMusicBeat)
				obj.sectionHir(decBeat);
		});
	}

	private function _stepHit(step:Int):Void
		{
			curStep = step;
			stepHit();
		}
	
		private function _beatHit(beat:Int):Void
		{
			curBeat = beat;
			beatHit();
		}
	
		private function _sectionHit(section:SwagSection):Void
		{
			curSection = section;
			sectionHit();
		}
	
		private function _decimalBeatHit(beat:Float):Void
		{
			curDecimalBeat = beat;
		}

	
}