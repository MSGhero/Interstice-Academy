package dialogue;

import hxd.snd.Channel;
import timing.Tweener;
import io.newgrounds.NG;
import haxe.ui.events.MouseEvent;
import haxe.ui.components.Button;
import h2d.Object;
import ecs.Entity;
import dialogue.Dialogue.Line;
import hxd.Res;
import haxe.ds.StringMap;
import timing.Updater;
import ecs.Universe;
import ecs.System;
import ui.Text;
import input.Input;
import hscript.Parser;
import hscript.Interp;
import haxe.ui.containers.Grid;
import ui.*;
import haxe.ui.components.Image;
import hxd.snd.ChannelGroup;
import states.Game;

class DialogueSystem extends System {
	
	public static var NAME:String = "Player";
	
	@:fullFamily
	var uiElements : {
		resources : {
			text:Text,
			speaker:Speaker,
			options:Grid,
			image:Display,
			fade:Image,
			bg:Background,
			bgFade:BGFade,
			charFade:CharFade,
			container:UIContainer,
			border:Border,
			musicGroup:ChannelGroup,
			game:Game
		}
	};
	
	@:fastFamily
	var events : {
		event:Event
	};
	
	@:fullFamily
	var inputs : {
		resources : {
			input:Input
		}
	};
	
	var uiEntity:Entity;
	var fadeEntity:Entity;
	var optEntity:Entity;
	var charEntity:Entity;
	var charFadeEntity:Entity;
	var containerEntity:Entity;
	var borderEntity:Entity;
	
	var typing:Updater;
	var paused:Bool;
	
	var diaMap:StringMap<Dialogue>;
	var currDia:Dialogue;
	var currLine:Line;
	var finalText:String;
	
	var bgChannel:Channel;
	var voiceChannel:Channel;
	
	var parser:Parser;
	var interp:Interp;
	
	public function new(ecs:Universe) {
		super(ecs);
		
		typing = {
			duration : 0.02,
			repetitions : 0,
			paused : false,
			callback : onType,
			onComplete : onFinishType
		};
		
		paused = false;
		
		parser = new Parser();
		interp = new Interp();
		
		bgChannel = null;
		voiceChannel = null;
		
		diaMap = new StringMap();
		
		var diaFiles = Res.loader.dir("dia/s0")
			.concat(Res.loader.dir("dia/s1"))
			.concat(Res.loader.dir("dia/s2"))
			.concat(Res.loader.dir("dia/s3"))
			.concat(Res.loader.dir("dia/ana"))
			.concat(Res.loader.dir("dia/ars"))
			.concat(Res.loader.dir("dia/demi"))
			.concat(Res.loader.dir("dia/fme"))
			.concat(Res.loader.dir("dia/henderson"))
			.concat(Res.loader.dir("dia/junior"))
		;
		
		for (file in diaFiles) {
			
			var s = file.name;
			
			if (s.substr(-4, 4) != ".dia") {
				continue;
			}
			
			s = s.substring(0, s.length - 4);
			
			var dia = DiaParser.parseDia(file.entry.getText(), s);
			var d = Dialogue.fromDynamic(Reflect.field(dia, s));
			diaMap.set(s, d);
		}
		
		interp.variables.set("player", NAME);
		interp.variables.set("chosen", "");
		interp.variables.set("item", "");
		interp.variables.set("itemName", "");
		interp.variables.set("anastasia", "");
		interp.variables.set("hark", hark);
		
		interp.variables.set("playMusic", playMusic);
		interp.variables.set("fadeMusic", fadeMusic);
		interp.variables.set("showBG", showBG);
		interp.variables.set("fadeBG", fadeBG);
		interp.variables.set("showImage", showImage);
		interp.variables.set("showImages", showImages);
		interp.variables.set("hideImage", hideImage);
		interp.variables.set("fadeOut", fadeOut);
		interp.variables.set("fadeIn", fadeIn);
		interp.variables.set("doubleFade", doubleFade);
		interp.variables.set("pause", pause);
		interp.variables.set("column", column);
		interp.variables.set("demiFont", demiFont);
		interp.variables.set("boldFont", boldFont);
		interp.variables.set("defaultFont", defaultFont);
		interp.variables.set("medal", medal);
		interp.variables.set("showUI", showUI);
		interp.variables.set("hideUI", hideUI);
		interp.variables.set("showBorder", showBorder);
		interp.variables.set("hideBorder", hideBorder);
		interp.variables.set("changeBorder", changeBorder);
		interp.variables.set("bwBox", bwBox);
		interp.variables.set("normalBox", normalBox);
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		uiElements.onActivated.subscribe(onUI);
		events.onEntityAdded.subscribe(handleEvent);
	}
	
