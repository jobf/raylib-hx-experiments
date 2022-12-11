import Physics.MotionComponent;

using Physics.MotionComponentLogic;

import Rl.Color;

class Emitter {
	var particles:Array<Particle>;
	var x:Int;
	var y:Int;
	var maximum_particles:Int;

	public function new(x:Int, y:Int, maximum_particles:Int = 3) {
		particles = [];
		this.x = x;
		this.y = y;
		this.maximum_particles = maximum_particles;
	}

	var seconds_until_next_particle:Float = 0.0;
	var seconds_between_particles:Float = 1.0;

	public function update(elapsed_seconds:Float) {
		for (p in particles) {
			p.update(elapsed_seconds);
		}
		if (seconds_until_next_particle <= 0) {
			if (particles.length < maximum_particles) {
				make_particle();
			}
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

	function make_particle() {
		// trace('new $x $y');
		final size = 5;
		final lifetime_seconds:Float = 2;
		var particle = new Particle(x, y, size, Rl.Colors.LIGHTGRAY, lifetime_seconds);

		var x_min = 5;
		var x_max = 200;
		var x_speed = (x_max * Math.random()) + x_min;
		var x_direction = Math.random() > 0.5 ? 1 : -1;
		var x_acceleration = x_speed * x_direction;
		trace('x : speed $x_speed * direction $x_direction = $x_acceleration');
		particle.set_trajectory(x_acceleration, -100.0);
		particles.push(particle);
	}
}

class Particle {
	var size:Int;
	var color:Color;
	var motion:MotionComponent;
	var lifetime_seconds:Float;
	var lifetime_seconds_remaining:Float;
	var is_expired:Bool;

	public function new(x:Int, y:Int, size:Int, color:Color, lifetime_seconds:Float) {
		this.color = color;
		this.size = size;
		this.lifetime_seconds = lifetime_seconds;
		this.lifetime_seconds_remaining = lifetime_seconds;
		is_expired = false;
		this.motion = new MotionComponent(x, y);
	}

	public function update(elapsed_seconds:Float) {
		if (!this.is_expired) {
			motion.compute_motion(elapsed_seconds);
			lifetime_seconds_remaining -= elapsed_seconds;
			if (lifetime_seconds_remaining <= 0) {
				this.is_expired = true;
			}
		}
	}

	public function draw() {
		if (!is_expired) {
			Rl.drawRectangle(Std.int(motion.position.x), Std.int(motion.position.y), Std.int(size), // width
				Std.int(size), // height
				color);
		}
	}

	public function set_trajectory(x_acceleration:Float, y_acceleration:Float) {
		motion.acceleration.x = x_acceleration;
		motion.acceleration.y = y_acceleration;
	}
}
