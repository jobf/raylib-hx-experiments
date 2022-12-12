import Particles.Emitter;
import Rl.RlVector2;
import Physics.MotionComponent;

class Ship{
	var motion:MotionComponent;

	public function new(x:Int, y:Int) {
		motion = new MotionComponent(x, y);
		width = 18;
		width_half = width * 0.5;
		height = 20;
		particles_thruster = new Emitter(x, y + height);
	}

	public function update(elapsed_seconds:Float){
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
}