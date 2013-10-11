﻿package ws.equator.controls{

	import ws.equator.controls.ASTween.TweenFunctions;
	import ws.equator.controls.ASTween.TweenEvent;
	import ws.equator.controls.ASTween.Tween;
  	import flash.display.SpreadMethod;
  	import flash.display.GradientType;
  	import flash.geom.Matrix;
  	import flash.utils.getTimer;
	import flash.text.TextFieldType;
	import flash.text.TextFieldAutoSize;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	public class Combobox extends InteractiveControl{

		public static const DROP_DOWN:String="DropDown";
		
		static private const DRAWER_MAX_ITEMS:int=7;
		static private const DRAWER_MAX_WIDTH:int=300;
		static private const COMBOBOX_MIN_WIDTH:int=50;
		
		//private fields
		private var textField:TextField=createTextField();
		private var drawerSprite:Sprite;
		private var container:Sprite;
		private var textSprite:Sprite;
		private var scrollbar:Scrollbar;
		private var textMask:Sprite; 
		private var containerMask:Shape;
		
		private var drawer_width:int=-1;
		
		private var drawer_opened:Boolean=false;
		private var overObject:DisplayObject=null;
		private var drawer_y:int=0;
		private var drawer_open_time:int=-1;
		private var drawer_ready:Boolean=false;
		private var drawer_max:int=0;
		private var drawer_min:int=0;
		private var new_selected_index:int=-1;
		private var last_selected_index:int=-1;
		
		
		//public fields
		private var _items:Array;
		private var _selected_index:int=-1;
		
		private var tween:Tween=null;
	
		
		
		static private function createTextField():TextField{
			var field:TextField;
			field=new TextField(); 
			field.autoSize=TextFieldAutoSize.NONE;
			field.background=false;
			field.border=false;
			field.selectable=false;
			field.type=TextFieldType.DYNAMIC;
			field.wordWrap=field.multiline=false;
			field.mouseWheelEnabled=false;
			field.embedFonts=false;
			field.mouseEnabled=false;
			field.tabEnabled=false;
			return field;
		}
		
		
		/************************
		 * Set/get
		 ************************/
		 
		public function get selectedIndex():int{
			return _selected_index;
		}
		public function set selectedIndex(param:int):void{
			if(_items.length && param >=0 && param <_items.length){
				_selected_index=param;
				if( !drawer_opened){
					textField.htmlText=_items[_selected_index]["caption"];
				}
			}
		}
		public function get selectedData():*{
			if( _items.length){
				return _items[_selected_index]["data"];
			}else{
				return null;
			}
		}
		public function set selectedData( param:*):void{
			var i:int;
			for(i=0; i<_items.length; i++){
				if( param==_items[i]["data"]){
					selectedIndex=i;
					break;
				}
			}
		}
		public function get items():Array{
			return _items;
		}
		public function get length():uint{
			return _items.length;
		}
		public function addItem(caption:String, data:Object=null):Object{
			var o:Object=new Object();
			var field:TextField=createTextField();
			
			o["caption"]=caption;
			o["data"]=data;
			o["field"]=field;
			
			field.htmlText=caption;
			field.setTextFormat( controlStyle.controlTextFormat( ControlState.create( true, false, false, false)));
			field.width=field.textWidth+4;
			field.height=field.textHeight+4;
			field.x=controlStyle.COMBOBOX_PADDING;
			textSprite.addChild( field);
			
			_items.push(o);
			if(_selected_index==-1){
				_selected_index=_items.length-1;
				textField.htmlText=caption;
			}
			invalidate_recursive();
			return o;
		}
		public function removeAll():void{
			var tf:Object;
			_selected_index=-1;
			while( _items.length){
				tf=_items.pop();
				textSprite.removeChild( tf["field"] as TextField);
			}
			textField.htmlText=" ";
			_items=new Array();
			invalidate();
		}
	
		override protected function makeEnabled():void{
			if(_enabled){
				tabEnabled = true;
				mouseEnabled=true;
				
				addEventListener( MouseEvent.ROLL_OVER, on_mouse_over);
				addEventListener( MouseEvent.ROLL_OUT, on_mouse_out);
				addEventListener( MouseEvent.MOUSE_DOWN, on_press);
				addEventListener( FocusEvent.FOCUS_IN, on_focus);
				addEventListener( FocusEvent.FOCUS_OUT, on_blur);
				addEventListener( KeyboardEvent.KEY_DOWN, on_key_down);
				addEventListener( MouseEvent.MOUSE_WHEEL, on_mouse_wheel);
				state=ControlState.create( true, false, false, false);
			
			}else{
				if(drawer_opened){
					close_drawer();
				}
				tabEnabled = false;
				mouseEnabled=false;
				
				removeEventListener( MouseEvent.ROLL_OVER, on_mouse_over);
				removeEventListener( MouseEvent.ROLL_OUT, on_mouse_out);
				removeEventListener( MouseEvent.MOUSE_DOWN, on_press);
				removeEventListener( FocusEvent.FOCUS_IN, on_focus);
				removeEventListener( FocusEvent.FOCUS_OUT, on_blur);
				removeEventListener( KeyboardEvent.KEY_DOWN, on_key_down);
				removeEventListener( MouseEvent.MOUSE_WHEEL, on_mouse_wheel);
				state=ControlState.create( false, false, false, false);
				if( stage && stage.focus==this){
					stage.focus=undefined;
				}
			}
			setVisibleSprite();
			if( textField !=null){
				textField.setTextFormat( controlStyle.controlTextFormat( state));
			}
		}
				
		private function open_drawer():void{
			var i:int;
			var ty:int;
			//var max, min;
			var o:Point;
			
			drawer_y=-_selected_index*__height;
	
			if(_items.length>(DRAWER_MAX_ITEMS+1)/2){
				drawer_max=-Math.round((DRAWER_MAX_ITEMS-1)*__height/2);
				o=globalToLocal( new Point(0, 0));
				if(o.y>drawer_max){
					drawer_max=Math.min(0, drawer_max+(Math.floor((o.y-drawer_max)/__height)+1)*__height);
				}else{
					o=globalToLocal( new Point(0, stage.stageHeight));
					if(o.y<drawer_max+__height*DRAWER_MAX_ITEMS){
						drawer_max=Math.max(__height-__height*DRAWER_MAX_ITEMS, drawer_max-(Math.floor((drawer_max+__height*DRAWER_MAX_ITEMS-o.y)/__height)+1)*__height);
					}
				}
				drawer_min=drawer_max+DRAWER_MAX_ITEMS*__height-__height*_items.length;
			
				if(_items.length>DRAWER_MAX_ITEMS){
					drawer_y=Math.min(drawer_y, drawer_max);
					drawer_y=Math.max(drawer_y, drawer_min);
					scrollbar.width=controlStyle.COMBOBOX_BUTTON_WIDTH+controlStyle.COMBOBOX_PADDING-controlStyle.COMBOBOX_BORDER_WIDTH;
					scrollbar.height=__height*DRAWER_MAX_ITEMS;
					scrollbar.x=__width-scrollbar.width;
					scrollbar.y=drawer_max;//-(DRAWER_MAX_ITEMS-1)*__height/2;
					scrollbar.max=_items.length*10;
					scrollbar.pos=(drawer_y-drawer_max)*scrollbar.max/(drawer_min-drawer_max);
					
					textMask.x=0;
					textMask.y=drawer_max;
					textMask.width=__width;
					textMask.height=DRAWER_MAX_ITEMS*__height;
					
					scrollbar.visible=true;
					
				}else{
					drawer_y=Math.max(drawer_y, drawer_max);
					drawer_y=Math.min(drawer_y, drawer_min);
					
					textMask.x=0;
					textMask.y=drawer_y;
					textMask.width=__width;
					textMask.height=_items.length*__height;
					
					scrollbar.visible=false;
				}
				
			}else{
				o=globalToLocal(new Point( 0, 0));
				if(o.y>drawer_y) {
					drawer_y=Math.min(0, drawer_y+(Math.floor((o.y-drawer_y)/__height)+1)*__height);
				}else{
					o=globalToLocal(new Point(0, stage.height));
					if(o.y<drawer_y+__height*_items.length){
						drawer_y=Math.max(__height-__height*_items.length, drawer_y-(Math.floor((drawer_y+__height*_items.length-o.y)/__height)+1)*__height);
					}
				}
				
				textMask.x=0;
				textMask.y=drawer_y;
				textMask.width=__width;
				textMask.height=_items.length*__height;

				scrollbar.visible=false;
			}
			
			ty=drawer_y+controlStyle.COMBOBOX_PADDING;
			for(i=0; i<_items.length; i++){
				(_items[i]["field"] as TextField).y=ty;
				ty+=__height;
			}
			new_selected_index=-1;
			last_selected_index=_selected_index;
			drawer_opened=true;
			drawer_ready=false;
			drawer_open_time=getTimer();
			
			(root as DisplayObjectContainer).addChild( container);
			(root as DisplayObjectContainer).addChild( containerMask);
			
			state |=ControlState.DOWN;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, on_mouse_move);
			dispatchEvent( new Event( DROP_DOWN));
			
			if( tween !=null){
				tween.stopAnimation();
			}
			tween=new Tween();
			tween.ease=TweenFunctions.cubicEaseIn;
			tween.duration=200;
			tween.addEventListener( TweenEvent.ITERATE, tweenIterate);
			tween.addEventListener( TweenEvent.STOP, tweenStop);
			tween.startAnimation();
		}
		
		private function tweenIterate( ev:TweenEvent):void{
			var matrix:Matrix, colors:Array, alphas:Array, ratios:Array;
			var y:int, y1:int;
			
			containerMask.graphics.clear();
			
			if(_items.length>DRAWER_MAX_ITEMS){
				y=drawer_max*ev.ratio;
				y1=__height+(drawer_max+DRAWER_MAX_ITEMS*__height-__height)*ev.ratio;
			}else{
				y=drawer_y*ev.ratio;
				y1=__height+(drawer_y+_items.length*__height-__height)*ev.ratio;
			}
			
			matrix=new Matrix();
			matrix.createGradientBox( __width, __height, Math.PI/2, 0, y-__height);
			colors=[0x000000, 0x000000];
			alphas=[0, 1];
			ratios=[0, 255];
			containerMask.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix, SpreadMethod.PAD);
			containerMask.graphics.drawRect( 0, y-__height, __width, __height);
			containerMask.graphics.endFill();
			
			containerMask.graphics.beginFill(0x000000, 1);
			containerMask.graphics.drawRect(0, y, __width, y1-y);
			containerMask.graphics.endFill();
			
			matrix=new Matrix();
			matrix.createGradientBox( __width, __height, Math.PI/2, 0, y1);
			colors=[0x000000, 0x000000];
			alphas=[1, 0];
			ratios=[0, 255];
			containerMask.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix, SpreadMethod.PAD);
			containerMask.graphics.drawRect( 0, y1, __width, __height);
			containerMask.graphics.endFill();
			
			var p:Point;
			if( _items.length>(DRAWER_MAX_ITEMS+1)/2){
				y=(-_selected_index*__height)-drawer_y;
				p=localToGlobal( new Point( 0, y*(1-ev.ratio)));
			}else{
				p=localToGlobal( new Point( 0, 0));
			}
			container.y=p.y;
		}
		
		private function tweenStop( ev:TweenEvent):void{
			tween=null;
		}
		
		private function close_drawer():void{

			var idx:int;
			var changed:Boolean=false;
			
			if( tween !=null){
				tween.stopAnimation();
			}
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, on_mouse_move);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, on_mouse_down);
			(root as DisplayObjectContainer).removeChild( container);
			(root as DisplayObjectContainer).removeChild( containerMask);
			if( -1==new_selected_index){
				idx=_selected_index;
			}else{
				if(new_selected_index !=_selected_index){
					changed=true;
				}
				idx=new_selected_index;
			}

			_selected_index = idx;
			textField.htmlText=_items[_selected_index]["caption"];
			
			drawer_opened=false;
			drawer_open_time=-1;
			
			state &= ~ControlState.DOWN;
			
			invalidate(true);
			setVisibleSprite();
			if(changed){
				dispatchEvent(new Event(Event.CHANGE));
			}else{
				dispatchEvent(new Event(Event.CANCEL));
			}
		}
	
		private function on_key_down(event:KeyboardEvent):void{
			var k:uint=event.keyCode;
			var old_selected_index:int=_selected_index;
			
			if(_selected_index !=-1 && _items.length>1 ){
				if(k==Keyboard.HOME){
					_selected_index=0;
				}else if(k==Keyboard.END){
					_selected_index=_items.length-1;
				}else if(k==Keyboard.UP && _selected_index>0){
					_selected_index--;
				}else if(k==Keyboard.DOWN && _selected_index<_items.length-1){
					_selected_index++;
				}else if(k==Keyboard.PAGE_DOWN){
					_selected_index=Math.min(_items.length-1, _selected_index+3);
				}else if(k==Keyboard.PAGE_UP){
					_selected_index=Math.max(0, _selected_index-3);
				}
				
				textField.htmlText=_items[_selected_index]["caption"];
			}
			if(old_selected_index !=_selected_index ){
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		private function scroll_change( event:Event):void{
			var ty:int;
			var i:int;
			
			drawer_y=scrollbar.pos*(drawer_min-drawer_max)/scrollbar.max+drawer_max;
			ty=drawer_y+controlStyle.COMBOBOX_PADDING;
			for(i=0; i<_items.length; i++){
				(_items[i]["field"] as TextField).y=ty;
				ty+=__height;
			}
			invalidate(true);
		}
		
		private function on_mouse_wheel( event:MouseEvent):void{ 
			var newy:int;
			var ty:int;
			var i:int;
			var delta:int=event.delta;
	
			if( drawer_opened && event.target==drawerSprite){
				if (_items.length>DRAWER_MAX_ITEMS){
					if(delta>0){
						newy=drawer_y+__height;
					}else{
						newy=drawer_y-__height;
					}
					drawer_y=Math.max(Math.min(newy, drawer_max), drawer_min);
					scrollbar.pos=(drawer_y-drawer_max)*scrollbar.max/(drawer_min-drawer_max);
					ty=drawer_y+controlStyle.COMBOBOX_PADDING;
					for(i=0; i<_items.length; i++){
						(_items[i]["field"] as TextField).y=ty;
						ty+=__height;
					}
					on_mouse_move( null);
				}
			}else if((!drawer_opened) && event.target==this){
				if(_selected_index !=-1 && _items.length>1 ){
					if( delta>0){
						delta=1;
					}else if( delta<0){
						delta=-1;
					}
					
					var index:int=_selected_index-delta;
					
					index=Math.max(0, Math.min(_items.length-1, index));
					if( index !=_selected_index){
						_selected_index=index;
						textField.htmlText=_items[_selected_index]["caption"];
						dispatchEvent(new Event(Event.CHANGE));
					}
				}
			}
		}
		
		private function on_mouse_over(event:Event):void{
			if( overObject==null && _items.length){
				overObject=event.target as DisplayObject;
				state |=ControlState.OVER;
			}
			setVisibleSprite(); 
		}
		
		private function on_mouse_out(event:Event):void{
			if( overObject !=null && (event.target as DisplayObject)==overObject){
				overObject=null;
				state &=~ControlState.OVER;
				new_selected_index=-1;
			}
			setVisibleSprite();
		}
		
		private function on_focus( event: Event): void{
			setVisibleSprite();
			textField.setTextFormat( controlStyle.controlTextFormat( state));
		}

		private function on_blur( event: Event): void{
			setVisibleSprite();
			textField.setTextFormat( controlStyle.controlTextFormat( state));
		}
		
		private function on_mouse_move(event:Event):void{
			var i:int;
			var selected_found:Boolean=false;
			var y:int;
			var over:Boolean;
			
			if(overObject !=null){
				over=mouseX<Math.max(drawer_width, __width-controlStyle.COMBOBOX_BUTTON_WIDTH);
				if( over){
					y=drawer_y;
					for(i=0; i<_items.length; i++){
						if(mouseY>=y && mouseY<y+__height){
							new_selected_index=last_selected_index=i;
							selected_found=true;
							break;
						}
						y+=__height;
					}
					if(selected_found !=true){
						new_selected_index=-1;
					}
				}else{
					new_selected_index=-1;
				}
				invalidate(true);
			}
		}
		
		private function on_press(event:Event):void{
			if( !drawer_opened){
				if(_items.length && stage!=null && root !=null){
					stage.addEventListener( MouseEvent.MOUSE_UP, on_release);
					open_drawer();
				}
				invalidate(true);
				setVisibleSprite();
			}
		}
		
		private function on_mouse_down( event:Event):void{
			if( event.target !=scrollbar){
				if(_items.length>DRAWER_MAX_ITEMS){
					if( !(mouseX>=scrollbar.x && mouseX<=scrollbar.x+scrollbar.width && mouseY>=scrollbar.y && mouseY<=scrollbar.y+scrollbar.height)){
						if( overObject ==null){
							close_drawer();
						}
					}
				}else{
					if( overObject==null){
						close_drawer();
					}
				}
			}
		}
		
		private function on_release(event:Event):void{
			if (event.target == this || event.target==overObject || event.target==scrollbar){
				// on_release
				stage.addEventListener( MouseEvent.MOUSE_DOWN, on_mouse_down);
				if(drawer_ready && event.target !=scrollbar){
					stage.removeEventListener( MouseEvent.MOUSE_UP, on_release);
					close_drawer();
				}else{
					if( -1!=new_selected_index && new_selected_index !=_selected_index ){
						stage.removeEventListener( MouseEvent.MOUSE_UP, on_release);
						close_drawer();
					}else{
						drawer_ready=true;
						invalidate(true);
						setVisibleSprite();
					}
				}
				
			}else{
				// on_release_outside
				stage.removeEventListener( MouseEvent.MOUSE_UP, on_release);
				overObject=null;
				if(drawer_opened){
					new_selected_index=-1;
					if(_items.length>DRAWER_MAX_ITEMS){
						if( !(mouseX>=scrollbar.x && mouseX<scrollbar.x+scrollbar.width && mouseY>=scrollbar.y && mouseY<scrollbar.y+scrollbar.height)){
							close_drawer();
						}else{
							stage.addEventListener( MouseEvent.MOUSE_DOWN, on_mouse_down);
							drawer_ready=true;
							invalidate(true);
							setVisibleSprite();
						}
					}else{
						close_drawer();
					}
				}
			}
		}
		
		
		/************************
		 * Draw element
		 ************************/
		
		private function draw_drawer():void{
			var x:int, y:int, w:int, h:int, i:int;
	
			x=0;
			if(_items.length>DRAWER_MAX_ITEMS){
				y=drawer_max;
				h=DRAWER_MAX_ITEMS*__height;
				w=__width;
			}else{
				y=drawer_y;
				w=Math.max(drawer_width, __width-controlStyle.COMBOBOX_BUTTON_WIDTH);
				h=_items.length*__height;
			}
			
			drawerSprite.x=x;
			drawerSprite.y=y;
			drawerSprite.width=w;
			drawerSprite.height=h;
			
			textSprite.graphics.clear();
			w=Math.max(drawer_width, __width-controlStyle.COMBOBOX_BUTTON_WIDTH);
			for( i=0; i<_items.length; i++){
				if( _items.length<=DRAWER_MAX_ITEMS || 
						((drawer_y+controlStyle.COMBOBOX_BORDER_WIDTH+i*__height>=drawer_max-__height) &&
						 (drawer_y+controlStyle.COMBOBOX_BORDER_WIDTH+i*__height<=drawer_max+h+__height) )){
					controlStyle.drawComboboxItem( 
						textSprite, 
						new Rectangle( x, drawer_y+i*__height, w, __height), 
						ControlState.create( true, i==_selected_index, i==new_selected_index, false));
				}
				(_items[i]["field"] as TextField).setTextFormat( controlStyle.controlTextFormat( ControlState.create( true, i==_selected_index, i==new_selected_index, false)));
			}
		}
		
		private function auto_resize( rcaption:String):Point{
			textField.htmlText=rcaption;
			drawer_width=Math.round(Math.min(DRAWER_MAX_WIDTH, Math.max(drawer_width, textField.textWidth+4+controlStyle.COMBOBOX_PADDING*2)));
			return new Point( textField.textWidth+4, textField.textHeight+4);
		}
		
		override protected function refresh_control( event: Event = null, recursive:Boolean=false): void{
			var i:int;
			var p:Point;
			
			super.refresh_control( event, recursive);
			
			drawer_width=COMBOBOX_MIN_WIDTH-controlStyle.COMBOBOX_PADDING*2-controlStyle.COMBOBOX_BUTTON_WIDTH;
			
			p=auto_resize(" ");
			for(i=0; i<_items.length; i++){
				auto_resize(_items[i]["caption"]);
			}
			if( -1 !=_selected_index){
				textField.htmlText=_items[_selected_index]["caption"];
			}
			if(_behaviourx==ControlBehaviour.AUTO){
				__width=drawer_width+controlStyle.COMBOBOX_BUTTON_WIDTH;
			}else  if(_behaviourx==ControlBehaviour.STRETCH){
				__width=Math.max(drawer_width+controlStyle.COMBOBOX_BUTTON_WIDTH, __width);
			}
			if(_behavioury==ControlBehaviour.AUTO){
				__height=p.y+controlStyle.COMBOBOX_PADDING*2;
			}else  if(_behavioury==ControlBehaviour.STRETCH){
				__height=Math.max( p.y+controlStyle.COMBOBOX_PADDING*2, __height);
			}
			
			for( i=0; i< _items.length; i++){
				(_items[i]["field"] as TextField).width=drawer_width-controlStyle.COMBOBOX_PADDING*2;
				(_items[i]["field"] as TextField).height=p.y; 
			}
			textField.width=drawer_width-controlStyle.COMBOBOX_PADDING*2;
			textField.height=p.y;
			
			p=localToGlobal( new Point( 0, 0));
			container.x=p.x;
			if( tween==null){
				container.y=p.y;
			}
			containerMask.x=p.x;
			containerMask.y=p.y;
			if(drawer_opened){
				draw_drawer();
			}
			
			resizeSprite();
		}
		
		override internal function sizeRequest():Point{
			var w:int, h:int;
			
			if(_behaviourx==ControlBehaviour.FIXED){
				w=__width;
			}else{
				w=drawer_width+controlStyle.COMBOBOX_BUTTON_WIDTH;
			}
			if(_behavioury==ControlBehaviour.FIXED){
				h=__height;
			}else{
				h=textField.height+controlStyle.COMBOBOX_PADDING*2; 
			}
			return new Point( w, h);
		}
		
		
		override protected function getStateSprite():Sprite{
			return controlStyle.combobox(state);
		}
		
		override protected function getFocusSprite():Sprite{
			return controlStyle.comboboxFocusRect();
		}
		
		/****************************
		 * constructor/destructor
		 ****************************/
		 
		
		
		function Combobox(){
			super();
			
			_items=new Array();
			textField.defaultTextFormat = controlStyle.controlTextFormat( state);
			textField.x=textField.y=controlStyle.COMBOBOX_PADDING;
			addChild( textField);
			
			container=new Sprite();
			container.cacheAsBitmap=true;
			container.tabEnabled=false;
			container.tabChildren=false; 
			container.mouseEnabled=false;
			container.mouseChildren=true;
			
			drawerSprite=controlStyle.comboboxDrawer();
			drawerSprite.name="drawerSprite";
			drawerSprite.tabEnabled=false;
			drawerSprite.tabChildren=false;
			drawerSprite.mouseEnabled=true;
			container.addChild(drawerSprite);
			
			textSprite=new Sprite();
			textSprite.name="textSprite";
			textSprite.mouseEnabled=false;
			container.addChild( textSprite);
			
			textMask=controlStyle.comboboxDrawerItemsMask();
			textMask.name="textMask";
			container.addChild( textMask);
			textSprite.mask=textMask;
			
			
			scrollbar=new Scrollbar;
			scrollbar.name="scrollbar";
			scrollbar.visible=false;
			scrollbar.horizontal=false;
			scrollbar.behaviour = ControlBehaviour.FIXED;
			scrollbar.combo_scrollbar=true;
			container.addChild( scrollbar);
			
			drawerSprite.addEventListener( MouseEvent.ROLL_OVER, on_mouse_over);
			drawerSprite.addEventListener( MouseEvent.ROLL_OUT, on_mouse_out);
			drawerSprite.addEventListener( MouseEvent.MOUSE_WHEEL, on_mouse_wheel);
			scrollbar.addEventListener( Event.CHANGE, scroll_change);
				
			containerMask=new Shape();
			containerMask.name="containerMask";
			containerMask.cacheAsBitmap = true;
			container.mask=containerMask;

		}
		
		
		override protected function removed_from_stage( event:Event):void{
			if( drawer_opened){
				close_drawer();
			}
			if( stage.focus==this){
				stage.focus=null;
			}
			stage.removeEventListener( MouseEvent.MOUSE_UP, on_release);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, on_mouse_move);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, on_mouse_down);
			super.removed_from_stage(event);
		}
		
		override public function remove():void{
			remove_from_stage();
			if( stage){
				stage.removeEventListener( MouseEvent.MOUSE_UP, on_release);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, on_mouse_move);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, on_mouse_down);
			}
			removeEventListener( MouseEvent.ROLL_OVER, on_mouse_over);
			removeEventListener( MouseEvent.ROLL_OUT, on_mouse_out);
			removeEventListener( MouseEvent.MOUSE_DOWN, on_press);
			removeEventListener( FocusEvent.FOCUS_IN, on_mouse_over);
			removeEventListener( FocusEvent.FOCUS_OUT, on_mouse_out);
			removeEventListener( KeyboardEvent.KEY_DOWN, on_key_down);
			removeEventListener( MouseEvent.MOUSE_WHEEL, on_mouse_wheel);
			
			removeChild( textField);
			textField=null;
			while( _items.length){
				textSprite.removeChild( _items.pop()["field"]);
			}
			_items=null;
			
			container.removeChild( drawerSprite);
			drawerSprite.removeEventListener( MouseEvent.ROLL_OVER, on_mouse_over);
			drawerSprite.removeEventListener( MouseEvent.ROLL_OUT, on_mouse_out);
			drawerSprite.removeEventListener( MouseEvent.MOUSE_WHEEL, on_mouse_wheel);
			drawerSprite=null;
			container.removeChild( textSprite);
			textSprite.mask=null;
			textSprite=null;
			container.removeChild( textMask);
			textMask=null;
			container.removeChild( scrollbar);
			scrollbar=null;
			container.mask=null;
			container=null;
			containerMask=null;
			
			overObject=null;
		}
	}
}
