package graphics;

import haxe.ds.StringMap;
import h2d.Tile;
import timing.Updater;

@:structInit
class Animation {
	
	public var updater:Updater;
	
	public var frames(get, never):Array<Tile>;
	inline function get_frames():Array<Tile> { return currAnim.frames; }
	
	public var index:Int = 0;
	
	public var currFrame(get, never):Tile;
	inline function get_currFrame():Tile { return frames[index]; }
	
	var anims:StringMap<AnimData> = new StringMap();
	var currAnim:AnimData = null;
	var next:Array<String> = [];
	
	public function add(name:String, anim:AnimData) {
		anims.set(name, anim);
		anim.name = name;
		return this;
	}
	
	public function play(name:String, overrideNext:Bool = true) {
		
		currAnim = anims.get(name);
		index = 0;
		
		updater.resetCounter();
		updater.paused = false;
		updater.duration = 1 / currAnim.fps;
		updater.repetitions = currAnim.loop ? -1 : frames.length;
		
		if (overrideNext && next.length > 0) {
			next.splice(0, next.length);
		}
	}
	
	public inline function pause() {
		updater.paused = true;
	}
	
	public inline function chain(nextAnim:String) {
		next.push(nextAnim);
	}
	
	public function advance() {
		if (currAnim.loop)
			index = (index + 1) % frames.length;
		else if (index + 1 < frames.length)
			index++;
		else if (next.length > 0)
			play(next.shift(), false);
	}
}

@:structInit
private class AnimData {
	public var name:String = "";
	public var frames:Array<Tile>;
	public var loop:Bool = true;
	public var fps:Float = 1;
}