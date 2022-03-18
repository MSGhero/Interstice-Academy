package graphics.shaders;

import h3d.shader.ScreenShader;

class OverlayShader extends ScreenShader {
	static var SRC = {
		
		@param var texture:Sampler2D;
		@param var color:Vec4;
		@const var active:Bool;
		
		function fragment() {
			
			if (active) {
				var pixel = texture.get(calculatedUV);
				pixelColor = mix(1 - 2 * (1 - pixel) * (1 - color), 2 * pixel * color, step(pixel, vec4(0.5)));
			}
			
			else pixelColor = texture.get(calculatedUV);
		}
	};
}