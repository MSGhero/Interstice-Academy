package;

import h2d.Interactive;
import haxe.ui.components.Button;
import h2d.Text;
import h2d.TextInput;
import states.Gallery;
import states.Menu;
import hxd.snd.ChannelGroup;
import states.Game;
import hxd.res.Loader;
import hxd.fmt.pak.FileSystem;
import h2d.Bitmap;
import io.newgrounds.NG;
import input.MouseInput;
import h3d.Engine;
import h2d.Scene;
import haxe.ui.Toolkit;
import graphics.RenderObject;
import graphics.Animation;
import input.PadInput;
import hxd.Window;
import haxe.ds.Vector;
import input.Actions;
import hxd.Key;
import h2d.Object;
import input.Input;
import input.ActionSet;
import ecs.Universe;
import hxd.Res;
import hxd.App;
import utils.ResTools;
import graphics.AnimSystem;
import input.InputSystem;
import input.KeyboardInput;
import graphics.RenderSystem;
import graphics.fx.FXSystem;
import utils.ListEnumAbstract;
import dialogue.DialogueSystem;
import audio.AudioSystem;

class Main extends App {
	
	var ecs:Universe;
	
	var preload:h2d.Text;
	var preloader:Bitmap;
	var uiScene:Scene;
	
	var menu:Menu;
	var game:Game;
	var gallery:Gallery;
	
	static function main() {
		
		#if !js
		Res.initPak();
		#end
		new Main();
	}
	
	override function init() {
		
		NG.createAndCheckSession("54051:rCaap0qo");
		NG.core.initEncryption("bEjwAy3faDRTr53eqaNQhg==");
		
		if (!NG.core.attemptingLogin) NG.core.requestLogin(onNGLogin);
		else NG.core.onLogin.add(onNGLogin);
		
		#if !js
		realInit();
		#else
		ResTools.initPakAuto("preload",
			() -> {
				
				preload = new h2d.Text(Res.fonts.defaultFont.toFont(), s2d);
				preload.textColor = 0xffffffff;
				preload.x = 940; preload.y = 660;
				
				preloader = new Bitmap(Res.preloader.Loading.toTile(), s2d);
				preloader.x = 1280 - 815; preloader.y = 720 - 292;
			},
			p -> { }
		);
		
		ResTools.initPakAuto("assets",
			() -> {
				s2d.removeChild(preload);
				s2d.removeChild(preloader);
				
				var intro = new Object(s2d);
				
				var input = new TextInput(Res.fonts.defaultFont.toFont(), intro);
				input.backgroundColor = 0xffffffff;
				input.inputWidth = 300;
				input.maxWidth = 300;
				input.textColor = 0xffaaaaaa;
				input.text = DialogueSystem.NAME;
				input.scale(2);
				input.x = (1280 - input.maxWidth * 2) / 2;
				input.y = 330;
				
				input.onFocus = e -> {
					input.textColor = 0xff000000;
				};
				
				input.onFocusLost = e -> {
					input.textColor = 0xffaaaaaa;
				};
				
				input.onChange = () -> {
					if (input.text.length > 18) input.text = input.text.substr(0, 18);
				};
				
				var tf = new Text(Res.fonts.defaultFont.toFont(), intro);
				tf.textColor = 0xffffffff;
				tf.textAlign = Center;
				tf.text = "Welcome to Interstice Academy!\nEnter your name:\n\n\nClick to enroll";
				tf.scale(2);
				tf.x = (1280 - tf.maxWidth) / 2;
				tf.y = 190;
				
				var button = new Interactive(400, 80, intro);
				button.x = (1280 - button.width) / 2;
				button.y = 440;
				
				button.onOver = e -> {
					Res.sfx.over.play();
					button.cursor = Button;
				}
				
				button.onOut = e -> {
					button.cursor = Default;
				};
				
				button.onClick = e -> {
					
					if (input.text.length > 0) {
						DialogueSystem.NAME = input.text;
						Res.sfx.select.play();
						s2d.removeChild(intro);
						realInit();
					}
				};
			},
			(p:Float) -> {
				if (preload != null) preload.text = '${Std.int(p * 100)}%';
			}
		);
		#end
	}
	
