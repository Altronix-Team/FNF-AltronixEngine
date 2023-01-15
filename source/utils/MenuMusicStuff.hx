package utils;


class MenuMusicStuff
{
	public static var musicArray = [];

	public static function updateMusic()
	{
		musicArray = [];
		for (i in AssetsUtil.listAssetsInPath('core/music/', MUSIC))
		{
			var str = i.replaceAll('.ogg', '').replaceAll('.mp3', '');
			if (!musicArray.contains(str))
			{
				musicArray.push(str);
			}
		}

		return musicArray;
	}

	public static function getMusic()
	{
		return musicArray;
	}

	public static function getMusicByID(id:Int)
	{
		return musicArray[id];
	}
}	
