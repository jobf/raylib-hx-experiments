
class Game {
	var current_scene:Scene;

	public function new(init:Game->Scene) {
		current_scene = init(this);
		current_scene.init();
	}

	public function update(elapsed_seconds:Float) {
		current_scene.update(elapsed_seconds);
	}

	public function draw() {
		current_scene.draw();
	}
}

abstract class Scene {
	var game:Game;

	public function new(game:Game) {
		this.game = game;
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