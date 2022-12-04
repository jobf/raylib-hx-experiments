import Physics.MotionComponent;
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

		Rl.initWindow(windowBounds.width, windowBounds.height, "platfoms");
		// Rl.setTargetFPS(60);
		// as far as I can see, VSYNC_HINT is a bit smoother
		Rl.setWindowState(Rl.ConfigFlags.VSYNC_HINT);

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
			on_pressed_up: () -> player.jump(),
			on_pressed_right: () -> player.accelerate_x(1),
			on_pressed_left: () -> player.accelerate_x(-1),
			on_released_right: () -> player.apply_brakes_x(),
			on_released_left: () -> player.apply_brakes_x(),
			// on_pressed_down: on_pressed_down,
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

		var x_player = Std.int(player.rectangle.x);
		var y_player = Std.int(player.rectangle.y);
		game.update_cameraCenterInsideBounds(x_player, y_player, bounds.width, bounds.height);
	}

	function collide_player_with_bounds() {
		// check if player is outside bounds
		if (0 > player.rectangle.x) {
			player.stop_x();
			// reset player position to within the bounds
			player.set_x(0);
		}
		if (player.rectangle.x > bounds.width - player.rectangle.width) {
			player.stop_x();
			// reset player position to within the bounds
			player.set_x(bounds.width - player.rectangle.width);
		}
		if (0 > player.rectangle.y) {
			player.stop_y();
			// reset player position to within the bounds
			player.set_y(0);
		}
		if (player.rectangle.y > bounds.height) {
			player.stop_y();
			// reset player position to within the bounds
			player.set_y(bounds.height - player.rectangle.height);
		}
	}

	function collide_player_with_platforms() {
		for (platform in platforms) {
			if (Rl.checkCollisionRecs(player.rectangle, platform.rectangle)) {
				var is_collided_with_floor = platform == floor;

				// trace('player collision with ${is_collided_with_floor ? "floor" : "platform"}');

				if (player.wasMovingRight() && !is_collided_with_floor) {
					var is_collision_on_right = platform.rectangle.x > player.rectangle.x;
					if (is_collision_on_right) {
						player.stop_x();
						// find out how much player overlaps
						var overlap = Rl.getCollisionRec(player.rectangle, platform.rectangle);
						// adjust player position by overlap amount
						player.rectangle.x = player.rectangle.x - Std.int(overlap.width);
					}
				}
				if (player.wasMovingLeft() && !is_collided_with_floor) {
					var is_collision_on_left = platform.rectangle.x < player.rectangle.x;
					if (is_collision_on_left) {
						player.stop_x();
						// find out how much player overlaps
						var overlap = Rl.getCollisionRec(player.rectangle, platform.rectangle);
						// adjust player position by overlap amount
						player.rectangle.x = player.rectangle.x + Std.int(overlap.width);
					}
				}
				if (player.wasMovingDown()) {
					var is_collision_on_down = platform.rectangle.y > player.rectangle.y;
					if (is_collision_on_down) {
						player.stop_y();
						// find out how much player overlaps
						var overlap = Rl.getCollisionRec(player.rectangle, platform.rectangle);
						// adjust player position by overlap amount
						player.rectangle.y = player.rectangle.y - Std.int(overlap.height);
						player.set_touching_ground(true);
					}
				}
				if (player.wasMovingUp()) {
					var is_collision_on_up = platform.rectangle.y < player.rectangle.y;
					if (is_collision_on_up) {
						player.stop_y();
						// find out how much player overlaps
						var overlap = Rl.getCollisionRec(player.rectangle, platform.rectangle);
						// adjust player position by overlap amount
						player.rectangle.y = player.rectangle.y + Std.int(overlap.height);
					}
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
	public var rectangle:Rl.Rectangle;
	public var color:RlColor = Rl.Colors.ORANGE;

	var motion:MotionComponent;
	
	/** the maximum speed on x axis **/
	var x_velocity_max:Float = 250;

	/** the maximum speed on y axis **/
	var y_velocity_max:Float = 400;

	/** how fast to accelerate left or right **/
	var x_acceleration:Float = 500;

	/** how fast to slow down when not accelerating left or right **/
	var x_deceleration:Float = 900;

	/** how fast to accelerate towards the ground **/
	var y_acceleration:Float = 500;
	
	public var is_touching_ground(default, null):Bool = false;
	var jump_is_in_progress:Bool = false;

	/** how long before jump timer should reset **/
	var jump_duration_seconds:Float = 0.34;
	var jump_timer_seconds:Float = 0.0;

	/** how much acceleration to apply on y axis when jumping aka jump power **/
	var jump_acceleration:Float = 900.0;

	public function new(x:Int, y:Int) {
		motion = new MotionComponent(x, y);
		motion.acceleration_increase.y = y_acceleration;
		motion.acceleration_decrease.x = x_deceleration;
		motion.velocity_maximum.x = x_velocity_max;
		var width = 22;
		var height = 48;
		rectangle = Rl.Rectangle.create(motion.position_now.x, motion.position_now.y, width, height);
	}

	public function update(elapsed_seconds:Float) {
		if (is_touching_ground) {
			motion.acceleration_increase.y = 0;
		} else {
			if (jump_is_in_progress && jump_timer_seconds > 0) {
				jump_timer_seconds -= elapsed_seconds;
			}
			else{
				motion.acceleration_increase.y = y_acceleration;
			}
		}

		motion.compute_motion(elapsed_seconds);
		rectangle.x = motion.position_now.x;
		rectangle.y = motion.position_now.y;
	}

	public function draw() {
		var x = Std.int(rectangle.x);
		var y = Std.int(rectangle.y);
		var width = Std.int(rectangle.width);
		var height = Std.int(rectangle.height);
		Rl.drawRectangle(x, y, width, height, color);
	}

	public function accelerate_x(x_direction:Int) {
		motion.acceleration_increase.x = x_direction * x_acceleration;
		trace('new x acceleration ${motion.acceleration_increase.x}');
	}

	public function apply_brakes_x(){
		motion.acceleration_increase.x = 0;
	}

	public function stop() {
		motion.acceleration_increase.x = 0;
		motion.acceleration_increase.y = 0;
		motion.velocity_now.x = 0;
		motion.velocity_now.y = 0;
		trace('player stop x y');
	}
	
	public function stop_x() {
		motion.acceleration_increase.x = 0;
		motion.velocity_now.x = 0;
		trace('player stop x');
	}
	
	public function stop_y() {
		motion.acceleration_increase.y = 0;
		motion.velocity_now.y = 0;
		trace('player stop y');
	}

	public function hasNonZeroVelocity():Bool {
		return motion.velocity_now.x != 0 || motion.velocity_now.y != 0;
	}

	public function wasMovingRight() {
		return motion.position_previous.x < motion.position_now.x;
	}

	public function wasMovingLeft() {
		return motion.position_previous.x > motion.position_now.x;
	}

	public function wasMovingDown() {
		return motion.position_previous.y < motion.position_now.y;
	}

	public function wasMovingUp() {
		return motion.position_previous.y > motion.position_now.y;
	}

	public function set_x(x:Float) {
		motion.position_now.x = x;
		rectangle.x = x;
	}

	public function set_y(y:Float) {
		motion.position_now.y = y;
		rectangle.y = y;
	}

	public function set_touching_ground(isTouching:Bool) {
		is_touching_ground = isTouching;
		trace('player is grounded ? $is_touching_ground');
	}

	public function jump() {
		if (is_touching_ground) {
			motion.acceleration_increase.y = -jump_acceleration;
			jump_is_in_progress = true;
			jump_timer_seconds = jump_duration_seconds;
			set_touching_ground(false);
		}
	}
}
