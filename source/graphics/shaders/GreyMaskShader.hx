package graphics.shaders;

import hxsl.Shader;

class GreyMaskShader extends Shader {
	static var SRC = {
		@:import h3d.shader.Base2d;
		
		@param var mask:Sampler2D;
		@param var percent:Float;
		
		function fragment() {
			// does alpha mess with this?
			var invgrey = 1.0 - mask.get(calculatedUV).r;
			pixelColor = textureColor * step(invgrey, percent) * sign(percent); // 1 if perc == igrey == 1.0, 0 if perc == igrey == 0.0
		}
	}
}