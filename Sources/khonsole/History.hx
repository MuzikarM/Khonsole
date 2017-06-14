package khonsole;

class History{

	static var i:Int;
	var lines:Array<String>;
	var toRender:Array<String>;

	public function new(){
		i = 0;
		lines = [];
		toRender = [];
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
		var total = getTotalLines();
		if (lines.length > total){
			var index = lines.length - total;
			toRender = lines.slice(index);
		} else {
			toRender = lines;
		}
	}

	function getTotalLines():Int{
		var wh = kha.System.windowHeight();
		var height = wh*Khonsole.height;
		var fits = Std.int(height / Khonsole.fontSize)-1;
		return fits;
	}

	public function render(g:kha.graphics2.Graphics){
		var wh = kha.System.windowHeight();
		var top = wh-(Khonsole.height * wh);
		var height = wh*Khonsole.height;
		var a = 0;
		for (line in toRender){
			var lineNum = '[$a]: ';
			g.drawString(lineNum, 0, top + (a * Khonsole.fontSize));
			g.drawString(line, Khonsole.font.width(Khonsole.fontSize, lineNum), top + (a * Khonsole.fontSize));
			a++;
		}
	}

}