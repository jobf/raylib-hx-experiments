import Rl;

@:structInit
class ControllerActions {
	public var on_move_left:Void->Void = () -> return;
	public var on_move_right:Void->Void = () -> return;
	public var on_move_up:Void->Void = () -> return;
	public var on_move_down:Void->Void = () -> return;
	public var on_mouse_press_left:(mouse_pos_screen:Vector2) -> Void = (mouse_pos_screen) -> return;
	public var on_mouse_press_right:(mouse_pos_screen:Vector2) -> Void = (mouse_pos_screen) -> return;
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
		}

		if (Rl.isMouseButtonPressed(Rl.MouseButton.LEFT)) {
			mouse_press_left();
		}
		if (Rl.isMouseButtonPressed(Rl.MouseButton.RIGHT)) {
			mouse_press_right();
		}
	}

	function move_right() {
		trace("key RIGHT");
		actions.on_move_right();
	}

	function move_left() {
		trace("key LEFT");
		actions.on_move_left();
	}

	function move_up() {
		trace("key UP");
		actions.on_move_up();
	}

	function move_down() {
		trace("key DOWN");
		actions.on_move_down();
	}

	function mouse_press_left() {
		var position_on_screen = Rl.getMousePosition();
		trace('click LEFT screen position ${position_on_screen.x} ${position_on_screen.y}');
		actions.on_mouse_press_left(position_on_screen);
	}

	function mouse_press_right() {
		var position_on_screen = Rl.getMousePosition();
		trace('click RIGHT screen position ${position_on_screen.x} ${position_on_screen.y}');
		actions.on_mouse_press_right(position_on_screen);
	}
}
