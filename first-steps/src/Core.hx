import Rl;

class Game {
	var current_scene:Scene;
	var windowBounds:RectangleGeometry;
	var assets:Assets;

	public var camera(default, null):Camera2D;

	public function new(init:Game->Scene, windowBounds:RectangleGeometry, assets:Assets = null) {
		this.assets = assets == null ? new Assets([]) : assets;
		this.windowBounds = windowBounds;
		
		camera = Rl.Camera2D.create(Rl.Vector2.create(0, 0), Rl.Vector2.create(0, 0));

		current_scene = init(this);
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

	public function getTexture(key:Int):Null<Texture> {
		if (assets.textures.exists(key)) {
			return assets.textures[key];
		}

		trace('no asset found for key $key');
		return null;
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

	public function new(game:Game, bounds:RectangleGeometry, color:cpp.Struct<Color> = null) {
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

class Assets {
	public var textures(default, null):Map<Int, Texture>;

	public function new(texture_paths:Map<Int, String>) {
		textures = [
			for (_ in texture_paths.keyValueIterator()) {
				// if we don't use the interim "var texture:Texture" then cpp conversion shits the bed
				var texture:Texture = Rl.loadTexture(_.value);
				_.key => texture;
			}
		];
	}
}
