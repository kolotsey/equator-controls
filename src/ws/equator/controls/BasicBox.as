package ws.equator.controls{

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class BasicBox extends BasicContainer{
		//position and size
		protected var _paddingTop:int=0;
		protected var _paddingRight:int=0;
		protected var _paddingBottom:int=0;
		protected var _paddingLeft:int=0;
		

		public function set paddingTop(param:int):void{
			if( _paddingTop !=param){
				_paddingTop=param;
				invalidate();
			}
		}
		public function get paddingTop():int{
			return _paddingTop;
		}
		public function set paddingRight(param:int):void{
			if(_paddingRight !=param){
				_paddingRight=param;
				invalidate();
			}
		}
		public function get paddingRight():int{
			return _paddingRight;
		}
		public function set paddingBottom(param:int):void{
			if(_paddingBottom !=param){
				_paddingBottom=param;
				invalidate();
			}
		}
		public function get paddingBottom():int{
			return _paddingBottom;
		}
		public function set paddingLeft(param:int):void{
			if(_paddingLeft !=param){
				_paddingLeft=param;
				invalidate();
			}
		}
		public function get paddingLeft():int{
			return _paddingLeft;
		}
		public function set padding(param:int):void{
			if( !(_paddingTop==param && _paddingRight==param && _paddingBottom==param && _paddingLeft==param)){
				_paddingTop=_paddingRight=_paddingBottom=_paddingLeft=param;
				invalidate();
			}
		}
		
		override internal function sizeRequest():Point{
			var w:int=0;
			var h:int=0;
			var i:int;
			var p:Point;
			var child:DisplayObject;
			
			if(numChildren==0){
				w=(_behaviourx==ControlBehaviour.FIXED? __width  : _paddingLeft+_paddingRight);
				h=(_behavioury==ControlBehaviour.FIXED? __height : _paddingTop+_paddingBottom);
				
			}else{
				w=h=0;
				for(i=0; i<numChildren; i++){
					child=getChildAt( i);
					if( child is Control){
						p=(child as Control).sizeRequest();
						w=Math.max(w, p.x);
						h=Math.max(h, p.y);
					}else{
						w=Math.max(w, child.width);
						h=Math.max(h, child.height);
					}
				}
				w=(_behaviourx==ControlBehaviour.FIXED? __width  : w+_paddingLeft+_paddingRight);
				h=(_behavioury==ControlBehaviour.FIXED? __height : h+_paddingTop+_paddingBottom);
				
			}
			return new Point( w, h);
		}
		
		private function positionChild( object:DisplayObject, x:int, y:int, w:int, h:int):void{
			if( object is Control){
				var child_x:int;
				var child_y:int;
				var child:Control=(object as Control);
				
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
				
			}else{
				//Position in the top-left corner
				object.x=x+Math.round((w-object.width)/2);
				object.y=y+Math.round((h-object.height)/2);
			}
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
							child.width=__width-_paddingLeft-_paddingRight;
						}
						if( (child as Control).behaviourY==ControlBehaviour.STRETCH){
							child.height=__height-_paddingTop-_paddingBottom;
						}
						positionChild( child as Control, _paddingLeft, _paddingTop, 
								__width-_paddingLeft-_paddingRight, __height-_paddingTop-_paddingBottom);
						
					}else{
						child.x=_paddingLeft;
						child.y=_paddingTop;
					}
				}
				
			}
			
			if(debug){
				var c:int=Math.round(Math.random()*0xffffff);	
				graphics.clear();
				graphics.lineStyle( 0, c, 0.7);
				graphics.beginFill( c, 0.2);
				graphics.drawRect( paddingLeft, paddingTop, __width-_paddingLeft-_paddingRight, __height-_paddingTop-_paddingBottom);
				graphics.endFill();
			}
		}
		
		
		public function BasicBox(){
			super(); 
		}
	}
}	
	

