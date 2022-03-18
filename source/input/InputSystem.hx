package input;

import ecs.Universe;
import ecs.System;

class InputSystem extends System {
	
	@:fullFamily
	var inputs : {
		requires : {
			input:Input
		}
	}
	
	public function new(ecs:Universe) {
		super(ecs);
		
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		iterate(inputs, {
			
			input.previous.copyFrom(input.actions);
			
			for (i in 0...input.actions.pressed.length)
				input.actions.pressed[i] = false;
			
			for (device in input.devices) {
				
				for (i in 0...input.actions.pressed.length) {
					if (input.actions.pressed[i]) continue;
					input.actions.pressed[i] = device.getStatus(i);
				}
			}
			
			input.actions.updateJust(input.previous);
		});
	}
}