	override function onDisabled() {
		super.onDisabled();
		
		uiElements.onActivated.unsubscribe(onUI);
		events.onEntityAdded.unsubscribe(handleEvent);
	}
	
	function onUI(_) {
		
		setup(uiElements, {
			
			uiEntity = ECS.ecs.createEntity();
			fadeEntity = ECS.ecs.createEntity();
			optEntity = ECS.ecs.createEntity();
			charEntity = ECS.ecs.createEntity();
			charFadeEntity = ECS.ecs.createEntity();
			containerEntity = ECS.ecs.createEntity();
			borderEntity = ECS.ecs.createEntity();
			
			ECS.ecs.setComponents(uiEntity, (fade:Object));
			ECS.ecs.setComponents(fadeEntity, (cast bgFade:Object));
			ECS.ecs.setComponents(optEntity, (cast options:Object));
			ECS.ecs.setComponents(charEntity, (cast image:Object));
			ECS.ecs.setComponents(charFadeEntity, (cast charFade:Object));
			ECS.ecs.setComponents(containerEntity, (cast container:Object));
			ECS.ecs.setComponents(borderEntity, (cast border:Object));
		});
	}
	
	function onOver(me:MouseEvent) {
		Res.sfx.over.play();
	}
	
	function onSelection(me:MouseEvent) {
		
		setup(uiElements, {
			
			typing.paused = false;
			
			Res.sfx.select.play();
			
			options.lockLayout(false);
			options.columns = 1;
			options.disabled = true;
			
			ECS.event(FX_FADE(optEntity, 1, 0, 0.25, () -> {
				options.hidden = true;
				options.unlockLayout(false);
				options.disabled = false;
				options.removeAllComponents();
			}));
			
			ECS.event(DIALOGUE_INIT(me.target.userData));
			ECS.event(DIALOGUE_ADVANCE);
		});
	}
	
	function handleEvent(eventity) {
		
		fetch(events, eventity, {
			
			switch (event) {
				
				case DIALOGUE_INIT(id):
					
					if (id == null) {
						// trigger menu or something?
						return;
					}
					
					else {
						currDia = diaMap.get(id);
						currDia.resetLines();
					}
					
				case DIALOGUE_ADVANCE:
					
					if (typing.isActive) {
						// give to updater? force complete
						typing.repetitions = 0;
						if (typing.onComplete != null) typing.onComplete();
					}
					
					else if (!typing.paused) {
						
						currLine = currDia.getNextLine();
						
						if (currLine != null) {
							// dialogue to progress through
							
							if (currLine.speaker != null && currLine.speaker.length > 0) {
								setup(uiElements, {
									speaker.hidden = false;
									speaker.text = execute(currLine.speaker);
									if (speaker.text == "Demi" || speaker.text == "Shadow Spawn") demiFont(); // easier than assigning each time for demi
									else defaultFont();
								});
							}
							
							else {
								setup(uiElements, {
									speaker.hidden = true;
									defaultFont(); // easier than assigning each time for demi
								});
							}
							
							if (currLine.text != null) {
								
								finalText = execute(currLine.text);
								
								setup(uiElements, {
									
									text.text = "";
									
									var fc = finalText.charAt(0);
									if (fc != '"' && fc != '”' && fc != '“') { // in case there's no obvious reset, narration and player don't have quotes
										speaker.hidden = true;
										defaultFont();
									}
								});
								
								typing.repetitions = finalText.length;
							}
							
							if (currLine.tags != null) {
								var pp = currLine.tags.get("ex");
								if (pp != null) execute(pp);
							}
						}
						
						else {
							
							if (currDia.options.length == 0) {
								
								setup(uiElements, {
									if (bgChannel != null) bgChannel.stop();
									game.end();
								});
								
								return;
							}
							
							var text0 = execute(currDia.options[0].text);
							
							if (currDia.options.length == 1 && (text0 == null || text0.length == 0)) {
								ECS.event(DIALOGUE_INIT(execute(currDia.options[0].next)));
								ECS.event(DIALOGUE_ADVANCE);
							}
							
							else {
								
								setup(uiElements, {
									
									var b:Button, ww = 0.0, hh = 0.0, useX = false;
									for (option in currDia.options) {
										
										b = new Button();
										
										var tt = execute(option.text);
										if (Res.loader.exists(tt + ".png")) {
											ww = b.width = 160;
											hh = b.height = 160;
											b.icon = tt + ".png";
											useX = true;
										}
										
										else {
											ww = b.width = 350;
											hh = 90; // b.height = 90;
											b.styleNames = "selbut";
											b.text = tt;
										}
										
										b.userData = execute(option.next);
										b.registerEvent(MouseEvent.CLICK, onSelection);
										b.registerEvent(MouseEvent.MOUSE_OVER, onOver);
										options.addComponent(b);
									}
									
									if (useX) {
										options.x = (1116 - options.columns * ww - (options.columns - 1) * 20) / 2;
										options.y = (404 - Math.ceil(options.numComponents / options.columns) * (hh + 20) + 20) / 2;
									}
									
									else {
										options.left = (1116 - options.columns * ww - (options.columns - 1) * 20) / 2;
										options.top = (404 - Math.ceil(options.numComponents / options.columns) * (hh + 20) + 20) / 2;
									}
									
									options.hidden = false;
									options.disabled = true;
									
									ECS.event(FX_FADE(optEntity, 0, 1, 0.25, () -> {
										options.disabled = false;
									})); // fade buttons in
								});
								
								typing.paused = true;
							}
						}
					}
					
					else if (!paused) {
						
						setup(uiElements, {
							if (options.hidden) {
								typing.paused = false;
							}
						});
					}
					
				default:
			}
		});
	}
	
