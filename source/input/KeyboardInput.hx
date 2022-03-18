package input;

import haxe.ds.Vector;
import input.Input.InputMapping;
import hxd.Key;

class KeyboardInput extends InputDevice {
	
	public function new(mappings:InputMapping, isComplex:Vector<Bool>) {
		super("kb", mappings, isComplex);
	}
	
	function isButtonDown(buttonCode:Int) {
		return Key.isDown(buttonCode);
	}
}