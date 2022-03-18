package graphics.fx;

import timing.Updater;

@:forward
abstract Delay(Updater) to Updater {
	
	public function new(dur:Float, onComplete:()->Void) {
		
		this = {
			duration : dur,
			repetitions : 1,
			callback : onComplete
		};
	}
}