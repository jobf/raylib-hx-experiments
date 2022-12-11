import Particles.Emitter;
import Rl;
import Core;

using Physics.MotionComponentLogic;

class Main {
	static var game:Game;

	static function main() {
		var windowBounds:RectangleGeometry = {
			width: 640,
			height: 480
		}

		Rl.initWindow(windowBounds.width, windowBounds.height, "particles");
		// Rl.setTargetFPS(60);
		// as far as I can see, VSYNC_HINT is a bit smoother
		Rl.setWindowState(Rl.ConfigFlags.VSYNC_HINT);

		var sceneBounds:RectangleGeometry = {
			width: windowBounds.width,
			height: windowBounds.height
		}

		var scene_constructor = game -> return new ParticleScene(game, sceneBounds, Rl.Colors.BLACK);

		game = new Game(scene_constructor, windowBounds);

		while (!Rl.windowShouldClose()) {
			game.update(Rl.getFrameTime());
			Rl.beginDrawing();
			game.draw();
			Rl.endDrawing();
		}

		Rl.closeWindow();
	}
}

class ParticleScene extends Scene {
	var emitter:Emitter;

	public function init() {
		var center_scene = Std.int(bounds.width * 0.5);
		emitter = new Emitter(center_scene, bounds.height);

		var speed_slider_min = 0.1;
		var speed_slider_max = 3000;
		game.editor.add_slider("x acceleration min", emitter.x_speed_minimum, speed_slider_min, speed_slider_max, value -> emitter.x_speed_minimum = value);
		game.editor.add_slider("x acceleration max", emitter.y_speed_maximum, speed_slider_min, speed_slider_max, value -> emitter.y_speed_maximum = value);
		game.editor.add_slider("y acceleration min", emitter.y_speed_minimum, speed_slider_min, speed_slider_max, value -> emitter.y_speed_minimum = value);
		game.editor.add_slider("y acceleration max", emitter.y_speed_maximum, speed_slider_min, speed_slider_max, value -> emitter.y_speed_maximum = value);

		game.editor.add_slider("seconds between particles", emitter.seconds_between_particles, 0.001, 2, value -> emitter.seconds_between_particles = value);
		game.editor.add_slider("particle size", emitter.particle_size, 1, 100, value -> emitter.particle_size = Std.int(value));
	}


	public function update(elapsed_seconds:Float) {
		emitter.update(elapsed_seconds);
	}

	public function draw() {
		emitter.draw();
	}
}
