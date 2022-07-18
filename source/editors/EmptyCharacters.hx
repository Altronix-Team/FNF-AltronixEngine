package editors;

import gameplayStuff.Character;

class EmptyCharacters
{
    public static function createEmptyCharacter():CharacterData {
		var testChar:CharacterData = 
		{
			{
				animations: [
					{
						looped: false,
						offsets: [0,0],
						frameRate: 24,
						name: "idle",
						nextAnim: "idleLoop",
						frameIndices: [],
						prefix: "Dad idle dance"
					},
					{
						name: "idleLoop",
						prefix: "Dad idle dance",
						offsets: [0, 0],
						frameIndices: [11, 12],
						frameRate: 12,
						looped: true
					},
					{
						offsets: [0,0],
						frameIndices: [],
						frameRate: 24,
						name: "singLEFT",
						looped: false,
						prefix: "Dad Sing Note LEFT"
					},
					{
						offsets: [0,0],
						frameIndices: [],
						frameRate: 24,
						name: "singDOWN",
						looped: false,
						prefix: "Dad Sing Note DOWN"
					},
					{
						offsets: [0,0],
						frameIndices: [],
						frameRate: 24,
						name: "singUP",
						looped: false,
						prefix: "Dad Sing Note UP"
					},
					{
						offsets: [0,0],
						frameIndices: [],
						frameRate: 24,
						name: "singRIGHT",
						looped: false,
						prefix: "Dad Sing Note RIGHT"
					}
				],
				name: 'Dad',
				startingAnim: 'idle',
				antialiasing: true,
				asset: 'characters/DADDY_DEAREST',
				camFollow: [0,0],
				charPos: [0,0],
				flipX: false,
				barColorJson: [161,161,161],
				camPos: [0,0],
				holdLength: 6.1,
				scale: 1
			}
		};
		return testChar;
	}

	public static function createEmptyGF():CharacterData {
		var testChar:CharacterData = 
		{
			{
				animations: [
					{
						offsets: [0,-19],
						nextAnim: "danceRight",
						frameRate: 24,
						frameIndices: [],
						prefix: "GF left note",
						name: "singLEFT",
						interrupt: false
					},
					{
						offsets: [0,-20],
						nextAnim: "danceRight",
						frameRate: 24,
						frameIndices: [],
						prefix: "GF Right Note",
						name: "singRIGHT",
						interrupt: false
					},
					{
						offsets: [0,4],
						nextAnim: "danceRight",
						frameRate: 24,
						frameIndices: [],
						prefix: "GF Up Note",
						name: "singUP",
						interrupt: false
					},
					{
						offsets: [0,-20],
						nextAnim: "danceRight",
						frameRate: 24,
						frameIndices: [],
						prefix: "GF Down Note",
						name: "singDOWN",
						interrupt: false
					},
					{
						offsets: [0,-9],
						frameRate: 24,
						prefix: "GF Dancing Beat",
						frameIndices: [30,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],
						name: "danceLeft"
					},
					{
						offsets: [0,-9],
						frameRate: 24,
						prefix: "GF Dancing Beat",
						frameIndices: [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29],
						name: "danceRight"
					},
					{
						offsets: [0,0],
						frameRate: 24,
						prefix: "GF Cheer",
						frameIndices: [],
						name: "cheer"
					},
					{
						offsets: [45,-8],
						frameRate: 24,
						frameIndices: [0,1,2,3],
						prefix: "GF Dancing Beat Hair blowing",
						looped: true,
						name: "hairBlow",
						interrupt: false
					},
					{
						offsets: [0,-9],
						nextAnim: "danceRight",
						frameRate: 24,
						frameIndices: [0,1,2,3,4,5,6,7,8,9,10,11],
						prefix: "GF Dancing Beat Hair Landing",
						isDanced: true,
						name: "hairFall",
						interrupt: false
					},
					{
						offsets: [-2,-21],
						frameRate: 24,
						prefix: "gf sad",
						frameIndices: [0,1,2,3,4,5,6,7,8,9,10,11,12],
						name: "sad"
					},
					{
						offsets: [-2,-17],
						frameRate: 24,
						frameIndices: [],
						prefix: "GF FEAR",
						name: "scared",
						looped: true
					}
				],
				name: 'GF',
				startingAnim: 'danceRight',
				characterIcon: "gf",
				antialiasing: true,
				asset: 'characters/GF_assets',
				isDancing: true,
				replacesGF: true,
				camFollow: [0,0],
				charPos: [0,0],
				flipX: false,
				barColorJson: [161,161,161],
				camPos: [0,0],
				holdLength: 6.1,
				scale: 1
			}
		};
		return testChar;
	}
}