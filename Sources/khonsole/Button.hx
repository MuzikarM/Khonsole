package khonsole;


class Button{

	static inline var MARGIN:Int = 2;

	var bounds:Bounds;
	public var text(default, set):String;
	var textWidth:Float;
	public var color:Int;
	var onClick:Int->Bool;
	var focused:Bool;
	var parent:Window;
	var offX:Float;
	var offY:Float;

	public function new(offX:Float,offY:Float, text:String, onClick:Int->Bool, color:Int = 0xffffffff, square:Bool = false){
		this.textWidth = Khonsole.font.width(Khonsole.fontSize, text);		
		if (square){
			var size = Std.int(Math.max(textWidth, Khonsole.fontSize));
			bounds = {
				x: 0,
				y: 0,
				w: size,
				h: size
			}
		} else {
			bounds = {
				x: 0,
				y: 0,
				w: Std.int(textWidth + MARGIN),
				h: Std.int(Khonsole.fontSize + MARGIN)
			};
		}
		this.offX = offX;
		this.offY = offY;
		this.onClick = onClick;
		this.text = text;
		this.color = color;
		focused = false;
	}


	@:allow(khonsole.Window)
	function setParent(w:Window){
		this.parent = w;
		bounds = {
			x: Std.int(parent.bounds.x + parent.bounds.w * offX - bounds.w),
			y: Std.int(parent.bounds.y + parent.bounds.h * offY + MARGIN),
			w: bounds.w,
			h: bounds.h
		};
	}

	function recalculateBounds(){
		if (parent == null)
			return;
		textWidth = Khonsole.font.width(Khonsole.fontSize, text);
		bounds = {
			x: Std.int(parent.bounds.x + parent.bounds.w * offX - textWidth),
			y: Std.int(parent.bounds.y + parent.bounds.h * offY + MARGIN),
			w: Std.int(textWidth + MARGIN),
			h: Std.int(Khonsole.fontSize + MARGIN)
		}
	}

	function set_text(value){
		this.text = value;
		recalculateBounds();
		return this.text;
	}

	public function parentResized(prevB:Bounds, newB:Bounds){
		bounds = {
			x: Std.int(parent.bounds.x + parent.bounds.w * offX - bounds.w),
			y: Std.int(parent.bounds.y + parent.bounds.h * offY),
			w: bounds.w,
			h: bounds.h
		};
	}

	public function overlaps(x:Float,y:Float){
		return x > bounds.x &&
			x < bounds.x + bounds.w &&
			y > bounds.y &&
			y < bounds.y + bounds.h;
	}

	public function focus(){
		focused = true;
	}

	public function lostFocus(){
		focused = false;
	}

	public function click(id:Int){
		if (onClick != null)
			return onClick(id);
		return false;
	}

	public function render(g:kha.graphics2.Graphics){
		g.color = 0xffcccccc;
		g.fillRect(bounds.x, bounds.y, bounds.w, bounds.h);
		if (focused)
			g.color = 0xff999999;
		g.drawRect(bounds.x, bounds.y, bounds.w, bounds.h, 2);
		g.color = color;
		g.drawString(text, bounds.x + bounds.w / 2 - textWidth /2, bounds.y);
	}


}