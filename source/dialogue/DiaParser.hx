package dialogue;

import dialogue.Dialogue.Option;
import haxe.ds.StringMap;

using StringTools;

class DiaParser {
	
	public static function msg(text:String):Void {
		trace(text);
	}
	
	public static function parseDia(text:String, id:String):Dynamic {
		
		var speaker = "";
		var dialogue = "";
		var firstChar = "";
		var lines = text.split("\n");
		var subline = "";
		var bracketIndex = -1;
		
		var set:Array<Dynamic> = [];
		var tags = "";
		var options:Array<Option> = [/* { next : Std.string(id + 1), text : null, disabled : "false" } */];
		
		var charData:Array<String> = [];
		var settingChar = false;
		var characters = new Array<Array<String>>(); // interpret to stringmap in dia's fromDynamic. Also utilize parseKV
		
		for (line in lines) {
			
			firstChar = line.charAt(0);
			
			if (settingChar && firstChar != '\t') settingChar = false;
			
			if (!settingChar) {
				
				subline = StringTools.trim(line.substr(2));
				
				if (settingChar && firstChar != '\t') {
					settingChar = false;
				}
				
				if (line.charAt(1) != ':' || firstChar == '"' || firstChar == "“") {
					// stuff in quotes or without a tag will just immediately turn into dia
					
					dialogue = StringTools.trim(line);
					set.push( { speaker : speaker, text : dialogue, tags : tags } );
					
					tags = "";
				}
				
				else if (firstChar == 'C') {
					speaker = subline;
				}
				
				else if (firstChar == 'D') {
					
					dialogue = subline;
					set.push( { speaker : speaker, text : dialogue, tags : tags } );
					
					tags = "";
				}
				
				// execution currently occurs on dia only... kinda want it to be more arbitrary
				else if (firstChar == '*') {
					tags = tags.length == 0 ? subline : tags + "|" + subline;
				}
				
				else if (firstChar == 'T') {
					bracketIndex = subline.lastIndexOf("[[");
					options.push ( { next : subline.substring(bracketIndex), text : subline.substring(0, bracketIndex), disabled : "false" } );
				}
				
				else if (firstChar == '-' && subline == "charSetup") {
					settingChar = true;
					charData = [];
					characters.push(charData);
				}
			}
			
			else {
				
				subline = StringTools.trim(line.substr(1));
				
				if (firstChar == '\t') {
					charData.push(subline);
				}
			}
		}
		
		var ret:Dynamic = { };
		
		Reflect.setField(ret, id, { id : id, set : set, options : options, characters : characters } );
		
		return ret;
	}
	
	public static function parseKV(text:String, parse:Bool):StringMap<String> {
		
		if (text == null || text.length == 0) return null;
		
		var map = new StringMap<String>();
		
		var lines = text.split("|");
		
		var tline:String = null;
		for (line in lines) {
			tline = line.trim();
			if (tline.length == 0) continue;
			var strs = tline.split(":");
			if (parse) map.set(strs[0].trim(), strs[1] == null ? "" : parseForHscript(strs[1].trim()));
			else map.set(strs[0].trim(), strs[1].trim());
		}
		
		return map;
	}
	
	public static function parseForHscript(s:String):String {
		
		if (s == null) return null;
		
		s = s.trim();
		
		if (s.lastIndexOf("[[") == 0 && s.endsWith("]]")) {
			s = s.substring(2, s.length - 2);
		}
		
		else {
			s = "\"" + ~/\[\[/g.replace(s, "\"+("); // find [[ ]], replace with string concat
			s = ~/\]\]/g.replace(s, ")+\"") + "\""; // e.g. "text" + (hscript) + "text"
		}
		
		return s;
	}
	
	public static function mapToDynamic(map:StringMap<Dynamic>):Dynamic {
		
		var dd = { };
		
		for (k in map.keys()) {
			var v = map.get(k);
			checkType(dd, k, v);
		}
		
		return dd;
	}
	
	static function checkType(dd, k, v) {
		
		if (Std.isOfType(v, StringMap)) Reflect.setField(dd, k, mapToDynamic(cast v));
		
		else if (Std.isOfType(v, Array)) {
			
			var a = [];
			var b:Array<Dynamic> = cast v;
			
			for (c in b) {
				a.push(checkArrType(c));
			}
			
			Reflect.setField(dd, k, a);
		}
		
		else Reflect.setField(dd, k, v);
	}
	
	static function checkArrType(c):Dynamic {
		
		if (Std.isOfType(c, StringMap)) return mapToDynamic(cast c);
		
		if (Std.isOfType(c, Array)) {
			
			var a = [];
			var b:Array<Dynamic> = cast c;
			
			for (v in b) {
				a.push(checkArrType(v));
			}
			
			return a;
		}
		
		return c;
	}
}