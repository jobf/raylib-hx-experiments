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

		var scene_constructor = game -> return new PlayScene(game, sceneBounds, Rl.Colors.BLACK);

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
