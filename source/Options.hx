package;

import lime.app.Application;
import lime.system.DisplayMode;
import flixel.util.FlxColor;
import Controls.KeyboardScheme;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.Lib;
import states.OptionsMenu;
import states.GameplayCustomizeState;
import states.PlayState;
import states.StoryMenuState;
import states.LoadingState;
import gameplayStuff.Song;
import gameplayStuff.Highscore;

class Option
{
	public function new()
	{
		display = updateDisplay();
	}

	private var description:String = "";
	private var display:String;
	private var acceptValues:Bool = false;

	public var acceptType:Bool = false;

	public var waitingType:Bool = false;

	public final function getDisplay():String
	{
		return display;
	}

	public final function getAccept():Bool
	{
		return acceptValues;
	}

	public final function getDescription():String
	{
		return description;
	}

	public function getValue():String
	{
		return updateDisplay();
	};

	public function onType(text:String)
	{
	}

	// Returns whether the label is to be updated.
	public function press():Bool
	{
		return true;
	}

	private function updateDisplay():String
	{
		return "";
	}

	public function left():Bool
	{
		return false;
	}

	public function right():Bool
	{
		return false;
	}
}

class DFJKOption extends Option
{
	public function new()
	{
		super();
		if (!FlxG.save.data.language)
			description = "Edit your keybindings";
		else
			description = "Изменить настройки управления";
	}

	public override function press():Bool
	{
		OptionsMenu.instance.selectedCatIndex = 4;
		OptionsMenu.instance.switchCat(OptionsMenu.instance.options[4], false);
		return false;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Edit Keybindings";
		else
			return "Изменить настройки управления";
	}
}

class UpKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.upBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "UP: " + (waitingType ? "> " + FlxG.save.data.upBind + " <" : FlxG.save.data.upBind) + "";
		else
			return "Вверх: " + (waitingType ? "> " + FlxG.save.data.upBind + " <" : FlxG.save.data.upBind) + "";
	}
}

class DownKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.downBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "DOWN: " + (waitingType ? "> " + FlxG.save.data.downBind + " <" : FlxG.save.data.downBind) + "";
		else
			return "Вниз: " + (waitingType ? "> " + FlxG.save.data.downBind + " <" : FlxG.save.data.downBind) + "";
	}
}

class RightKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.rightBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "RIGHT: " + (waitingType ? "> " + FlxG.save.data.rightBind + " <" : FlxG.save.data.rightBind) + "";
		else
			return "Вправо: " + (waitingType ? "> " + FlxG.save.data.rightBind + " <" : FlxG.save.data.rightBind) + "";
	}
}

class LeftKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.leftBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "LEFT: " + (waitingType ? "> " + FlxG.save.data.leftBind + " <" : FlxG.save.data.leftBind) + "";
		else
			return "Влево: " + (waitingType ? "> " + FlxG.save.data.leftBind + " <" : FlxG.save.data.leftBind) + "";
	}
}

class AttackKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.attackBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "ATTACK: " + (waitingType ? "> " + FlxG.save.data.attackBind + " <" : FlxG.save.data.attackBind) + "";
		else
			return "Атака: " + (waitingType ? "> " + FlxG.save.data.attackBind + " <" : FlxG.save.data.attackBind) + "";
	}
}
class PauseKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.pauseBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "PAUSE: " + (waitingType ? "> " + FlxG.save.data.pauseBind + " <" : FlxG.save.data.pauseBind) + "";
		else
			return "Пауза: " + (waitingType ? "> " + FlxG.save.data.pauseBind + " <" : FlxG.save.data.pauseBind) + "";
	}
}

class ResetBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.resetBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "RESET: " + (waitingType ? "> " + FlxG.save.data.resetBind + " <" : FlxG.save.data.resetBind) + "";
		else
			return "Сбросить: " + (waitingType ? "> " + FlxG.save.data.resetBind + " <" : FlxG.save.data.resetBind) + "";
	}
}

class MuteBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.muteBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "VOLUME MUTE: " + (waitingType ? "> " + FlxG.save.data.muteBind + " <" : FlxG.save.data.muteBind) + "";
		else
			return "Заглушить звук: " + (waitingType ? "> " + FlxG.save.data.muteBind + " <" : FlxG.save.data.muteBind) + "";
	}
}

class VolUpBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.volUpBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "VOLUME UP: " + (waitingType ? "> " + FlxG.save.data.volUpBind + " <" : FlxG.save.data.volUpBind) + "";
		else
			return "Повысить громкость: " + (waitingType ? "> " + FlxG.save.data.volUpBind + " <" : FlxG.save.data.volUpBind) + "";
	}
}

class VolDownBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.volDownBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "VOLUME DOWN: " + (waitingType ? "> " + FlxG.save.data.volDownBind + " <" : FlxG.save.data.volDownBind) + "";
		else
			return "Понизить громкость: " + (waitingType ? "> " + FlxG.save.data.volDownBind + " <" : FlxG.save.data.volDownBind) + "";
	}
}

class FullscreenBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.fullscreenBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "FULLSCREEN:  " + (waitingType ? "> " + FlxG.save.data.fullscreenBind + " <" : FlxG.save.data.fullscreenBind) + "";
		else
			return "Полный экран:  " + (waitingType ? "> " + FlxG.save.data.fullscreenBind + " <" : FlxG.save.data.fullscreenBind) + "";
	}
}

class UpP2Keybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.upBindP2 = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "UP (P2): " + (waitingType ? "> " + FlxG.save.data.upBindP2 + " <" : FlxG.save.data.upBindP2) + "";
		else
			return "Вверх (игрок 2): " + (waitingType ? "> " + FlxG.save.data.upBindP2 + " <" : FlxG.save.data.upBindP2) + "";
	}
}

class DownP2Keybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.downBindP2 = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "DOWN (P2): " + (waitingType ? "> " + FlxG.save.data.downBindP2 + " <" : FlxG.save.data.downBindP2) + "";
		else
			return "Вниз (игрок 2): " + (waitingType ? "> " + FlxG.save.data.downBindP2 + " <" : FlxG.save.data.downBindP2) + "";
	}
}

class RightP2Keybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.rightBindP2 = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "RIGHT (P2): " + (waitingType ? "> " + FlxG.save.data.rightBindP2 + " <" : FlxG.save.data.rightBindP2) + "";
		else
			return "Вправо (игрок 2): " + (waitingType ? "> " + FlxG.save.data.rightBindP2 + " <" : FlxG.save.data.rightBindP2) + "";
	}
}

class LeftP2Keybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.leftBindP2 = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "LEFT (P2): " + (waitingType ? "> " + FlxG.save.data.leftBindP2 + " <" : FlxG.save.data.leftBindP2) + "";
		else
			return "Влево (игрок 2): " + (waitingType ? "> " + FlxG.save.data.leftBindP2 + " <" : FlxG.save.data.leftBindP2) + "";
	}
}

class SickMSOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (!FlxG.save.data.language)
			description = desc + " (Press R to reset)";
		else
			description = desc + " (Нажмите R для сброса)";
		acceptType = true;
	}

	public override function left():Bool
	{
		FlxG.save.data.sickMs--;
		if (FlxG.save.data.sickMs < 0)
			FlxG.save.data.sickMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		FlxG.save.data.sickMs++;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			FlxG.save.data.sickMs = 45;
	}

	private override function updateDisplay():String
	{
		return "SICK: < " + FlxG.save.data.sickMs + " ms >";
	}
}

class GoodMsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (!FlxG.save.data.language)
			description = desc + " (Press R to reset)";
		else
			description = desc + " (Нажмите R для сброса)";
		acceptType = true;
	}

	public override function left():Bool
	{
		FlxG.save.data.goodMs--;
		if (FlxG.save.data.goodMs < 0)
			FlxG.save.data.goodMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		FlxG.save.data.goodMs++;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			FlxG.save.data.goodMs = 90;
	}

	private override function updateDisplay():String
	{
		return "GOOD: < " + FlxG.save.data.goodMs + " ms >";
	}
}

class BadMsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (!FlxG.save.data.language)
			description = desc + " (Press R to reset)";
		else
			description = desc + " (Нажмите R для сброса)";
		acceptType = true;
	}

	public override function left():Bool
	{
		FlxG.save.data.badMs--;
		if (FlxG.save.data.badMs < 0)
			FlxG.save.data.badMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		FlxG.save.data.badMs++;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			FlxG.save.data.badMs = 135;
	}

	private override function updateDisplay():String
	{
		return "BAD: < " + FlxG.save.data.badMs + " ms >";
	}
}

class ShitMsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (!FlxG.save.data.language)
			description = desc + " (Press R to reset)";
		else
			description = desc + " (Нажмите R для сброса)";
		acceptType = true;
	}

	public override function left():Bool
	{
		FlxG.save.data.shitMs--;
		if (FlxG.save.data.shitMs < 0)
			FlxG.save.data.shitMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			FlxG.save.data.shitMs = 160;
	}

	public override function right():Bool
	{
		FlxG.save.data.shitMs++;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "SHIT: < " + FlxG.save.data.shitMs + " ms >";
	}
}
class GraphicLoading extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.cacheImages = !FlxG.save.data.cacheImages;

		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "";
	}
}

class EditorRes extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.editorBG = !FlxG.save.data.editorBG;

		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Editor Grid: < " + (FlxG.save.data.editorBG ? "Shown" : "Hidden") + " >";
		else
			return "Сетка редактора: < " + (FlxG.save.data.editorBG ? "Показывается" : "Скрытая") + " >";
	}
}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		/*if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else*/
			description = desc;
	}

	public override function left():Bool
	{
		//if (OptionsMenu.isInPause)
			//return false;
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Scroll: < " + (FlxG.save.data.downscroll ? "Downscroll" : "Upscroll") + " >";
		else
			return "Прокручивание: < " + (FlxG.save.data.downscroll ? "Сверху-вниз" : "Снизу-вверх") + " >";
	}
}

class GhostTapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.ghost = !FlxG.save.data.ghost;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Ghost Tapping: < " + (FlxG.save.data.ghost ? "Enabled" : "Disabled") + " >";
		else
			return "Призрачные нажатия: < " + (FlxG.save.data.ghost ? "Включено" : "Выключено") + " >";
	}
}

class PsychInterfaceOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.enablePsychInterface = !FlxG.save.data.enablePsychInterface;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Interface type < " + (!FlxG.save.data.enablePsychInterface ? "Kade" : "Psych") + " >";
		else
			return "Тип интерфейса < " + (!FlxG.save.data.enablePsychInterface ? "Kade" : "Psych") + " >";
	}
}

class AccuracyOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Accuracy Display < " + (!FlxG.save.data.accuracyDisplay ? "off" : "on") + " >";
		else
			return "Отображение точности < " + (!FlxG.save.data.accuracyDisplay ? "выключено" : "включено") + " >";
	}
}

class SongPositionOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	public override function getValue():String
	{
		if (!FlxG.save.data.language)
			return "Song Position Bar: < " + (!FlxG.save.data.songPosition ? "off" : "on") + " >";
		else
			return "Полоса позиции песни: < " + (!FlxG.save.data.songPosition ? "выключено" : "включено") + " >";
	}
}

class DistractionsAndEffectsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.distractions = !FlxG.save.data.distractions;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Distractions: < " + (!FlxG.save.data.distractions ? "off" : "on") + " >";
		else
			return "Раздражители: < " + (!FlxG.save.data.distractions ? "выключены" : "включены") + " >";
	}
}

