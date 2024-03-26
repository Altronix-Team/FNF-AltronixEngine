package altronixengine.data;

class EngineConstants
{
	public static final engineVer:String = "1.0.0";
	public static final funkinVer:String = "0.2.8";
	public static final defaultStages:Array<String> = [
		'stage',
		'halloween',
		'philly',
		'limo',
		'mall',
		'mallEvil',
		'school',
		'schoolEvil',
		'warzone'
	];
	public static final defaultCharacters:Array<String> = [
		'bf', 'dad', 'gf', 'spooky', 'pico', 'mom', 'mom-car', 'bf-car', 'gf-car', 'parents-christmas', 'monster-christmas', 'bf-christmas', 'gf-christmas',
		'monster', 'bf-pixel', 'gf-pixel', 'senpai', 'senpai-angry', 'spirit', 'tankman', 'gftank', 'bfAndGF', 'picospeaker', 'pico-player', 'nogf',
		'bfAndGF-DEAD', 'bf-pixel-dead', 'picospeaker-player'
	];
	public static final defaultGFs:Array<String> = ['gf', 'gf-car', 'gf-christmas', 'gf-pixel', 'gftank', 'picospeaker', 'nogf'];
	public static final screenResolution169:Array<Array<Int>> = [
		[1024, 576],
		[1152, 648],
		[1280, 720],
		[1366, 768],
		[1600, 900],
		[1920, 1080],
		[2560, 1440],
		[3840, 2160],
		[7680, 4320]
	];
	public static final defaultAchievementsArray:Array<altronixengine.core.Achievements.AchievementData> = [
		{
			displayedName: 'First Play!',
			displayedDescription: 'Start an Altronix Engine',
			saveId: 'first_start',
			isHidden: false,
			imageName: 'engine'
		},
		{
			displayedName: 'Friday Night Funkin\'',
			displayedDescription: 'Complete the standart game without misses',
			saveId: 'vanila_game_completed',
			isHidden: false,
			imageName: 'vanilaGame'
		},
		{
			displayedName: 'New opponents!',
			displayedDescription: 'Download mod for Altronix Engine',
			saveId: 'download_mod',
			isHidden: false,
			imageName: 'mods'
		},
		{
			displayedName: 'Lemon?',
			displayedDescription: 'Start Monster song',
			saveId: 'monster_song',
			isHidden: true,
			imageName: 'lemon'
		},
		{
			displayedName: 'HE CAN SHOOT!!!',
			displayedDescription: 'Lose on week 3',
			saveId: 'week3_lose',
			isHidden: true,
			imageName: 'dead'
		},
		{
			displayedName: 'Biginning of corruption mod',
			displayedDescription: 'Die on Winter Horrorland',
			saveId: 'corruption',
			isHidden: true,
			imageName: 'corruption'
		},
		{
			displayedName: 'Hooray, freedom',
			displayedDescription: 'Lose on Thorns song',
			saveId: 'thorns_lose',
			isHidden: true,
			imageName: 'dead-pixel'
		},
		{
			displayedName: 'This is WAR!!!',
			displayedDescription: 'Lose on Stress song',
			saveId: 'stress_lose',
			isHidden: true,
			imageName: 'dead-withGf'
		},
		{
			displayedName: 'DadBattled',
			displayedDescription: 'Complete week 1 on Hard or Hard Plus without misses',
			saveId: 'week1_nomiss',
			isHidden: false,
			imageName: 'week1'
		},
		{
			displayedName: 'Spooky month!!',
			displayedDescription: 'Complete week 2 on Hard or Hard Plus without misses',
			saveId: 'week2_nomiss',
			isHidden: false,
			imageName: 'week2'
		},
		{
			displayedName: 'Go Pico yeah!',
			displayedDescription: 'Complete week 3 on Hard or Hard Plus without misses',
			saveId: 'week3_nomiss',
			isHidden: false,
			imageName: 'week3'
		},
		{
			displayedName: 'WoW, M.I.L.F!!',
			displayedDescription: 'Complete week 4 on Hard or Hard Plus without misses',
			saveId: 'week4_nomiss',
			isHidden: false,
			imageName: 'week4'
		},
		{
			displayedName: 'Did Santa survive?',
			displayedDescription: 'Complete week 5 on Hard or Hard Plus without misses',
			saveId: 'week5_nomiss',
			isHidden: false,
			imageName: 'week5'
		},
		{
			displayedName: 'We need antivirus!',
			displayedDescription: 'Complete week 6 on Hard or Hard Plus without misses',
			saveId: 'week6_nomiss',
			isHidden: false,
			imageName: 'week6'
		},
		{
			displayedName: 'Ugh, Pretty Good',
			displayedDescription: 'Complete week 7 on Hard or Hard Plus without misses',
			saveId: 'week7_nomiss',
			isHidden: false,
			imageName: 'week7'
		},
	];
}
