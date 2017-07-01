package khonsole;

import kha.input.*;

class InputManager{

	var windows:Array<Window>;
	var active:Window;
	var textInput:Window;

	public function new(windows:Array<Window>, textInput:Window){
		this.windows = windows;
		this.textInput = textInput;
		Mouse.get().notify(mouseDown, mouseUp, mouseMove, mouseScroll);
		Keyboard.get().notify(keyDown, keyUp, keyPressed);
	}

	function mouseDown(id, x, y){
		
	}

	function mouseUp(id, x, y){
		if (active != null)
			active.click(id, x, y);
	}

	function mouseMove(x,y,dx,dy){
		if (active != null){
			if (!active.pointInBounds(x,y)){
				for (window in windows){
					if (window.pointInBounds(x,y)){
						active.lostFocus();
						active = window;
						window.setFocus();
						return;
					}
				}
			}
		} else {
			for (window in windows){
				if (window.pointInBounds(x,y)){
					active = window;
					window.setFocus();
					return;
				}
			}
		}
	}

	function mouseScroll(y){
		if (active != null)
			active.scroll(y);
	}

	function keyDown(i){
		if (active != null){
			if (active.acceptsKeyInput())
				active.keyInput(i);
			else
				textInput.keyInput(i);
		} else {
			textInput.keyInput(i);
		}
	}

	function keyUp(i){

	}

	function keyPressed(s){
		if (active != null){
			if (active.acceptsKeyInput())
				active.strInput(s);
			else
				textInput.strInput(s);
		} else {
			textInput.strInput(s);
		}
	}


}
