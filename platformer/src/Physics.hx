import Rl;

class MotionComponent {
	public function new(x:Int, y:Int) {
		position_now = RlVector2.create(x, y);
		position_previous = RlVector2.create(x, y);

		velocity_now = RlVector2.create(0,0);
		velocity_maximum = RlVector2.create(0,0);

		acceleration_increase = RlVector2.create(0,0);
		acceleration_decrease = RlVector2.create(0,0);
	}

	public var position_now:Vector2;
	public var position_previous:Vector2;

	public var velocity_now:Vector2;
	public var velocity_maximum:Vector2;

	public var acceleration_increase:Vector2;
	public var acceleration_decrease:Vector2;
}

class MotionComponentLogic {
	public static function compute_motion(_:MotionComponent, elapsed_seconds:Float) {
		// x
		var vel_delta = 0.5 * (compute_axis(
			_.velocity_now.x,
			_.acceleration_increase.x,
			_.acceleration_decrease.x,
			_.velocity_maximum.x,
			elapsed_seconds
		) - _.velocity_now.x);
		_.velocity_now.x = _.velocity_now.x + vel_delta;
		var delta = _.velocity_now.x * elapsed_seconds;
		_.position_previous.x = _.position_now.x;
		_.position_now.x = _.position_now.x + delta;

		// y
		var vel_delta = 0.5 * (compute_axis(
			_.velocity_now.y,
			_.acceleration_increase.y,
			_.acceleration_decrease.y,
			_.velocity_maximum.y,
			elapsed_seconds
		) - _.velocity_now.y);
		_.velocity_now.y = _.velocity_now.y + vel_delta;
		var delta = _.velocity_now.y * elapsed_seconds;
		_.position_previous.y = _.position_now.y;
		_.position_now.y = _.position_now.y + delta;
	}

	static function compute_axis(velocity:Float, acc_inc:Float, acc_dec:Float, vel_max:Float, elapsed_seconds:Float):Float {
		if (acc_inc != 0) {
			velocity += acc_inc * elapsed_seconds;
		} else if (acc_dec != 0) {
			var drag:Float = acc_dec * elapsed_seconds;
			if (velocity - drag > 0) {
				velocity -= drag;
			} else if (velocity + drag < 0) {
				velocity += drag;
			} else {
				velocity = 0;
			}
		}
		if ((velocity != 0) && (vel_max != 0)) {
			if (velocity > vel_max) {
				velocity = vel_max;
			} else if (velocity < -vel_max) {
				velocity = -vel_max;
			}
		}
		return velocity;
	}
}
