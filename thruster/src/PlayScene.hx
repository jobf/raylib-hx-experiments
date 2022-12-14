import Core.Scene;
import Controller;

class PlayScene extends Scene {
	public function init() {
		ship = new Ship(30, 30);
		controller = new Controller({
			// on_released_up: on_released_up,
			on_released_right: () -> ship.set_rotation_direction(0),
			on_released_left: () -> ship.set_rotation_direction(0),
			// on_released_down: on_released_down,
			on_released_accelerate: () -> ship.set_acceleration(false),
			// on_pressed_up: on_pressed_up,
			on_pressed_right: () -> ship.set_rotation_direction(1),
			on_pressed_left: () -> ship.set_rotation_direction(-1),
			// on_pressed_down: on_pressed_down,
			on_pressed_accelerate: () -> ship.set_acceleration(true),
			// on_mouse_press_right: on_mouse_press_right,
			// on_mouse_press_left: on_mouse_press_left
		});
	}

	public function update(elapsed_seconds:Float) {
		controller.update();
		ship.update(elapsed_seconds);
	}

	public function draw() {
		ship.draw();
	}

	var ship:Ship;

	var controller:Controller;
}
