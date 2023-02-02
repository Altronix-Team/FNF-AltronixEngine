package gameplayStuff;

import flixel.group.FlxSpriteGroup;
import gameplayStuff.Section.SwagSection;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxRandom;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.effects.FlxFlicker;
import openfl.utils.Assets;
import flixel.util.FlxColor;
import states.PlayState;
import states.GameplayCustomizeState;
import gameplayStuff.StageData;
import WiggleEffect;
#if sys
import sys.FileSystem;
#end

@:hscriptClass()
class StageScript extends Stage implements polymod.hscript.HScriptedClass{}

class Stage extends FlxTypedGroup<FlxBasic> implements gameplayStuff.Conductor.IMusicBeat
{
	public var camZoom:Float; // The zoom of the camera to have at the start of the game

	// BGs still must be added by using toAdd Array for them to show in game after slowBacks take effect!!
	// BGs still must be added by using toAdd Array for them to show in game after slowBacks take effect!!
	// All of the above must be set or used in your stage case code block!!

	public var started:Bool = false;
	public var startedidle:Bool = false;

	var steve:FlxSprite;
	public var foregroundSprites:FlxTypedGroup<FlxSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;

	var wiggleShit:WiggleEffect;

	public var curStep:Int = 0;

	public var curBeat:Int = 0;

	public var curDecimalBeat:Float = 0;

