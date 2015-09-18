package platformer.pxlSq;

import flambe.Entity;

#if flash
import flash.external.ExternalInterface;
#end

/**
 * ...
 * @author Anthony Ganzon
 * Console logger for debugging purposes.
 * NOTE: Works only with flash build
 */
class Utils
{
	public static function ConsoleLog(str: Dynamic): Void {
		#if debug
			#if flash
			ExternalInterface.call("console.log", str);
			#elseif html
			trace(str);
			#end
		#end
	}
	
	public static function ToMMSS(ms: Float): String {		
		var sec: Int = Std.int((ms % 3600) % 60);
		var secStr: String = (sec < 10) ? "0" + sec : "" + sec;
		
		var min = Std.int((ms % 3600) / 60);
		var minStr: String = (min < 10) ? "0" + min : "" + min;
		
		//var hr = Std.int(ms / 3600);
		//var hrStr: String = (hr < 10) ? "0" + hr : "" + hr;
		
		return minStr + ":" + secStr;
	}
}
