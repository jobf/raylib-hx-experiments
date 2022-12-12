import Physics.MotionComponent;

using Physics.MotionComponentLogic;

import Rl.Color;

class Emitter {
	/** starting x position of particles **/
	var x:Int;
	
	/** starting y position of particles **/
	var y:Int;

	/** pool of particles for recycling **/
	var particles:Array<Particle>;

	/** size of particle pool **/
	var maximum_particles:Int = 300;
	
	/** amount of time between particle emissions emission **/
	public var seconds_between_particles:Float = 0;
	var seconds_until_next_particle:Float = 0;

	/** lowest x speed used when determining random x acceleration **/
	public var x_speed_minimum:Float = 0;

	/** highest x speed used when determining random y acceleration **/
	public var x_speed_maximum:Float = 400;

	/** lowest y speed used when determining random y acceleration **/
	public var y_speed_minimum:Float = 200;

	/** highest y speed used when determining random y acceleration **/
	public var y_speed_maximum:Float = 1000;

	/** width and height of particles **/
	public var particle_size:Float = 15;

	/** how many seconds the particle will ascend before descending again **/
	public var particle_ascend_seconds:Float = 0.75;

	/** how many seconds the particle will be active before it can be recycled **/
	public var particle_life_seconds:Float = 5;

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
			} else {
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
		var color = Rl.Colors.LIGHTGRAY;
		color.a = 80;
		var particle = new Particle(x, y, Std.int(particle_size), color, particle_life_seconds, particle_ascend_seconds);
		set_random_trajectory(particle);
		particles.push(particle);
	}

	function recycle_particle() {
		for (p in particles) {
			if (p.is_expired) {
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
		// emitter is on 'floor' so always want the particles to ascend initially
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
	var acceleration_seconds:Float;
	var acceleration_seconds_remaining:Float;
	var is_ascending:Bool;

	public var is_expired(default, null):Bool;

	public function new(x:Int, y:Int, size:Int, color:Color, lifetime_seconds:Float, acceleration_seconds:Float) {
		this.color = color;
		this.size = size;
		this.lifetime_seconds = lifetime_seconds;
		this.lifetime_seconds_remaining = lifetime_seconds;
		this.acceleration_seconds = acceleration_seconds;
		this.acceleration_seconds_remaining = acceleration_seconds;
		is_expired = false;
		this.motion = new MotionComponent(x, y);
		is_ascending = true;
	}

	public function update(elapsed_seconds:Float) {
		if (!is_expired) {
			// only run this logic if the particle is not expired

			// calculate new position
			motion.compute_motion(elapsed_seconds);

			// enough time has passed, stop accelerating away from the ground
			acceleration_seconds_remaining -= elapsed_seconds;
			if (is_ascending && acceleration_seconds_remaining <= 0) {
				// set acceleration towards the floor
				motion.acceleration.y = motion.acceleration.y * -1;
				// change ascending state so this branch is not run again
				is_ascending = false;
			}

			// enough enough time has passed, expire the particle so it can be recycled
			lifetime_seconds_remaining -= elapsed_seconds;
			if (lifetime_seconds_remaining <= 0) {
				// change expired state so update logic is no longer run
				is_expired = true;
			}
		}
	}

	public function draw() {
		if (!is_expired) {
			// only draw if particle is not expired
			Rl.drawRectangle(
				Std.int(motion.position.x),
				Std.int(motion.position.y),
				Std.int(size), // width
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

		// reset ascension limiter
		is_ascending = true;
		acceleration_seconds_remaining = acceleration_seconds;

		// reset motion
		motion.acceleration.x = 0;
		motion.acceleration.y = 0;
		motion.velocity.x = 0;
		motion.velocity.y = 0;
		motion.deceleration.y = 0;

		// set new position
		motion.position.x = Std.int(x);
		motion.position.y = Std.int(y);

		// set new size
		this.size = size;
	}
}
