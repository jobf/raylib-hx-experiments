import Rl;
import Particles.Emitter;
import Physics.MotionComponent;
using Physics.MotionComponentLogic;

class Ship{
	var motion:MotionComponent;
	var triangle:Triangle;
	var gravity:Float = 10;
	var rotation:Float = 0;
	var thruster_position:Point;
	var scale = 6;

	public function new(x:Int, y:Int) {
		motion = new MotionComponent(x, y);
		triangle = new Triangle();
		thruster_position = {x:  0.0, y: 3.0 };
		// give ship some gravity
		motion.acceleration.y = gravity;
		width = 18;
		width_half = width * 0.5;
		height = 20;
		particles_thruster = new Emitter(x, y + height);
	}

	public function update(elapsed_seconds:Float){
		motion.compute_motion(elapsed_seconds);
		var rotation_sin = Math.sin(rotation);
		var rotation_cos = Math.cos(rotation);
		
		// rotate
		var thruster_position_translated:Point = {
			x: thruster_position.x * rotation_cos - thruster_position.y * rotation_sin,
			y: thruster_position.x * rotation_sin + thruster_position.y * rotation_cos
		};

		// scale
		thruster_position_translated.x = thruster_position_translated.x * scale;
		thruster_position_translated.y = thruster_position_translated.y * scale;

		// transform
		thruster_position_translated.x = thruster_position_translated.x + motion.position.x;
		thruster_position_translated.y = thruster_position_translated.y + motion.position.y;
		
		var x_particles = Std.int(thruster_position_translated.x);
		var y_particles = Std.int(thruster_position_translated.y);
		
		particles_thruster.set_position(x_particles, y_particles);
		particles_thruster.update(elapsed_seconds);
		rotation = rotation + (0.05 * rotation_direction);
	}

	public function draw() {
		particles_thruster.draw();
		DrawTrianglePoints(triangle.points, motion.position.x, motion.position.y, rotation, scale, Rl.Colors.GRAY);
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
	var rotation_direction:Int = 0;
	public function set_rotation_direction(direction:Int) {
		rotation_direction = direction;
	}
}

@:structInit
class Point{
	public var x:Float;
	public var y:Float;
}

/** isosceles triangle model **/
class Triangle {
	public var a_point:Point;
	public var b_point:Point;
	public var c_point:Point;
	public var points:Array<Point>;

	public function new() {
		a_point = {x:  0.0, y: -6.0};
		b_point = {x: -3.0, y:  3.0};
		c_point = {x:  3.0, y:  3.0};
		points = [a_point, b_point, c_point];
	}
}


function DrawTrianglePoints(points:Array<Point>, x_center:Float, y_center:Float, rotation:Float, scale:Float, color:Color){
	var rotation_sin = Math.sin(rotation);
	var rotation_cos = Math.cos(rotation);

	// first apply rotation to the model points
	var points_transformed:Array<Point> = [for(i in 0...points.length) {
		x: points[i].x * rotation_cos - points[i].y * rotation_sin,
		y: points[i].x * rotation_sin + points[i].y * rotation_cos
	}];

	// now scale the transformed points (change size)
	for(i in 0...points.length){
		points_transformed[i].x = points_transformed[i].x * scale;
		points_transformed[i].y = points_transformed[i].y * scale;
	}

	// now translate the transofrmed point positions
	for(i in 0...points.length){
		points_transformed[i].x = points_transformed[i].x + x_center;
		points_transformed[i].y = points_transformed[i].y + y_center;
	}

	// convert points to rl vectors and draw
	var a = Rl.RlVector2.create(points_transformed[0].x, points_transformed[0].y);
	var b = Rl.RlVector2.create(points_transformed[1].x, points_transformed[1].y);
	var c = Rl.RlVector2.create(points_transformed[2].x, points_transformed[2].y);
	Rl.drawTriangle(a, b, c, color);
}