	public var curSection:SwagSection = null;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public function new()
	{
		super();
		camZoom = 1.05; // Don't change zoom here, unless you want to change zoom of every stage that doesn't have custom one

		Main.fnfSignals.beatHit.add(_beatHit);
		Main.fnfSignals.sectionHit.add(_sectionHit);
		Main.fnfSignals.stepHit.add(_stepHit);
		Main.fnfSignals.decimalBeatHit.add(_decimalBeatHit);

		boyfriendGroup = new FlxSpriteGroup(PlayState.BF_X, PlayState.BF_Y);
		dadGroup = new FlxSpriteGroup(PlayState.DAD_X, PlayState.DAD_Y);
		gfGroup = new FlxSpriteGroup(PlayState.GF_X, PlayState.GF_Y);

		/*switch (daStage)
		{
			case 'halloween':
				{
					var hallowTex = Paths.getSparrowAtlas('weeks/assets/week2/images/halloween_bg', 'gameplay');

					var halloweenBG = new FlxSprite(-200, -80);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = Main.save.data.antialiasing;
					swagBacks['halloweenBG'] = halloweenBG;
					toAdd.push(halloweenBG);

					var halloweenWhite = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
					halloweenWhite.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.WHITE);
					halloweenWhite.alpha = 0;
					halloweenWhite.blend = ADD;
					swagBacks['halloweenWhite'] = halloweenWhite;
					toAdd.push(halloweenWhite);
				}
			case 'philly':
				{
					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.loadImage('weeks/assets/week3/images/philly/sky', 'gameplay'));
					bg.scrollFactor.set(0.1, 0.1);
					bg.antialiasing = Main.save.data.antialiasing;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.loadImage('weeks/assets/week3/images/philly/city', 'gameplay'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					city.antialiasing = Main.save.data.antialiasing;
					swagBacks['city'] = city;
					toAdd.push(city);


					//for (i in 0...5)
					//{
						//Lets change color for white windows instead of using different sprites
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.loadImage('weeks/assets/week3/images/philly/window', 'gameplay'));
						light.scrollFactor.set(0.3, 0.3);
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = Main.save.data.antialiasing;
						randomColor();
						light.color = windowColor;
						swagBacks['light'] = light;
						toAdd.push(light);
						//phillyCityLights.add(light);
					//}

					var streetBehind:FlxSprite = new FlxSprite(-40,
						50).loadGraphic(Paths.loadImage('weeks/assets/week3/images/philly/behindTrain', 'gameplay'));
					streetBehind.antialiasing = Main.save.data.antialiasing;
					swagBacks['streetBehind'] = streetBehind;
					toAdd.push(streetBehind);

					var phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.loadImage('weeks/assets/week3/images/philly/train', 'gameplay'));
					phillyTrain.antialiasing = Main.save.data.antialiasing;
					if (Main.save.data.distractions)
					{
						swagBacks['phillyTrain'] = phillyTrain;
						toAdd.push(phillyTrain);
					}

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40,
						streetBehind.y).loadGraphic(Paths.loadImage('weeks/assets/week3/images/philly/street', 'gameplay'));
					street.antialiasing = Main.save.data.antialiasing;
					swagBacks['street'] = street;
					toAdd.push(street);
				}
			case 'limo':
				{
					camZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.loadImage('weeks/assets/week4/images/limo/limoSunset', 'gameplay'));
					skyBG.scrollFactor.set(0.1, 0.1);
					skyBG.antialiasing = Main.save.data.antialiasing;
					swagBacks['skyBG'] = skyBG;
					toAdd.push(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('weeks/assets/week4/images/limo/bgLimo', 'gameplay');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					bgLimo.antialiasing = Main.save.data.antialiasing;
					swagBacks['bgLimo'] = bgLimo;
					toAdd.push(bgLimo);

					var fastCar:FlxSprite;
					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.loadImage('weeks/assets/week4/images/limo/fastCarLol', 'gameplay'));
					fastCar.antialiasing = Main.save.data.antialiasing;
					fastCar.visible = false;

					if (Main.save.data.distractions)
					{
						grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
						swagGroup['grpLimoDancers'] = grpLimoDancers;
						toAdd.push(grpLimoDancers);

						for (i in 0...5)
						{
							var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
							dancer.scrollFactor.set(0.4, 0.4);
							grpLimoDancers.add(dancer);
							swagBacks['dancer' + i] = dancer;
						}

						swagBacks['fastCar'] = fastCar;
						layInFront[2].push(fastCar);
						resetFastCar();
						//limoKillingState = 0;
					}

					var overlayShit:FlxSprite = new FlxSprite(-500,
						-600).loadGraphic(Paths.loadImage('weeks/assets/week4/images/limo/limoOverlay', 'gameplay'));
					overlayShit.alpha = 0.5;

					var limoTex = Paths.getSparrowAtlas('weeks/assets/week4/images/limo/limoDrive', 'gameplay');

					var limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = Main.save.data.antialiasing;
					layInFront[0].push(limo);
					swagBacks['limo'] = limo;
				}
			case 'mall':
				{
					camZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.loadImage('weeks/assets/week5/images/christmas/bgWalls', 'gameplay'));
					bg.antialiasing = Main.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('weeks/assets/week5/images/christmas/upperBop', 'gameplay');
					upperBoppers.animation.addByPrefix('idle', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = Main.save.data.antialiasing;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					if (Main.save.data.distractions)
					{
						swagBacks['upperBoppers'] = upperBoppers;
						toAdd.push(upperBoppers);
						animatedBacks.push(upperBoppers);
					}

					var bgEscalator:FlxSprite = new FlxSprite(-1100,
						-600).loadGraphic(Paths.loadImage('weeks/assets/week5/images/christmas/bgEscalator', 'gameplay'));
					bgEscalator.antialiasing = Main.save.data.antialiasing;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					swagBacks['bgEscalator'] = bgEscalator;
					toAdd.push(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370,
						-250).loadGraphic(Paths.loadImage('weeks/assets/week5/images/christmas/christmasTree', 'gameplay'));
					tree.antialiasing = Main.save.data.antialiasing;
					tree.scrollFactor.set(0.40, 0.40);
					swagBacks['tree'] = tree;
					toAdd.push(tree);

					var bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('weeks/assets/week5/images/christmas/bottomBop', 'gameplay');
					bottomBoppers.animation.addByPrefix('idle', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = Main.save.data.antialiasing;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					if (Main.save.data.distractions)
					{
						swagBacks['bottomBoppers'] = bottomBoppers;
						toAdd.push(bottomBoppers);
						animatedBacks.push(bottomBoppers);
					}

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.loadImage('weeks/assets/week5/images/christmas/fgSnow', 'gameplay'));
					fgSnow.active = false;
					fgSnow.antialiasing = Main.save.data.antialiasing;
					swagBacks['fgSnow'] = fgSnow;
					toAdd.push(fgSnow);

					var santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('weeks/assets/week5/images/christmas/santa', 'gameplay');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = Main.save.data.antialiasing;
					if (Main.save.data.distractions)
					{
						swagBacks['santa'] = santa;
						toAdd.push(santa);
						animatedBacks.push(santa);
					}
				}
			case 'mallEvil':
				{
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.loadImage('weeks/assets/week5/images/christmas/evilBG', 'gameplay'));
					bg.antialiasing = Main.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.loadImage('weeks/assets/week5/images/christmas/evilTree', 'gameplay'));
					evilTree.antialiasing = Main.save.data.antialiasing;
					evilTree.scrollFactor.set(0.2, 0.2);
					swagBacks['evilTree'] = evilTree;
					toAdd.push(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.loadImage("weeks/assets/week5/images/christmas/evilSnow", 'gameplay'));
					evilSnow.antialiasing = Main.save.data.antialiasing;
					swagBacks['evilSnow'] = evilSnow;
					toAdd.push(evilSnow);
				}
			case 'school':
				{
					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.loadImage('weeks/assets/week6/images/weeb/weebSky', 'gameplay'));
					bgSky.scrollFactor.set(0.1, 0.1);
					swagBacks['bgSky'] = bgSky;
					toAdd.push(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.loadImage('weeks/assets/week6/images/weeb/weebSchool', 'gameplay'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					swagBacks['bgSchool'] = bgSchool;
					toAdd.push(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.loadImage('weeks/assets/week6/images/weeb/weebStreet', 'gameplay'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					swagBacks['bgStreet'] = bgStreet;
					toAdd.push(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170,
						130).loadGraphic(Paths.loadImage('weeks/assets/week6/images/weeb/weebTreesBack', 'gameplay'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					swagBacks['fgTrees'] = fgTrees;
					toAdd.push(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeks/assets/week6/images/weeb/weebTrees', 'gameplay');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					swagBacks['bgTrees'] = bgTrees;
					toAdd.push(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeks/assets/week6/images/weeb/petals', 'gameplay');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					swagBacks['treeLeaves'] = treeLeaves;
					toAdd.push(treeLeaves);

					var bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (PlayState.SONG != null)
					{
						if (PlayState.SONG.scaredbgdancers)
						{
							if (Main.save.data.distractions)
								bgGirls.getScared();
						}
					}
					else if (GameplayCustomizeState.freeplaySong == 'roses')
					{
						if (Main.save.data.distractions)
							bgGirls.getScared();
					}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * CoolUtil.daPixelZoom));
					bgGirls.updateHitbox();
					if (Main.save.data.distractions)
					{
						swagBacks['bgGirls'] = bgGirls;
						toAdd.push(bgGirls);
					}
					if (PlayState.SONG != null)
					{
						if (PlayState.SONG.showbgdancers)
						{
							bgGirls.visible = true;	
						}
						else
							bgGirls.visible = false;
					}

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();
				}
			case 'schoolEvil':
				{
					var posX = 400;
					var posY = 200;
					 
					var bg:FlxSprite = new FlxSprite(posX + 10,
						posY + 165).loadGraphic(Paths.loadImage('weeks/assets/week6/images/weeb/evilSchoolBG', 'gameplay'));
					bg.scale.set(6, 6);
					swagBacks['bg'] = bg;
					toAdd.push(bg);	

					var fg:FlxSprite = new FlxSprite(posX + 10,
						posY + 165).loadGraphic(Paths.loadImage('weeks/assets/week6/images/weeb/evilSchoolFG', 'gameplay'));
					fg.scale.set(6, 6);
					swagBacks['fg'] = fg;
					toAdd.push(fg);	

					var effectType:Array<String> = ['DREAMY', 'WAVY', 'HEAT_WAVE_HORIZONTAL', 'HEAT_WAVE_VERTICAL', 'FLAG'];

					wiggleShit = new WiggleEffect(effectType[FlxG.random.int(0, effectType.length - 1)], 0.8, 60, 0.01);

					if (Main.save.data.distractions)
					{
						if (!PlayStateChangeables.Optimize)
						{
							bg.shader = wiggleShit.shader;
							fg.shader = wiggleShit.shader;
						}
					}					
				}
			case 'warzone':
				{
					camZoom = 0.9;

					var tankSky:FlxSprite = new FlxSprite(-400, -400).loadGraphic(Paths.loadImage('weeks/assets/week7/images/tankSky', 'gameplay'));
					tankSky.antialiasing = true;
					tankSky.scrollFactor.set(0, 0);
					swagBacks['tankSky'] = tankSky;
					toAdd.push(tankSky);

					var tankClouds:FlxSprite = new FlxSprite(-700, -100).loadGraphic(Paths.loadImage('weeks/assets/week7/images/tankClouds', 'gameplay'));
					tankClouds.antialiasing = true;
					tankClouds.scrollFactor.set(0.1, 0.1);
					swagBacks['tankClouds'] = tankClouds;
					toAdd.push(tankClouds);

					var tankMountains:FlxSprite = new FlxSprite(-300, -20).loadGraphic(Paths.loadImage('weeks/assets/week7/images/tankMountains', 'gameplay'));
					tankMountains.antialiasing = true;
					tankMountains.setGraphicSize(Std.int(tankMountains.width * 1.1));
					tankMountains.scrollFactor.set(0.2, 0.2);
					tankMountains.updateHitbox();
					swagBacks['tankMountains'] = tankMountains;
					toAdd.push(tankMountains);

					var tankBuildings:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.loadImage('weeks/assets/week7/images/tankBuildings', 'gameplay'));
					tankBuildings.antialiasing = true;
					tankBuildings.setGraphicSize(Std.int(tankBuildings.width * 1.1));
					tankBuildings.scrollFactor.set(0.3, 0.3);
					tankBuildings.updateHitbox();
					swagBacks['tankBuildings'] = tankBuildings;
					toAdd.push(tankBuildings);

					var tankRuins:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.loadImage('weeks/assets/week7/images/tankRuins', 'gameplay'));
					tankRuins.antialiasing = true;
					tankRuins.setGraphicSize(Std.int(tankRuins.width * 1.1));
					tankRuins.scrollFactor.set(0.35, 0.35);
					tankRuins.updateHitbox();
					swagBacks['tankRuins'] = tankRuins;
					toAdd.push(tankRuins);

					var smokeLeft:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('weeks/assets/week7/images/smokeLeft', 'gameplay'));
					smokeLeft.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/smokeLeft', 'gameplay');
					smokeLeft.animation.addByPrefix('idle', 'SmokeBlurLeft', 24, true);
					smokeLeft.animation.play('idle');
					smokeLeft.scrollFactor.set(0.4, 0.4);
					smokeLeft.antialiasing = true;
					swagBacks['smokeLeft'] = smokeLeft;
					toAdd.push(smokeLeft);

					var smokeRight:FlxSprite = new FlxSprite(1100, -100).loadGraphic(Paths.loadImage('weeks/assets/week7/images/smokeRight', 'gameplay'));
					smokeRight.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/smokeRight', 'gameplay');
					smokeRight.animation.addByPrefix('idle', 'SmokeRight', 24, true);
					smokeRight.animation.play('idle');
					smokeRight.scrollFactor.set(0.4, 0.4);
					smokeRight.antialiasing = true;
					swagBacks['smokeRight'] = smokeRight;
					toAdd.push(smokeRight);

					var tankWatchtower = new FlxSprite(100, 50);
					tankWatchtower.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tankWatchtower', 'gameplay');
					tankWatchtower.animation.addByPrefix('idle', 'watchtower gradient color', 24, false);
					tankWatchtower.animation.play('idle');
					tankWatchtower.scrollFactor.set(0.5, 0.5);
					tankWatchtower.antialiasing = true;
					swagBacks['tankWatchtower'] = tankWatchtower;
					toAdd.push(tankWatchtower);

					steve = new FlxSprite(300, 300);
					steve.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tankRolling', 'gameplay');
					steve.animation.addByPrefix('idle', "BG tank w lighting", 24, true);
					steve.animation.play('idle', true);
					steve.antialiasing = true;
					steve.scrollFactor.set(0.5, 0.5);
					swagBacks['steve'] = steve;
					toAdd.push(steve);

					var tankmanRun:FlxTypedGroup<TankmenBG> = new FlxTypedGroup<TankmenBG>();
					if (Main.save.data.distractions)
					{
						swagGroup['tankmanRun'] = tankmanRun;
						toAdd.push(tankmanRun);
					}

					var tankGround:FlxSprite = new FlxSprite(-420, -150).loadGraphic(Paths.loadImage('weeks/assets/week7/images/tankGround', 'gameplay'));
					tankGround.setGraphicSize(Std.int(tankGround.width * 1.15));
					tankGround.updateHitbox();
					tankGround.antialiasing = true;
					swagBacks['tankGround'] = tankGround;
					toAdd.push(tankGround);

					foregroundSprites = new FlxTypedGroup<FlxSprite>();

					var tank0 = new FlxSprite(-500, 650);
					tank0.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tank0', 'gameplay');
					tank0.animation.addByPrefix('idle', 'fg tankhead far right', 24, false);
					tank0.scrollFactor.set(1.7, 1.5);
					tank0.antialiasing = true;
					swagBacks['tank0'] = tank0;
					foregroundSprites.add(tank0);
					layInFront[2].push(tank0);

					var tank1 = new FlxSprite(-300, 750);
					tank1.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tank1', 'gameplay');
					tank1.animation.addByPrefix('idle', 'fg', 24, false);
					tank1.scrollFactor.set(2, 0.2);
					tank1.antialiasing = true;
					swagBacks['tank1'] = tank1;
					foregroundSprites.add(tank1);
					layInFront[2].push(tank1);

					var tank2 = new FlxSprite(450, 940);
					tank2.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tank2', 'gameplay');
					tank2.animation.addByPrefix('idle', 'foreground', 24, false);
					tank2.scrollFactor.set(1.5, 1.5);
					tank2.antialiasing = true;
					swagBacks['tank2'] = tank2;
					foregroundSprites.add(tank2);
					layInFront[2].push(tank2);

					var tank4 = new FlxSprite(1300, 900);
					tank4.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tank4', 'gameplay');
					tank4.animation.addByPrefix('idle', 'fg', 24, false);
					tank4.scrollFactor.set(1.5, 1.5);
					tank4.antialiasing = true;
					swagBacks['tank4'] = tank4;
					foregroundSprites.add(tank4);
					layInFront[2].push(tank4);

					var tank5 = new FlxSprite(1620, 700);
					tank5.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tank5', 'gameplay');
					tank5.animation.addByPrefix('idle', 'fg', 24, false);
					tank5.scrollFactor.set(1.5, 1.5);
					tank5.antialiasing = true;
					swagBacks['tank5'] = tank5;
					foregroundSprites.add(tank5);
					layInFront[2].push(tank5);

					var tank3 = new FlxSprite(1300, 1200);
					tank3.frames = Paths.getSparrowAtlas('weeks/assets/week7/images/tank3', 'gameplay');
					tank3.animation.addByPrefix('idle', 'fg', 24, false);
					tank3.scrollFactor.set(1.5, 1.5);
					tank3.antialiasing = true;
					swagBacks['tank3'] = tank3;
					foregroundSprites.add(tank3);
					layInFront[2].push(tank3);

					if (Main.save.data.distractions)
					{
						swagGroup['foregroundSprites'] = foregroundSprites;
						toAdd.push(foregroundSprites);
					}

					if (PlayState.SONG != null)
					{
						if (PlayState.SONG.gfVersion == 'picospeaker')
							{
								var firstTank:TankmenBG = new TankmenBG(20, 500, true);
								firstTank.resetShit(20, 600, true);
								firstTank.strumTime = 10;
								tankmanRun.add(firstTank);
				
								for (i in 0...TankmenBG.animationNotes.length)
								{
									if(FlxG.random.bool(16)) {
										var tankBih = tankmanRun.recycle(TankmenBG);
										tankBih.strumTime = TankmenBG.animationNotes[i][0];
										tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
										tankmanRun.add(tankBih);
									}
								}
							}
					}
				}
			case 'stage':
				{
					camZoom = 0.9;
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.loadImage('stageback'));
					bg.antialiasing = Main.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.loadImage('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = Main.save.data.antialiasing;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					swagBacks['stageFront'] = stageFront;
					toAdd.push(stageFront);

					var stageLightLeft:FlxSprite = new FlxSprite(-125, -100).loadGraphic(Paths.loadImage('stage_light'));
					stageLightLeft.setGraphicSize(Std.int(stageLightLeft.width * 1.1));
					stageLightLeft.updateHitbox();
					stageLightLeft.scrollFactor.set(0.9, 0.9);
					stageLightLeft.antialiasing = Main.save.data.antialiasing;
					swagBacks['stageLightLeft'] = stageLightLeft;
					toAdd.push(stageLightLeft);

					var stageLightRight:FlxSprite = new FlxSprite(1225, -100).loadGraphic(Paths.loadImage('stage_light'));
					stageLightRight.setGraphicSize(Std.int(stageLightRight.width * 1.1));
					stageLightRight.updateHitbox();
					stageLightRight.flipX = true;
					stageLightRight.scrollFactor.set(0.9, 0.9);
					stageLightRight.antialiasing = Main.save.data.antialiasing;
					swagBacks['stageLightRight'] = stageLightRight;
					toAdd.push(stageLightRight);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.loadImage('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = Main.save.data.antialiasing;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					swagBacks['stageCurtains'] = stageCurtains;
					toAdd.push(stageCurtains);	
				}
			default:
				{
					curStage = 'stage';
					camZoom = 0.9;
					
				}
		}*/

		Debug.logTrace('generated stage');

		if (!members.contains(gfGroup))
			add(gfGroup);
		if (!members.contains(dadGroup))
			add(dadGroup);
		if (!members.contains(boyfriendGroup))
			add(boyfriendGroup);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		/*if (!PlayStateChangeables.Optimize)
		{
			switch (curStage)
			{
				case 'philly':
					if (trainMoving)
					{
						trainFrameTiming += elapsed;

						if (trainFrameTiming >= 1 / 24)
						{
							updateTrainPos();
							trainFrameTiming = 0;
						}
					}

				case 'schoolEvil':
					wiggleShit.update(elapsed);
					
				case 'warzone':
					moveTank(elapsed);
			}
		}*/
	}

