package khonsole;

import khonsole.commands.Status;

class Display{

	var display:Array<Line>;

	public function new(){
		display = new Array<Line>();
	}

	public function print(text:String, color:Int){
		display.push({text: text, color: color});
		var wh = kha.System.windowHeight();
		var height = (wh*Khonsole.height)-Khonsole.fontSize;
		var maxLines = Std.int(height / Khonsole.fontSize)-1;
		if (display.length > maxLines){
			var del = Std.int(Math.abs(maxLines - display.length));
			display.splice(0, del);
		}
	}

	public function success(text:String){
		print(text, 0xff00cc00);
	}	

	public function error(text:String){
		print(text, 0xffcc0000);
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
	var color: Int;
	var text:String;
}