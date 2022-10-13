package utils;

//well

@:autoBuild(flixel.system.FlxAssets.buildFileReferences("assets/images", true))
@:autoBuild(flixel.system.FlxAssets.buildFileReferences("assets/shared/images", true))
class Images{}

@:autoBuild(flixel.system.FlxAssets.buildFileReferences("assets/", true, ['lua', 'hscript']))
class Scripts{}