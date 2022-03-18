package states;

import haxe.ui.core.Component;
import hxd.snd.Manager;
import h2d.Scene;
import h3d.shader.UVScroll;
import haxe.ui.containers.Box;
import hxd.Res;
import h2d.Bitmap;
import haxe.ui.containers.Absolute;
import haxe.ui.containers.Grid;
import haxe.ui.components.Label;
import haxe.ui.components.Image;
import ui.*;
import haxe.ui.macros.ComponentMacros;
import ecs.Universe;

class Game {
	
	var ui:Component;
	var ecs:Universe;
	var uiScene:Scene;
	
	public var menu:Menu;
	
	public function new(ecs:Universe, uiScene:Scene) {
		
		this.ecs = ecs;
		this.uiScene = uiScene;
		
		ui = ComponentMacros.buildComponent("assets/baseline.xml");
		
		var bg:Background = ui.findComponent("bg", Image);
		var bgFade:BGFade = ui.findComponent("bgFade", Image);
		var text:Text = ui.findComponent("myText", Label);
		var speaker:Speaker = ui.findComponent("myChar", Label);
		var options:Grid = ui.findComponent("options", Grid);
		var image:Display = ui.findComponent("myImage", Image);
		var fade:Image = ui.findComponent("myFade", Image);
		var charFade:CharFade = ui.findComponent("myImageFade", Image);
		var cont:UIContainer = ui.findComponent("uiContainer", Absolute);
		var border:Border = ui.findComponent("border", Image);
		
		ecs.setResources(text, speaker, options, image, fade, bg, bgFade, charFade, cont, border, Manager.get());
		
		// can add to container as well as a haxeui Image
		var image = new Bitmap(Res.Hearts_red.toTile().sub(0, 0, 536, 90), ui.findComponent("myHearts", Box));
		image.scale(2);
		//image.x = 104; image.y = 460;
		image.alpha = 1;
		
		var uvs = new UVScroll(0.03, 0.03);
		image.tileWrap = true;
		image.addShader(uvs);
	}
	
	public function begin() {
		
		uiScene.addChild(ui);
		
		ui.findComponent("border", Image).hidden = true;
		
		ecs.getPhase("dia").enable();
		ECS.event(DIALOGUE_INIT("s0_intro"));
		ECS.event(DIALOGUE_ADVANCE);
	}
	
	public function end() {
		uiScene.removeChild(ui);
		ui.validateNow();
		menu.begin();
	}
}