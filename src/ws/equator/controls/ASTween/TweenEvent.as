package ws.equator.controls.ASTween{
	import flash.events.Event;
	
	public class TweenEvent extends Event{
		public static const ITERATE:String="Iterate";
		public static const STOP:String="Stop";
		
		public var ratio:Number=0;
		
		public function TweenEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false){
			 super( type, bubbles, cancelable);
		}
	}
}
