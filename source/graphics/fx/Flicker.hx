package graphics.fx;

import h2d.Object;
import timing.Updater;

@:forward
abstract Flicker(Updater) to Updater {
	
	public function new(obj:Object, from:Bool, to:Bool, dur:Float, count:Int, onComplete:()->Void = null) {
		
		obj.visible = from;
		
		var reps = count * 2 - 1;
		
		this = {
			duration : dur / reps,
			repetitions : reps,
			callback : () -> {
				obj.visible = !obj.visible;
			},
			onComplete : () -> {
				obj.visible = to;
				if (onComplete != null) onComplete();
			}
		};
	}
}