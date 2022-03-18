package states;

import hxd.snd.Channel;
import haxe.ui.events.MouseEvent;
import hxd.Res;
import haxe.ui.core.Component;
import haxe.ui.components.Button;
import h2d.Scene;
import haxe.ui.containers.Absolute;
import haxe.ui.macros.ComponentMacros;
import ecs.Universe;

class Menu {
	
	var ui:Component;
	var ecs:Universe;
	var uiScene:Scene;
	
	var playb:Button;
	var galleryb:Button;
	var channel:Channel;
	
	public var game:Game;
	public var gallery:Gallery;
	
	public function new(ecs:Universe, uiScene:Scene) {
		
		this.ecs = ecs;
		this.uiScene = uiScene;
		
		ui = ComponentMacros.buildComponent("assets/menu.xml");
		
		playb = ui.findComponent("playb", Button);
		playb.onMouseOver = onOver;
		playb.onClick = me -> {
			Res.sfx.select.play();
			end();
		};
		
		galleryb = ui.findComponent("galleryb", Button);
		galleryb.onMouseOver = onOver;
		galleryb.onClick = me -> {
			Res.sfx.select.play();
			toGallery();
		};
	}
	
	function onOver(me:MouseEvent) {
		Res.sfx.over.play();
	}
	
	public function begin() {
		
		uiScene.addChild(ui);
		
		if (channel == null) channel = Res.music.menu_01.play(true, 0.6);
	}
	
	public function end() {
		
		uiScene.removeChild(ui);
		
		if (channel != null) {
			channel.fadeTo(0, 2.5);
			channel = null;
		}
		
		playb.removeClass(":hover");
		ui.validateNow();
		game.begin();
	}
	
	public function toGallery() {
		
		uiScene.removeChild(ui);
		galleryb.removeClass(":hover");
		ui.validateNow();
		
		gallery.begin();
	}
}