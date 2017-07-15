package khonsole;

import khonsole.commands.Status;

class Display extends Window{

	var display:Array<Line>;
	var index:Int;
	var maxIndex:Int;

	public function new(x:Int, y:Int, w:Int, h:Int){
		display = new Array<Line>();
		initBounds(x,y,w,h);
		this.onResize = _resize;
		this.onScroll = _scroll;
		maxIndex = Std.int((bounds.h - Khonsole.fontSize) / Khonsole.fontSize);
	}

	function _scroll(i){
		if (display.length < maxIndex)
			return;
		index += i;
		if (index < 0)
			index = 0;
		if (index > display.length - maxIndex)
			index = display.length - maxIndex;
	}

	public function print(text:String, color:Int){
		var lines = text.split("\n");
		var fwidth = Khonsole.font.width.bind(Khonsole.fontSize);
		if (fwidth(text) > bounds.w){
			var words = text.split(" ");
			var w:Float = fwidth('[__]: ');
			var line = "";
			for (word in words){
				var tempW = fwidth('$word ');
				if (tempW + w >= bounds.w){
					line += "\n";
					w = fwidth('[__]: ');
				}
				w += tempW;
				line += word + " ";
			}
			lines = line.split("\n");
		}
		if (lines.length == 1)
			display.push({text: text, color: color});
		else {
			for (line in lines)
				display.push({text: line, color: color});
		}
		if (display.length > maxIndex){
			index = display.length - maxIndex;
		}
	}

	public function _resize(w:Int, h:Int){
		bounds.w = w;
		bounds.y = Std.int(h - h * Khonsole.height);
	}

	public function success(text:String){
		print(text, 0xff00ff00);
	}	

	public function error(text:String){
		print(text, 0xffff0000);
	}

	public function info(text:String){
		print(text, 0xff000000);
	}

	public function clear(){
		display.splice(0, display.length);
		index = 0;
	}

	public function displayStatus(status:Status){
		if (status.success){
			if (status.output != null)
				success(status.output);
			else
				success("COMMAND SUCCESSFUL");				
		} else {
			if (status.output != null)
				error(status.output);
			else
				error("COMMAND FAILED");		
		}
	}

	public function render(g:kha.graphics2.Graphics){
		var a = 0;
		g.opacity = Khonsole.opacity;
		g.fillRect(bounds.x, bounds.y, bounds.w, bounds.h); 
		for (i in index...Std.int(Math.min(index+maxIndex, display.length))){
			var line = display[i];
			g.color = line.color;			
			var lineNum = '[$i]: ';
			g.drawString(lineNum, 0, bounds.y + (a * Khonsole.fontSize));
			g.drawString(line.text, Khonsole.font.width(Khonsole.fontSize, lineNum), bounds.y + (a * Khonsole.fontSize));
			a++;
		}
		if (display.length > maxIndex){
			g.color = 0xffffffff;
			g.fillRect(bounds.w - 4, bounds.y + bounds.h * (index / display.length), 4, bounds.h * (maxIndex / display.length));
		}
	}

}

typedef Line = {
	var color:Int;
	var text:String;
}