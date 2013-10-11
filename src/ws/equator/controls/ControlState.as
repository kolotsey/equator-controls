package ws.equator.controls{
	
	public final class ControlState{
		public static const ENABLED:int=(1<<0);
		public static const SELECTED:int=(1<<1);
		public static const OVER:int=(1<<2);
		public static const DOWN:int=(1<<3);
		
		
		public static function toString( state:int):String{
			var ret:String="";
			if( state & ControlState.ENABLED){
				ret="ENABLED";
			}
			if( state & ControlState.OVER){
				if( ret.length) ret+=", ";
				ret+="OVER";
			}
			if( state & ControlState.DOWN){
				if( ret.length) ret+=", ";
				ret+="DOWN";
			}
			return ret;
		}
		public static function create( enabled:Boolean=true, selected:Boolean=false, over:Boolean=false, down:Boolean=false):int{
			var ret:uint=0;
			if( enabled){
				ret |= ENABLED;
				if( over) ret |= OVER;
				if( down) ret |= DOWN;
			}
			if(selected) ret|= SELECTED;
			return ret;
		}
	}
}