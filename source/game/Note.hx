package game;

import utilities.NoteVariables;
import states.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;

	public var rawNoteData:Int = 0;

	public var modifiedByLua:Bool;
	public var modAngle:Float = 0;
	public var localAngle:Float = 0;

	public var character:Int = 0;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?character:Int = 0)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		this.character = character;
		this.strumTime = strumTime;
		this.noteData = noteData;
		isSustainNote = sustainNote;

		x += 100 - ((PlayState.SONG.keyCount - 4) * 16);
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y = -2000;

		frames = PlayState.arrow_Texture;

		animation.addByPrefix("default", NoteVariables.Other_Note_Anim_Stuff[PlayState.SONG.keyCount - 1][noteData] + "0");
		animation.addByPrefix("hold", NoteVariables.Other_Note_Anim_Stuff[PlayState.SONG.keyCount - 1][noteData] + " hold0");
		animation.addByPrefix("holdend", NoteVariables.Other_Note_Anim_Stuff[PlayState.SONG.keyCount - 1][noteData] + " hold end0");

		setGraphicSize(Std.int((width * Std.parseFloat(PlayState.instance.ui_Settings[0])) * (Std.parseFloat(PlayState.instance.ui_Settings[2]) - ((PlayState.SONG.keyCount - 4) * 0.06))));
		updateHitbox();
		
		antialiasing = PlayState.instance.ui_Settings[3] == "true";

		x += swagWidth * noteData;
		animation.play("default");

		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			if(PlayState.SONG.ui_Skin != 'pixel')
				x += width / 2;

			animation.play("holdend");
			updateHitbox();

			if(PlayState.SONG.ui_Skin != 'pixel')
				x -= width / 2;

			if (PlayState.SONG.ui_Skin == 'pixel')
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play("hold");

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		angle = modAngle + localAngle;

		if (mustPress)
		{
			// old ass code i guess \_(:/)_/
			/*
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
				canBeHit = true;
			else
				canBeHit = false;
			*/

			// taken from kade engine moment
			if (isSustainNote)
			{
				if (strumTime + Conductor.offset > (Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)) + Conductor.offset
					&& strumTime + Conductor.offset < (Conductor.songPosition + (Conductor.safeZoneOffset * 0.5)) + Conductor.offset)
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime + Conductor.offset > (Conductor.songPosition - Conductor.safeZoneOffset) + Conductor.offset
					&& strumTime + Conductor.offset < (Conductor.songPosition + Conductor.safeZoneOffset) + Conductor.offset)
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime + Conductor.offset < (Conductor.songPosition - Conductor.safeZoneOffset) + Conductor.offset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime + Conductor.offset <= Conductor.songPosition + Conductor.offset)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
