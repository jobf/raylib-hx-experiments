import Physics.MotionComponent;

using Physics.MotionComponentLogic;

import Rl.Color;

class Emitter {
	var particles:Array<Particle>;
	var x:Int;
	var y:Int;

	public function new(x:Int, y:Int) {
		particles = [];
		this.x = x;
		this.y = y;
	}

	var seconds_until_next_particle:Float = 0.0;
	var seconds_between_particles:Float = 1.0;

	public function update(elapsed_seconds:Float) {
		for (p in particles) {
			p.update(elapsed_seconds);
			
		}
		if (seconds_until_next_particle <= 0) {
			make_particle();
			seconds_until_next_particle = seconds_between_particles;
		} else {
			seconds_until_next_particle = seconds_until_next_particle - elapsed_seconds;
		}
	}

	public function draw() {
		for (p in particles) {
			p.draw();
		}
	}

	function make_particle(){
		trace('new $x $y');
		final size = 5;
		var particle = new Particle(x, y, 5, Rl.Colors.LIGHTGRAY);
		particle.set_trajectory(0.0, -100.0);
		particles.push(particle);
	}
}

class Particle {
	var size:Int;
	var color:Color;
	var motion:MotionComponent;

	public function new(x:Int, y:Int, size:Int, color:Color) {
		this.color = color;
		this.size = size;
		this.motion = new MotionComponent(x, y);
	}

	public function update(elapsed_seconds:Float) {
		motion.compute_motion(elapsed_seconds);
		// trace('update particle');ah 
	}

	public function draw() {
		Rl.drawRectangle(
			Std.int(motion.position.x), 
			Std.int(motion.position.y), 
			Std.int(size), // width
			Std.int(size), // height
			color);
	}

	public function set_trajectory(x_acceleration:Float, y_acceleration:Float){
		motion.acceleration.x = x_acceleration;
		motion.acceleration.y = y_acceleration;
	}
}
