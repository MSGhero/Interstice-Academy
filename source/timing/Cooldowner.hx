package timing;

@:structInit @:forward @:access(timing.Updater)
abstract Cooldowner (Updater) from Updater to Updater {
    
	public function update(dt:Float) {
		
		if (this.isActive) {
			
			if (this.isReady) {
				
				if (this.callback != null) this.callback();
				
				if (this.repetitions > 0) {
					--this.repetitions;
					if (this.repetitions == 0 && this.onComplete != null) this.onComplete();
				}
				
				this.counter = 0;
			}
		}
		
		if (!this.isReady) {
			this.incrementCounter(dt);
			if (this.counter > this.duration) this.counter = this.duration;
		}
	}
}