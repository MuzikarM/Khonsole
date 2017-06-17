package khonsole;

import kha.Framebuffer;
import kha.Font;
import kha.input.KeyCode;
import khonsole.commands.Commands;
import kha.System;

using StringTools;
using Lambda;

class Khonsole{

	private static inline var MARGIN:Int = 5;

	public static var font:Font;
	static var showing:Bool;
	public static var height:Float;
	public static var opacity:Float;
	public static var fontSize:Int;
	//static var input:String;
	//static var inputPos:Int;
	static var input:Input;

	public static var history(default, null):History;
	public static var interpreter(default, null):Interpreter;
	public static var commands(default, null):Commands;
	public static var display(default, null):Display;

	static var charWidth:Float;

	static var prevSize = {
		width: 0,
		height: 0
	};

	private function new(){
		//NO-OP
	}

/**
	Registers a new variable to use in console.
	@param name Name of variable.
	@param value Value of variable
**/
	public static function register(name:String, value:Dynamic){
		interpreter.register(name, value);
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
		history = new History();
		interpreter = new Interpreter();
		commands = new Commands();
		display = new Display();
		charWidth = font.width(fontSize, '_');
		input = new Input(0, System.windowHeight() - fontSize - 6, System.windowWidth(), fontSize + 4, charWidth);
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

	private static function resize(w:Int, h:Int){
		prevSize = {width: w, height: h};
	}

/**
Renders Khonsole
@param g Graphics2 object
**/
	public static function render(fb:Framebuffer){
		if (!showing)
			return;
		if (fb.height != prevSize.height || fb.width != fb.width)
			resize(fb.width, fb.height);
		var g = fb.g2;
		g.font = font;
		g.fontSize = fontSize;
		g.color = kha.Color.fromFloats(.7, .7, .7, 1);
		g.opacity = opacity;
		var w = prevSize.width;
		var h = prevSize.height;
		g.fillRect(0, h, w, -h*height); // Background of Display
		display.render(g);
		input.render(g);
		g.opacity = 1;
		g.color = 0xffffffff;
	}


}