	public function sectionHit()
	{

	}

	public function stepHit()
	{
	}

	var oldLight = 999999;

	public var windowColor:FlxColor = FlxColor.WHITE;

	public function beatHit()
	{
		/*if (animatedBacks != null)
		{
			if (Main.save.data.distractions && animatedBacks.length > 0)
			{
				for (bg in animatedBacks)
					bg.animation.play('idle', true);
			}
		}

		if (!PlayStateChangeables.Optimize)
		{
			switch (curStage)
			{
				case 'halloween':
					if (PlayState.SONG != null){
						if (FlxG.random.bool(Conductor.bpm > 320 ? 100 : 10) && curBeat > lightningStrikeBeat + lightningOffset)
						{
							if (Main.save.data.distractions)
							{
								lightningStrikeShit();
								trace('spooky');
							}
						}
					}
				case 'school':
					if (Main.save.data.distractions)
					{
						swagBacks['bgGirls'].dance();
					}
				case 'limo':
					if (Main.save.data.distractions)
					{
						swagGroup['grpLimoDancers'].forEach(function(dancer:BackgroundDancer)
						{
							dancer.dance();
						});

						if (FlxG.random.bool(10) && fastCarCanDrive)
							fastCarDrive();
					}
				case "philly":
					if (Main.save.data.distractions)
					{
						if (!trainMoving)
							trainCooldown += 1;

						if (curBeat % 4 == 0)
						{
							var phillyCityLight:FlxSprite = swagBacks['light'];

							randomColor();

							if (PlayState.SONG != null){
								if (PlayState.SONG.songId != 'blammed')
									phillyCityLight.color = windowColor;
							}
						}
					}

					if (curBeat % 8 == 4 && FlxG.random.bool(Conductor.bpm > 320 ? 150 : 30) && !trainMoving && trainCooldown > 8)
					{
						if (Main.save.data.distractions)
						{
							trainCooldown = FlxG.random.int(-4, 0);
							trainStart();
							trace('train');
						}
					}
				case 'warzone':
					if (curBeat % 2 == 0)
					{
						swagBacks['tankWatchtower'].animation.play('idle', true);
						swagBacks['tank0'].animation.play('idle', true);
						swagBacks['tank1'].animation.play('idle', true);
						swagBacks['tank2'].animation.play('idle', true);
						swagBacks['tank4'].animation.play('idle', true);
						swagBacks['tank5'].animation.play('idle', true);
						swagBacks['tank3'].animation.play('idle', true);
					}				
			}
		}*/
	}