	function onType() {
		
		setup(uiElements, {
			
			var char = finalText.charAt(finalText.length - typing.repetitions);
			text.text = finalText.substr(0, finalText.length - typing.repetitions + 1);
			
			if (char == '\n') {
				typing.paused = true;
			}
		});
	}
	
	function onFinishType() {
		
		setup(uiElements, {
			text.text = finalText;
			pause(0.2);
		});
	}
	
	function hark() {
		
		if (NG.core.loggedIn) {
			
			var medals = NG.core.medals;
			
			var hark = 68004;
			if (medals.get(hark).unlocked) return "s0_hark";
			
			// good routes only:
			// ana = 67996;
			// ars = 67997;
			// demi = 68063;
			// fme = 68001;
			// hend = 68002;
			// junior = 68003;
			
			var ids = [
				67996, 67997, 68063, 68001, 68002, 68003
			];
			
			for (id in ids) {
				if (!medals.get(id).unlocked) return "s1_intro";
			}
			
			return "s0_hark";
		}
		
		return "s1_intro";
	}
	
	function playMusic(path:String) {
		
		setup(uiElements, {
			
			var sndCh = Res.loader.load('$path.ogg').toSound().play(true, 0.6, musicGroup); // volume
			var currVol = bgChannel == null ? 1 : bgChannel.volume;
			
			var currTw:Tweener = {
				repetitions : 1,
				duration : 1,
				onUpdate : f -> {
					if (bgChannel != null) bgChannel.volume = (1 - f) * currVol;
					sndCh.volume = f * currVol;
				},
				onComplete : () -> {
					if (bgChannel != null) bgChannel.stop();
					bgChannel = sndCh;
				}
			}
			
			ECS.event(FX_UPDATER_RAW(uiEntity, currTw));
		});
	}
	
	function fadeMusic(dur:Float) {
		
		setup(uiElements, {
			
			var currTw:Tweener = {
				repetitions : 1,
				duration : dur,
				onUpdate : f -> {
					if (bgChannel != null) bgChannel.volume = (1 - f);
				},
				onComplete : () -> {
					if (bgChannel != null) bgChannel.stop();
					bgChannel = null;
				}
			}
			
			ECS.event(FX_UPDATER_RAW(uiEntity, currTw));
		});
	}
	
	function showBG(path:String, delay:Float = 0) {
		
		setup(uiElements, {
			
			if (delay == 0) {
				bg.resource = path + ".png";
				bg.hidden = false;
				bg.validateComponent();
			}
			
			else {
				ECS.event(FX_DELAY(uiEntity, delay, showBG.bind(path)));
			}
			
			0;
		});
	}
	
	function fadeBG(path:String, dur:Float) {
		
		setup(uiElements, {
			
			bgFade.resource = path + ".png";
			bgFade.hidden = false;
			bgFade.alpha = 0;
			bgFade.validateNow();
			
			ECS.event(
				FX_FADE(
					fadeEntity,
					0,
					1,
					dur,
					() -> {
						showBG(path);
						bgFade.hidden = true;
						bgFade.validateNow();
					}
				)
			);
		});
	}
	
	function showImage(path:String) {
		
		setup(uiElements, {
			
			if (image.hidden) {
				charFade.resource = '$path.png';
				charFade.alpha = 0;
				charFade.validateNow();
				fadeImageIn();
				
				ECS.event(FX_DELAY(uiEntity, 0.25, () -> {
					playSFX(path);
				}));
			}
			
			else if (image.resource != '$path.png') {
				
				image.resource = '$path.png';
				// image.alpha = 0;
				// image.validateNow();
				fadeImageOut();
				
				ECS.event(FX_DELAY(charFadeEntity, 0.25, () -> {
					charFade.resource = '$path.png';
					charFade.validateNow();
					playSFX(path);
				}));
			}
		});
	}
	
