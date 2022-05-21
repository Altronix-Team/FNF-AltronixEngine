import flixel.FlxGame;


class CustomFlxGame extends FlxGame {
	public function new() {
		super();
		_customSoundTray = CustomSoundTray;	
	}
}