	var blammedeventplayed:Bool = false;

	function randomColor() {
		curLight = FlxG.random.int(0, 4, [oldLight]);
		oldLight = curLight;

		switch(curLight)
		{
			case 4:
				windowColor = FlxColor.fromRGB(251, 166, 51);
			case 3:
				windowColor = FlxColor.fromRGB(253, 69, 49);
			case 2:
				windowColor = FlxColor.fromRGB(251, 51, 245);
			case 1:
				windowColor = FlxColor.fromRGB(49, 253, 140);
			case 0:
				windowColor = FlxColor.fromRGB(49, 162, 253);
		}
	}

	// Variables and Functions for Stages
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	public var curLight:Int = 0;

	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX = 400;
	function moveTank(?elapsed:Float = 0)
	{
		if(!PlayState.inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			steve.angle = tankAngle - 90 + 15;
			steve.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			steve.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	function lightningStrikeShit():Void
	{
		/*FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2, 'core'));
		swagBacks['halloweenBG'].animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if (Main.save.data.camzoom)
		{
			FlxG.camera.zoom += 0.015;
			PlayState.instance.camHUD.zoom += 0.03;

			FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom}, 0.5);
			FlxTween.tween(PlayState.instance.camHUD, {zoom: 1}, 0.5);
		}

		if (PlayState.instance.boyfriend != null)
		{
			PlayState.instance.boyfriend.playAnim('scared', true);
			PlayState.instance.gf.playAnim('scared', true);
		}
		else
		{
			GameplayCustomizeState.boyfriend.playAnim('scared', true);
			GameplayCustomizeState.gf.playAnim('scared', true);
		}

		if(Main.save.data.flashing) {
			swagBacks['halloweenWhite'].alpha = 0.4;
			FlxTween.tween(swagBacks['halloweenWhite'], {alpha: 0.5}, 0.075);
			FlxTween.tween(swagBacks['halloweenWhite'], {alpha: 0}, 0.25, {startDelay: 0.15});
		}*/
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var trainSound:FlxSound;

	function trainStart():Void
	{
		if (Main.save.data.distractions)
		{
			trainMoving = true;
			trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		/*if (Main.save.data.distractions)
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;

				if (PlayState.SONG != null){
					if (PlayState.instance.gf != null)
						PlayState.instance.gf.playAnim('hairBlow');
					else
						GameplayCustomizeState.gf.playAnim('hairBlow');
				}
			}

			if (startedMoving)
			{
				var phillyTrain = swagBacks['phillyTrain'];
				phillyTrain.x -= 400;

				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;

					if (trainCars <= 0)
						trainFinishing = true;
				}

				if (phillyTrain.x < -4000 && trainFinishing)
					trainReset();
			}
		}*/
	}

	function trainReset():Void
	{
		/*if (Main.save.data.distractions)
		{
			if (PlayState.SONG != null){
				if (PlayState.instance.gf != null)
					PlayState.instance.gf.playAnim('hairFall');
				else
					GameplayCustomizeState.gf.playAnim('hairFall');
			}

			swagBacks['phillyTrain'].x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}*/
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		/*if (Main.save.data.distractions)
		{
			var fastCar = swagBacks['fastCar'];
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCar.visible = false;
			fastCarCanDrive = true;
		}*/
	}

	function fastCarDrive()
	{
		/*if (Main.save.data.distractions)
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1, 'core'), 0.7);

			swagBacks['fastCar'].visible = true;
			swagBacks['fastCar'].velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}*/
	}

	private function _stepHit(step:Int):Void
	{
		curStep = step;
		stepHit();
	}

	private function _beatHit(beat:Int):Void
	{
		curBeat = beat;
		beatHit();
	}

	private function _sectionHit(section:SwagSection):Void
	{
		curSection = section;
		sectionHit();
	}

	private function _decimalBeatHit(beat:Float):Void
	{
		curDecimalBeat = beat;
	}

	override public function destroy()
	{
		Main.fnfSignals.beatHit.remove(_beatHit);
		Main.fnfSignals.sectionHit.remove(_sectionHit);
		Main.fnfSignals.stepHit.remove(_stepHit);
		Main.fnfSignals.decimalBeatHit.remove(_decimalBeatHit);

		super.destroy();
	}
}