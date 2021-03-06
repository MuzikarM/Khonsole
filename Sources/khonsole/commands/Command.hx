package khonsole.commands;

class Command{

	var id:String;
	var usage:String;
	var action:Array<String>->Status;

	public function new(id:String, action:Array<String>->Status, ?usage:String){
		this.id = id;
		this.action = action;
		this.usage = usage;
	}

	public function invoke(params:Array<String>){
		return action(params);
	}

	public function getUsage():String{
		return usage;
	}

	function success(?output:String):Status{
		if (output == null)
			return {
				success: true,
			};
		return {
			success: true,
			output: output
		}
	}

	function fail(?output:String):Status{
		if (output == null)
			return {
				success: false,
			}
		return {
			success: false,
			output: output
		}
	}
}
