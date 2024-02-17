package altronixengine.states;

import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;

// Well, thats sooo big
class TransitionableState extends FlxTransitionableState
{
	public var nextState:FlxState = FlxG.state;

	override public function create()
	{
		super.create();
	}

	override function finishTransIn()
	{
		if (nextState == FlxG.state)
			FlxG.resetState();
		else
			startOutro(() ->
			{
				FlxG.switchState(nextState);
			});
	}
}
