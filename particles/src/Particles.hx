import Physics.MotionComponent;

using Physics.MotionComponentLogic;

import Rl.Color;

class Emitter {
	var particles:Array<Particle>;
	var x:Int;
	var y:Int;
	var maximum_particles:Int = 300;
	var seconds_until_next_particle:Float = 0;
	public var seconds_between_particles:Float = 0;
	public var x_speed_minimum:Float = 0;
	public var x_speed_maximum:Float = 400;
	public var y_speed_minimum:Float = 200;
	public var y_speed_maximum:Float = 1000;
	public var particle_size:Float = 15;

	public function new(x:Int, y:Int) {
		particles = [];
		this.x = x;
		this.y = y;
	}


	public function update(elapsed_seconds:Float) {
		for (p in particles) {
			p.update(elapsed_seconds);
		}
		if (seconds_until_next_particle <= 0) {
			if (particles.length < maximum_particles) {
				make_particle();
			}
			else{
				recycle_particle();
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
		final lifetime_seconds:Float = 5;
		var color = Rl.Colors.LIGHTGRAY;
		color.a = 80;
		var particle = new Particle(x, y, Std.int(particle_size), color, lifetime_seconds);
		set_random_trajectory(particle);
		particles.push(particle);
	}

	function recycle_particle() {
		for(p in particles){
			if(p.is_expired){
				p.reset_to(x, y, Std.int(particle_size));
				set_random_trajectory(p);
				// break out of the loop because only recycle one particle
				break;
			}
		}
	}

	function set_random_trajectory(particle:Particle) {
		// set a random x speed
		var x_speed = (x_speed_maximum * Math.random()) + x_speed_minimum;
		
		// choose left or right at random
		var x_direction = Math.random() > 0.5 ? 1 : -1;
		var x_acceleration = x_speed * x_direction;

		// set a random y speed
		var y_speed = (y_speed_maximum * Math.random()) + y_speed_minimum;
		// emitter is on 'floor' so always want the particles to ascend
		var y_direction = -1;
		var y_acceleration = y_speed * y_direction;

		particle.set_trajectory(x_acceleration, y_acceleration);
	}
}

class Particle {
	var size:Int;
	var color:Color;
	var motion:MotionComponent;
	var lifetime_seconds:Float;
	var lifetime_seconds_remaining:Float;
	public var is_expired(default, null):Bool;

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

	public function reset_to(x:Int, y:Int, size:Int) {
		// reset life time
		is_expired = false;
		lifetime_seconds_remaining = lifetime_seconds;

		// reset motion
		motion.acceleration.x = 0;
		motion.acceleration.y = 0;
		motion.velocity.x = 0;
		motion.velocity.y = 0;

		// set new position
		motion.position.x = Std.int(x);
		motion.position.y = Std.int(y);

		// set new size
		this.size = size;
	}
}
