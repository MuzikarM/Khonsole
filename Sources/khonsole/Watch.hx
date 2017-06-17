package khonsole;

import kha.Scheduler;

class Watch{

	var watches:Array<WatchObj>;
	var bounds:Bounds;
	var taskId:Int;

	public function new(x:Int, y:Int, w:Int, h:Int, rate:Float = 1){
		watches = new Array<WatchObj>();
		bounds = {
			x:x,
			y:y,
			w:w,
			h:h
		};
		taskId = Scheduler.addTimeTask(refresh, rate, rate);
	}

	public function setRefreshRate(rate:Float){
		Scheduler.removeTimeTask(taskId);
		Scheduler.addTimeTask(refresh, rate, rate);
	}

	function refresh(){
		watches = watches.map(function(watch){
			if (watch.type == FIELD)
				return {name: watch.name, object: watch.object, value: Reflect.field(watch.object, watch.name), type: FIELD};
			else if (watch.type == PROPERTY)
				return {name: watch.name, object: watch.object, value: Reflect.getProperty(watch.object, watch.name), type: PROPERTY};
			return {name: watch.name, object: watch.object, type: FIELD, value: "ERROR"};
		});
	}

	public function watch(name:String, value:Dynamic){
		if (Reflect.hasField(value, name)){
			watches.push({name: name, object: value, value: Reflect.field(value, name), type: WatchType.FIELD});
		} else {
			var prop = Reflect.getProperty(value, name);
			if (prop != null)
				watches.push({name: name, object: value, value: Reflect.getProperty(value, name), type: WatchType.PROPERTY});
			else
				throw "Watched object doesn't exist";
		}
		trace(watches);
	}

	public function render(g:kha.graphics2.Graphics){
		g.color = 0xffcccccc;
		g.opacity = Khonsole.opacity;
		g.fillRect(bounds.x, bounds.y, bounds.w, bounds.h);
		g.opacity = 1;
		g.color = 0xff000000;
		var i = 0;
		for (watch in watches){
			g.drawString('${watch.name}: ${watch.value}', bounds.x, bounds.y + i*g.fontSize);
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