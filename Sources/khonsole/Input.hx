package khonsole;

import kha.input.KeyCode;

using StringTools;
using Lambda;

class Input extends Window{

	private static var BLACK_LIST = ["\n", "\r", "\t"];

	static inline var MARGIN = 5;
	var input:String;
	public var pos:Int;
	var charWidth:Float;

	public function new(x:Int, y:Int, w:Int, h:Int, charWidth:Float){
		initBounds(x + MARGIN, y, w - MARGIN, h);
		this.charWidth = charWidth;
		input = "";
		pos = 0;
		this.onResize = _resize;
		this.onKeyInput = down;
		this.onStrInput = pressed;
	}

	public function _resize(w:Int, h:Int){
		bounds.w = w-MARGIN;
		bounds.y = h-Khonsole.fontSize-6;
	}


	public function render(g:kha.graphics2.Graphics){
		g.opacity += 0.2;
		g.color = 0xffffffff;
		g.fillRect(bounds.x-MARGIN, bounds.y, bounds.w+MARGIN, bounds.h);
		g.opacity = 1;
		g.color = 0xff000000;
		g.drawString(input, bounds.x, bounds.y);
		g.opacity = Math.max(Math.abs(Math.sin(2*kha.System.time)), 0.2);
		g.fillRect(pos * charWidth + charWidth/2, bounds.y + g.fontSize, charWidth, 2);
	}

	public function getInput():String{
		return input;
	}


	function down(x:KeyCode){
		switch(x){
			case KeyCode.Backspace:{
				if (input.length == 0)
					return;
				input = input.substr(0, input.length-1);
				pos--;
			}
			case KeyCode.Return:{
				input = input.trim();
				if (input == "")
					return;
				Khonsole.display.info(input);
				if (input.charAt(0) != "#" && input.charAt(0) != "@"){
					Khonsole.history.addToHistory(input);
				}
				Khonsole.display.displayStatus(Khonsole.interpreter.interpret(input));
				input = "";
				pos = 0;
			}
			case KeyCode.Left:{
				if (pos > 0)
					pos--;
			}
			case KeyCode.Right:{
				if (pos < input.length)
					pos++;
			}
			case KeyCode.Up:{
				input = Khonsole.history.getPrevious();
				pos = input.length;
			}
			case KeyCode.Down:{
				input = Khonsole.history.getNext();
				pos = input.length;
			}
			case KeyCode.F1:{
				input = Khonsole.commands.getSuggestion(input);
				pos = input.length;
			}
			case KeyCode.Delete:{
				if (pos == input.length)
					return;
				input = input.substr(0, pos) + input.substr(pos+1);
			}
			default:
		}
	}

	function pressed(x:String){
		if (BLACK_LIST.has(x))
			return;
		if (pos == input.length)
			input += x;
		else
			input = insert(input, x, pos);
		pos++;		
	}

	function insert(to:String, what:String, index:Int):String{
		var b = to.substr(0, index);
		var f = to.substr(index);
		return '$b$what$f';
	}

}