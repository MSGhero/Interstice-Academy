package graphics.fx;

import h2d.Object;
import timing.Updater;
import timing.Tweener;

@:forward
abstract FadeAlpha(Tweener) to Updater {
	
	public function new(obj:Object, from:Float, to:Float, dur:Float, onComplete:()->Void = null) {
		
		obj.alpha = from;
		if (from == 0) obj.visible = true;
		
		this = {
			duration : dur,
			repetitions : 1,
			onUpdate : easedPerc -> {
				obj.alpha = Math.max(from + (to - from) * easedPerc, 0);
			},
			callback : () -> {
				obj.alpha = to;
				if (to == 0) obj.visible = false;
			}
		};
		
		if (onComplete != null) this.onComplete = onComplete;
	}
}