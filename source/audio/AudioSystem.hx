package audio;

import ecs.Universe;
import ecs.System;
import input.Input;
import hxd.snd.Manager;
import hxd.snd.ChannelGroup;

class AudioSystem extends System {
	
	@:fullFamily
	var audioTriggers : {
		resources : {
			soundManager:Manager,
			musicGroup:ChannelGroup
		},
		requires : {
			input:Input
		}
	};
	
	var origVol:Float;
	
	public function new(ecs:Universe) {
		super(ecs);
		
		origVol = 1;
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		setup(audioTriggers, {
			origVol = musicGroup.volume = 0.6;
		});
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		setup(audioTriggers, {
			iterate(audioTriggers, {
				
				if (input.actions.justPressed.getAction(MUTE)) {
					soundManager.masterVolume = soundManager.masterVolume == 0 ? 1 : 0;
				}
				
				if (input.actions.justPressed.getAction(VOL_UP)) {
					musicGroup.volume = origVol = hxd.Math.clamp(origVol + 0.1, 0, 1);
				}
				
				if (input.actions.justPressed.getAction(VOL_DOWN)) {
					musicGroup.volume = origVol = hxd.Math.clamp(origVol - 0.1, 0, 1);
				}
			});
		});
	}
}