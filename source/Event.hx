package;

import timing.Updater;
import ecs.Entity;

enum Event {
	
	ANIM_PLAY(entity:Entity, name:String);
	ANIM_CHAIN(entity:Entity, name:String);
	ANIM_REPLAY(entity:Entity);
	ANIM_CONT(entity:Entity, name:String);
	ANIM_SET_COMPLETE(entity:Entity, onComplete:()->Void);
	
	// maybe make TweenerProps<T> that has from<T> to<T> dur onComplete ease, etc
	FX_FADE(entity:Entity, from:Float, to:Float, dur:Float, onComplete:()->Void);
	FX_FLICKER(entity:Entity, from:Bool, to:Bool, dur:Float, count:Int, onComplete:()->Void);
	FX_DELAY(entity:Entity, dur:Float, onComplete:()->Void);
	FX_FLASH(entity:Entity, color:Int, dur:Float, count:Int, onComplete:()->Void);
	FX_UPDATER_RAW(entity:Entity, updater:Updater);
	
	DIALOGUE_INIT(id:String);
	DIALOGUE_ADVANCE;
}