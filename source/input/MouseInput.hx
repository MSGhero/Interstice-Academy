package input;

import hxd.Key;
import haxe.ds.Vector;
import input.Input.InputMapping;

class MouseInput extends InputDevice {
	
	public function new(mappings:InputMapping, isComplex:Vector<Bool>) {
		super("mouse", mappings, isComplex);
		
	}
	
	function isButtonDown(buttonCode:Int):Bool {
		return Key.isDown(buttonCode);
	}
}