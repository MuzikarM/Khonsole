package khonsole;

class History{

	public var i(default, null):Int;
	public var lines(default, null):Array<String>;

	public function new(){
		i = 0;
		lines = [];
	}

	public function getPrevious():String{
		if (lines.length == 0)
			return "";
		if (i>0){
			i--;
			return lines[i];
		}
		return lines[i];
	}

	public function get(i:Int):String{
		if (i < 0 || i >= lines.length)
			return "";
		return lines[i];
	}

	public function getNext():String{
		if (i >= lines.length-1){
			i = lines.length;
			return "";
		}
		i++;
		return lines[i];
	}

	public function addToHistory(cmd:String){
		lines.push(cmd);
		i++;
	}


}