
using hx.strings.Strings;

class MenuMusicStuff
{
	public static var musicArray = [];

	public static function updateMusic()
	{
		musicArray = [];
		var count:Int = 0;
		musicArray.push('freakyMenu');
		for (i in Paths.listMusicInPath('assets/music/'))
		{
			if (i.endsWith('.ogg'))
				musicArray.push(i.replaceAll('.ogg', ''));	

			if (i == 'freakyMenu')
				continue;

			if (i.endsWith('.mp3'))
				musicArray.push(i.replaceAll('.mp3', ''));
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
