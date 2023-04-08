#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#else
import flixel.FlxG;
import utils.*;
#end

#if USE_YAML
import yaml.Yaml;
#end

using StringTools;
using hx.strings.Strings;
using utils.ConvertUtil;