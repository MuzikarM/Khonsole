package khonsole.commands;

import haxe.Json;

using StringTools;

class DumpCmd extends Command{

	public function new(){
		super("!dump", start, "!dump <VAR|WATCHES|PROFILES> [FILE_NAME]");
	}

	function save(path:String, content:Dynamic):Status{
		if (!sys.FileSystem.exists("dumps"))
			sys.FileSystem.createDirectory("dumps");
		sys.io.File.saveContent('dumps/$path.json', Json.stringify(content));
		return {
			success: true,
			output: "File is saved as " + sys.FileSystem.fullPath('dumps/$path.json')
		}
	}

	function determinePath(params:Array<String>):String{
		if (params.length == 2)
			return params[1];
		else
			return Date.now().toString().replace(" ", "_").replace("/","_").replace(":","_") + "_" + params[0];
	}

	function start(params:Array<String>):Status{
		if (params.length < 1)
			return {
				success: false,
				output: "Variable name must be specified"
			}
		var inter = Khonsole.interpreter.getInterp();
		if (inter.variables.exists(params[0])){
			var x = inter.variables.get(params[0]);
			var path = determinePath(params);
			return save(path, x);
		} else {
			switch(params[0].toUpperCase()){
				case"PROFILES":{
					var path = determinePath(params);
					return save(path, Khonsole.profiler.profiles);
				}
				case"WATCHES":{
					var path = determinePath(params);
					return save(path, Khonsole._watch.watches);
				}
			}
			return {
				success: false,
				output: "Variable does not exist"
			}
		}
	}

}