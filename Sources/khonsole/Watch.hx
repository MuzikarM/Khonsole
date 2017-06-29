package khonsole;

import kha.Scheduler;

using StringTools;

class Watch{

	public var watches(default, null):Array<WatchObj>;
	var bounds:Bounds;
	var taskId:Int;
	var heading:String;
	public var showing:Bool;

	public function new(x:Int, y:Int, w:Int, h:Int, rate:Float = 1){
		watches = new Array<WatchObj>();
		bounds = {
			x:x,
			y:y,
			w:w,
			h:h
		};
		heading = "";
		showing = false;
		taskId = Scheduler.addTimeTask(refresh, rate, rate);
	}

	public function setRefreshRate(rate:Float){
		Scheduler.removeTimeTask(taskId);
		Scheduler.addTimeTask(refresh, rate, rate);
	}


	function str(obj:Dynamic):Dynamic{
		var str = '$obj';
		str = str.replace("\n", "").replace("\t", "");
		var fw = Khonsole.font.width.bind(Khonsole.fontSize, _);
		if (fw(str) > bounds.w){
			var words = str.split(" ");
			var w:Float = 0;
			var lines = [];
			var line = "";
			for (word in words){
				word += " ";
				if (w + fw(word) > bounds.w){
					lines.push(line);
					line = "";
					w = fw(word);
				} else {
					w += fw(word);
					line += word;
				}
			}
			if (line != "")
				lines.push(line);
			return lines;
		}
		return str;
	}

	function refresh(){
		watches = watches.map(function(watch){
			if (watch.type == FIELD)
				return {name: watch.name, object: watch.object, value: str(Reflect.field(watch.object, watch.name)), type: FIELD};
			else if (watch.type == PROPERTY)
				return {name: watch.name, object: watch.object, value: str(Reflect.getProperty(watch.object, watch.name)), type: PROPERTY};
			return {name: watch.name, object: watch.object, type: FIELD, value: "ERROR"};
		});
	}

	public function watch(name:String, value:Dynamic){
		showing = true;
		if (Reflect.hasField(value, name)){
			watches.push({name: name, object: value, value: str(Reflect.field(value, name)), type: WatchType.FIELD});
		} else {
			var prop = Reflect.getProperty(value, name);
			if (prop != null)
				watches.push({name: name, object: value, value: str(prop), type: WatchType.PROPERTY});
			else
				throw "Watched object doesn't exist";
		}
	}

	function makeHeading(g:kha.graphics2.Graphics){
		var eq = Std.int((bounds.w - g.font.width(Khonsole.fontSize, "WATCHES") / g.font.width(Khonsole.fontSize, "=")) / 2 / g.font.width(Khonsole.fontSize, "=")) - 1;
		heading = "WATCHES";
		for (i in 0...eq){
			heading = '=$heading=';
		}
	}

	function drawMultiline(g:kha.graphics2.Graphics, val:Array<String>, i:Int){
		for (line in val){
			g.drawString(line, bounds.x, bounds.y + i * g.fontSize);
			i++;
		}
	}

	public function resize(w:Int, h:Int){
		if (Khonsole.profiler.showing){
			bounds.w = Std.int(w / 2);
		} else {
			bounds.w = w;
		}
		bounds.h = Std.int(h / 2);
		heading = "";
		refresh();
	}

	public function render(g:kha.graphics2.Graphics){
		if (!showing)
			return;
		g.color = 0xffcccccc;
		g.opacity = Khonsole.opacity;
		g.fillRect(bounds.x, bounds.y, bounds.w, bounds.h);
		g.opacity = 1;
		g.color = 0xff000000;
		if (heading == "")
			makeHeading(g);
		g.drawString(heading, bounds.x, bounds.y);
		var i = 1;
		for (watch in watches){
			if (Std.is(watch.value, String)){
				g.drawString('${watch.name}: ${watch.value}', bounds.x, bounds.y + i*g.fontSize);
				i++;
			}
			else {
				g.drawString('${watch.name}: ', bounds.x, bounds.y + i * g.fontSize);
				i++;
				drawMultiline(g, cast watch.value, i);
			}
		}
	}

}

typedef WatchObj = {
	public var name:String;
	public var value:Dynamic;
	public var object:Dynamic;
	public var type:WatchType;
}

enum WatchType{
	PROPERTY;
	FIELD;
}