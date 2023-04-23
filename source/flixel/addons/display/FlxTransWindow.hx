package flixel.addons.display;

/**
 * @see https://github.com/DuskieWhy/Transparent-and-MultiWindow-FNF
 * Credits:
 *	DuskieWhy @see https://twitter.com/DuskieWhy
 *	TaeYai @see https://twitter.com/TaeYai
 *	BreezyMelee @see https://twitter.com/BreezyMelee
 *	YoshiCrafter @see https://twitter.com/YoshiCrafter29 - Additional help
 *	KadeDev @see https://twitter.com/kade0912 - Transparent window .hx file code
 */
@:cppFileCode('#include <windows.h>\n#include <dwmapi.h>\n\n#pragma comment(lib, "Dwmapi")')
class FlxTransWindow
{
	@:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) | WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(1, 1, 1), 0, LWA_COLORKEY);
        }
    ')
	static public function getWindowsTransparent(res:Int = 0)
	{
		return res;
	}

	@:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) ^ WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(1, 1, 1), 1, LWA_COLORKEY);
        }
    ')
	static public function getWindowsbackward(res:Int = 0)
	{
		return res;
	}
}
