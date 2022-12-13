import Particles.Emitter;
import Rl.RlVector2;
import Physics.MotionComponent;
using Physics.MotionComponentLogic;

class Ship{
	var motion:MotionComponent;
	var gravity:Float = 10;
	public function new(x:Int, y:Int) {
		motion = new MotionComponent(x, y);
		// give ship some gravity
		motion.acceleration.y = gravity;
		width = 18;
		width_half = width * 0.5;
		height = 20;
		particles_thruster = new Emitter(x, y + height);
	}

	public function update(elapsed_seconds:Float){
		motion.compute_motion(elapsed_seconds);
		var x_particles = Std.int(motion.position.x);
		var y_particles = Std.int(motion.position.y + height);
		particles_thruster.set_position(x_particles, y_particles);
		particles_thruster.update(elapsed_seconds);
	}

	public function draw() {
		particles_thruster.draw();

		var top = RlVector2.create(motion.position.x, motion.position.y);
		var left = RlVector2.create(motion.position.x - width_half, motion.position.y + height);
		var right = RlVector2.create(motion.position.x + width_half, motion.position.y + height);
		
		Rl.drawTriangle(
			top,
			left,
			right,
			Rl.Colors.GRAY
		);
	}


	var width:Int;

	var height:Int;

	var width_half:Float;

	var particles_thruster:Emitter;

	public function set_acceleration(should_enable:Bool):Void {
		if(should_enable){
			particles_thruster.is_emitting = true;
			// give ship some thrust
			motion.acceleration.y = -(gravity * 3);

		}
		else{
			particles_thruster.is_emitting = false;
			// give ship some gravity
			motion.acceleration.y = gravity;
		}
	}
}