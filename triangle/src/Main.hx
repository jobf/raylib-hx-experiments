import Rl;

class Main {
	static function main() {
		var width_window = 640;
		var height_window = 480;
		
		
		var x_center =Std.int(width_window * 0.5);
		var y_center =Std.int(height_window * 0.5);
		
		// how large the triangle is
		var scale = 30.0;

		// how much to rotate the triangle
		var rotation:Float = 0.0;

		// variable to keep track of elapsed time
		var time:Float = 0.0;

		// the triangle model to draw
		var triangle = new Triangle();
		
		// initialize raylib window
		Rl.initWindow(width_window, height_window, "triangle");
		Rl.setWindowState(Rl.ConfigFlags.VSYNC_HINT);

		// game loop
		while (!Rl.windowShouldClose()) {
			Rl.beginDrawing();
			Rl.clearBackground(Rl.Colors.BLACK);

			// record amount of time passed
			time += Rl.getFrameTime();

			// occasionally increase the rotation
			if(Std.int(time * 60) % 3 == 0){
				rotation += 0.05;
			}

			//draw the triangle
			DrawTrianglePoints(triangle.points, x_center, y_center, rotation, scale, Rl.Colors.LIME);
			Rl.endDrawing();
		}

		Rl.closeWindow();
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