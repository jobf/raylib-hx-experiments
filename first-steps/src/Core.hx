import Rl;

class Game {
	var current_scene:Scene;

	public var camera(default, null):Camera2D;

	public function new(init:Game->Scene) {
		current_scene = init(this);
		current_scene.init();
		camera = Rl.Camera2D.create(Rl.Vector2.create(0, 0), Rl.Vector2.create(0, 0));
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
}

abstract class Scene {
	var game:Game;
	public var color(default, null):Color;

	public function new(game:Game, color:cpp.Struct<Color> = null) {
		this.game = game;
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
