package graphics;

import ecs.Universe;
import ecs.System;

class AnimSystem extends System {
	
	@:fullFamily
	var anims : {
		requires : {
			anim:Animation
		}
	}
	
	@:fastFamily
	var events : {
		event:Event
	}
	
	public function new(ecs:Universe) {
		super(ecs);
		
	}
	
	override function onEnabled() {
		
		anims.onEntityAdded.subscribe(onAnimAdded);
		anims.onEntityRemoved.subscribe(onAnimRemoved);
		
		events.onEntityAdded.subscribe(handleEvent);
	}
	
	override function onDisabled() {
		
		anims.onEntityAdded.unsubscribe(onAnimAdded);
		anims.onEntityRemoved.unsubscribe(onAnimRemoved);
		
		events.onEntityAdded.unsubscribe(handleEvent);
	}
	
	function onAnimAdded(entity) {
		
		fetch(anims, entity, {
			anim.updater.callback = anim.advance;
		});
	}
	
	function onAnimRemoved(entity) {
		
		fetch(anims, entity, {
			anim.updater.callback = null;
		});
	}
	
	function handleEvent(eventity) {
		
		fetch(events, eventity, {
			
			switch (event) {
				case ANIM_PLAY(entity, name):
					fetch(anims, entity, {
						anim.play(name);
					});
				case ANIM_CHAIN(entity, name):
					fetch(anims, entity, {
						anim.chain(name);
					});
				case ANIM_CONT(entity, name):
					fetch(anims, entity, {
						final index = anim.index;
						anim.play(name);
						anim.play(name);
						anim.index = index % anim.frames.length;
					});
				case ANIM_REPLAY(entity):
					fetch(anims, entity, {
						anim.index = 0;
						anim.updater.repetitions = 1;
						anim.updater.resetCounter();
					});
				case ANIM_SET_COMPLETE(entity, onComplete):
					fetch(anims, entity, {
						anim.updater.onComplete = onComplete;
					});
				default:
			}
		});
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		iterate(anims, {
			anim.updater.update(dt);
		});
	}
}