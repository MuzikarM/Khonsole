package khonsole;

import khonsole.commands.Status;

class Display{

	var display:Array<Line>;
	var bounds:Bounds;

	public function new(x:Int, y:Int, w:Int, h:Int){
		display = new Array<Line>();
		bounds = {
			x:x,
			y:y,
			w:w,
			h:h
		};
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
		//var wh = kha.System.windowHeight();
		//var height = (wh*Khonsole.height)-Khonsole.fontSize;
		var maxLines = Std.int(bounds.h / Khonsole.fontSize)-1;
		if (display.length > maxLines){
			var del = Std.int(Math.abs(maxLines - display.length));
			display.splice(0, del);
		}
	}

	public function resize(w:Int, h:Int){
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
		if (display == null)
			return;
		var wh = kha.System.windowHeight();
		var top = wh-(Khonsole.height * wh);
		var a = 0;
		g.opacity = Khonsole.opacity;
		g.fillRect(bounds.x, bounds.y, bounds.w, bounds.h); 
		for (line in display){
			g.color = line.color;			
			var lineNum = '[$a]: ';
			g.drawString(lineNum, 0, top + (a * Khonsole.fontSize));
			g.drawString(line.text, Khonsole.font.width(Khonsole.fontSize, lineNum), top + (a * Khonsole.fontSize));
			a++;
		}
	}

}

typedef Line = {
	var color:Int;
	var text:String;
}