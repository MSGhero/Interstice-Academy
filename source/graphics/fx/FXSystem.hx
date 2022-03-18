package graphics.fx;

import ecs.Entity;
import ecs.Universe;
import ecs.System;
import h2d.Object;

class FXSystem extends System {
	
	@:fastFamily
	var objs : {
		obj:Object
	}
	
	@:fastFamily
	var effects : {
		effectList:FX
	}
	
	@:fastFamily
	var events : {
		event:Event
	}
	
	public function new(ecs:Universe) {
		super(ecs);
		
	}
	
	override function onEnabled() {
		events.onEntityAdded.subscribe(handleEvent);
		// maybe cleanup refs onRemove?
	}
	
	override function onDisabled() {
		events.onEntityAdded.unsubscribe(handleEvent);
		// maybe cleanup refs onRemove?
	}
	
	function handleEvent(eventity) {
		
		fetch(events, eventity, {
			
			var fx:FX;
			
			switch (event) {
				
				case FX_FADE(entity, from, to, dur, onComplete):
					
					fx = getEffects(entity);
					
					fetch(objs, entity, {
						fx.push(
							new FadeAlpha(
								obj,
								from, to, dur,
								onComplete
							)
						);
					});
					
				case FX_FLICKER(entity, from, to, dur, count, onComplete):
					
					fx = getEffects(entity);
					
					fetch(objs, entity, {
						fx.push(
							new Flicker(
								obj,
								from, to, dur, count,
								onComplete
							)
						);
					});
					
				case FX_DELAY(entity, dur, onComplete):
					
					fx = getEffects(entity);
					
					fetch(objs, entity, {
						fx.push(
							new Delay(
								dur,
								onComplete
							)
						);
					});
					
				case FX_FLASH(entity, color, dur, count, onComplete):
					
					fx = getEffects(entity);
					
					fetch(objs, entity, {
						fx.push(
							new Flash(
								obj,
								color, dur, count,
								onComplete
							)
						);
					});
					
				case FX_UPDATER_RAW(entity, updater):
					
					fx = getEffects(entity);
					cast fx.push(updater);
					
				default:
			}
		});
	}
	
	function getEffects(entity:Entity) {
		
		var fx = null;
		
		fetch(effects, entity, {
			fx = effectList;
		});
		
		if (fx == null) {
			fx = new FX();
			universe.setComponents(entity, fx);
		}
		
		return fx;
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		iterate(effects, {
			
			for (effect in effectList) {
				
				effect.update(dt);
				
				if (effect.repetitions == 0) {
					effectList.remove(effect);
				}
			}
		});
	}
}