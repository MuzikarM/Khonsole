package khonsole.commands;

import khonsole.Khonsole;
import haxe.Json;

using StringTools;

class Commands{

	var commands:Map<String, Command>;

	public function new(){
		commands = new Map<String, Command>();
		init();
	}

	private function init(){
		register("help", function(params){
			if (params.length < 0)
				return {
					success: true,
					output: "Testing output"
				}
			var name = '!' + params[0];
			if (commands.exists(name)){
				var cmd = commands.get(name);
				return {
					success: true,
					output: cmd.getUsage()
				};
			} else {
				return {
					success: false,
					output: 'Command $name was not found'
				};
			}
		});
		register("close", function(_){
			Khonsole.hide();
			return {
				success: true
			}
		});
		register("clear", function(_){
			Khonsole.display.clear();
			return {
				success: true
			}
		});
		register("import", function(params){
			if (params.length < 1)
				return {
					success: false,
					output: "At least one classname is required!"
				}
			var i = 0;
			while (i < params.length){
				var x = params[i];
				if (x.toLowerCase() == "as")
					continue;
				var clazz = Type.resolveClass(x);
				if (clazz == null)
					return {
						success: false,
						output: 'Type $x was not found'
					}
				if (i+1<params.length && params[i+1].toLowerCase() == "as"){
					if (i+2<params.length){
						var name = params[i+2];
						Khonsole.register(name, clazz);
						i = i + 3;
					}
					else 
						return {
							success: false,
							output: "You need to include an alias after keyword AS"
						}
				}
				else {
					Khonsole.register(x, clazz);
					i++;
				}

			}
			return {
				success: true
			}
		}, "!import <CLASS_PATH> [as alias]...");
		register("height", function(params){
			if (params.length < 1)
				return {
					success: false,
					output: "Height was not specified"
				}
			var val = Std.parseFloat(params[0]);
			if (val == Math.NaN)
				return {
					success: false,
					output: "Could not parse height as a number"
				}
			if (val > 1)
				val /= 100;
			Khonsole.height = val;
			return {
				success: true
			}
		}, "!height <NEW_HEIGHT (in % or 0.0 - 1.0)>");
		register("opacity", function(params){
			if (params.length < 1)
				return {
					success: false,
					output: "Opacity was not specified"
				}
			var val = Std.parseFloat(params[0]);
			if (val == Math.NaN)
				return {
					success: false,
					output: "Could not parse opacity as a number"
				}
			if (val > 1)
				val /= 100;
			Khonsole.opacity = val;
			return {
				success: true
			}
		}, "!opacity <NEW_OPACITY (in % of 0.0 - 1.0)>");
		#if (!js && !flash)
		commands.set("!dump", new DumpCmd());
		#end
		register("commands", function (_){
			var iter = commands.keys();
			var cmds = "";
			while (iter.hasNext()){
				var cmd = iter.next();
				cmds += '$cmd ';
			}
			return {
				success: true,
				output: "Registered commands: " + cmds
			}
		});
		register("vars", function(_){
			var iter = Khonsole.interpreter.getInterp().variables.keys();
			var vars = "";
			while (iter.hasNext()){
				var v = iter.next();
				vars += '$v ';
			}
			return {
				success: true,
				output: 'Registered vars: $vars'
			}
		});
		register("history", function(_){
			var history = "";
			var i = 0;
			for (line in Khonsole.history.lines){
				history += '[$i]: $line ';
				i++;
			}
			return {
				success: true,
				output: history
			}
		});
		register("show", function(params){
			if (params.length < 1){
				return {
					success: false,
					output: "You need to specify which window to show"
				};
			}
			switch(params[0].toUpperCase()){
				case"WATCHES":{
					Khonsole._watch.showing = true;
					Khonsole.refresh();
					return {
						success: true
					};
				}
				case"PROFILES":{
					Khonsole.profiler.showing = true;
					Khonsole.refresh();
					return {
						success: true
					};
				}
				case (_):{
					return {
						success: false,
						output: 'Could not interpret ${params[0]}'
					}
				}
			}
		}, "!show <watches|profiles>");
		register("hide", function(params){
			if (params.length < 1){
				return {
					success: false,
					output: "You need to specify which window to show"
				};
			}
			switch(params[0].toUpperCase()){
				case"WATCHES":{
					Khonsole._watch.showing = false;
					Khonsole.refresh();
					return {
						success: true
					};
				}
				case"PROFILES":{
					Khonsole.profiler.showing = false;
					Khonsole.refresh();
					return {
						success: true
					};
				}
				case (_):{
					return {
						success: false,
						output: 'Could not interpret ${params[0]}'
					}
				}
			}
		}, "!hide <watches|profiles>");
		commands.set("!fields", new FieldsCmd());
	}
	public function register(id:String, action:Array<String>->Status, usage:String = "NOT SPECIFIED"){
		commands.set('!$id', new Command(id, action, usage));
	}

	public function get(id:String):Command{
		return commands.get(id);
	}

	public function getSuggestion(x:String):String{
		var iter = commands.keys();
		while (iter.hasNext()){
			var key = iter.next();
			trace(key);
			if (key.startsWith(x)){
				return key;
			}
		}
		return x;
		
	}

}