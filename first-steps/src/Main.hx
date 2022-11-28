import Rl;
import Core;
import Controller;

class Main {
	static var game:Game;

	static function main() {
		var windowBounds:RectangleGeometry = {
			width: 640,
			height: 480
		}
		Rl.initWindow(windowBounds.width, windowBounds.height, "ray");

		// using VSYNC_HINT is better than setTargetFPS as it will use the GPU as a source for timing, which is more reliable
		// more info here - https://bedroomcoders.co.uk/why-you-shouldnt-use-settargetfps-with-raylib/
		// it should result in less CPU and less screen tearing
		Rl.setWindowState(Rl.ConfigFlags.VSYNC_HINT);
		// Rl.setTargetFPS(60);

		var assets = new Assets([BACKGROUND => "assets/bg-dogtooth.png"]);

		var bg:Texture2D = assets.textures[BACKGROUND];

		var sceneBounds:RectangleGeometry = {
			width: bg.width,
			height: bg.height
		}
		var initScene = game -> return new TestScene(game, sceneBounds, Rl.Colors.GOLD);

		game = new Game(initScene, windowBounds, assets);

		while (!Rl.windowShouldClose()) {
			game.update(Rl.getFrameTime());
			Rl.beginDrawing();
			game.draw();
			Rl.endDrawing();
			/*
				By default, Rl.endDrawing() calls the following processes:
				* 1. Draw remaining batch data: rlDrawRmain_loop_enderBatchActive()
				* 2. SwapScreenBuffer()
				* 3. Frame time control: WaitTime()
				* 4. PollInputEvents()
			 */
		}

		Rl.closeWindow();
	}
}

class TestScene extends Scene {
	var controller:Controller;
	var background:Texture;
	var player:Player;

	public function init() {
		background = game.getTexture(BACKGROUND);

		var x_init:Int = Std.int(bounds.width * 0.5);
		var y_init:Int = Std.int(bounds.height * 0.5);
		player = new Player(x_init, y_init);

		controller = new Controller({
			on_move_right: () -> player.move(1, 0),
			on_move_left: () -> player.move(-1, 0),
			on_move_up: () -> player.move(0, -1),
			on_move_down: () -> player.move(0, 1)
		});
	}

	public function update(elapsed_seconds:Float) {
		controller.update();
		player.update(elapsed_seconds);

		// check if player is outside bounds
		if (0 > player.x - player.size) {
			player.stop_x();
			// reset player position to within the bounds
			player.x = player.size;
		}
		if (player.x > bounds.width - player.size) {
			player.stop_x();
			// reset player position to within the bounds
			player.x = bounds.width - player.size;
		}
		if (0 > player.y - player.size) {
			player.stop_y();
			// reset player position to within the bounds
			player.y = player.size;
		}
		if (player.y > bounds.height - player.size) {
			player.stop_y();
			// reset player position to within the bounds
			player.y = bounds.height - player.size;
		}

		game.update_cameraCenterInsideBounds(player.x, player.y, bounds.width, bounds.height);
	}

	public function draw() {
		Rl.drawTexture(background, 0, 0, Rl.Colors.WHITE);
		player.draw();
	}
}

class Player {
	public var x:Int;
	public var y:Int;

	var x_vel:Float = 0.0;
	var y_vel:Float = 0.0;
	var x_vel_increment:Float = 100.0;
	var y_vel_increment:Float = 100.0;

	public var size:Int = 50;
	public var color:RlColor = Rl.Colors.DARKPURPLE;

	public function new(x:Int, y:Int) {
		this.x = x;
		this.y = y;
	}

	public function update(elapsed_seconds:Float) {
		x += Math.ceil(x_vel * elapsed_seconds);
		y += Math.ceil(y_vel * elapsed_seconds);
		// trace('$elapsed_seconds $x $y');
	}

	public function draw() {
		Rl.drawCircle(x, y, size * 0.5, color);
	}

	public function move(x_direction:Int, y_direction:Int) {
		x_vel += x_direction * x_vel_increment;
		y_vel += y_direction * y_vel_increment;
		trace('new velocities $x_vel $y_vel');
	}

	public function stop() {
		y_vel = 0;
		x_vel = 0;
	}

	public function stop_x() {
		x_vel = 0;
	}

	public function stop_y() {
		y_vel = 0;
	}
}

enum abstract Textures(Int) from Int to Int {
	var BACKGROUND;
}
