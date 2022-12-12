import Core.Scene;

class PlayScene extends Scene{
	

	public function init() {
		ship = new Ship(30, 30);
	}

	public function update(elapsed_seconds:Float) {
		ship.update(elapsed_seconds);
	}

	public function draw() {
		ship.draw();
	}

	var ship:Ship;
}