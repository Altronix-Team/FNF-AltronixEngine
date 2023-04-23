#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#else
import data.*;
import flixel.FlxG;
import utils.*;
import core.*;
#end

#if USE_YAML
import yaml.Yaml;
#end

using StringTools;
using hx.strings.Strings;
using utils.ConvertUtil;
