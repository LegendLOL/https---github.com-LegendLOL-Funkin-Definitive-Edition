package backend;

import backend.Song.SwagSong;
import flixel.FlxG;

/**
 * ...
 * @author
 */

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor
{
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds
	public static var timeScale:Float = Conductor.safeZoneOffset / 166;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public function new() {}

	public static function recalculateTimings()
	{
		Conductor.safeZoneOffset = Math.floor((Conductor.safeFrames / 60) * 1000);
		Conductor.timeScale = Conductor.safeZoneOffset / 166;
	}

	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Float)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}

class Ratings
{
	/**
	* Rating Hit Windows 
	* Sick: 45ms | Good: 90ms | Bad: 135ms | Shit: 166ms
	**/

    public static var timingWindows = [166.0, 135.0, 90.0, 45.0]; 
   
    public static function judgeNote(noteDiff:Float)
    {
        var diff = Math.abs(noteDiff);
        for (index in 0...timingWindows.length) // based on 4 timing windows, will break with anything else
        {
            var time = timingWindows[index] * Conductor.timeScale;
            var nextTime = index + 1 > timingWindows.length - 1 ? 0 : timingWindows[index + 1];
            if (diff < time && diff >= nextTime * Conductor.timeScale)
            {
                switch (index)
                {
                    case 0:
                        return "shit";
                    case 1:
                        return "bad";
                    case 2:
                        return "good";
                    case 3:
                        return "sick";
                }
            }
        }
        return "good";
    }

	public static function fullComboRank() 
	{
		PlayState.ratingFC = 'N/A';
		
		if (PlayState.misses == 0) 
		{
			if (PlayState.bads > 0 || PlayState.shits > 0) {
				PlayState.ratingFC = 'FC';
			} else if (PlayState.goods > 0) {
				PlayState.ratingFC = 'GFC';
			} else if (PlayState.sicks > 0) {
				PlayState.ratingFC = 'MFC';
			}
		}
		else
		{
			if (PlayState.misses < 10) 
				PlayState.ratingFC = 'SDCB';
			else
				PlayState.ratingFC = 'Clear';
		}
	}
}