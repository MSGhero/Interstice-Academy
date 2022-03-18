package input;

import utils.ListEnumAbstract;
import haxe.ds.Vector;

@:forward
abstract ActionList(Vector<Bool>) {
	
	public function new() {
		
		// int instead of vec int?
		this = new Vector(ListEnumAbstract.count(Actions));
		
		for (i in 0...this.length) this[i] = false;
	}

	public function copyFrom(al:ActionList) {
		
		for (i in 0...this.length) {
			this[i] = al[i];
		}
	}
	
	public function getAction(action:Actions) {
		return this[action];
	}
	
	public function setAction(action:Actions, b:Bool) {
		return this[action] = b;
	}
	
	@:op([]) public inline function get(index:Int) {
		return this.get(index);
	}
	
	@:op([]) public inline function set(index:Int, val:Bool) {
		return this.set(index, val);
	}
}