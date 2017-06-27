package khonsole;

#if !macro
import kha.Framebuffer;
import kha.Font;
import khonsole.commands.Commands;
import kha.System;
import kha.input.KeyCode;
#end
#if macro
import haxe.macro.Expr;
import haxe.macro.Expr.ExprDef;
#end
class Khonsole{

	#if !macro
	private static inline var MARGIN:Int = 5;

	public static var font:Font;
	public static var showing:Bool;
	public static var height:Float;
	public static var opacity:Float;
	public static var fontSize:Int;
	static var input:Input;
	public static var actionKey:Int;

	public static var history(default, null):History;
	public static var interpreter(default, null):Interpreter;
	public static var commands(default, null):Commands;
	public static var display(default, null):Display;
	public static var _watch(default, null):Watch;
	public static var profiler(default, null):Profiler;

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
	public static function init(font:Font, key:Int = KeyCode.Home, fontSize:Int = 20, height:Float = 0.33, opacity:Float = 0.5){
		showing = true;
		Khonsole.font = font;
		Khonsole.height = height;
		Khonsole.opacity = opacity;
		Khonsole.fontSize = fontSize;
		actionKey = key;
		history = new History();
		interpreter = new Interpreter();
		commands = new Commands();
		var h = System.windowHeight();
		var w = System.windowWidth();
		display = new Display(0, Std.int(h - h * height), w, Std.int(h * height));
		charWidth = font.width(fontSize, '_');
		input = new Input(0, h - fontSize - 6, w, fontSize + 4, charWidth);
		_watch = new Watch(0, 0, Std.int(w/2), Std.int(h/2));
		profiler = new Profiler(Std.int(w/2), 0, Std.int(w/2), Std.int(h/2));
		
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
		input.resize(w,h);
		display.resize(w,h);
	}

	public static function startProfile(name:String){
		profiler.startProfile(name);
	}

	public static function endProfile(name:String){
		profiler.endProfile(name);
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
		//if (System.windowWidth() != prevSize.height || System.windowHeight() != prevSize.height)
		//	resize(System.windowWidth(), System.windowHeight());
		var g = fb.g2;
		g.font = font;
		g.fontSize = fontSize;
		g.opacity = opacity;
		display.render(g);
		input.render(g);
		_watch.render(g);
		profiler.render(g);
		g.opacity = 1;
		g.color = 0xffffffff;
	}
	#end

	macro public static function watch(value:Expr){
		switch(value.expr){
			case EField(e, name):{
				return macro Khonsole._watch.watch($v{name}, ${e});
			}
			case _:{
				throw "Field must be supplied in watch";
			}
		}
	}

}