	function hideImage() {
		
		setup(uiElements, {
			
			if (!image.hidden || image.alpha != 0) {
				
				image.hidden = true;
				image.alpha = 0;
				
				fadeImageOut();
			}
		});
	}
	
	function showImages(paths:Array<String>, dur:Float) {
		
		showImage(paths.shift());
		
		var cuDur = 0.0;
		while (paths.length > 0) {
			cuDur += dur;
			var path = paths.shift();
			ECS.event(FX_DELAY(uiEntity, cuDur, showImage.bind(path)));
		}
	}
	
	function fadeImageOut() {
		
		setup(uiElements, {
			
			charFade.hidden = false;
			
			ECS.event(FX_FADE(
				charFadeEntity, 1, 0, 0.25, () -> charFade.hidden = true
			));
		});
	}
	
	function fadeImageIn() {
		
		setup(uiElements, {
			
			charFade.hidden = false;
			
			ECS.event(FX_FADE(
				charFadeEntity, 0, 1, 0.25, () -> {
					image.resource = charFade.resource;
					image.hidden = false;
					image.alpha = 1;
					image.validateNow();
					// charFade.hidden = true;
				}
			));
		});
	}
	
	function fadeOut(dur:Float) {
		
		ECS.event(FX_FADE(
			uiEntity,
			0,
			1,
			dur,
			null
		));
	}
	
	function fadeIn(dur:Float) {
		
		ECS.event(FX_FADE(
			uiEntity,
			1,
			0,
			dur,
			null
		));
	}
	
	function doubleFade(path0:String, path1:String, durOut:Float, durHold:Float, durIn:Float) {
		
		fadeBG(path0, durOut);
		
		ECS.event(
			FX_DELAY(
				uiEntity,
				durOut + durHold,
				fadeBG.bind(path1, durIn)
			)
		);
	}
	
	function pause(dur:Float) {
		
		paused = typing.paused = true;
		
		ECS.event(
			FX_DELAY(
				uiEntity,
				dur,
				() -> {
					paused = typing.paused = false;
				}
			)
		);
	}
	
	function column(i:Int) {
		
		setup(uiElements, {
			options.columns = i;
		});
	}
	
	function demiFont() {
		
		setup(uiElements, {
			text.styleString = "font-name: fonts/astonished.fnt;";
		});
	}
	
	function boldFont() {
		
		setup(uiElements, {
			text.styleString = "font-name: fonts/boldfont.fnt;";
		});
	}
	
	function defaultFont() {
		
		setup(uiElements, {
			text.styleString = "font-name: fonts/defaultFont.fnt;";
		});
	}
	
	function playSFX(path:String) {
		
		if (Res.loader.exists('$path.ogg')) {
			if (voiceChannel != null) voiceChannel.stop();
			voiceChannel = Res.load('$path.ogg').toSound().play(false);
		}
	}
	
	function medal(id:Int) {
		
		if (NG.core.loggedIn && NG.core.medals != null) {
			var med = NG.core.medals.get(id);
			if (!med.unlocked) {
				med.sendUnlock();
			}
		}
	}
	
	function showUI() {
		
		setup(uiElements, {
			ECS.event(FX_FADE(
				containerEntity,
				0,
				1,
				2,
				null
			));
		});
	}
	
	function hideUI() {
		
		setup(uiElements, {
			ECS.event(FX_FADE(
				containerEntity,
				1,
				0,
				2,
				null
			));
		});
	}
	
	function showBorder(dur:Float, delay:Float) {
		
		setup(uiElements, {
			
			ECS.event(FX_DELAY(
				borderEntity, delay, () -> {
					
					border.hidden = false;
					
					ECS.event(FX_FADE(
						borderEntity,
						0,
						1,
						dur,
						null
					));
				}
			));
			
			
		});
	}
	
	function hideBorder(dur:Float, delay:Float) {
		
		setup(uiElements, {
			
			ECS.event(FX_DELAY(
				borderEntity, delay, () -> {
					
					ECS.event(FX_FADE(
						borderEntity,
						1,
						0,
						dur,
						() -> border.hidden = true
					));
				}
			));
		});
	}
	
	function changeBorder(path:String) {
		
		setup(uiElements, {
			border.resource = '$path.png';
			border.validateNow();
		});
	}
	
	function bwBox() {
		
		setup(uiElements, {
			text.backgroundImage = "candybox6_9s.png";
		});
	}
	
	function normalBox() {
		
		setup(uiElements, {
			text.backgroundImage = "candybox4_9s.png";
		});
	}
	
	function execute(s:String) {
		return (interp.execute(parser.parseString(s)):String);
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		typing.update(dt);
		
		setup(inputs, {
			
			if (input.actions.justPressed.getAction(SELECT)) {
				ECS.event(DIALOGUE_ADVANCE);
			}
		});
	}
}