	function realInit() {
		
		var stage = hxd.Window.getInstance();
		stage.displayMode = Windowed;
		
		engine.backgroundColor = 0xff871717;
		
		// stage.vsync = false;
		
		// need to carefully consider the order here
		// render comes before animate
		
		ecs = Universe.create({
			entities : 100, // eventually this should be chosen intelligently
			phases : [
				{
					name : "all",
					systems : [
						InputSystem,
						FXSystem,
						RenderSystem,
						AnimSystem,
						AudioSystem
					]
				},
				{
					name : "dia",
					enabled : false,
					systems : [
						DialogueSystem
					]
				}
			]
		});
		
		ECS.eventity = ecs.createEntity();
		ECS.ecs = ecs;
		
		var globalMapping = new InputMapping();
		globalMapping[Actions.SELECT] = [Key.SPACE, Key.Z];
		globalMapping[Actions.MUTE] = [Key.M];
		globalMapping[Actions.VOL_DOWN] = [Key.QWERTY_MINUS, Key.QWERTY_COMMA];
		globalMapping[Actions.VOL_UP] = [Key.QWERTY_EQUALS, Key.QWERTY_PERIOD];
		// globalMapping[Actions.FULLSCREEN] = [Key.F];
		
		var globalPad = new InputMapping();
		globalPad[Actions.SELECT] = [PadButtons.A];
		
		var globalMouse = new InputMapping();
		globalMouse[Actions.SELECT] = [Key.MOUSE_LEFT]; // includes touch
		
		var input:Input = {
			actions : new ActionSet(),
			previous : new ActionSet(),
			devices : [
				new KeyboardInput(
					globalMapping,
					new Vector(ListEnumAbstract.count(Actions))
				),
				new PadInput(
					globalPad,
					new Vector(ListEnumAbstract.count(Actions))
				),
				new MouseInput(
					globalMouse,
					new Vector(ListEnumAbstract.count(Actions))
				)
			]
		};
		
		var musicGroup = new ChannelGroup("music");
		
		uiScene = new Scene();
		setScene2D(uiScene, false);
		Toolkit.init({ root : uiScene, manualUpdate : false });
		
		menu = new Menu(ecs, uiScene);
		game = new Game(ecs, uiScene);
		gallery = new Gallery(ecs, uiScene);
		menu.game = game;
		menu.gallery = gallery;
		game.menu = menu;
		gallery.menu = menu;
		
		ecs.setComponents(ecs.createEntity(), input);
		ecs.setResources(input, musicGroup, game);
		
		menu.begin();
		
		onResize();
	}
	
	function onNGLogin() {
		
		trace('hi ${NG.core.user.name}');
		
		if (DialogueSystem.NAME == "Player" || DialogueSystem.NAME == null) {
			DialogueSystem.NAME = NG.core.user.name;
		}
		
		NG.core.requestMedals(() -> {
			trace('got medals');
			
		});
	}
	
	override function onResize() {
		super.onResize();
		
		var scale = 1;
		
		if (scale > 1) {
			if (s2d.filter == null) s2d.filter = new h2d.filter.Nothing();
			if (uiScene.filter == null) uiScene.filter = new h2d.filter.Nothing();
		}
		
		else {
			s2d.filter = null;
			uiScene.filter = null;
		}
		
		final screen = Window.getInstance();
		
		var w = Std.int(screen.width / scale);
		var h = Std.int(screen.height / scale);
		
		s2d.scaleMode = ScaleMode.Stretch(w, h);
		uiScene.scaleMode = ScaleMode.Stretch(w, h);
	}
	
	override function render(e:Engine) {
		super.render(e);
		
		if (uiScene != null) uiScene.render(e);
	}
	
	override function update(dt:Float) {
		
		if (ecs != null) ecs.update(dt);
		super.update(dt);
		
		// trace("draw calls: " + engine.drawCalls);
	}
}