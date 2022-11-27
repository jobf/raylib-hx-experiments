import Rl;
import Core;
import Controller;

class Main {
	static var game:Game;

	static function main() {
		Rl.initWindow(640, 480, "ray");

		// using VSYNC_HINT is better than setTargetFPS as it will use the GPU as a source for timing, which is more reliable
		// more info here - https://bedroomcoders.co.uk/why-you-shouldnt-use-settargetfps-with-raylib/
		// it should result in less CPU and less screen tearing
		Rl.setWindowState(Rl.ConfigFlags.VSYNC_HINT);
		// Rl.setTargetFPS(60);

		game = new Game(game -> {
			return new TestScene(game, Rl.Colors.GOLD);
		});

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
	var background:Texture2D;
	var player:Player;

	public function init() {
		background = Rl.loadTexture("assets/bg-dogtooth.png");

		player = new Player(40, 60);

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
		game.camera.target.x = player.x;
		game.camera.target.y = player.y;
	}

	public function draw() {
		Rl.drawTexture(background, 0, 0, Rl.Colors.WHITE);
		player.draw();
	}
}

class Player {
	public var x(default, null):Int;
	public var y(default, null):Int;
	var x_vel:Float = 0.0;
	var y_vel:Float = 0.0;
	var x_vel_increment:Float = 50.0;
	var y_vel_increment:Float = 50.0;

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
		Rl.drawCircle(x, y, size, color);
	}

	public function move(x_direction:Int, y_direction:Int) {
		x_vel += x_direction * x_vel_increment;
		y_vel += y_direction * y_vel_increment;
		trace('new velocities $x_vel $y_vel');
	}
}
