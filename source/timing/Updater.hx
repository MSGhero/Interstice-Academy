package timing;

@:structInit
class Updater {
	
	public var duration:Float = 1;
	public var repetitions:Int = -1;
	public var paused:Bool = false;
	public var useFrames:Bool = false;
	public var changed:Bool = true;
	
	public var callback:()->Void = null;
	public var onComplete:()->Void = null;
	
	public var isActive(get, never):Bool;
	inline function get_isActive() { return !paused && repetitions != 0; }
	
	public var isTimeLeft(get, never):Bool;
	inline function get_isTimeLeft() { return counter > 0; }
	
	public var isReady(get, never):Bool;
	inline function get_isReady() { return counter >= duration; }
	
	var counter:Float = 0;
	
	public function dispose() {
		callback = null;
		onComplete = null;
	}
	
	public inline function resetCounter() {
		counter = 0;
		changed = true;
	}
	
	public function forceCallback() {
		
		if (callback != null) callback();
		
		if (repetitions > 0) {
			--repetitions;
			if (repetitions == 0 && onComplete != null) onComplete();
		}
		
		resetCounter();
	}
	
	public function update(dt:Float) {
		
		if (changed) changed = false;
		
		if (isActive) {
			
			while (isReady) {
				
				if (callback != null) callback();
				
				if (repetitions > 0) {
					--repetitions;
					if (repetitions == 0 && onComplete != null) onComplete();
				}
				
				counter -= duration;
			}
			
			incrementCounter(dt);
		}
	}
	
	function incrementCounter(dt:Float) {
		if (!useFrames) counter += dt;
		else counter++;
		changed = true;
	}
	
	function decrementCounter(dt:Float) {
		if (!useFrames) counter -= dt;
		else counter--;
		changed = true;
	}
}