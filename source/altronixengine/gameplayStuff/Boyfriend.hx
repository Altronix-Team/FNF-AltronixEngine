package altronixengine.gameplayStuff;

class Boyfriend extends Character
{
	public function new(x:Float, y:Float, ?char:String = 'bf')
	{
		super(x, y, char, true);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !curCharacter.endsWith('-car'))
			{
				playAnim('idle', true, false, 10);
			}
			else if (curCharacter.endsWith('-car') && !animation.curAnim.name.startsWith('sing') && animation.curAnim.finished)
				playAnim('idleHair');

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
			{
				playAnim('deathLoop');
			}
		}

		super.update(elapsed);
	}
}
