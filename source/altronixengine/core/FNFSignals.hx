package core;

import gameplayStuff.Section.SwagSection;
import flixel.util.FlxSignal;

// Wonderful idea, Max
class FNFSignals
{
	public var beatHit(default, null):FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	public var stepHit(default, null):FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	public var sectionHit(default, null):FlxTypedSignal<SwagSection->Void> = new FlxTypedSignal<SwagSection->Void>();

	public var decimalBeatHit(default, null):FlxTypedSignal<Float->Void> = new FlxTypedSignal<Float->Void>();

	// Lol, flixel signals does not have update signals with elapsed val
	public var update(default, null):FlxTypedSignal<Float->Void> = new FlxTypedSignal<Float->Void>();

	@:allow(Main)
	function new()
	{
	}
}
