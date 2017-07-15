package khonsole;

import khonsole.commands.*;
import hscript.Interp;
import hscript.Parser;

using StringTools;

class Interpreter{

	var interp:Interp;
	var parser:Parser;

	public function new(){
		interp = new Interp();
		interp.variables.set("trace", function(x){
			Khonsole.display.info(x);
		});
		parser = new Parser();
	}

	public function register(name:String, value:Dynamic){
		interp.variables.set(name, value);
	}

	function runCommand(input:String):Status{
		var words = input.split(" ");
			var cmd = Khonsole.commands.get(words[0]);
			if (cmd == null)
				return {
					success: false,
					output: "Command was not found"
				}
		return cmd.invoke(words.slice(1));
	}

	public function interpret(input:String):Status{
		if (input.charAt(0) == "#"){
			var pos = Std.parseInt(input.substring(1));
			if (pos == null)
				return {
					success: false,
					output: input.substring(1) + "is not valid number"
				}
			return interpret(Khonsole.history.get(pos));
		}
		if (input.charAt(0) == "@"){
			var pos = Std.parseInt(input.substring(1));
			pos = Khonsole.history.i - pos;
			if (pos == null)
				return {
					success: false,
					output: input.substring(1) + "is not valid number"
				}
			return interpret(Khonsole.history.get(pos));
		}
		if (input.charAt(0) == "!"){
			return runCommand(input);
		}
		else {
			try{
				var program = parser.parseString(input);
				switch(program){
					case hscript.Expr.EVar(n, t, e):{
						var val = interp.execute(e);
						Khonsole.register(n, val);
						return {
							success: true
						}
					}
					default:{
						var ret = interp.execute(program);
						return {
							success: true,
							output: ret != null?ret.toString():"Interpreted successfully"
						}
					}
				}
			}
			catch(e:Dynamic){
				var cmd = runCommand('!$input');
				if (cmd.success || cmd.output != null){
					return cmd;
				}
				return {
					success: false,
					output: e.toString()
				}
			}
		}
		return {
			success: false,
			output: "Nothing was found"
		}
	}

	public function getInterp():Interp{
		return interp;
	}

}