package gameplayStuff;


import openfl.utils.Assets;

typedef StageFile = {
	var defaultZoom:Float;
	var isPixelStage:Bool;
	var hideGF:Bool;

	var boyfriend:Array<Float>;
	var gf:Array<Float>;
	var dad:Array<Float>;

	var camera_boyfriend:Array<Float>;
	var camera_opponent:Array<Float>;
	var camera_girlfriend:Array<Float>;
	var camera_speed:Null<Float>;
}

class StageData {
	public static function getStageFile(stage:String):StageFile {
		var rawJson:String = null;
		var retVal:StageFile = {
			defaultZoom: 0.9,
			isPixelStage: false,
			hideGF: false,

			boyfriend: [770, 450],
			gf: [400, 130],
			dad: [100, 100],

			camera_boyfriend: [0, 0],
			camera_opponent: [0, 0],
			camera_girlfriend: [0, 0],
			camera_speed: 1
		};
		
		if (Assets.exists(Paths.json('stages/$stage', 'gameplay'))){
			retVal = cast AssetsUtil.loadAsset('stages/$stage', JSON, 'gameplay');
		}
		else
		{
			return retVal;
		}
		return retVal;
	}
}