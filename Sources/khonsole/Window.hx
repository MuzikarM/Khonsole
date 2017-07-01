package khonsole;

class Window{

	var bounds:Bounds;
	var focused:Bool;
	var onScroll:Int->Void;
	var onKeyInput:Int->Void;
	var onStrInput:String->Void;
	var onClick:Int->Int->Int->Void;
	var onResize:Int->Int->Void;
	var headX:Float;
	var heading:String;

	function initBounds(x:Int, y:Int, w:Int, h:Int){
		this.bounds = {
			x: x,
			y: y,
			w: w,
			h: h
		};
		focused = false;
		calculateHeadingX();
	}

	public function setFocus(){
		focused = true;
	}

	public function lostFocus(){
		focused = false;
	}

	public function resize(w:Int, h:Int){
		if (onResize != null)
			onResize(w,h);
		calculateHeadingX();
	}

	public function pointInBounds(x:Float, y:Float):Bool{
		return x > bounds.x &&
			x < bounds.x + bounds.w &&
			y > bounds.y &&
			y < bounds.y + bounds.h;
	}

	function calculateHeadingX(){
		var w = Khonsole.font.width(Khonsole.fontSize, heading)/2;
		headX = bounds.x + bounds.w / 2 - w;
	}

	function prepareWindow(g:kha.graphics2.Graphics){
		g.color = 0xffcccccc;
		g.opacity = Khonsole.opacity;
		if (focused){
			g.color = 0xffffffff;
			g.drawRect(bounds.x, bounds.y, bounds.w, bounds.h, 2);
			g.color = 0xffcccccc;
		}
		g.fillRect(bounds.x, bounds.y, bounds.w, bounds.h);
		g.color = 0xffffffff;
		g.drawString(heading, headX, bounds.y);
	}

	public function click(id,x,y){
		if (onClick != null)
			onClick(id, x, y);
	}

	public function scroll(y){
		if (onScroll != null)
			onScroll(y);
	}

	public function keyInput(key){
		if (onKeyInput != null)
			onKeyInput(key);
	}

	public function strInput(s){
		if (onStrInput != null)
			onStrInput(s);
	}

	public function acceptsKeyInput(){
		return onKeyInput != null || onStrInput != null;
	}

}