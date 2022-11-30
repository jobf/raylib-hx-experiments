import Rl;
import Core;

class Main {
	static var game:Game;

	static function main() {
		var windowBounds:RectangleGeometry = {
			width: 640,
			height: 480
		}

		Rl.initWindow(windowBounds.width, windowBounds.height, "platfoms");
		Rl.setTargetFPS(60);

		var sceneBounds:RectangleGeometry = {
			width: windowBounds.width,
			height: Std.int(windowBounds.height * 1.14)
		}

		var scene_constructor = game -> return new PlatformerScene(game, sceneBounds, Rl.Colors.DARKBLUE);

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

class PlatformerScene extends Scene {
	var floor:Platform;
	var platforms:Array<Platform> = [];
	var player:Player;
	var controller:Controller;

	public function init() {
		var thickness_platform = 20;
		var height_floor = thickness_platform * 3;
		var y_floor = bounds.height - height_floor;

		floor = {
			rectangle: Rl.Rectangle.create(0, y_floor, bounds.width, height_floor),
			color: Rl.Colors.GREEN
		}

		platforms.push(floor);

		var center_scene = Std.int(bounds.width * 0.5);
		player = new Player(center_scene, 0);

		controller = new Controller({
			// on_move_up: on_move_up,
			on_move_right: () -> player.move(1, 0),
			on_move_left: () -> player.move(-1, 0),
			// on_move_down: on_move_down,
			// on_mouse_press_right: on_mouse_press_right,
			// on_mouse_press_left: on_mouse_press_left
		});
	}

	public function update(elapsed_seconds:Float) {
		controller.update();

		player.update(elapsed_seconds);

		// check collisions if player is moving
		if (player.hasNonZeroVelocity()) {
			collide_player_with_bounds();
			collide_player_with_platforms();
		}

		var x_player = Std.int(player.position.x);
		var y_player = Std.int(player.position.y);
		game.update_cameraCenterInsideBounds(x_player, y_player, bounds.width, bounds.height);
	}

	function collide_player_with_bounds() {
		// check if player is outside bounds
		if (0 > player.position.x) {
			player.stop_x();
			// reset player position to within the bounds
			player.set_x(0);
		}
		if (player.position.x > bounds.width - player.rectangle.width) {
			player.stop_x();
			// reset player position to within the bounds
			player.set_x(bounds.width - player.rectangle.width);
		}
		if (0 > player.position.y) {
			player.stop_y();
			// reset player position to within the bounds
			player.set_y(0);
		}
		if (player.position.y > bounds.height) {
			player.stop_y();
			// reset player position to within the bounds
			player.set_y(bounds.height - player.rectangle.height);
		}
	}

	function collide_player_with_platforms() {
		for (platform in platforms) {
			if (Rl.checkCollisionRecs(player.rectangle, platform.rectangle)) {
				// collision happened so stop the player
				player.stop();

				var collided = platform == floor ? "floor" : "platform";
				trace('player collision with $collided');

				// the player may be overlapping the platform when it stops because of the way movement is handled
				// so need to separate the player from the collided platform

				// find out how much player overlaps
				var overlap = Rl.getCollisionRec(player.rectangle, platform.rectangle);
				// trace('collision overlap x ${overlap.x} y ${overlap.y} w ${overlap.width} h ${overlap.height}');

				// adjust player position by overlap amount
				if (player.wasMovingRight()) {
					player.position.x = player.position.x - Std.int(overlap.width);
				}
				if (player.wasMovingLeft()) {
					player.position.x = player.position.x + Std.int(overlap.width);
				}
				if (player.wasMovingDown()) {
					player.position.y = player.position.y - Std.int(overlap.height);
				}
				if (player.wasMovingUp()) {
					player.position.y = player.position.y + Std.int(overlap.height);
				}

				// break because don't need to check the rest of the collisions as the player has now stopped.
				break;
			}
		}
	}

	public function draw() {
		for (platform in platforms) {
			platform.draw();
		}
		player.draw();
	}
}

@:structInit
class Platform {
	public var rectangle:Rectangle;
	public var color:Color;

	public function draw() {
		var x = Std.int(rectangle.x);
		var y = Std.int(rectangle.y);
		var width = Std.int(rectangle.width);
		var height = Std.int(rectangle.height);
		Rl.drawRectangle(x, y, width, height, color);
	}
}

class Player {
	public var position(default, null):Vector2;
	public var position_previous(default, null):Vector2;

	var x_vel:Float = 0.0;
	var y_vel:Float = 50.0;
	var x_vel_increment:Float = 100.0;
	var y_vel_increment:Float = 100.0;

	public var rectangle:Rl.Rectangle;
	public var color:RlColor = Rl.Colors.ORANGE;

	public function new(x:Int, y:Int) {
		position = Rl.Vector2.create(x, y);
		position_previous = Rl.Vector2.create(x, y);
		var width = 22;
		var height = 48;
		rectangle = Rl.Rectangle.create(position.x, position.y, width, height);
	}

	public function update(elapsed_seconds:Float) {
		position_previous.x = position.x;
		position_previous.y = position.y;
		position.x = position.x + (x_vel * elapsed_seconds);
		position.y = position.y + (y_vel * elapsed_seconds);
		rectangle.x = position.x;
		rectangle.y = position.y;
		// trace('$elapsed_seconds $x $y');
	}

	public function draw() {
		var x = Std.int(rectangle.x);
		var y = Std.int(rectangle.y);
		var width = Std.int(rectangle.width);
		var height = Std.int(rectangle.height);
		Rl.drawRectangle(x, y, width, height, color);
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

	public function hasNonZeroVelocity():Bool {
		return x_vel != 0 || y_vel != 0;
	}

	public function wasMovingRight() {
		return position_previous.x < position.x;
	}

	public function wasMovingLeft() {
		return position_previous.x > position.x;
	}

	public function wasMovingDown() {
		return position_previous.y < position.y;
	}

	public function wasMovingUp() {
		return position_previous.y > position.y;
	}

	public function set_x(x:Float) {
		position.x = x;
		rectangle.x = x;
	}

	public function set_y(y:Float) {
		position.y = y;
		rectangle.y = y;
	}
}
