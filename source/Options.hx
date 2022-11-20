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
		if (!Main.save.data.language)
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
		if (!Main.save.data.language)
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
			Main.save.data.upBind = text;
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
		if (!Main.save.data.language)
			return "UP: " + (waitingType ? "> " + Main.save.data.upBind + " <" : Main.save.data.upBind) + "";
		else
			return "Вверх: " + (waitingType ? "> " + Main.save.data.upBind + " <" : Main.save.data.upBind) + "";
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
			Main.save.data.downBind = text;
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
		if (!Main.save.data.language)
			return "DOWN: " + (waitingType ? "> " + Main.save.data.downBind + " <" : Main.save.data.downBind) + "";
		else
			return "Вниз: " + (waitingType ? "> " + Main.save.data.downBind + " <" : Main.save.data.downBind) + "";
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
			Main.save.data.rightBind = text;
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
		if (!Main.save.data.language)
			return "RIGHT: " + (waitingType ? "> " + Main.save.data.rightBind + " <" : Main.save.data.rightBind) + "";
		else
			return "Вправо: " + (waitingType ? "> " + Main.save.data.rightBind + " <" : Main.save.data.rightBind) + "";
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
			Main.save.data.leftBind = text;
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
		if (!Main.save.data.language)
			return "LEFT: " + (waitingType ? "> " + Main.save.data.leftBind + " <" : Main.save.data.leftBind) + "";
		else
			return "Влево: " + (waitingType ? "> " + Main.save.data.leftBind + " <" : Main.save.data.leftBind) + "";
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
			Main.save.data.attackBind = text;
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
		if (!Main.save.data.language)
			return "ATTACK: " + (waitingType ? "> " + Main.save.data.attackBind + " <" : Main.save.data.attackBind) + "";
		else
			return "Атака: " + (waitingType ? "> " + Main.save.data.attackBind + " <" : Main.save.data.attackBind) + "";
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
			Main.save.data.pauseBind = text;
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
		if (!Main.save.data.language)
			return "PAUSE: " + (waitingType ? "> " + Main.save.data.pauseBind + " <" : Main.save.data.pauseBind) + "";
		else
			return "Пауза: " + (waitingType ? "> " + Main.save.data.pauseBind + " <" : Main.save.data.pauseBind) + "";
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
			Main.save.data.resetBind = text;
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
		if (!Main.save.data.language)
			return "RESET: " + (waitingType ? "> " + Main.save.data.resetBind + " <" : Main.save.data.resetBind) + "";
		else
			return "Сбросить: " + (waitingType ? "> " + Main.save.data.resetBind + " <" : Main.save.data.resetBind) + "";
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
			Main.save.data.muteBind = text;
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
		if (!Main.save.data.language)
			return "VOLUME MUTE: " + (waitingType ? "> " + Main.save.data.muteBind + " <" : Main.save.data.muteBind) + "";
		else
			return "Заглушить звук: " + (waitingType ? "> " + Main.save.data.muteBind + " <" : Main.save.data.muteBind) + "";
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
			Main.save.data.volUpBind = text;
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
		if (!Main.save.data.language)
			return "VOLUME UP: " + (waitingType ? "> " + Main.save.data.volUpBind + " <" : Main.save.data.volUpBind) + "";
		else
			return "Повысить громкость: " + (waitingType ? "> " + Main.save.data.volUpBind + " <" : Main.save.data.volUpBind) + "";
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
			Main.save.data.volDownBind = text;
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
		if (!Main.save.data.language)
			return "VOLUME DOWN: " + (waitingType ? "> " + Main.save.data.volDownBind + " <" : Main.save.data.volDownBind) + "";
		else
			return "Понизить громкость: " + (waitingType ? "> " + Main.save.data.volDownBind + " <" : Main.save.data.volDownBind) + "";
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
			Main.save.data.fullscreenBind = text;
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
		if (!Main.save.data.language)
			return "FULLSCREEN:  " + (waitingType ? "> " + Main.save.data.fullscreenBind + " <" : Main.save.data.fullscreenBind) + "";
		else
			return "Полный экран:  " + (waitingType ? "> " + Main.save.data.fullscreenBind + " <" : Main.save.data.fullscreenBind) + "";
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
			Main.save.data.upBindP2 = text;
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
		if (!Main.save.data.language)
			return "UP (P2): " + (waitingType ? "> " + Main.save.data.upBindP2 + " <" : Main.save.data.upBindP2) + "";
		else
			return "Вверх (игрок 2): " + (waitingType ? "> " + Main.save.data.upBindP2 + " <" : Main.save.data.upBindP2) + "";
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
			Main.save.data.downBindP2 = text;
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
		if (!Main.save.data.language)
			return "DOWN (P2): " + (waitingType ? "> " + Main.save.data.downBindP2 + " <" : Main.save.data.downBindP2) + "";
		else
			return "Вниз (игрок 2): " + (waitingType ? "> " + Main.save.data.downBindP2 + " <" : Main.save.data.downBindP2) + "";
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
			Main.save.data.rightBindP2 = text;
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
		if (!Main.save.data.language)
			return "RIGHT (P2): " + (waitingType ? "> " + Main.save.data.rightBindP2 + " <" : Main.save.data.rightBindP2) + "";
		else
			return "Вправо (игрок 2): " + (waitingType ? "> " + Main.save.data.rightBindP2 + " <" : Main.save.data.rightBindP2) + "";
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
			Main.save.data.leftBindP2 = text;
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
		if (!Main.save.data.language)
			return "LEFT (P2): " + (waitingType ? "> " + Main.save.data.leftBindP2 + " <" : Main.save.data.leftBindP2) + "";
		else
			return "Влево (игрок 2): " + (waitingType ? "> " + Main.save.data.leftBindP2 + " <" : Main.save.data.leftBindP2) + "";
	}
}

class SickMSOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (!Main.save.data.language)
			description = desc + " (Press R to reset)";
		else
			description = desc + " (Нажмите R для сброса)";
		acceptType = true;
	}

	public override function left():Bool
	{
		Main.save.data.sickMs--;
		if (Main.save.data.sickMs < 0)
			Main.save.data.sickMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		Main.save.data.sickMs++;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			Main.save.data.sickMs = 45;
	}

	private override function updateDisplay():String
	{
		return "SICK: < " + Main.save.data.sickMs + " ms >";
	}
}

class GoodMsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (!Main.save.data.language)
			description = desc + " (Press R to reset)";
		else
			description = desc + " (Нажмите R для сброса)";
		acceptType = true;
	}

	public override function left():Bool
	{
		Main.save.data.goodMs--;
		if (Main.save.data.goodMs < 0)
			Main.save.data.goodMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		Main.save.data.goodMs++;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			Main.save.data.goodMs = 90;
	}

	private override function updateDisplay():String
	{
		return "GOOD: < " + Main.save.data.goodMs + " ms >";
	}
}

class BadMsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (!Main.save.data.language)
			description = desc + " (Press R to reset)";
		else
			description = desc + " (Нажмите R для сброса)";
		acceptType = true;
	}

	public override function left():Bool
	{
		Main.save.data.badMs--;
		if (Main.save.data.badMs < 0)
			Main.save.data.badMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		Main.save.data.badMs++;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			Main.save.data.badMs = 135;
	}

	private override function updateDisplay():String
	{
		return "BAD: < " + Main.save.data.badMs + " ms >";
	}
}

class ShitMsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (!Main.save.data.language)
			description = desc + " (Press R to reset)";
		else
			description = desc + " (Нажмите R для сброса)";
		acceptType = true;
	}

	public override function left():Bool
	{
		Main.save.data.shitMs--;
		if (Main.save.data.shitMs < 0)
			Main.save.data.shitMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			Main.save.data.shitMs = 160;
	}

	public override function right():Bool
	{
		Main.save.data.shitMs++;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "SHIT: < " + Main.save.data.shitMs + " ms >";
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
		Main.save.data.cacheImages = !Main.save.data.cacheImages;

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
		Main.save.data.editorBG = !Main.save.data.editorBG;

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
		if (!Main.save.data.language)
			return "Editor Grid: < " + (Main.save.data.editorBG ? "Shown" : "Hidden") + " >";
		else
			return "Сетка редактора: < " + (Main.save.data.editorBG ? "Показывается" : "Скрытая") + " >";
	}
}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		/*if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.downscroll = !Main.save.data.downscroll;
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
		if (!Main.save.data.language)
			return "Scroll: < " + (Main.save.data.downscroll ? "Downscroll" : "Upscroll") + " >";
		else
			return "Прокручивание: < " + (Main.save.data.downscroll ? "Сверху-вниз" : "Снизу-вверх") + " >";
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
		Main.save.data.ghost = !Main.save.data.ghost;
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
		if (!Main.save.data.language)
			return "Ghost Tapping: < " + (Main.save.data.ghost ? "Enabled" : "Disabled") + " >";
		else
			return "Призрачные нажатия: < " + (Main.save.data.ghost ? "Включено" : "Выключено") + " >";
	}
}

class AccuracyOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.accuracyDisplay = !Main.save.data.accuracyDisplay;
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
		if (!Main.save.data.language)
			return "Accuracy Display < " + (!Main.save.data.accuracyDisplay ? "off" : "on") + " >";
		else
			return "Отображение точности < " + (!Main.save.data.accuracyDisplay ? "выключено" : "включено") + " >";
	}
}

class SongPositionOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.songPosition = !Main.save.data.songPosition;
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
		if (!Main.save.data.language)
			return "Song Position Bar: < " + (!Main.save.data.songPosition ? "off" : "on") + " >";
		else
			return "Полоса позиции песни: < " + (!Main.save.data.songPosition ? "выключено" : "включено") + " >";
	}
}

class DistractionsAndEffectsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.distractions = !Main.save.data.distractions;
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
		if (!Main.save.data.language)
			return "Distractions: < " + (!Main.save.data.distractions ? "off" : "on") + " >";
		else
			return "Раздражители: < " + (!Main.save.data.distractions ? "выключены" : "включены") + " >";
	}
}

class Colour extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.colour = !Main.save.data.colour;
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
		if (!Main.save.data.language)
			return "Colored HP Bars: < " + (Main.save.data.colour ? "Enabled" : "Disabled") + " >";
		else
			return "Цветные полосы здоровья: < " + (Main.save.data.colour ? "Включены" : "Выключены") + " >";
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
		Main.save.data.resetButton = !Main.save.data.resetButton;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!Main.save.data.language)
			return "Reset Button: < " + (!Main.save.data.resetButton ? "off" : "on") + " >";
		else
			return "Кнопка сброса: < " + (!Main.save.data.resetButton ? "выключено" : "включено") + " >";
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
		Main.save.data.InstantRespawn = !Main.save.data.InstantRespawn;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!Main.save.data.language)
			return "Instant Respawn: < " + (!Main.save.data.InstantRespawn ? "off" : "on") + " >";
		else
			return "Мгновенное возрождение: < " + (!Main.save.data.InstantRespawn ? "выключено" : "включено") + " >";
	}
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.flashing = !Main.save.data.flashing;
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
		if (!Main.save.data.language)
			return "Flashing Lights: < " + (!Main.save.data.flashing ? "off" : "on") + " >";
		else
			return "Мигающие огни: < " + (!Main.save.data.flashing ? "выключены" : "включены") + " >";
	}
}

class AntialiasingOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.antialiasing = !Main.save.data.antialiasing;
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
		if (!Main.save.data.language)
			return "Antialiasing: < " + (!Main.save.data.antialiasing ? "off" : "on") + " >";
		else
			return "Сглаживание: < " + (!Main.save.data.antialiasing ? "выключено" : "включено") + " >";
	}
}

class MissSoundsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.missSounds = !Main.save.data.missSounds;
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
		if (!Main.save.data.language)
			return "Miss Sounds: < " + (!Main.save.data.missSounds ? "off" : "on") + " >";
		else
			return "Звуки пропуска стрелок: < " + (!Main.save.data.missSounds ? "выключены" : "включены") + " >";
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
		Main.save.data.inputShow = !Main.save.data.inputShow;
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
		if (!Main.save.data.language)
			return "Score Screen Debug: < " + (Main.save.data.inputShow ? "Enabled" : "Disabled") + " >";
		else
			return "Отладка экрана счёта: < " + (Main.save.data.inputShow ? "Включена" : "Выключена") + " >";
	}
}

class Judgement extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		if (!Main.save.data.language)
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
		Main.save.data.fps = !Main.save.data.fps;
		(cast(Lib.current.getChildAt(0), Main)).toggleFPS(Main.save.data.fps);
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
		if (!Main.save.data.language)
			return "FPS Counter: < " + (!Main.save.data.fps ? "off" : "on") + " >";
		else
			return "Счётчик ФПС: < " + (!Main.save.data.fps ? "выключено" : "включено") + " >";
	}
}

class NoteSplashOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.notesplashes = !Main.save.data.notesplashes;
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
		if (!Main.save.data.language)
			return "Note Splashes: < " + (!Main.save.data.notesplashes ? "Disabled" : "Enabled") + " >";
		else
			return "Брызги нот: < " + (!Main.save.data.notesplashes ? "Выключены" : "Включены") + " >";
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
			if (!Main.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;

		curLocale = Main.save.data.localeStr;
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
		
		Main.save.data.localeStr = LanguageStuff.locales[selectedId];
		curLocale = Main.save.data.localeStr;
		if (curLocale == null)
		{
			curLocale = LanguageStuff.locales[0];
			Main.save.data.localeStr = curLocale;
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

		Main.save.data.localeStr = LanguageStuff.locales[selectedId];
		curLocale = Main.save.data.localeStr;
		if (curLocale == null)
		{	
			curLocale = LanguageStuff.locales[0];
			Main.save.data.localeStr = curLocale;
		}
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!Main.save.data.language)
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
		Main.save.data.scoreScreen = !Main.save.data.scoreScreen;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!Main.save.data.language)
			return "Score Screen: < " + (Main.save.data.scoreScreen ? "Enabled" : "Disabled") + " >";
		else
			return "Экран счёта: < " + (Main.save.data.scoreScreen ? "Включен" : "Выключен") + " >";
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
		if (!Main.save.data.language)
			return "FPS Cap: < " + Main.save.data.fpsCap + " >";
		else
			return "Ограничение ФПС: < " + Main.save.data.fpsCap + " >";
	}

	override function right():Bool
	{
		if (Main.save.data.fpsCap >= 290)
		{
			Main.save.data.fpsCap = 290;
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);
		}
		else
			Main.save.data.fpsCap = Main.save.data.fpsCap + 10;
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(Main.save.data.fpsCap);

		return true;
	}

	override function left():Bool
	{
		if (Main.save.data.fpsCap > 290)
			Main.save.data.fpsCap = 290;
		else if (Main.save.data.fpsCap < 60)
			Main.save.data.fpsCap = Application.current.window.displayMode.refreshRate;
		else
			Main.save.data.fpsCap = Main.save.data.fpsCap - 10;
				(cast(Lib.current.getChildAt(0), Main)).setFPSCap(Main.save.data.fpsCap);
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
		if (!Main.save.data.language)
			return "Scroll Speed: < " + CoolUtil.truncateFloat(Main.save.data.scrollSpeed, 1) + " >";
		else
			return "Скорость прокручивания: < " + CoolUtil.truncateFloat(Main.save.data.scrollSpeed, 1) + " >";
	}

	override function right():Bool
	{
		Main.save.data.scrollSpeed += 0.1;

		if (Main.save.data.scrollSpeed < 1)
			Main.save.data.scrollSpeed = 1;

		if (Main.save.data.scrollSpeed > 4)
			Main.save.data.scrollSpeed = 4;
		return true;
	}

	override function getValue():String
	{
		return updateDisplay();
	}

	override function left():Bool
	{
		Main.save.data.scrollSpeed -= 0.1;

		if (Main.save.data.scrollSpeed < 1)
			Main.save.data.scrollSpeed = 1;

		if (Main.save.data.scrollSpeed > 4)
			Main.save.data.scrollSpeed = 4;

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
		Main.save.data.fpsRain = !Main.save.data.fpsRain;
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
		if (!Main.save.data.language)
			return "FPS Rainbow: < " + (!Main.save.data.fpsRain ? "off" : "on") + " >";
		else
			return "Радужное переливание ФПС: < " + (!Main.save.data.fpsRain ? "выключено" : "включено") + " >";
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

class AccuracyDOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.accuracyMod = Main.save.data.accuracyMod == 1 ? 0 : 1;
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
		if (!Main.save.data.language)
			return "Accuracy Mode: < " + (Main.save.data.accuracyMod == 0 ? "Accurate" : "Complex") + " >";
		else
			return "Режим точности: < " + (Main.save.data.accuracyMod == 0 ? "Точная" : "Сложная") + " >";
	}
}

class CustomizeGameplay extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		if (!Main.save.data.language)
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
			if (!Main.save.data.language)
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
		Main.save.data.memoryCount = Main.memoryCount;
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
		if (!Main.save.data.language)
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
			if (!Main.save.data.language)
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
		Main.save.data.watermark = Main.watermarks;
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
		if (!Main.save.data.language)
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
		if (!Main.save.data.language)
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
			if (!Main.save.data.language)
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
		Main.save.data.offset--;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		Main.save.data.offset++;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!Main.save.data.language)
			return "Note offset: < " + CoolUtil.truncateFloat(Main.save.data.offset, 0) + " >";
		else
			return "Смещение стрелок: < " + CoolUtil.truncateFloat(Main.save.data.offset, 0) + " >";
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
			if (!Main.save.data.language)
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
		
		Main.save.data.botplay = !Main.save.data.botplay;
		trace('BotPlay : ' + Main.save.data.botplay);
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
		if (!Main.save.data.language)
			return "BotPlay: < " + (Main.save.data.botplay ? "on" : "off") + " >";
		else
			return "Бот: < " + (Main.save.data.botplay ? "включено" : "выключено") + " >";
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
		Main.save.data.logWriter = !Main.save.data.logWriter;
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
		if (!Main.save.data.language)
			return "Log Writer: < " + (Main.save.data.logWriter ? "off" : "on") + " >";
		else
			return "Логирование: < " + (Main.save.data.logWriter ? "выключено" : "включено") + " >";
	}
}

class FullscreenOnStartOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.fullscreenOnStart = !Main.save.data.fullscreenOnStart;
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
		if (!Main.save.data.language)
			return "Full screen when starting the game: < " + (!Main.save.data.fullscreenOnStart ? "off" : "on") + " >";
		else
			return "Полный экран при запуске игры: < " + (!Main.save.data.fullscreenOnStart ? "выключено" : "включено") + " >";
	}
}

class CamZoomOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.camzoom = !Main.save.data.camzoom;
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
		if (!Main.save.data.language)
			return "Camera Zoom: < " + (!Main.save.data.camzoom ? "off" : "on") + " >";
		else
			return "Приближение камеры: < " + (!Main.save.data.camzoom ? "выключено" : "включено") + " >";
	}
}

class JudgementCounter extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.judgementCounter = !Main.save.data.judgementCounter;
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
		if (!Main.save.data.language)
			return "Judgement Counter: < " + (Main.save.data.judgementCounter ? "Enabled" : "Disabled") + " >";
		else
			return "Счётчик оценок: < " + (Main.save.data.judgementCounter ? "Включено" : "Выключено") + " >";
	}
}

class MiddleScrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		/*if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.middleScroll = !Main.save.data.middleScroll;
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
		if (!Main.save.data.language)
			return "Middle Scroll: < " + (Main.save.data.middleScroll ? "Enabled" : "Disabled") + " >";
		else
			return "Прокручивание в центре: < " + (Main.save.data.middleScroll ? "Включено" : "Выключено") + " >";
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
			if (!Main.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;

		if (Std.isOfType(Main.save.data.noteskin, String))
			curSkin = Main.save.data.noteskin;
		else if (Std.isOfType(Main.save.data.noteskin, Int))
			curSkin = NoteskinHelpers.getNoteskinByID(Main.save.data.noteskin);

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
		Main.save.data.noteskin = curSkin;

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
		Main.save.data.noteskin = curSkin;

		display = updateDisplay();
		return true;
	}

	public override function getValue():String
	{
		if (!Main.save.data.language)
			return "Current Noteskin: < " + curSkin + " >";
		else
			return "Выбранный вид стрелок: < " + curSkin + " >";
	}
}

class MenuMusicOption extends Option
{
	var curSelectedId:Int = 0;
	var curMusic:String = 'freakyMenu';

	public function new(desc:String)
	{
		super();
		description = desc;

		if (Std.isOfType(Main.save.data.menuMusic, String))
			curMusic = Main.save.data.menuMusic;
		else if (Std.isOfType(Main.save.data.menuMusic, Int))
			curMusic = Main.save.data.menuMusic;

		if (MenuMusicStuff.musicArray.contains(curMusic))
			curSelectedId = MenuMusicStuff.musicArray.indexOf(curMusic);
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		curSelectedId--;
		if (curSelectedId < 0)
			curSelectedId = MenuMusicStuff.getMusic().length - 1;

		curMusic = MenuMusicStuff.getMusicByID(curSelectedId);
		Main.save.data.menuMusic = curMusic;

		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		curSelectedId++;
		if (curSelectedId > MenuMusicStuff.getMusic().length - 1)
			curSelectedId = 0;

		curMusic = MenuMusicStuff.getMusicByID(curSelectedId);
		Main.save.data.menuMusic = curMusic;

		display = updateDisplay();
		return true;
	}

	public override function getValue():String
	{
		if (!FlxG.sound.music.playing)
		{
			if (!OptionsMenu.isInPause)
				FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(curSelectedId)));
		}
		else
		{
			if (!OptionsMenu.isInPause)
			{
				FlxG.sound.music.stop();
				FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(curSelectedId)));
			}
		}
		
		if (!Main.save.data.language)
			return "Current Menu Music: < " + curMusic + " >";
		else
			return "Выбранная музыка меню: < " + curMusic + " >";
	}
}

class HealthBarOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
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
		Main.save.data.healthBar = !Main.save.data.healthBar;
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
		if (!Main.save.data.language)
			return "Health Bar: < " + (Main.save.data.healthBar ? "Enabled" : "Disabled") + " >";
		else
			return "Полоса здоровья: < " + (Main.save.data.healthBar ? "Включено" : "Выключено") + " >";
	}
}

class LaneUnderlayOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			if (!Main.save.data.language)
				description = "This option cannot be toggled in the pause menu.";
			else
				description = "Эта опция не может быть переключена во время паузы";
		else
			description = desc;
		acceptValues = true;
	}

	private override function updateDisplay():String
	{
		if (!Main.save.data.language)
			return "Lane Transparceny: < " + CoolUtil.truncateFloat(Main.save.data.laneTransparency, 1) + " >";
		else
			return "Прозрачность полосы здоровья: < " + CoolUtil.truncateFloat(Main.save.data.laneTransparency, 1) + " >";
	}

	override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		Main.save.data.laneTransparency += 0.1;

		if (Main.save.data.laneTransparency > 1)
			Main.save.data.laneTransparency = 1;
		return true;
	}

	override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		Main.save.data.laneTransparency -= 0.1;

		if (Main.save.data.laneTransparency < 0)
			Main.save.data.laneTransparency = 0;

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
		if (!Main.save.data.language)
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
			if (!Main.save.data.language)
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
		Main.save.data.weekUnlocked = 1;
		StoryMenuState.weekUnlocked = [true, true];
		confirm = false;
		trace('Weeks Locked');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!Main.save.data.language)
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
			if (!Main.save.data.language)
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
		Main.save.data.songScores = null;
		for (key in Highscore.songScores.keys())
		{
			Highscore.songScores[key] = 0;
		}
		Main.save.data.songCombos = null;
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
		if (!Main.save.data.language)
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
			if (!Main.save.data.language)
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
		Main.save.data.weekUnlocked = null;
		Main.save.data.newInput = null;
		Main.save.data.downscroll = null;
		Main.save.data.antialiasing = null;
		Main.save.data.missSounds = null;
		Main.save.data.dfjk = null;
		Main.save.data.accuracyDisplay = null;
		Main.save.data.offset = null;
		Main.save.data.songPosition = null;
		Main.save.data.fps = null;
		Main.save.data.changedHit = null;
		Main.save.data.fpsRain = null;
		Main.save.data.fpsCap = null;
		Main.save.data.scrollSpeed = null;
		Main.save.data.frames = null;
		Main.save.data.accuracyMod = null;
		Main.save.data.watermark = null;
		Main.save.data.ghost = null;
		Main.save.data.distractions = null;
		Main.save.data.colour = null;
		Main.save.data.flashing = null;
		Main.save.data.resetButton = null;
		Main.save.data.botplay = null;
		Main.save.data.cpuStrums = null;
		Main.save.data.strumline = null;
		Main.save.data.customStrumLine = null;
		Main.save.data.camzoom = null;
		Main.save.data.scoreScreen = null;
		Main.save.data.inputShow = null;
		Main.save.data.optimize = null;
		Main.save.data.cacheImages = null;
		Main.save.data.editor = null;
		Main.save.data.laneTransparency = 0;
		Main.save.data.menuMusic = null;
		Main.save.data.noteskin = null;
		Main.save.data.modConfig = null;
		Main.save.data.weekCompleted = null;
		Main.save.data.logWriter = null;
		Main.save.data.notesplashes = null;
		Main.save.data.fullscreenOnStart = null;

		EngineData.initSave();
		confirm = false;
		trace('All settings have been reset');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		if (!Main.save.data.language)
			return confirm ? "Confirm Settings Reset" : "Reset Settings";
		else
			return confirm ? "Подтвердить сброс настроек" : "Сбросить настройки";
	}
}
