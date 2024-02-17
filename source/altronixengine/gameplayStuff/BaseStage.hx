package altronixengine.gameplayStuff;

import altronixengine.scriptStuff.HScriptHandler.ScriptException;
import altronixengine.scriptStuff.HscriptStage;
import altronixengine.scriptStuff.ScriptHelper;
import flixel.FlxSprite;
import flixel.FlxBasic;
import altronixengine.core.musicbeat.FNFTypedGroup;
import altronixengine.states.playState.PlayState;
import altronixengine.states.playState.GameData as Data;
import altronixengine.gameplayStuff.StageData;
import funkin.stages.*;
import flixel.group.FlxSpriteGroup;

class BaseStage extends FNFTypedGroup<FlxBasic>{

    public var gf:Character = null;
	public var dad:Character = null;
	public var boyfriend:Boyfriend = null;
    public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

    var curStage:String = "stage";
    var playState:PlayState;
    public var stageData:StageFile = null;
	public var camZoom:Float;

    public static function initStage(daStage:String, playState:PlayState):BaseStage {
        switch (daStage){
            case 'halloween':
                return new HalloweenStage(daStage, playState);
            case 'philly':
                return new PhillyStage(daStage, playState);
            case 'limo':
                return new LimoStage(daStage, playState);
            case 'mall':
                return new MallStage(daStage, playState);
            case 'mallEvil':
                return new MallEvilStage(daStage, playState);
            case 'school':
                return new SchoolStage(daStage, playState);
            case 'schoolEvil':
                return new SchoolEvilStage(daStage, playState);
            case 'warzone':
                return new WarzoneStage(daStage, playState);
            default:
                if (Paths.getHscriptPath(Data.SONG.stage, 'stages') != null)
                {
                    try
                    {
                        var hscriptStage = new HscriptStage(daStage, playState, Paths.getHscriptPath(Data.SONG.stage, 'stages'));
                        ScriptHelper.hscriptFiles.push(hscriptStage);
                        playState.hscriptStageCheck = true;
                        return hscriptStage;
                    }
                    catch (e)
                    {
                        if (Std.isOfType(e, ScriptException))
                        {
                            playState.scriptError(e);
                            return new BaseStage("stage", playState);
                        }
                        else
                            Debug.displayAlert('Error with hscript stage file!', Std.string(e));
                    }
                }
                return new BaseStage("stage", playState);
        }
    }

    public function new(daStage:String, playState:PlayState) {
        super();
		this.curStage = daStage;
        this.playState = playState;

		camZoom = 1.05;

		if (PlayStateChangeables.Optimize)
			return;

        boyfriendGroup = new FlxSpriteGroup(playState.BF_X, playState.BF_Y);
		dadGroup = new FlxSpriteGroup(playState.DAD_X, playState.DAD_Y);
		gfGroup = new FlxSpriteGroup(playState.GF_X, playState.GF_Y);

        if (curStage == null)
            this.curStage = "stage";

		stageData = StageData.getStageFile(this.curStage);
		if (stageData == null)
		{
			stageData = {
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
		}

        var gfCheck:String = 'gf';

		gfCheck = Data.SONG.gfVersion;

        gf = new Character(400, 130, gfCheck);

		startCharacterPos(gf);
		gf.scrollFactor.set(0.95, 0.95);
		gfGroup.add(gf);
		playState.startCharacterHscript(gf.curCharacter);

        boyfriend = new Boyfriend(770, 450, Data.SONG.player1);

		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		playState.startCharacterHscript(boyfriend.curCharacter);

        dad = new Character(100, 100, Data.SONG.player2);

		startCharacterPos(dad, true);
		dadGroup.add(dad);
		playState.startCharacterHscript(dad.curCharacter);

        if (this.curStage == null || this.curStage == "stage")
            prepareDefaultStage();
        else
            create();
    }

    function startCharacterPos(char:Character, ?gfCheck:Bool = false)
    {
        if (gfCheck && char.replacesGF)
        {
            char.setPosition(playState.GF_X, playState.GF_Y);
            char.scrollFactor.set(0.95, 0.95);
        }
        if (char.positionArray != null)
        {
            char.x += char.positionArray[0];
            char.y += char.positionArray[1];
        }
    }

    private function create(){}

    private function prepareDefaultStage() {
        camZoom = 0.9;
        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.loadImage('stageback'));
        bg.antialiasing = Main.save.data.antialiasing;
        bg.scrollFactor.set(0.9, 0.9);
        bg.active = false;
        add(bg);

        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.loadImage('stagefront'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = Main.save.data.antialiasing;
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);

        var stageLightLeft:FlxSprite = new FlxSprite(-125, -100).loadGraphic(Paths.loadImage('stage_light'));
        stageLightLeft.setGraphicSize(Std.int(stageLightLeft.width * 1.1));
        stageLightLeft.updateHitbox();
        stageLightLeft.scrollFactor.set(0.9, 0.9);
        stageLightLeft.antialiasing = Main.save.data.antialiasing;
        add(stageLightLeft);

        var stageLightRight:FlxSprite = new FlxSprite(1225, -100).loadGraphic(Paths.loadImage('stage_light'));
        stageLightRight.setGraphicSize(Std.int(stageLightRight.width * 1.1));
        stageLightRight.updateHitbox();
        stageLightRight.flipX = true;
        stageLightRight.scrollFactor.set(0.9, 0.9);
        stageLightRight.antialiasing = Main.save.data.antialiasing;
        add(stageLightRight);

        var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.loadImage('stagecurtains'));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
        stageCurtains.updateHitbox();
        stageCurtains.antialiasing = Main.save.data.antialiasing;
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;
        add(stageCurtains);

        add(gfGroup);
        add(dadGroup);
        add(boyfriendGroup);
    }
}