class Colour extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.colour = !FlxG.save.data.colour;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Colored HP Bars: < " + (FlxG.save.data.colour ? "Enabled" : "Disabled") + " >";
		else
			return "Цветные полосы здоровья: < " + (FlxG.save.data.colour ? "Включены" : "Выключены") + " >";
	}
}
class ResetButtonOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.resetButton = !FlxG.save.data.resetButton;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Reset Button: < " + (!FlxG.save.data.resetButton ? "off" : "on") + " >";
		else
			return "Кнопка сброса: < " + (!FlxG.save.data.resetButton ? "выключено" : "включено") + " >";
	}
}

class InstantRespawn extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.InstantRespawn = !FlxG.save.data.InstantRespawn;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Instant Respawn: < " + (!FlxG.save.data.InstantRespawn ? "off" : "on") + " >";
		else
			return "Мгновенное возрождение: < " + (!FlxG.save.data.InstantRespawn ? "выключено" : "включено") + " >";
	}
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.flashing = !FlxG.save.data.flashing;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Flashing Lights: < " + (!FlxG.save.data.flashing ? "off" : "on") + " >";
		else
			return "Мигающие огни: < " + (!FlxG.save.data.flashing ? "выключены" : "включены") + " >";
	}
}

class AntialiasingOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Antialiasing: < " + (!FlxG.save.data.antialiasing ? "off" : "on") + " >";
		else
			return "Сглаживание: < " + (!FlxG.save.data.antialiasing ? "выключено" : "включено") + " >";
	}
}

class MissSoundsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.missSounds = !FlxG.save.data.missSounds;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Miss Sounds: < " + (!FlxG.save.data.missSounds ? "off" : "on") + " >";
		else
			return "Звуки пропуска стрелок: < " + (!FlxG.save.data.missSounds ? "выключены" : "включены") + " >";
	}
}

class ShowInput extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.inputShow = !FlxG.save.data.inputShow;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Score Screen Debug: < " + (FlxG.save.data.inputShow ? "Enabled" : "Disabled") + " >";
		else
			return "Отладка экрана счёта: < " + (FlxG.save.data.inputShow ? "Включена" : "Выключена") + " >";
	}
}

class Judgement extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		OptionsMenu.instance.selectedCatIndex = 5;
		OptionsMenu.instance.switchCat(OptionsMenu.instance.options[5], false);
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Edit Judgements";
		else
			return "Редактировать оценку нажатий";
	}
}

class FPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.fps = !FlxG.save.data.fps;
		(cast(Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "FPS Counter: < " + (!FlxG.save.data.fps ? "off" : "on") + " >";
		else
			return "Счётчик ФПС: < " + (!FlxG.save.data.fps ? "выключено" : "включено") + " >";
	}
}

class NoteSplashOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.notesplashes = !FlxG.save.data.notesplashes;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Note Splashes: < " + (!FlxG.save.data.notesplashes ? "Disabled" : "Enabled") + " >";
		else
			return "Брызги нот: < " + (!FlxG.save.data.notesplashes ? "Выключены" : "Включены") + " >";
	}
}

class LanguageOption extends Option
{
	var selectedId:Int = 0;

	var curLocale:String = 'en_US';

	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;

		curLocale = FlxG.save.data.localeStr;
		selectedId = LanguageStuff.locales.indexOf(curLocale);
	}

	public override function left():Bool
	{
		selectedId -= 1;

		if (selectedId < 0)
			selectedId = LanguageStuff.locales.length - 1;
		if (selectedId > LanguageStuff.locales.length - 1)
			selectedId = 0;

		if (OptionsMenu.isInPause)
			return false;
		
		FlxG.save.data.localeStr = LanguageStuff.locales[selectedId];
		curLocale = FlxG.save.data.localeStr;
		if (curLocale == null)
		{
			curLocale = LanguageStuff.locales[0];
			FlxG.save.data.localeStr = curLocale;
		}
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		selectedId += 1;

		if (selectedId < 0)
			selectedId = LanguageStuff.locales.length;
		if (selectedId > LanguageStuff.locales.length)
			selectedId = 0;

		if (OptionsMenu.isInPause)
			return false;

		FlxG.save.data.localeStr = LanguageStuff.locales[selectedId];
		curLocale = FlxG.save.data.localeStr;
		if (curLocale == null)
		{	
			curLocale = LanguageStuff.locales[0];
			FlxG.save.data.localeStr = curLocale;
		}
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Language: < " + curLocale + " >";
		else
			return "Язык: < " + curLocale + " >";
	}
}
class ScoreScreen extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.scoreScreen = !FlxG.save.data.scoreScreen;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Score Screen: < " + (FlxG.save.data.scoreScreen ? "Enabled" : "Disabled") + " >";
		else
			return "Экран счёта: < " + (FlxG.save.data.scoreScreen ? "Включен" : "Выключен") + " >";
	}
}

class FPSCapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "FPS Cap: < " + FlxG.save.data.fpsCap + " >";
		else
			return "Ограничение ФПС: < " + FlxG.save.data.fpsCap + " >";
	}

	override function right():Bool
	{
		if (FlxG.save.data.fpsCap >= 290)
		{
			FlxG.save.data.fpsCap = 290;
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);
		}
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap + 10;
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		return true;
	}

	override function left():Bool
	{
		if (FlxG.save.data.fpsCap > 290)
			FlxG.save.data.fpsCap = 290;
		else if (FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = Application.current.window.displayMode.refreshRate;
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap - 10;
				(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		return true;
	}

	override function getValue():String
	{
		return updateDisplay();
	}
}

class ScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Scroll Speed: < " + CoolUtil.truncateFloat(FlxG.save.data.scrollSpeed, 1) + " >";
		else
			return "Скорость прокручивания: < " + CoolUtil.truncateFloat(FlxG.save.data.scrollSpeed, 1) + " >";
	}

	override function right():Bool
	{
		FlxG.save.data.scrollSpeed += 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;
		return true;
	}

	override function getValue():String
	{
		return updateDisplay();
	}

	override function left():Bool
	{
		FlxG.save.data.scrollSpeed -= 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;

		return true;
	}
}

class RainbowFPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.fpsRain = !FlxG.save.data.fpsRain;
		(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(FlxColor.WHITE);
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "FPS Rainbow: < " + (!FlxG.save.data.fpsRain ? "off" : "on") + " >";
		else
			return "Радужное переливание ФПС: < " + (!FlxG.save.data.fpsRain ? "выключено" : "включено") + " >";
	}
}

class ScreenResolutionOption extends Option
{
	var curSelected:Int = 0;

	var curRes:Array<Int> = [1280, 720];

	public function new(desc:String)
	{
		super();

		for (res in EngineConstants.screenResolution169)
		{
			if (Main.save.data.gameWidth != null && Main.save.data.gameHeight != null)
			{
				if (res[0] == Main.save.data.gameWidth && res[1] == Main.save.data.gameHeight)
					curRes = res;
			}
		}
		description = desc;
	}

	public override function left():Bool
	{
		curSelected -= 1;

		if (curSelected < 0)
			curSelected = EngineConstants.screenResolution169.length - 1;
		if (curSelected > EngineConstants.screenResolution169.length - 1)
			curSelected = 0;
		curRes = EngineConstants.screenResolution169[curSelected];
		Main.save.data.gameWidth = curRes[0];
		Main.save.data.gameHeight = curRes[1];
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		curSelected += 1;

		if (curSelected < 0)
			curSelected = EngineConstants.screenResolution169.length - 1;
		if (curSelected > EngineConstants.screenResolution169.length - 1)
			curSelected = 0;
		curRes = EngineConstants.screenResolution169[curSelected];
		Main.save.data.gameWidth = curRes[0];
		Main.save.data.gameHeight = curRes[1];
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		WindowUtil.resizeWindow(curRes[0], curRes[1]);
		return 'Placeholder: < ${curRes[0]}x${curRes[1]} >';
	}
}

class NPSDisplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.npsDisplay = !FlxG.save.data.npsDisplay;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "NPS Display: < " + (!FlxG.save.data.npsDisplay ? "off" : "on") + " >";
		else
			return "Отображение стрелок в секунду: < " + (!FlxG.save.data.npsDisplay ? "выключено" : "включено") + " >";
	}
}

/*class ReplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");
		FlxG.switchState(new LoadReplayState());
		return false;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Load replays";
		else
			return "Загрузить реплей";
	}
}*/

class AccuracyDOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.accuracyMod = FlxG.save.data.accuracyMod == 1 ? 0 : 1;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Accuracy Mode: < " + (FlxG.save.data.accuracyMod == 0 ? "Accurate" : "Complex") + " >";
		else
			return "Режим точности: < " + (FlxG.save.data.accuracyMod == 0 ? "Точная" : "Сложная") + " >";
	}
}

class CustomizeGameplay extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		trace("switch");
		FlxG.switchState(new GameplayCustomizeState());
		return false;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Customize Gameplay";
		else
			return "Кастомизировать геймплей";
	}
}

class MemoryCountOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		Main.memoryCount = !Main.memoryCount;
		FlxG.save.data.memoryCount = Main.memoryCount;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Using memory counter: < " + (Main.memoryCount ? "on" : "off") + " >";
		else
			return "Счётчик используемой памяти: < " + (Main.memoryCount ? "включено" : "выключено") + " >";
	}
}

class WatermarkOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		Main.watermarks = !Main.watermarks;
		FlxG.save.data.watermark = Main.watermarks;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Watermarks: < " + (Main.watermarks ? "on" : "off") + " >";
		else
			return "Водяные знаки: < " + (Main.watermarks ? "включено" : "выключено") + " >";
	}
}

class OffsetMenu extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");

		PlayState.SONG = Song.loadFromJson('tutorial', '');
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 0;
		PlayState.storyWeek = 0;
		PlayState.offsetTesting = true;
		trace('CUR WEEK' + PlayState.storyWeek);
		LoadingState.loadAndSwitchState(new PlayState());
		return false;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Time your offset";
		else
			return "Время вашего смещения";
	}
}

class OffsetThing extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.offset--;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.offset++;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Note offset: < " + CoolUtil.truncateFloat(FlxG.save.data.offset, 0) + " >";
		else
			return "Смещение стрелок: < " + CoolUtil.truncateFloat(FlxG.save.data.offset, 0) + " >";
	}

	public override function getValue():String
	{
		return updateDisplay();
	}
}

class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();

		if (gameplayStuff.PlayStateChangeables.twoPlayersMode)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled while you playing two players mode.";
			else
				description = "Эта опция не может быть переключена в режиме двух игроков";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (gameplayStuff.PlayStateChangeables.twoPlayersMode)
			return false;
		
		FlxG.save.data.botplay = !FlxG.save.data.botplay;
		trace('BotPlay : ' + FlxG.save.data.botplay);
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "BotPlay: < " + (FlxG.save.data.botplay ? "on" : "off") + " >";
		else
			return "Бот: < " + (FlxG.save.data.botplay ? "включено" : "выключено") + " >";
	}
}

class LogWriter extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.logWriter = !FlxG.save.data.logWriter;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Log Writer: < " + (FlxG.save.data.logWriter ? "off" : "on") + " >";
		else
			return "Логирование: < " + (FlxG.save.data.logWriter ? "выключено" : "включено") + " >";
	}
}

class FullscreenOnStartOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.fullscreenOnStart = !FlxG.save.data.fullscreenOnStart;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Full screen when starting the game: < " + (!FlxG.save.data.fullscreenOnStart ? "off" : "on") + " >";
		else
			return "Полный экран при запуске игры: < " + (!FlxG.save.data.fullscreenOnStart ? "выключено" : "включено") + " >";
	}
}

class CamZoomOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.camzoom = !FlxG.save.data.camzoom;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Camera Zoom: < " + (!FlxG.save.data.camzoom ? "off" : "on") + " >";
		else
			return "Приближение камеры: < " + (!FlxG.save.data.camzoom ? "выключено" : "включено") + " >";
	}
}

class JudgementCounter extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.judgementCounter = !FlxG.save.data.judgementCounter;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Judgement Counter: < " + (FlxG.save.data.judgementCounter ? "Enabled" : "Disabled") + " >";
		else
			return "Счётчик оценок: < " + (FlxG.save.data.judgementCounter ? "Включено" : "Выключено") + " >";
	}
}

class MiddleScrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		/*if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else*/
			description = desc;
	}

	public override function left():Bool
	{
		//if (OptionsMenu.isInPause)
			//return false;
		FlxG.save.data.middleScroll = !FlxG.save.data.middleScroll;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Middle Scroll: < " + (FlxG.save.data.middleScroll ? "Enabled" : "Disabled") + " >";
		else
			return "Прокручивание в центре: < " + (FlxG.save.data.middleScroll ? "Включено" : "Выключено") + " >";
	}
}

class NoteskinOption extends Option
{
	var curSelectedId:Int = 0;
	var curSkin:String = 'Arrows';

	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;

		if (Std.isOfType(FlxG.save.data.noteskin, String))
			curSkin = FlxG.save.data.noteskin;
		else if (Std.isOfType(FlxG.save.data.noteskin, Int))
			curSkin = NoteskinHelpers.getNoteskinByID(FlxG.save.data.noteskin);

		if (NoteskinHelpers.noteskinArray.contains(curSkin))
			curSelectedId = NoteskinHelpers.noteskinArray.indexOf(curSkin);
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		curSelectedId--;
		if (curSelectedId < 0)
			curSelectedId = NoteskinHelpers.getNoteskins().length - 1;

		curSkin = NoteskinHelpers.getNoteskinByID(curSelectedId);
		FlxG.save.data.noteskin = curSkin;

		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		curSelectedId++;
		if (curSelectedId > NoteskinHelpers.getNoteskins().length - 1)
			curSelectedId = 0;

		curSkin = NoteskinHelpers.getNoteskinByID(curSelectedId);
		FlxG.save.data.noteskin = curSkin;

		display = updateDisplay();
		return true;
	}

	public override function getValue():String
	{
		if (!FlxG.save.data.language)
			return "Current Noteskin: < " + curSkin + " >";
		else
			return "Выбранный вид стрелок: < " + curSkin + " >";
	}
}

class MenuMusicOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.menuMusic--;
		if (FlxG.save.data.menuMusic < 0)
			FlxG.save.data.menuMusic = MenuMusicStuff.getMusic().length - 1;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.menuMusic++;
		if (FlxG.save.data.menuMusic > MenuMusicStuff.getMusic().length - 1)
			FlxG.save.data.menuMusic = 0;
		display = updateDisplay();
		return true;
	}

	public override function getValue():String
	{
		if (!FlxG.sound.music.playing)
		{
			if (!OptionsMenu.isInPause)
				FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)));
		}
		else
		{
			if (!OptionsMenu.isInPause)
			{
				FlxG.sound.music.stop();
				FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)));
			}
		}
		
		if (!FlxG.save.data.language)
			return "Current Menu Music: < " + MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic) + " >";
		else
			return "Выбранная музыка меню: < " + MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic) + " >";
	}
}

class HealthBarOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.healthBar = !FlxG.save.data.healthBar;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Health Bar: < " + (FlxG.save.data.healthBar ? "Enabled" : "Disabled") + " >";
		else
			return "Полоса здоровья: < " + (FlxG.save.data.healthBar ? "Включено" : "Выключено") + " >";
	}
}

class LaneUnderlayOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
		acceptValues = true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Lane Transparceny: < " + CoolUtil.truncateFloat(FlxG.save.data.laneTransparency, 1) + " >";
		else
			return "Прозрачность полосы здоровья: < " + CoolUtil.truncateFloat(FlxG.save.data.laneTransparency, 1) + " >";
	}

	override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.laneTransparency += 0.1;

		if (FlxG.save.data.laneTransparency > 1)
			FlxG.save.data.laneTransparency = 1;
		return true;
	}

	override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.laneTransparency -= 0.1;

		if (FlxG.save.data.laneTransparency < 0)
			FlxG.save.data.laneTransparency = 0;

		return true;
	}
}

class DebugMode extends Option
{
	public function new(desc:String)
	{
		description = desc;
		super();
	}

	public override function press():Bool
	{
		FlxG.switchState(new editors.AnimationDebug());
		return false;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return "Animation Debug";
		else
			return "Отладка анимаций";
	}
}

class LockWeeksOption extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.weekUnlocked = 1;
		StoryMenuState.weekUnlocked = [true, true];
		confirm = false;
		trace('Weeks Locked');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return confirm ? "Confirm Story Reset" : "Reset Story Progress";
		else
			return confirm ? "Подтвердить сброс недель" : "Сброс прогресса недель";
	}
}

class ResetScoreOption extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.songScores = null;
		for (key in Highscore.songScores.keys())
		{
			Highscore.songScores[key] = 0;
		}
		FlxG.save.data.songCombos = null;
		for (key in Highscore.songCombos.keys())
		{
			Highscore.songCombos[key] = '';
		}
		confirm = false;
		trace('Highscores Wiped');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return confirm ? "Confirm Score Reset" : "Reset Score";
		else
			return confirm ? "Подтвердить сброс очков" : "Сбросить очки";
	}
}

class ResetSettings extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!FlxG.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.weekUnlocked = null;
		FlxG.save.data.newInput = null;
		FlxG.save.data.downscroll = null;
		FlxG.save.data.antialiasing = null;
		FlxG.save.data.missSounds = null;
		FlxG.save.data.dfjk = null;
		FlxG.save.data.accuracyDisplay = null;
		FlxG.save.data.offset = null;
		FlxG.save.data.songPosition = null;
		FlxG.save.data.fps = null;
		FlxG.save.data.changedHit = null;
		FlxG.save.data.fpsRain = null;
		FlxG.save.data.fpsCap = null;
		FlxG.save.data.scrollSpeed = null;
		FlxG.save.data.npsDisplay = null;
		FlxG.save.data.frames = null;
		FlxG.save.data.accuracyMod = null;
		FlxG.save.data.watermark = null;
		FlxG.save.data.ghost = null;
		FlxG.save.data.distractions = null;
		FlxG.save.data.colour = null;
		FlxG.save.data.flashing = null;
		FlxG.save.data.resetButton = null;
		FlxG.save.data.botplay = null;
		FlxG.save.data.cpuStrums = null;
		FlxG.save.data.strumline = null;
		FlxG.save.data.customStrumLine = null;
		FlxG.save.data.camzoom = null;
		FlxG.save.data.scoreScreen = null;
		FlxG.save.data.inputShow = null;
		FlxG.save.data.optimize = null;
		FlxG.save.data.cacheImages = null;
		FlxG.save.data.editor = null;
		FlxG.save.data.laneTransparency = 0;
		FlxG.save.data.menuMusic = null;
		FlxG.save.data.noteskin = null;
		FlxG.save.data.modConfig = null;
		FlxG.save.data.weekCompleted = null;
		FlxG.save.data.logWriter = null;
		FlxG.save.data.enablePsychInterface = null;
		FlxG.save.data.notesplashes = null;
		FlxG.save.data.fullscreenOnStart = null;

		EngineData.initSave();
		confirm = false;
		trace('All settings have been reset');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!FlxG.save.data.language)
			return confirm ? "Confirm Settings Reset" : "Reset Settings";
		else
			return confirm ? "Подтвердить сброс настроек" : "Сбросить настройки";
	}
}
