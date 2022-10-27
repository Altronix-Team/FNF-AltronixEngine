package gameplayStuff;

typedef SwagSection =
{
	/**
	* Start time of section in ms.
	**/
	var startTime:Float;

	/**
	* End time of section in ms.
	**/
	var endTime:Float;

	/**
	* Information about notes in this section.
	**/
	var sectionNotes:Array<Array<Dynamic>>;

	/**
	 * Information about notes in this section.
	**/
	var newSectionNotes:Array<SectionNoteData>;

	/**
	* Length of section in steps.
	**/
	var lengthInSteps:Int;

	/**
	* Unused?
	* I think.
	**/
	var typeOfSection:Int;

	/**
	* Changes the performer of "left part" of chart between opponent and player.
	**/
	var mustHitSection:Bool;

	/**
	* DEPRECATED!!
	* Special bpm for this section.
	**/
	var bpm:Float;

	/**
	* DEPRECATED!!
	* Should song bpm be changed while this section playing.
	* Warning: Use "BPM change" event to change song BPM.
	**/
	var changeBPM:Bool;

	/**
	* DEPRECATED!!
	* Should "left part character" of chart toggle alt anim.
	**/
	var altAnim:Bool;

	/**
	* Should opponent toggle alt anim.
	**/
	var CPUAltAnim:Bool;

	/**
	* Should player toggle alt anim.
	**/
	var playerAltAnim:Bool;

	/**
	* Should GF toggle alt anim.
	**/
	var gfAltAnim:Bool;

	/**
	* Forces GF to perform the "left side" of the chart.
	**/
	var gfSection:Bool;
}

/**
 * A more intuitive system for storing information about notes than Dynamic array 
 */
 //Will use this later
class SectionNoteData {
	var strumTime:Float;
	var noteData:Int;
	var sustainLength:Float;
	var isAlt:Null<Bool>;
	var beat:Null<Float>;
	var noteType:Null<String>;
	var noteStyle:Null<String>;

	public function new(strumTime:Float, noteData:Int, sustainLength:Float, isAlt:Null<Bool>, beat:Null<Float>, noteType:Null<String>, noteStyle:Null<String>)
	{
		this.strumTime = strumTime;
		this.noteData = noteData;
		this.sustainLength = sustainLength;
		this.isAlt = isAlt;
		this.beat = beat;
		this.noteType = noteType;
		this.noteStyle = noteStyle;
	}
}

@:deprecated
class Section
{
	public var startTime:Float = 0;
	public var endTime:Float = 0;
	public var sectionNotes:Array<Array<Dynamic>> = [];
	public var changeBPM:Bool = false;
	public var bpm:Float = 0;

	public var lengthInSteps:Int = 16;
	public var gfSection:Bool = false;
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;

	/**
	 *	Copies the first section into the second section!
	 */
	public static var COPYCAT:Int = 0;

	public function new(lengthInSteps:Int = 16)
	{
		//this.lengthInSteps = lengthInSteps;
	}
}
