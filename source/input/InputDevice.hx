package input;

import input.Input.InputMapping;
import haxe.ds.Vector;

abstract class InputDevice {
	
	public var name(default, null):String;
	
	var mappings:InputMapping;
	var isComplex:Vector<Bool>;
	
	public function new(name:String, mappings:InputMapping, isComplex:Vector<Bool>) {
		this.name = name;
		this.mappings = mappings;
		this.isComplex = isComplex;
	}
	
	public function getStatus(action:Actions):Bool {
		
		if (!isComplex[action])
			return areAnyDown(mappings[action]);
		
		var actions = mappings[action];
		
		for (aa in actions) {
			if (!getStatus(aa)) return false;
		}
		
		return true;
	}
	
	abstract function isButtonDown(buttonCode:Int):Bool;
	
	function areAllDown(buttonCodes:Array<Int>):Bool {
		
		if (buttonCodes == null) return false;
		
		for (button in buttonCodes) {
			if (!isButtonDown(button)) return false;
		}
		
		return true;
	}
	
	function areAnyDown(buttonCodes:Array<Int>):Bool {
		
		if (buttonCodes == null) return false;
		
		for (button in buttonCodes) {
			if (isButtonDown(button)) return true;
		}
		
		return false;
	}
}