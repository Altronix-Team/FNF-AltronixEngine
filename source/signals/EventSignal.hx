package signals;

import flixel.util.FlxSignal;

//So big
class EventSignal
{
	public var onEvent(default, null):FlxTypedSignal<(String, Dynamic) -> Void> = new FlxTypedSignal<(String, Dynamic)->Void>();

	@:allow(states.PlayState)
	function new()
	{
	}
}