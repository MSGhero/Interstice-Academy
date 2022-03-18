package;

import h2d.filter.Group;
import Config.DisplayConfig;
import echo.Shape;
import echo.math.Vector2;
import Config.BodyConfig;
import Config.AnimConfig;
import Config.ContainerConfig;
import echo.Body;
import graphics.Spritesheet;
import h2d.Bitmap;
import graphics.RenderObject;
import h2d.Object;
import graphics.Animation;
import ecs.Universe;
import ecs.Entity;

@:forward @:transitive
abstract Base(Entity) to Entity {
	
	public function new(ecs:Universe, config:Config, sheet:Spritesheet) {
		
		this = ecs.createEntity();
		
		var obj = createContainer(config.container);
		var anim = createAnim(config.anim, sheet);
		var disp = createDisplay(config.display, obj, anim);
		var body = createBody(config.body);
		
		obj.x = config.init.x;
		obj.y = config.init.y;
		
		body.x += config.init.x;
		body.y += config.init.y;
		
		anim.play(config.init.anim);
		
		ecs.setComponents(this, obj, anim, disp, body);
	}
	
	function createContainer(config:ContainerConfig) {
		
		var o = new Object();
		o.filter = new Group();
		o.scale(config.scale);
		
		return o;
	}
	
	function createAnim(configs:Array<AnimConfig>, sheet:Spritesheet) {
		
		var anim:Animation = {
			updater : { }
		};
		
		for (config in configs) {
			anim.add(config.name, {
				frames : sheet.map(config.frameNames),
				loop : config.loop,
				fps : config.fps
			});
		}
		
		return anim;
	}
	
	function createDisplay(config:DisplayConfig, container:Object, anim:Animation) {
		
		var ro:RenderObject = {
			sprite : new Bitmap(null, container),
			anim : anim
		};
		
		ro.sprite.x = -config.offsetX;
		ro.sprite.y = -config.offsetY;
		
		return ro;
	}
	
	function createBody(config:BodyConfig) {
		
		// apply default shape since j2o sets everything to null by default
		var shape = Shape.defaults;
		
		for (field in Reflect.fields(config.shape)) {
			var p = Reflect.field(config.shape, field);
			if (p != null) Reflect.setField(shape, field, p);
		}
		
		var body = new Body({
			x : config.offsetX,
			y : config.offsetY,
			kinematic : config.kinematic,
			gravity_scale : config.gravityScale,
			elasticity : config.elasticity,
			drag_length : config.dragLength,
			max_velocity_length : config.maxSpeed,
			shape : shape
		});
		
		body.offset = new Vector2(-config.offsetX, -config.offsetY);
		
		for (layer in config.groups) body.layers.add(layer);
		for (mask in config.mask) body.layer_mask.add(mask);
		
		return body;
	}
}