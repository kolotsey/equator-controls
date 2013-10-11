package ws.equator.controls{
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.DisplayObject;

	/**
	 * @author kolotsey
	 */
	public class TabControl extends BasicContainer{
		
		private var verticalBox:VerticalBox;
		private var tabStack:HorizontalBox;
		private var swapBox:SwapBox;
		private var bg:Sprite;
		private var _innerPadding:int=0;
		
		
		public function set innerPadding( value:int):void{
			if( _innerPadding !=value){
				_innerPadding=value;
				swapBox.padding=value;
				invalidate_recursive();
			}
		}
		
		public function get innerPadding():int{
			return _innerPadding;
		}
		
		override public function set behaviourX(param:int):void{
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
				verticalBox.behaviourX=tabStack.behaviourX=swapBox.behaviourX=_behaviourx;
				invalidate();
			}
		}
		override public function set behaviourY(param:int):void{
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
				verticalBox.behaviourY=swapBox.behaviourY=_behavioury;
				invalidate();
			}
		}
		override public function set behaviour( param:int):void{
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
				verticalBox.behaviourX=tabStack.behaviourX=swapBox.behaviourX=verticalBox.behaviourY=swapBox.behaviourY=_behaviourx;
				invalidate();
			}
		}
		
		
		public function set selectedIndex( param:*):void{
			var id:int=-1;
			
			if(param is DisplayObject){
				id=swapBox.getChildIndex( param);
			}else{
				if( !isNaN(Number( param)) && int(param)<swapBox.numChildren && int(param)>=0){
					id=int( param);
				}
			}
			if( -1 != id){
				var button:TabButton;
				if( swapBox.selectedIndex !=-1){
					button=tabStack.getChildAt( swapBox.selectedIndex) as TabButton;
					button.selected=false;
				}
				button=tabStack.getChildAt( id) as TabButton;
				button.selected=true;
				swapBox.selectedIndex=id;
			};
		}
		
		public function get selectedIndex():int{
			return swapBox.selectedIndex;
		}
		
		internal function getTabbuttonAt( id:int):TabButton{
			if( id<tabStack.numChildren && id>=0){
				return tabStack.getChildAt( id) as TabButton;
			}else{
				return null;
			}
		}
		
		internal function getTabAt( id:int):DisplayObject{
			if( id<swapBox.numChildren && id>=0){
				return swapBox.getChildAt( id);
			}else{
				return null;
			}
		}
		
		private function tabChanged(ev:Event):void{
			var button:TabButton=ev.target as TabButton;
			var i:int;
			
			for( i=0; i<tabStack.numChildren; i++){
				if( button==tabStack.getChildAt( i)){
					swapBox.selectedIndex=i;
				}else{
					(tabStack.getChildAt( i) as TabButton).selected=false;
				}
			}
		}
		
		public function addTab( child:DisplayObject, caption:String=null):void{
			var button:TabButton=new TabButton();
			
			button.toggle=true;
			if( child is Panel){
				var panel:Panel=child as Panel;
				button.caption=panel.caption;
				panel.attach( this);
			}else{
				button.caption=(caption==null? ("Tab "+swapBox.numChildren+1): caption);
			}
			if( swapBox.numChildren==0){
				button.selected=true;
			}
			button.addEventListener( Event.CHANGE, tabChanged);
			tabStack.addChild( button);
			swapBox.addChild( child);
		}
		
		public function removeTabAt( id:int):void{
			//var button:TabButton=new TabButton();
			(tabStack.getChildAt(id) as Control).remove();
			(swapBox.getChildAt(id) as Control).remove();
			
			//button.toggle=true;
			//if( child is Panel){
				//var panel:Panel=child as Panel;
				//button.caption=panel.caption;
				//panel.attach( this);
			//}else{
				//button.caption=(caption==null? ("Tab "+swapBox.numChildren+1): caption);
			//}
			//if( swapBox.numChildren==0){
				//button.selected=true;
			//}
			//button.addEventListener( Event.CHANGE, tabChanged);
			//tabStack.addChild( button);
			//swapBox.addChild( child);
		}		
		
		public function get length():int{
			return swapBox.numChildren;
		}
		
		
		override internal function sizeRequest():Point{
			var w:int=0;
			var h:int=0;
			var p:Point;
			
			p=verticalBox.sizeRequest();
			w=(_behaviourx==ControlBehaviour.FIXED? __width  : p.x);
			h=(_behavioury==ControlBehaviour.FIXED? __height : p.y);
			
			return new Point( w, h);
		}
		
		private function positionChild( child:VerticalBox, x:int, y:int, w:int, h:int):void{
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
			var p:Point;
	
			super.refresh_control( event, recursive);
			
			p=sizeRequest();
			if(_behaviourx==ControlBehaviour.AUTO){
				__width=p.x; 
			}
			if(_behavioury==ControlBehaviour.AUTO){
				__height=p.y;
			}
			
			if( _behaviourx==ControlBehaviour.STRETCH){
				verticalBox.width=__width;
			}
			if( _behavioury==ControlBehaviour.STRETCH){
				verticalBox.height=__height;
			}
			positionChild( verticalBox, 0, 0, __width, __height);
			
			if( bg !=null){
				bg.x=0;
				bg.y=tabStack.height-1;
				bg.width=__width;
				bg.height=swapBox.height+1;
			}
		}
		
		
		public function TabControl(){
			super();
			
			bg=controlStyle.tabPanel();
			if( bg !=null){
				addChild( bg);
			}
			
			verticalBox=new VerticalBox();
			addChild(verticalBox);
			
			tabStack=new HorizontalBox();
			verticalBox.addChild( tabStack);
			
			swapBox=new SwapBox();
			swapBox.resizeMethod=SwapBox.RESIZE_TO_MAX_CHILD;
			verticalBox.addChild( swapBox);
			
		}
		
		override public function remove():void{
			var panel:Panel;
			var button:TabButton; 
			var control:DisplayObject;
			
			remove_from_stage();
			
			while( swapBox.numChildren){
				control=swapBox.removeChildAt(0);
				if( control is Panel){
					panel=control as Panel;
					panel.detach();
					panel.remove();
				}else if( control is Control){
					(control as Control).remove();
				}
			}
			verticalBox.removeChild( swapBox);
			swapBox.remove();
			swapBox=null;
				
			while( tabStack.numChildren){
				button=(tabStack.removeChildAt(0) as TabButton);
				button.removeEventListener( Event.CHANGE, tabChanged);
				button.remove();
			}
			verticalBox.removeChild( tabStack);
			tabStack.remove();
			tabStack=null;
			
			removeChild( verticalBox);
			verticalBox=null;
			if( bg !=null){
				removeChild( bg);
				bg=null;
			}
			
			super.remove();
		}
	}
}
