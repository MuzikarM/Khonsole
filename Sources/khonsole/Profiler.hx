package khonsole;


class Profiler{

	public var profiles(default, null):Map<String, Profile>;
	var bounds:Bounds;
	var heading:String;
	var columnWidth:Float;

	public function new(x:Int, y:Int, w:Int, h:Int){
		profiles = new Map<String, Profile>();
		bounds = {
			x:x,
			y:y,
			w:w,
			h:h
		};
		columnWidth = w / 4;
		heading = "";
	}

	public function startProfile(name:String){
		if (!profiles.exists(name)){
			profiles.set(name, {
				name: name,
				calls: 0,
				totalTime: 0,
				lastTime: 0,
				lastStartTime: haxe.Timer.stamp()
			});
		} else {
			var prof = profiles.get(name);
			profiles.set(name, {
				name: name,
				calls: prof.calls,
				totalTime: prof.totalTime,
				lastTime: prof.lastTime,
				lastStartTime: haxe.Timer.stamp()
			});
		}
	}

	public function endProfile(name:String){
		if (!profiles.exists(name)){
			throw '$name does not exist, you need to start profile before ending it';
		}
		var prof = profiles.get(name);
		var delta = haxe.Timer.stamp() - prof.lastStartTime;
		profiles.set(name, {
			name: name,
			calls: prof.calls+1,
			lastTime: delta,
			totalTime: prof.totalTime + delta,
			lastStartTime: prof.lastStartTime
		});
	}

	function r(number:Float): Float
	{
		number *= Math.pow(10, 5);
		return Math.round(number) / Math.pow(10, 5);
	}

	function makeHeading(g:kha.graphics2.Graphics){
		var eq = Std.int((bounds.w - g.font.width(Khonsole.fontSize, "PROFILES") / g.font.width(Khonsole.fontSize, "=")) / 2 / g.font.width(Khonsole.fontSize, "="));
		trace(eq);
		heading = "PROFILES";
		for (i in 0...eq){
			heading = '=$heading=';
		}
	}

	function drawColumns(g:kha.graphics2.Graphics, row: Int, contents:Array<String>){
		var x:Float = bounds.x;
		var y = bounds.y + row * g.fontSize;
		for (z in contents){
			g.drawString(z, x, y);
			x+=columnWidth;
		}
	}

	function drawProfile(g:kha.graphics2.Graphics, row: Int, prof:Profile){
		drawColumns(g, row, [
			prof.name,
			'${r(prof.lastTime)}',
			'${prof.calls}',
			'${r(prof.totalTime/prof.calls)}'
			]);
	}

	public function render(g:kha.graphics2.Graphics){
		g.color = 0xffcccccc;
		g.opacity = Khonsole.opacity;
		g.fillRect(bounds.x, bounds.y, bounds.w, bounds.h);
		g.opacity = 1;
		g.color = 0xff000000;
		if (heading == ""){
			makeHeading(g);
		}
		g.drawString(heading, bounds.x, bounds.y);
		drawColumns(g, 1, ["name", "last time", "calls", "avg"]);
		var i = 2;
		for (profile in profiles){
			drawProfile(g, i, profile);
			i++;
		}
	}

}

typedef Profile = {
	public var name:String;
	public var calls:Int;
	public var lastStartTime:Float;
	public var lastTime:Float;
	public var totalTime:Float;
}