import Core.RectangleGeometry;
import Rl;
import Raygui;

class Editor {
	var geometry:RectangleGeometry;
	var width_bg:Int;
	var sliders:Array<Slider>;

	public function new(geometry_element:RectangleGeometry, width_bg:Int) {
		this.geometry = geometry_element;
		this.width_bg = width_bg;
		this.sliders = [];
	}

	public function add_slider(name:String, value:Float, min:Float, max:Float, on_set_value:(value:Float) -> Void) {
		var slider:Slider = {
			value: value,
			value_min: min,
			value_max: max,
			label: name,
			label_aligned_right: true,
			on_set_value: on_set_value,
			bounds: Rl.Rectangle.create(
				geometry.x,
				geometry.y + (geometry.height * sliders.length),
				geometry.width,
				geometry.height),
			};
			trace(sliders.length);
		sliders.push(slider);
	}

	public function update() {
		
		Rl.drawRectangle(
			geometry.x,
			geometry.y,
			width_bg,
			Std.int(geometry.height * sliders.length),
			Rl.Color.create(0,0,0,0xc0)
		);

		var should_trace_values = Rl.isMouseButtonReleased(Rl.MouseButton.LEFT);
		for (slider in sliders) {
			slider.update();
			if(should_trace_values){
				trace(slider.to_string());
			}
		}
	}

}

@:structInit
class Slider {
	var value:Float;
	var value_min:Float;
	var value_max:Float;
	var label:String;
	var label_aligned_right:Bool = false;
	var on_set_value:(value:Float) -> Void;
	var bounds:Rectangle;


	var label_left:String = "";
	var label_right:String = "";
	public function update() {
		label_left = label_aligned_right
			? ""
			: to_string();
			
		label_right = label_aligned_right
			? to_string()	
			: "";

		value = Raygui.GuiSlider(
			bounds,
			label_left,
			label_right,
			value,
			value_min,
			value_max
		);
		on_set_value(value);
	}

	public function get_value():Float {
		return value;
	}

	public function to_string():String {
		return '$label $value';
	}
}
