package khonsole.commands;

using StringTools;

class FieldsCmd extends Command{

	public function new(){
		super("!fields", start,"!fields <VAR>");
	}

	function start(params:Array<String>):Status{
		if (params.length < 1)
			return fail("Variable name must be provided");
		var interp = Khonsole.interpreter.getInterp();
		var path = params[0].split(".");
		var name = path.shift();
		var x = null;
		try{
			if (isArray(name)){
				x = resolveArray(name, interp.variables.get(getVarName(name)));
			} else{ 
				x = interp.variables.get(name);
			}
			if (x == null)
				throw '$name was not found';
			for (p in path){
				x = resolve(p, x);
			}
			return success(extractFields(x));
		} catch (s:String){
			return fail(s);
		}
	}

	function extractFields(x:Dynamic):String{
		var str = "";
		for (f in Reflect.fields(x)){
			str += '$f ';
		}
		return str;
	}

	function isArray(name:String):Bool{
		return name.endsWith("]");
	}

	function getVarName(name:String):String{
		var i = name.indexOf("[");
		return name.substr(0, i);
	}

	function getIndexes(name:String):Array<Any>{
		name = name.replace("]", "");
		var indexes = name.split("[");
		indexes.shift();
		var x = indexes.map(function(s):Any {
			if (s.charAt(0) == '"'){
				return s.replace('"', "");
			} else 
				return Std.parseInt(s);
		});
		return x;
	}

	function resolveArray(name:String, obj:Dynamic):Dynamic{
		var n = getVarName(name);
		var indexes = getIndexes(name);
		for (index in indexes){
			var getfn = obj.get;
			if (getfn != null){
				obj = Reflect.callMethod(obj, getfn, [index]);
			} else {
				obj = obj[cast index];
			}
			if (obj == null)
				throw '$index was not found';
		}
		return obj;
	}

	function resolveVar(name:String, obj:Dynamic):Dynamic{
		var x =  Reflect.getProperty(obj, name);
		if (x == null)
			throw '$name was not found';
		return x;
	}

	function resolve(name:String, obj:Dynamic){
		if (isArray(name))
			return resolveArray(name, obj);
		return resolveVar(name, obj);
	}


}