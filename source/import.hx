#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#else
import altronixengine.core.*;
import altronixengine.data.*;
import flixel.FlxG;
import altronixengine.utils.*;
#if VIDEOS_ALLOWED
import hxvlc.flixel.*;
import hxvlc.openfl.*;
#end
#end

using StringTools;
using hx.strings.Strings;
using altronixengine.utils.ConvertUtil;
