package khonsole;

import kha.graphics2.Graphics;
import kha.Font;
import kha.input.KeyCode;
import khonsole.commands.Commands;

using StringTools;
using Lambda;

class Khonsole{

	private static inline var MARGIN:Int = 5;
	private static var BLACK_LIST = ["\n", "\r", "\t"];

	public static var font:Font;
	static var showing:Bool;
	public static var height:Float;
	public static var opacity:Float;
	public static var fontSize:Int;
	static var input:String;
	static var inputPos:Int;

	public static var history(default, null):History;
	public static var interpreter(default, null):Interpreter;
	public static var commands(default, null):Commands;
	public static var display(default, null):Display;

	static var charWidth:Float;

	private function new(){
		//NO-OP
	}

	public static function register(name:String, value:Dynamic){
		interpreter.register(name, value);
	}

	static function down(x){
		switch(x){
			case KeyCode.Backspace:{
				if (input.length == 0)
					return;
				input = input.substr(0, input.length-1);
				inputPos--;
			}
			case KeyCode.Return:{
				if (input.trim() == "")
					return;
				display.info(input.trim());
				display.displayStatus(interpreter.interpret(input.trim()));
				history.addToHistory(input.trim());
				input = "";
				inputPos = 0;
			}
			case KeyCode.Left:{
				if (inputPos > 0)
					inputPos--;
			}
			case KeyCode.Right:{
				if (inputPos < input.length)
					inputPos++;
			}
			case KeyCode.Up:{
				input = history.getPrevious();
				inputPos = input.length;
			}
			case KeyCode.Down:{
				input = history.getNext();
				inputPos = input.length;
			}
			case KeyCode.Tab:{
				input = commands.getSuggestion(input);
				inputPos = input.length;
			}
		}
	}

	static function pressed(x:String){
		if (BLACK_LIST.has(x))
			return;
		if (inputPos == input.length)
			input += x;
		else
			input = insert(input, x, inputPos);
		inputPos++;		
	}

	static function insert(to:String, what:String, index:Int):String{
		var b = to.substr(0, index);
		var f = to.substr(index);
		return '$b$what$f';
	}


	/**
	Creates a static instance of Khonsole
	@param font Font used by Khonsole
	@param height height of Khonsole (in %), 33 % by default
	@param opacity opacity of Khonsole (in %) 50 % by default
	**/
	public static function init(font:Font, fontSize:Int = 16, height:Float = 0.33, opacity:Float = 0.5){
		showing = true;
		Khonsole.font = font;
		Khonsole.height = height;
		Khonsole.opacity = opacity;
		Khonsole.fontSize = fontSize;
		input = "";
		inputPos = 0;
		history = new History();
		interpreter = new Interpreter();
		commands = new Commands();
		display = new Display();
		kha.input.Keyboard.get().notify(down, null, pressed);
		charWidth = font.width(fontSize, '_');
	}

	/**
	Turns the Khonsole visible
	**/	
	public static function show(){
		showing = true;
	}
/**
Hides Khonsole
**/
	public static function hide(){
		showing = false;
	}

	public static function render(g:Graphics){
		if (!showing)
			return;
		g.font = font;
		g.fontSize = fontSize;
		g.color = kha.Color.fromFloats(.7, .7, .7, 1);
		g.opacity = opacity;
		var w = kha.System.windowWidth();
		var h = kha.System.windowHeight();
		g.fillRect(0, h, w, -h*height);
		display.render(g);
		g.opacity = opacity+0.2;
		g.fillRect(MARGIN, h, w-10, -(fontSize+(MARGIN*2)));
		g.opacity = 1;
		g.color = 0xff000000;
		g.drawString(input, MARGIN, h-fontSize-(fontSize/2)+MARGIN/2);
		g.opacity = Math.max(Math.abs(Math.sin(2*kha.System.time)), 0.2);
		g.fillRect((inputPos * charWidth) + charWidth/2, h-MARGIN, charWidth, 2);
		g.opacity = 1;
		g.color = 0xffffffff;
	}


}