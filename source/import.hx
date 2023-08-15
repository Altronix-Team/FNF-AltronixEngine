#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#else
import core.*;
import data.*;
import flixel.FlxG;
import utils.*;
#end
#if USE_YAML
import yaml.Yaml;
#end

using StringTools;
using hx.strings.Strings;
using utils.ConvertUtil;
