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

		// using VSYNC_HINT might be better than setTargetFPS as it will use the GPU as a source for timing, which is more reliable
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
			on_move_down: () -> player.move(0, 1),
			on_mouse_press_left: mouse_pos_screen -> {
				trace_mouse_pos('LEFT', mouse_pos_screen);
				place_obstacle(mouse_pos_screen);
			},
			on_mouse_press_right: mouse_pos_screen -> trace_mouse_pos('RIGHT', mouse_pos_screen),
		});
	}

	public function update(elapsed_seconds:Float) {
		controller.update();
		player.update(elapsed_seconds);
		collide_player_with_bounds();
		collide_player_with_obstacles();

		var x_player = Std.int(player.position.x);
		var y_player = Std.int(player.position.y);
		game.update_cameraCenterInsideBounds(x_player, y_player, bounds.width, bounds.height);
	}

	public function draw() {
		Rl.drawTexture(background, 0, 0, Rl.Colors.WHITE);
		player.draw();
		for (obstacle in obstacles) {
			obstacle.draw();
		}
	}

	function trace_mouse_pos(button:String, mouse_pos_screen:Vector2) {
		var mouse_pos_world = Rl.getScreenToWorld2D(mouse_pos_screen, game.camera);
		trace('click $button \n window pos : ${mouse_pos_screen.x} ${mouse_pos_screen.y} \n world pos  : ${mouse_pos_world.x} ${mouse_pos_world.y}');
	}

	var obstacles:Array<Obstacle> = [];

	function place_obstacle(mouse_pos_screen:Vector2) {
		var mouse_pos_in_world = Rl.getScreenToWorld2D(mouse_pos_screen, game.camera);
		final size = 60;
		var x_center_offset = Std.int(mouse_pos_in_world.x - (size * 0.5));
		var y_center_offset = Std.int(mouse_pos_in_world.y - (size * 0.5));
		obstacles.push({
			box: Rl.Rectangle.create(
				x_center_offset,
				y_center_offset,
				size,
				size
				)
		});
	}

	function collide_player_with_bounds() {
		// check if player is outside bounds
		var size_player = player.radius * 2;
		if (0 > player.position.x - size_player) {
			player.stop_x();
			// reset player position to within the bounds
			player.position.x = size_player;
		}
		if (player.position.x > bounds.width - size_player) {
			player.stop_x();
			// reset player position to within the bounds
			player.position.x = bounds.width - size_player;
		}
		if (0 > player.position.y - size_player) {
			player.stop_y();
			// reset player position to within the bounds
			player.position.y = size_player;
		}
		if (player.position.y > bounds.height - size_player) {
			player.stop_y();
			// reset player position to within the bounds
			player.position.y = bounds.height - size_player;
		}
	}

	function collide_player_with_obstacles() {
		for (obstacle in obstacles) {
			if(Rl.checkCollisionCircleRec(player.position, player.radius, obstacle.box)){
				player.stop();
				// break because don't need to check the rest of the collisions as the player has now stopped.
				break;
			}
		}
	}
}

class Player {
	public var position:Vector2;
	var x_vel:Float = 0.0;
	var y_vel:Float = 0.0;
	var x_vel_increment:Float = 100.0;
	var y_vel_increment:Float = 100.0;

	public var radius:Int = 24;
	public var color:RlColor = Rl.Colors.DARKPURPLE;

	public function new(x:Int, y:Int) {
		position = Rl.Vector2.create(x, y);
	}

	public function update(elapsed_seconds:Float) {
		position.x = position.x + (x_vel * elapsed_seconds);
		position.y = position.y + (y_vel * elapsed_seconds);
		// trace('$elapsed_seconds $x $y');
	}

	public function draw() {
		var x = Std.int(position.x);
		var y = Std.int(position.y);
		Rl.drawCircle(x, y, radius, color);
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

@:structInit
class Obstacle {
	public var box:Rectangle;

	public function draw() {
		var x = Std.int(box.x);
		var y = Std.int(box.y);
		var width = Std.int(box.width);
		var height = Std.int(box.height);
		Rl.drawRectangle(x, y, width, height, Rl.Colors.RED);
	}
}
