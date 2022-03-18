package timing;

@:structInit
class Replenisher extends Updater {
    
	public var rechargeRate:Float;
	
	override public function update(dt:Float) {
		
		if (changed) changed = false;
		
		if (repetitions > 0) {
			
			if (isReady) {
				
				counter = duration;
				
				if (callback != null) callback();
				repetitions = 0;
				if (onComplete != null) onComplete();
			}
			
			else {
				incrementCounter(dt);
			}
			
			changed = true;
		}
		
		else if (!paused && isTimeLeft) {
			decrementCounter(dt * rechargeRate);
			if (counter < 0) counter = 0;
			changed = true;
		}
	}
}