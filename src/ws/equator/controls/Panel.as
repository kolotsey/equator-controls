package ws.equator.controls{
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.display.Sprite;

	/**
	 * @author kolotsey
	 */
	public class Panel extends BasicContainer{
		private var _caption:String=controlName();
		private var tabControl:TabControl=null;
		private var bg:Sprite;
		
		public function set caption(param:String):void{ 
			if( _caption !=param){
				_caption=param;
				if(tabControl){
					var button:TabButton=tabControl.getTabbuttonAt( parent.getChildIndex( this));
					button.caption=_caption;
					invalidate_recursive();
				}
			}
		}
		
		public function get caption():String{
			return _caption;
		}
		
		internal function attach( param:TabControl):void{
			tabControl=param;
			removeChild( bg);
			bg=null;
		}
		
		internal function detach():void{
			tabControl=null;
			bg=controlStyle.panel();
			addChildAt( bg, 0);
		}
		
		override internal function sizeRequest():Point{
			var w:int=0;
			var h:int=0;
			var i:int;
			var p:Point;
			var child:DisplayObject;
			
			if(numChildren==0){
				w=(_behaviourx==ControlBehaviour.FIXED? __width  : 0);
				h=(_behavioury==ControlBehaviour.FIXED? __height : 0);
				
			}else{
				w=h=0;
				for(i=0; i<numChildren; i++){
					child=getChildAt( i);
					if( child is Control){
						p=(child as Control).sizeRequest();
						w=Math.max(w, p.x);
						h=Math.max(h, p.y);
					}else{
						if( child !=bg){
							w=Math.max(w, child.width);
							h=Math.max(h, child.height);
						}
					}
				}
				w=(_behaviourx==ControlBehaviour.FIXED? __width  : w);
				h=(_behavioury==ControlBehaviour.FIXED? __height : h);
				
			}
			return new Point( w, h);
		}
		
		private function positionChild( child:Control, x:int, y:int, w:int, h:int):void{
			var child_x:int;
			var child_y:int;
			
			if( ((child.align & ControlAlign.LEFT) && (child.align & ControlAlign.RIGHT)) ||
			        (( !(child.align & ControlAlign.LEFT)) && ( !(child.align & ControlAlign.RIGHT))) ){
				//position in the center
				child_x=x+(w-child.width)/2;
			}else if(child.align & ControlAlign.RIGHT){
				child_x=x+w-child.width;
			}else{
				child_x=x;
			}
			if( ((child.align & ControlAlign.TOP) && (child.align & ControlAlign.BOTTOM)) ||
			        (( !(child.align & ControlAlign.TOP)) && ( !(child.align & ControlAlign.BOTTOM))) ){
				//position in the center
				child_y=y+(h-child.height)/2;
			}else if(child.align & ControlAlign.BOTTOM){
				child_y=y+h-child.height;
			}else{
				child_y=y;
			}
			child.move( child_x, child_y);
		}
		
		override protected function refresh_control(event:Event=null, recursive:Boolean=false):void{
			var i:int;
			var p:Point;
			var child:DisplayObject;
	
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
					child=getChildAt( i);
					if( child is Control){
						if( (child as Control).behaviourX==ControlBehaviour.STRETCH){
							child.width=__width;
						}
						if( (child as Control).behaviourY==ControlBehaviour.STRETCH){
							child.height=__height;
						}
						positionChild( child as Control, 0, 0, __width, __height);
						
					}else{
						child.x=0;
						child.y=0;
					}
				}
			}
			if( bg !=null){
				bg .width=__width;
				bg.height=__height;
			}
		}
		
		public function Panel(){
			super();
			mouseEnabled=false;
			mouseChildren=true;
			tabEnabled=false;
			tabChildren=true;
			
			bg=controlStyle.panel();
			addChildAt( bg, 0);
		}
		
		override public function remove():void{
			if( bg !=null){
				removeChild( bg);
				bg=null;
			}
			super.remove();
		}
	}
}
