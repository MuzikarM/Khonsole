package khonsole;

import kha.input.KeyCode;

class Window{

	public var bounds(default, set):Bounds;
	public var showing:Bool;
	var focused:Bool;
	var onScroll:Int->Void;
	var onKeyInput:KeyCode->Void;
	var onStrInput:String->Void;
	var onClick:Int->Int->Int->Void;
	var onResize:Int->Int->Void;
	var onMouseMove:Float->Float->Int->Int->Void;
	var headX:Float;
	var heading:String;
	var buttons:Array<Button>;
	var activeButton:Button;

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

	function set_bounds(b:Bounds){
		if (bounds != null)
			handleBoundsChange(bounds, b);
		this.bounds = b;
		return bounds;
	}

	public function moveWindow(dx:Int, dy:Int){
		var b = {
			x: bounds.x + dx,
			y: bounds.y + dy,
			w: bounds.w,
			h: bounds.h
		}
		this.bounds = b;
	}

	public function setPos(x:Int, y:Int){
		var b = {
			x: x,
			y: y,
			w: bounds.w,
			h: bounds.h
		};
		this.bounds = b;
	}

	function handleBoundsChange(prevB:Bounds, newB:Bounds){
		if (prevB.w != newB.w || prevB.x != newB.x)
			calculateHeadingX();
		if (buttons == null)
			return;
		for (button in buttons){
			button.parentResized(prevB, newB);
		}
	}

	public function addButton(b:Button){
		b.setParent(this);
		if (buttons == null)
			buttons = [b];
		else
			buttons.push(b);
	}

	public function removeButton(b:Button){
		if (buttons == null)
			return;
		if (b == activeButton){
			activeButton.lostFocus();
			activeButton = null;
		}
		buttons.remove(b);
		if (buttons.length == 0)
			buttons = null;
	}

	function buttonsMove(x:Float,y:Float){
		if (buttons == null)
			return;
		if (activeButton != null){
			if (!activeButton.overlaps(x,y)){
				activeButton.lostFocus();
				activeButton = null;
				for (button in buttons){
					if (button.overlaps(x,y)){
						activeButton = button;
						activeButton.focus();
						return;
					}
				}
			}
		}
		else {
			for (button in buttons){
				if (button.overlaps(x,y)){
					activeButton = button;
					activeButton.focus();
					return;
				}
			}
		}
	}

	function addCloseButton(){
		addButton(new Button(1.0, 0, "X", function(_) {showing = false; Khonsole.refresh(); return true;}, 0xffff0000, true));
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
		if (buttons != null){
			for (button in buttons){
				button.render(g);
			}
		}
	}

	public function click(id,x,y){
		if (activeButton != null){
			if (activeButton.click(id))
				return;
		}
		if (onClick != null)
			onClick(id, x, y);
	}

	public function mouseMove(x,y,dx,dy){
		if (buttons != null){
			buttonsMove(x,y);
		}
		if (onMouseMove != null)
			onMouseMove(x,y,dx,dy);
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