package graphics;

import hxd.Window;
import ecs.Entity;
import h2d.Scene;
import ecs.Universe;
import ecs.System;
import h2d.Object;
import input.Input;

class RenderSystem extends System {
	
	// animated objects
	@:fullFamily
	var sprites : {
		requires : {
			sprite:RenderObject
		}
	}
	
	// anything added to the screen
	@:fullFamily
	var display : {
		resources : {
			scene:Scene
		},
		requires : {
			obj:Object
		}
	}
	
	@:fullFamily
	var displayTriggers : {
		/*resources : {
			soundManager:Manager,
			musicGroup:ChannelGroup
		},*/
		requires : {
			input:Input
		}
	};
	
	var toBeAdded:Array<Entity>;
	
	public function new(ecs:Universe) {
		super(ecs);
		
		toBeAdded = [];
	}
	
	override function onEnabled() {
		display.onEntityAdded.subscribe(addToScene);
		display.onEntityRemoved.subscribe(removeFromScene);
	}
	
	override function onDisabled() {
		display.onEntityAdded.unsubscribe(addToScene);
		display.onEntityRemoved.unsubscribe(removeFromScene);
	}
	
	function addToScene(entity) {
		// delay add until next update to align with render timings
		toBeAdded.push(entity);
	}
	
	function removeFromScene(entity) {
		
		setup(display, {
			fetch(display, entity, {
				scene.removeChild(obj);
			});
		});
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		if (toBeAdded.length > 0) {
			
			setup(display, {
				
				for (entity in toBeAdded) {
					fetch(display, entity, {
						scene.addChild(obj);
					});
				}
			});
			
			toBeAdded.splice(0, toBeAdded.length);
		}
		
		iterate(sprites, {
			sprite.sprite.tile = sprite.anim.currFrame;
		});
		
		/*
		setup(displayTriggers, {
			iterate(displayTriggers, {
				
				if (input.actions.justPressed.getAction(FULLSCREEN)) {
					var stage = Window.getInstance();
					stage.displayMode = stage.displayMode == Borderless ? Windowed : Borderless;
				}
			});
		});
		*/
	}
}