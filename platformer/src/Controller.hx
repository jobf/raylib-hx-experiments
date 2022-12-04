import Rl;

@:structInit
class ControllerActions {
	public var on_pressed_left:Void->Void = () -> return;
	public var on_pressed_right:Void->Void = () -> return;
	public var on_pressed_up:Void->Void = () -> return;
	public var on_pressed_down:Void->Void = () -> return;
	public var on_released_left:Void->Void = () -> return;
	public var on_released_right:Void->Void = () -> return;
	public var on_released_up:Void->Void = () -> return;
	public var on_released_down:Void->Void = () -> return;
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
				pressed_right();
			case Rl.Keys.LEFT:
				pressed_left();
			case Rl.Keys.UP:
				pressed_up();
			case Rl.Keys.DOWN:
				pressed_down();
			case _:
		}

		if (Rl.isKeyReleased(Rl.Keys.RIGHT)) {
			released_right();
		}
		if (Rl.isKeyReleased(Rl.Keys.LEFT)) {
			released_left();
		}
		if (Rl.isKeyReleased(Rl.Keys.UP)) {
			released_up();
		}
		if (Rl.isKeyReleased(Rl.Keys.DOWN)) {
			released_down();
		}

		if (Rl.isMouseButtonPressed(Rl.MouseButton.LEFT)) {
			mouse_press_left();
		}
		if (Rl.isMouseButtonPressed(Rl.MouseButton.RIGHT)) {
			mouse_press_right();
		}
	}

	function pressed_right() {
		trace("press RIGHT");
		actions.on_pressed_right();
	}

	function pressed_left() {
		trace("press LEFT");
		actions.on_pressed_left();
	}

	function pressed_up() {
		trace("press UP");
		actions.on_pressed_up();
	}

	function pressed_down() {
		trace("press DOWN");
		actions.on_pressed_down();
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

	function released_right() {
		trace("release RIGHT");
		actions.on_released_right();
	}

	function released_left() {
		trace("release LEFT");
		actions.on_released_left();
	}

	function released_up() {
		trace("release UP");
		actions.on_released_up();
	}

	function released_down() {
		trace("release DOWN");
		actions.on_released_down();
	}
}
