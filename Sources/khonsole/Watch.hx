package khonsole;

import kha.Scheduler;

using StringTools;

class Watch extends Window{

	public var watches(default, null):Array<WatchObj>;
	var taskId:Int;

	public function new(x:Int, y:Int, w:Int, h:Int, rate:Float = 1){
		watches = new Array<WatchObj>();
		heading = "WATCHES";		
		initBounds(x,y,w,h);
		showing = false;
		taskId = Scheduler.addTimeTask(refresh, rate, rate);
		this.onResize = _resize;
		addCloseButton();
		addButton(new Button(0.95, 0, "Pause", _pause, 0xffbb0000));
		#if (!flash && !js)
		addButton(new Button(0.85, 0, "Save", _save, 0xff0000bb));
		#end
	}

	public function setRefreshRate(){
		Scheduler.removeTimeTask(taskId);
		taskId = Scheduler.addTimeTask(refresh, rate, rate);
	}

	public function changeRefreshRate(rate:Float){
		this.rate = rate;
		setRefreshRate();
	}

	function _scroll(i){
		if (totalLines < maxLines)
			return;
		index += i;
		if (index < 0)
			index = 0;
		if (index > totalLines - maxLines)
			index = totalLines - maxLines;
	}

	function _pause(id){
		if (taskId != -1){
			activeButton.text = "Resume";
			activeButton.color = 0xff00bb00;
			Scheduler.removeTimeTask(taskId);
			taskId = -1;
		} else {
			activeButton.text = "Pause";
			activeButton.color= 0xffbb0000;
			setRefreshRate();
		}
		return true;
	}

	function _save(id){
		Khonsole.interpreter.interpret("!dump watches");
		return true;
	}


	function str(obj:Dynamic):Dynamic{
		var str = '$obj';
		str = str.replace("\n", "").replace("\t", "");
		var fw = Khonsole.font.width.bind(Khonsole.fontSize, _);
		if (fw(str) > bounds.w){
			var words = str.split(" ");
			var w:Float = 0;
			var lines = [];
			var line = "  ";
			for (word in words){
				word += " ";
				if (w + fw(word) > bounds.w - 20){
					lines.push(line);
					line = "  ";
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
			return switch(watch.type){ 
				case(FIELD):
					{name: watch.name, object: watch.object, value: str(Reflect.field(watch.object, watch.name)), type: FIELD};
				case(PROPERTY):
					{name: watch.name, object: watch.object, value: str(Reflect.getProperty(watch.object, watch.name)), type: PROPERTY};
				case(ARRAY(i)):
					{name: watch.name, object: watch.object, value: str(Reflect.getProperty(watch.object, watch.name)[i]), type: ARRAY(i)};
				case(MAP(id, h)):
					{name: watch.name, object: watch.object, value: str(Reflect.getProperty(h, id)), type: MAP(id, h)};
				default:
					{name: watch.name, object: watch.object, type: FIELD, value: "ERROR"};
			}
		});
	}

	public function watch(name:String, value:Dynamic){
		showing = true;
		if (name.endsWith("]")){
			var i = name.indexOf("[");
			var n = name.substr(0, i);
			var ind:Any = name.substr(i);
			ind = ind.replace("[", "").replace("]", "");
			if (ind.endsWith('"'))
				ind = ind.replace('"', "");
			else 
				ind = Std.parseInt(ind);
			var prop = Reflect.getProperty(value, n);
			if (prop != null){
				if (Std.is(ind, Int)){
					watches.push({name: n, object: value, value: str(prop[cast ind]), type: WatchType.ARRAY(cast ind)});
				} else if (Std.is(ind, String)){
					var h = Reflect.getProperty(prop, "h");
					if (h != null){
						var val = Reflect.getProperty(h, ind);
						watches.push({name: n, object: value, value: str(val), type: MAP(ind, h)});
					}
					else
						throw "Something went wrong";
				}
			} else throw "Watched object doesn't exist";
		} else if (Reflect.hasField(value, name)){
			watches.push({name: name, object: value, value: str(Reflect.field(value, name)), type: WatchType.FIELD});
		} else {
			var prop = Reflect.getProperty(value, name);
			if (prop != null)
				watches.push({name: name, object: value, value: str(prop), type: WatchType.PROPERTY});
			else{
				var h = Reflect.getProperty(value, "h");
				if (h != null){
					watches.push({name: name, object: h, value: str(Reflect.getProperty(h, name)), type: PROPERTY});
				} else throw "Watched object doesn't exist";
			}
		}
	}

	function drawMultiline(g:kha.graphics2.Graphics, val:Array<String>, i:Int):Int{
		for (line in val){
			g.drawString(line, bounds.x, bounds.y + i * g.fontSize);
			i++;
		}
		return i;
	}

	public function _resize(w:Int, h:Int){
		if (Khonsole.profiler.showing){
			bounds.w = Std.int(w / 2);
		} else {
			bounds.w = w;
		}
		bounds.h = Std.int(h / 2);
		refresh();
	}

	public function render(g:kha.graphics2.Graphics){
		if (!showing)
			return;
		prepareWindow(g);
		g.opacity = 1;
		g.color = 0xff000000;
		var i = 1;
		for (watch in watches){
			var name = '${watch.name}';
			switch(watch.type){
				case(ARRAY(i)):
					name += '[$i]';
				case(MAP(id,_)):
					name += '["$id"]';
				default:
			}
			if (Std.is(watch.value, String)){
				g.drawString('${name}: ${watch.value}', bounds.x, bounds.y + i*g.fontSize);
				i++;
			}
			else {
				g.drawString('${name}: ', bounds.x, bounds.y + i * g.fontSize);
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
	ARRAY(i:Int);
	MAP(str:String, getFn:Dynamic);
}