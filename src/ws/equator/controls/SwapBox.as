

package ws.equator.controls{

	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	public class SwapBox extends BasicBox {
		static public const RESIZE_TO_MIN_POSSIBLE:int=1;
		static public const RESIZE_TO_MAX_CHILD:int=2;
		
		private var visible_child:int=0;
		private var resize_method:int=RESIZE_TO_MIN_POSSIBLE;
		
		public function get resizeMethod():int{
			return resize_method; 
		}
		
		public function set resizeMethod( param:int):void{
			if( param !=resize_method){
				switch( param){
					case RESIZE_TO_MAX_CHILD:
					case RESIZE_TO_MIN_POSSIBLE:
						resize_method=param;
						break;
					default:
						resize_method=RESIZE_TO_MIN_POSSIBLE;
						break;
				}
				invalidate_recursive();
			}
		}
		
		override internal function sizeRequest():Point{
			var p:Point;
			var w:int, h:int;
			
			if( resize_method==RESIZE_TO_MIN_POSSIBLE){
				if( numChildren && visible_child<numChildren){
					var child:DisplayObject;
					child=getChildAt( visible_child);
					if( child is Control){
						p=(child as Control).sizeRequest();
					}else{
						p=new Point( child.width, child.height);
					}
					w=_behaviourx==ControlBehaviour.FIXED? __width  : p.x+paddingLeft+paddingRight; 
					h=_behavioury==ControlBehaviour.FIXED? __height : p.y+paddingTop+paddingBottom;
				}else{
					w=paddingLeft+paddingRight;
					h=paddingTop+paddingBottom;
				}
				
				
			}else{
				var i:int;
				w=h=0;
				for( i=0; i<numChildren; i++){
					child=getChildAt( i);
					if( child is Control){
						p=(child as Control).sizeRequest();
					}else{
						p=new Point( child.width, child.height);
					}
					w=Math.max( w, p.x);
					h=Math.max( h, p.y);
				}
				w=_behaviourx==ControlBehaviour.FIXED? __width  : w+paddingLeft+paddingRight; 
				h=_behavioury==ControlBehaviour.FIXED? __height : h+paddingTop+paddingBottom;
			}
			 
			return new Point( w, h);
		}
		
		
			
		public function set selectedIndex( param:*):void{
			var id:int=-1;
			
			if(param is DisplayObject){
				id=getChildIndex( param);
			}else{
				if( !isNaN(Number( param)) && int(param)<numChildren && int(param)>=0){
					id=int( param);
				}
			}
			if( -1 != id){
				visible_child=id;
				invalidate_recursive();
			};
		}
		
		public function get selectedIndex():uint{
			return visible_child;
		}
		
		override protected function refresh_control(event:Event=null, recursive:Boolean=false):void{
			var i:int;
			var p:Point;
	
			super.refresh_control( event, recursive);
			
			p=sizeRequest();
			if(_behaviourx==ControlBehaviour.AUTO){
				__width=p.x; 
			}
			if(_behavioury==ControlBehaviour.AUTO){
				__height=p.y;
			}
			if( numChildren){
				for(i=0; i<numChildren; i++){
					if( i==visible_child){ 
						getChildAt( i).visible=true;
						
					}else{
						getChildAt( i).visible=false;
					}
				}
			}
		}
		
		
		public function SwapBox() {
			super();
		}
	}
}