import Rl;

class Game {
	var current_scene:Scene;
	var windowBounds:RectangleGeometry;
	var x_viewport_center:Int;
	var y_viewport_center:Int;


	public var camera(default, null):Camera2D;

	public function new(scene_constructor:Game->Scene, windowBounds:RectangleGeometry) {
		this.windowBounds = windowBounds;
		x_viewport_center = Std.int(windowBounds.width * 0.5);
		y_viewport_center = Std.int(windowBounds.height * 0.5);

		camera = Rl.Camera2D.create(Rl.Vector2.create(0, 0), Rl.Vector2.create(0, 0));

		current_scene = scene_constructor(this);
		current_scene.init();
	}

	public function update(elapsed_seconds:Float) {
		current_scene.update(elapsed_seconds);
	}

	public function draw() {
		Rl.clearBackground(current_scene.color);
		Rl.beginMode2D(camera);
		current_scene.draw();
		Rl.endMode2D();
	}

	/**
		Center camera on target
	**/
	public function update_cameraCenter(x_target:Float, y_target:Float) {
		camera.offset.x = windowBounds.width * 0.5;
		camera.offset.y = windowBounds.height * 0.5;
		camera.target.x = x_target;
		camera.target.y = y_target;
	}

	/**
		Center camera on target
		Do not let camera scroll outside bounds
	**/
	public function update_cameraCenterInsideBounds(x_target:Float, y_target:Float, x_boundary:Int, y_boundary:Int) {
		// first center camera on target
		update_cameraCenter(x_target, y_target);

		// now if the target is close to an edge
		// the camera offset will need adjusting away from 'center'

		// half a screen away from left
		var x_scroll_min = x_viewport_center;

		// half a screen away from top
		var y_scroll_min = y_viewport_center;

		// half a screen away from right
		var x_scroll_max = x_boundary - x_viewport_center;

		// half a screen away from bottom
		var y_scroll_max = y_boundary - y_viewport_center;

		// if target is closer than half a screen to the left
		if (x_target < x_scroll_min) {
			// set camera offset to distance between target and edge
			camera.offset.x = x_target;
		}

		// if target is closer than half a screen to the top
		if (y_target < y_scroll_min) {
			// set camera offset to distance between target and edge
			camera.offset.y = y_target;
		}

		// if target is closer than half a screen to the right
		if (x_target > x_scroll_max) {
			// calculate distance offset between target and edge
			var offset_distance = x_target - x_scroll_max;
			// adjust camera offset
			camera.offset.x = camera.offset.x + offset_distance;
		}

		// if target is closer than half a screen to the bottom
		if (y_target > y_scroll_max) {
			// calculate distance offset between target and edge
			var offset_distance = camera.target.y - y_scroll_max;
			// adjust camera offset
			camera.offset.y = camera.offset.y + offset_distance;
		}
	}
}

@:structInit
class RectangleGeometry {
	public var x:Int = 0;
	public var y:Int = 0;
	public var width:Int;
	public var height:Int;
}

abstract class Scene {
	var game:Game;
	var bounds:RectangleGeometry;

	public var color(default, null):Color;

	public function new(game:Game, bounds:RectangleGeometry, color:Color = null) {
		this.game = game;
		this.bounds = bounds;
		this.color = color == null ? Rl.Colors.BLACK : color;
	}

	/**
		Handle scene initiliasation here, e.g. set up level, player, etc.
	**/
	abstract public function init():Void;

	/**
		Handle game logic here, e,g, calculating movement for player, change object states, etc.
		@param elapsed_seconds is the amount of seconds that have passed since the last frame
	**/
	abstract public function update(elapsed_seconds:Float):Void;

	/**
		Make draw calls here
	**/
	abstract public function draw():Void;
}
