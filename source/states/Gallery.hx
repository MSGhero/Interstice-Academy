package states;

import io.newgrounds.NG;
import hxd.Window;
import h2d.Bitmap;
import hxd.snd.Channel;
import haxe.ui.events.MouseEvent;
import hxd.Res;
import haxe.ui.core.Component;
import haxe.ui.components.Button;
import h2d.Scene;
import haxe.ui.containers.Absolute;
import haxe.ui.macros.ComponentMacros;
import ecs.Universe;

class Gallery {
	
	var ui:Component;
	var ecs:Universe;
	var uiScene:Scene;
	
	var playb:Button;
	var galleryb:Button;
	var channel:Channel;
	
	var container:Component;
	
	var image:Bitmap;
	
	public var menu:Menu;
	
	public function new(ecs:Universe, uiScene:Scene) {
		
		this.ecs = ecs;
		this.uiScene = uiScene;
		
		image = new Bitmap(null, uiScene);
		
		ui = ComponentMacros.buildComponent("assets/gallery.xml");
		container = ui.findComponent("container");
		
		var button = ui.findComponent("arrow", Button);
		button.onMouseOver = onOver;
		button.onClick = me -> {
			Res.sfx.select.play();
			end();
		};
		
		for (child in container.childComponents) {
			child.onMouseOver = onOver;
			child.onClick = onClick;
		}
		
		Window.getInstance().addEventTarget(
			event -> {
				switch (event.kind) {
					case EPush if (image.visible):
						image.visible = false;
						ui.hidden = false;
					case ERelease if (!image.visible):
						for (child in container.childComponents) {
							child.onClick = onClick;
						}
					default:
				}
			}
		);
	}
	
	function onOver(me:MouseEvent) {
		Res.sfx.over.play();
	}
	
	function onClick(me:MouseEvent) {
		
		Res.sfx.select.play();
		
		ui.hidden = true;
		image.tile = Res.loader.load('endcards/${me.target.id}_Endcard.png').toTile();
		image.visible = true;
		
		for (child in container.childComponents) {
			child.onClick = null;
		}
	}
	
	public function begin() {
		
		uiScene.addChild(ui);
		ui.validateNow();
		image.visible = false;
		
		var medalIds = [
			"Ana" => [67996, 68060],
			"ARS" => [67997],
			"Demi" => [68063, 67998],
			"FME" => [68001],
			"Hend" => [68002],
			"Junior" => [68003]
		];
		
		var medals = NG.core.medals;
		
		for (i in 0...container.childComponents.length) {
			
			if (NG.core.loggedIn) {
				
				var b = false;
				var arr = medalIds[container.childComponents[i].id];
				for (j in arr) {
					if (medals.get(j).unlocked) b = true;
				}
				
				container.childComponents[i].hidden = !b;
			}
			
			else {
				container.childComponents[i].hidden = true;
			}
		}
	}
	
	public function end() {
		uiScene.removeChild(ui);
		menu.begin();
	}
}