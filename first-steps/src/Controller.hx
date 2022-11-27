import Rl;

@:structInit
class ControllerActions {
	public var on_move_left:Void->Void = () -> return;
	public var on_move_right:Void->Void = () -> return;
	public var on_move_up:Void->Void = () -> return;
	public var on_move_down:Void->Void = () -> return;
}

class Controller {
	var actions:ControllerActions;

	public function new(actions:ControllerActions) {
		this.actions = actions;
	}

	public function update() {
		switch Rl.getKeyPressed() {
			case Rl.Keys.RIGHT:
				move_right();
			case Rl.Keys.LEFT:
				move_left();
			case Rl.Keys.UP:
				move_up();
			case Rl.Keys.DOWN:
				move_down();
			case _:
				return;
		}
	}

	function move_right() {
		trace("right");
		actions.on_move_right();
	}

	function move_left() {
		trace("left");
		actions.on_move_left();
	}

	function move_up() {
		trace("up");
		actions.on_move_up();
	}

	function move_down() {
		trace("down");
		actions.on_move_down();
	}
}
