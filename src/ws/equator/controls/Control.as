package ws.equator.controls{
	import flash.events.Event;
	import flash.geom.Point;
	import ws.equator.controls.ControlStyles.Flash;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.system.Capabilities;
	import flash.utils.getQualifiedClassName;
	
	public class Control extends Sprite{
		
		protected var __x:int=0;
		protected var __y:int=0;
		protected var __width:int=0;
		protected var __height:int=0;
		protected var _enabled:Boolean=true;
		protected var _align:int=ControlAlign.TOP |ControlAlign.LEFT;
		protected var _behaviourx:int=ControlBehaviour.AUTO;
		protected var _behavioury:int=ControlBehaviour.AUTO;
		
		public static var debugByDefault:Boolean=false;
		public var debug:Boolean=debugByDefault; 
		 
		protected static var defaultControlStyleClass:Class=nativeControlStyle();
		protected var controlStyle:ControlStyle=new defaultControlStyleClass();
		 
		
		static public function nativeControlStyle():Class{
			if (Capabilities.os.toLowerCase().indexOf("win") !=-1){
				return Flash;
			}else if (Capabilities.os.toLowerCase().indexOf("lin") !=-1){
				return Flash;
			}else if (Capabilities.os.toLowerCase().indexOf("mac") !=-1){
				return Flash;
			}else{
				return Flash;
			}
		}
		
		protected static function resolveName( o:DisplayObject):String{
			if( o==null){
				return "null";
				
			}else{
				var ret:String=o.name;
				while( o.parent !=o && o.parent !=null){
					if( o.parent.name==null){
						ret=o.parent+"."+ret;
					}else{
						ret=o.parent.name+"."+ret;
					}
					o=o.parent;
				}
				return ret;
			}
		}
		
		protected function controlName( resolveControlName:Boolean=false):String{
			var name:String=getQualifiedClassName(this);
			var p:int;
			if( -1 !=(p=name.lastIndexOf( ":"))){
				name=name.substr(p+1);
			}
			if( resolveControlName){
				return resolveName( this)+"("+name+")";
			}else{
				return name;
			}
		}
		
		override public function toString():String {
			return controlName( true);
		}
		
		protected static function html_prepare( html:String):String{
			var s:String;
			var idx:int,len:int, len1:int;
			var subst:Object={
				"\\n":"<br>",
				"[[":"<",
				"]]":">"
				};
			
			subst["\\n"]="<br>";
			subst["[["]="<";
			subst["]]"]=">";
			
			for( s in subst){
				idx=0;
				len=s.length;
				len1=(subst[s] as String).length;
				do{
					if( -1 !=(idx=html.indexOf( s, idx))){
						html=html.substr( 0, idx)+subst[s]+html.substr(idx+len);
						idx+=len1;
					}
				}while( -1 !=idx);
			}
			return html;
		}
		
		/* The functions that are responsible for size and position and look 
		 * of a control are described below
		 */
		
		override public function set x(param:Number):void{
			super.x=__x=Math.round(param);
		}
		override public function set y(param:Number):void{
			super.y=__y=Math.round(param);
		}
		override public function set width(param:Number):void{
			var w:int=Math.round(Math.max(param, 0));
			if( _behaviourx !=ControlBehaviour.AUTO && __width !=w){
				__width=w;
				invalidate(true);
			}
		}
		override public function get width():Number{
			return __width;
		}
		override public function set height(param:Number):void{
			var h:int=Math.round(Math.max(param, 0));
			if( _behavioury !=ControlBehaviour.AUTO && __height !=h){
				__height=h;
				invalidate(true);
			}
		}
		override public function get height():Number{
			return __height;
		}
		public function get enabled():Boolean{
			return _enabled;
		}
		protected function makeEnabled():void{}
		public function set enabled(param:Boolean):void{
			if(_enabled !=param){
				_enabled=param;
				makeEnabled();
				invalidate();
			}
		}
		
		public function set behaviourX(param:int):void{
			if(param !=_behaviourx){
				switch(param){
					case ControlBehaviour.AUTO:
					case ControlBehaviour.FIXED:
					case ControlBehaviour.STRETCH:
						_behaviourx=param;
						break;
					default:
						_behaviourx=ControlBehaviour.AUTO;
						break;
				}
				invalidate();
			}
		}
		public function set behaviourY(param:int):void{
			if(param !=_behavioury){
				switch(param){
					case ControlBehaviour.AUTO:
					case ControlBehaviour.FIXED:
					case ControlBehaviour.STRETCH:
						_behavioury=param;
						break;
					default:
						_behavioury=ControlBehaviour.AUTO;
						break;
				}
				invalidate();
			}
		}
		public function set behaviour( param:int):void{
			if( !(_behaviourx==param && _behavioury==param)){
				switch(param){
					case ControlBehaviour.AUTO:
					case ControlBehaviour.FIXED:
					case ControlBehaviour.STRETCH:
						_behaviourx=_behavioury=param;
						break;
					default:
						_behaviourx=_behavioury=ControlBehaviour.AUTO;
						break;
				}
				invalidate();
			}
		}
		public function get behaviourX():int{
			return _behaviourx;
		}
		public function get behaviourY():int{
			return _behavioury;
		}
		public function set align(param:int):void{
			if( _align !=param){
				_align=(param & (ControlAlign.TOP |ControlAlign.RIGHT |ControlAlign.BOTTOM |ControlAlign.LEFT));
				invalidate();
			}
		}
		public function get align():int{
			return _align;
		}
		internal function restyle():void{
			invalidate();
		}
		public function set style(param:ControlStyle):void{
			controlStyle=param;
			restyle();
		}
		public static function set defaultStyle(param:Class):void{
			Control.defaultControlStyleClass = param;
		}
		
		public function move( x:int, y:int):void{
			super.x=__x=Math.round(x);
			super.y=__y=Math.round(y);
		}
		
		public function setSize( wid:int, hei:int):void{
			wid=Math.max(wid, 0);
			hei=Math.max(hei, 0);
			var changed:Boolean=false;
			
			if( _behaviourx !=ControlBehaviour.AUTO && __width !=wid){
				__width=wid;
				changed=true;
			}
			if( _behavioury !=ControlBehaviour.AUTO && __height !=hei){
				__height=hei;
				changed=true;
			}
			if( changed){
				invalidate(true);
			}
		}
		
		
		/* The function invalidate() is called when the control's parameters such
		 * as size or look are changed
		 */
		
		internal function sizeRequest():Point{
			return new Point(  _behaviourx==ControlBehaviour.FIXED? __width  : 0, 
								_behavioury==ControlBehaviour.FIXED? __height : 0);
		}
		
		protected function refresh_control( event:Event=null, recursive:Boolean=false):void{
			//Debug.debug("Called by "+this.toString());
			removeEventListener(Event.ENTER_FRAME, refresh_control);
			if( recursive){
				var i:int;
				var child:DisplayObject;
				for( i=0; i<numChildren; i++){
					child=getChildAt( i);
					if( child is Control){
						(child as Control).refresh_control( event, recursive);
					}
				}
			}
			if( debug){
				trace((recursive? "recursively " : "")+"refresh "+this);
			}
		}
		
		internal function invalidate( update_now:Boolean=false):void{
			if(update_now==true){
				refresh_control( null);
			}else{
				if( !hasEventListener( Event.ENTER_FRAME)){
					addEventListener(Event.ENTER_FRAME, refresh_control);
				}
			}
		}
		
		internal function invalidate_recursive():void{
			if( parent && parent is Control){
				(parent as Control).invalidate_recursive();
			}else{
				refresh_control( null, true);
			}
		}
		
		
		
		
		
		
		/*
		 * Constructor
		 */
		
		public function updateLook( recursive:Boolean=false):void{
			refresh_control( null, recursive);
		}
		
		public function Control():void{
			makeEnabled();
			addEventListener(Event.ADDED_TO_STAGE, added_to_stage);
			addEventListener(Event.REMOVED_FROM_STAGE, removed_from_stage);
		}
		
		protected function added_to_stage( event:Event):void{
			invalidate( true);
		}
		
		protected function removed_from_stage( event:Event):void{
			removeEventListener(Event.ENTER_FRAME, refresh_control);
		}
		
		protected function remove_from_stage():void{
			if( parent !=null){
				parent.removeChild( this);
			}
		}
		
		public function remove():void{
			remove_from_stage();
			removeEventListener(Event.ENTER_FRAME, refresh_control);
			removeEventListener(Event.ADDED_TO_STAGE, added_to_stage);
			removeEventListener(Event.REMOVED_FROM_STAGE, removed_from_stage);
			controlStyle=null;
		}
	}
}



