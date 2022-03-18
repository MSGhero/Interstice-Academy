package timing;

@:structInit
class Tweener extends Updater {
    
	public var onUpdate:(easedPerc:Float)->Void = null;
	public var ease:(perc:Float)->Float = f -> return f;
	
	override function dispose() {
		super.dispose();
		onUpdate = null;
		ease = null;
	}
	
	override function update(dt:Float) {
		
		if (changed) changed = false;
		
		if (isActive) {
			
			if (isReady) {
				
				if (callback != null) callback();
				
				if (repetitions > 0) {
					--repetitions;
					if (repetitions == 0 && onComplete != null) onComplete();
				}
			}
			
			incrementCounter(dt);
		}
	}
	
	override function incrementCounter(dt:Float) {
		
		if (counter >= duration) return;
		
		super.incrementCounter(dt);
		
		if (onUpdate != null) {
			if (counter > duration) counter = duration;
			onUpdate(ease(counter / duration));
		}
	}
}