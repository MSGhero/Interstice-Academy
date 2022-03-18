package dialogue;

import haxe.ds.StringMap;

class Dialogue {

	public var id(default, null):String;
	
	public var characters(default, null):StringMap<CharData>;
	
	public var set(default, null):Array<Line>;
	public var setIndex(default, null):Int;
	
	public var options(default, null):Array<Option>;
	
	public function new(id:String) {
		this.id = id;
		
		characters = new StringMap<CharData>();
		
		set = [];
		options = [];
		
		setIndex = -1;
	}
	
	public function getNextLine():Null<Line> {
		setIndex++;
		if (setIndex >= set.length) return null;
		return set[setIndex];
	}
	
	public function forceNextLine(index:Int):Null<Line> {
		setIndex = index - 1;
		return getNextLine();
	}
	
	public function resetLines():Void {
		setIndex = -1;
	}
	
	public static function fromDynamic(o:Dynamic):Dialogue {
		
		var d = new Dialogue(o.id);
		d.options = o.options;
		
		var lines:Array<Dynamic> = o.set;
		
		for (line in lines) {
			d.set.push( { speaker : DiaParser.parseForHscript(line.speaker), text : DiaParser.parseForHscript(line.text), tags : DiaParser.parseKV(line.tags, true) } );
		}
		
		for (opt in d.options) {
			opt.text = DiaParser.parseForHscript(opt.text);
			opt.next = DiaParser.parseForHscript(opt.next);
			opt.disabled = DiaParser.parseForHscript(opt.disabled);
		}
		
		var chars:Array<Array<String>> = o.characters;
		var charDatas = [for (char in chars) DiaParser.parseKV(char.join(","), false)];
		for (data in charDatas) {
			// default or non existent values?
			d.characters.set(data.get("id"), { id : data.get("id"), img : data.get("img"), left : Std.parseInt(data.get("left")), enter : data.get("enter"), enterDur : Std.parseFloat(data.get("enterDur")), exit : data.get("exit"), exitDur : Std.parseFloat(data.get("exitDur")), charAlign : data.get("charAlign") } );
		}
		
		return d;
	}
	
	public function toString():String {
		return 'Dia: "$id"';
	}
}

typedef Line = {
	speaker:String, // gets hscripted, should return string
	text:String, // gets hscripted, should return string
	tags:StringMap<String> // individual tags get hscripted, should return string
}

typedef Option = {
	text:String, // gets hscripted, should return string
	next:String, // gets hscripted, should return string
	disabled:String, // gets hscripted, should return bool
}