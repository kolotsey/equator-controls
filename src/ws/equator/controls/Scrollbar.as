package ws.equator.controls{
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.events.Event;
	import flash.display.SpreadMethod;
	import flash.display.GradientType;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class Scrollbar extends Control{
		
		private static const DEFAULT_THIKNESS:int=16;
		private static const DEFAULT_LENGTH:int=80;
		
		//private fields
		private var mouse_pressed:Boolean=false;
		private var mouse_over:Boolean=false;
		private var interval_id:Object=null;
		private var saved_pos:Number;
		private var state:String="";
		private var dy:Number;
	
		//public properties
		private var _horizontal:Boolean=false;
		private var _track_pos:Number=0;
		private var _track_max:Number=100;
		private var _track_delta:Number=1;
		private var _combo_scrollbar:Boolean=false;
		
		/***********************
		 * Set/get functions
		 ************************/
		public function set combo_scrollbar(param:Boolean):void{
			if( _combo_scrollbar !=param){
				_combo_scrollbar=param;
				invalidate( true);
			}
		}
		public function get combo_scrollbar():Boolean{
			return _combo_scrollbar;
		}
		
		override protected function makeEnabled():void{
			if(_enabled){
				mouseEnabled=true;
				addEventListener( MouseEvent.ROLL_OVER, on_mouse_over);
				addEventListener( MouseEvent.ROLL_OUT, on_mouse_out);
				addEventListener( MouseEvent.MOUSE_DOWN, on_press);
				
			}else{
				mouseEnabled=false;
				if (stage !=null){
					stage.removeEventListener( MouseEvent.MOUSE_MOVE, position_changed);
					stage.removeEventListener( MouseEvent.MOUSE_MOVE, on_mouse_move);
					stage.removeEventListener( MouseEvent.MOUSE_UP, on_release);
				}
				removeEventListener( MouseEvent.ROLL_OVER, on_mouse_over);
				removeEventListener( MouseEvent.ROLL_OUT, on_mouse_out);
				removeEventListener( MouseEvent.MOUSE_DOWN, on_press);
				if( stage && stage.focus==this){
					stage.focus=undefined;
				}
			}
		}
		public function set horizontal(param:Boolean):void{
			if( _horizontal !=param){
				_horizontal=param;
				invalidate( true);
			}
		}
		public function get horizontal():Boolean{
			return _horizontal;
		}
		public function set pos(param:Number):void{
			if( _track_pos !=param){
				_track_pos=Math.max(Math.min(_track_max, param), 0);
				invalidate(true);
			}
		}
		public function get pos():Number{
			return _track_pos;
		}
		public function set max(param:Number):void{
			if( _track_max !=param){
				_track_max=Math.max(param, 1);
				_track_pos=Math.max(Math.min(_track_max, _track_pos), 0);
				invalidate(true);
			}
		}
		public function get max():Number{
			return _track_max;
		}
		public function set delta(param:Number):void{
			_track_delta=Math.max(Math.min(_track_max, param), 1);
		}
		public function get delta():Number{
			return _track_delta;
		}
		
		/***********************
		 * private functions
		 ***********************/
		
		
		private static function draw_bg(target:Sprite, wid:int, hei:int, xmouse:Number, ymouse:Number, mouse_over:Boolean, state:String, track_pos:Number, track_max:Number, horizontal:Boolean, enabled:Boolean, combo:Boolean):void{
			var rad:int=8;
			var w:int;
			var h:int;
			var x:int;
			var y:int;
			var r:int;
			var matrix:Matrix = new Matrix();
			
			w=wid;
			h=hei;
			x=y=0;
			r=rad;
			
			target.graphics.clear();
			
			if(combo){
				x=1;
				y=1;
				w=wid-2;
				h=hei-2;
				r=rad-1;
			}else{
				//------------------
				// outline
				//------------------
				matrix.createGradientBox(w, h, Math.PI/2);
				target.graphics.beginGradientFill( GradientType.LINEAR, [0x999999 ,0x000000], [100, 100], [0, 175], matrix, SpreadMethod.PAD);
				
				target.graphics.drawRoundRect( x, y, w, h, r);
				//------------------
				// continue outline
				//------------------
				x=1;
				y=1;
				w=wid-2; h=hei-2;
				r=rad-1;
				target.graphics.drawRoundRect( x, y, w, h, r);
				target.graphics.endFill();
			}
			//---------------
			// background
			//---------------
			matrix.createGradientBox(w, h, Math.PI/2);
			if(combo){
				target.graphics.beginFill(0x00, 0);
			}else if( enabled){
				target.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff ,0xe3f2f9], [50, 75], [110, 150], matrix, SpreadMethod.PAD);
			}else{
				target.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff ,0xeeeeee], [50, 75], [110, 150], matrix, SpreadMethod.PAD);
			}
			target.graphics.drawRoundRect( x, y, w, h, r);
			target.graphics.endFill();
			//--------
			// arrows
			//--------
			w=wid;
			h=hei;
			if( horizontal){
				if(enabled && ((mouse_over && xmouse<=h && state =="") || state=="up")){
					target.graphics.beginFill(0x224F65);
				}else {
					target.graphics.beginFill(0x666666);
				}
				target.graphics.moveTo(h/4, h/2);
				target.graphics.lineTo(h*3/4, h*3/4);
				target.graphics.lineTo(h*3/4, h/4);
				target.graphics.endFill();
				if(enabled && ((mouse_over && xmouse>=w-h && state =="")||(state=="down"))){
					target.graphics.beginFill(0x224F65);
				}else{
					target.graphics.beginFill(0x666666);
				}
				target.graphics.moveTo(w-h/4, h/2);
				target.graphics.lineTo(w-h*3/4, h*3/4);
				target.graphics.lineTo(w-h*3/4, h/4);
				target.graphics.endFill();
			}else{
				if(enabled && ((mouse_over && ymouse<=w && state =="") || state=="up")){
					target.graphics.beginFill(0x224F65);
				}else {
					target.graphics.beginFill(0x666666);
				}
				target.graphics.moveTo(w/2, w/4);
				target.graphics.lineTo(w*3/4, w*3/4);
				target.graphics.lineTo(w/4, w*3/4);
				target.graphics.endFill();
				if(enabled && ((mouse_over && ymouse>=h-w && state =="")||(state=="down"))){
					target.graphics.beginFill(0x224F65);
				}else{
					target.graphics.beginFill(0x666666);
				}
				target.graphics.moveTo(w/2, h-w/4);
				target.graphics.lineTo(w*3/4, h-w*3/4);
				target.graphics.lineTo(w/4, h-w*3/4);
				target.graphics.endFill();
			}
			//--------
			// tracker
			//--------
			if(enabled){
				if( horizontal){
					x=hei;
					w=wid-2*hei;
					y=2;
					h=hei-4;
					r=rad-2;
					if((mouse_over && xmouse>x && xmouse<wid-x && state =="") ||(state=="drag")){
						target.graphics.beginFill(0x224F65);
					}else{
						target.graphics.beginFill(0x666666);
					}
					target.graphics.drawRoundRect( x+(track_pos*(w-h*2)/track_max), y, h*2, h, r);
					target.graphics.endFill();
				}else{
					x=2;
					w=wid-4;
					y=wid;
					h=hei-2*wid;
					r=rad-2;
					if((mouse_over && ymouse>y && ymouse<hei-y && state =="") ||(state=="drag")){
						target.graphics.beginFill(0x224F65);
					}else{
						target.graphics.beginFill(0x666666);
					}
					target.graphics.drawRoundRect( x, y+(track_pos*(h-w*2)/track_max), w, w*2, r);
					target.graphics.endFill();
				}
			}
		}
		
		override internal function sizeRequest():Point{
			var w:int, h:int;
			
			if( _horizontal){
				w=(_behaviourx==ControlBehaviour.FIXED? __width  : DEFAULT_LENGTH);
				h=(_behavioury==ControlBehaviour.FIXED? __height : DEFAULT_THIKNESS);
			}else{
				w=(_behaviourx==ControlBehaviour.FIXED? __width  : DEFAULT_THIKNESS);
				h=(_behavioury==ControlBehaviour.FIXED? __height : DEFAULT_LENGTH);
			}
			return new Point( w, h);
		}
		
		override protected function refresh_control( event:Event=null, recursive:Boolean=false):void{
			super.refresh_control( event, recursive);
			//set size
			if(_horizontal){
				if(_behaviourx==ControlBehaviour.AUTO){
					__width=DEFAULT_LENGTH;
				}else if(_behaviourx==ControlBehaviour.STRETCH){
					__width=Math.max(DEFAULT_LENGTH, __width);
				}
				__height=_behavioury==ControlBehaviour.FIXED? __height : DEFAULT_THIKNESS;
			}else{
				__width=_behaviourx==ControlBehaviour.FIXED? __width : DEFAULT_THIKNESS;
				if(_behavioury==ControlBehaviour.AUTO){
					__height=DEFAULT_LENGTH;
				}else if(_behavioury==ControlBehaviour.STRETCH){
					__height=Math.max(DEFAULT_LENGTH, __height);
				}
			}
			
			draw_bg(this, __width, __height, mouseX, mouseY, mouse_over, state, _track_pos, _track_max, _horizontal, _enabled, _combo_scrollbar);
		}
		
		
		/************************
		* Mouse/focus actions
		 *************************/
		
		private function position_changed( event:Event=null):void{
			var top:int;
			var bot:int;
			var pos:Number;
			
			if(state=="up"){
				//up
				if(_track_pos>0){
					_track_pos-=dy;
					if(_track_pos<0){
						_track_pos=0;
					}
					if(dy<3){
						dy++;
					}
				}
			}else if(state=="down"){
				//down
				if(_track_pos<_track_max){
					_track_pos+=dy;
					if(_track_pos>_track_max){
						_track_pos=_track_max;
					}
					if(dy<3){
						dy++;
					}
				}
			}else if(state=="drag"){
				if(_horizontal){
					top=__height+(__height-4)*3/4;
					bot=__width-__height-(__height-4)*3/4;
					pos=(mouseX-top)*_track_max/(bot-top);
				}else{
					top=__width+(__width-4)*3/4;
					bot=__height-__width-(__width-4)*3/4;
					pos=(mouseY-top)*_track_max/(bot-top);
				}
				pos=Math.min(Math.max(pos, 0), _track_max);
				_track_pos=Math.round(pos);
			}
			
			invalidate(true);
			if(_track_pos !=saved_pos){
				saved_pos=_track_pos;
				dispatchEvent( new Event(Event.CHANGE));
			}
		}
		
		private function on_mouse_move( event:Event):void{
			invalidate();
		}
		private function on_mouse_over( event:Event):void{
			mouse_over=true;
			stage.addEventListener( MouseEvent.MOUSE_MOVE, on_mouse_move);
			invalidate(true);
		}
		private function on_mouse_out( event:Event):void{
			if( !mouse_pressed && null !=interval_id){
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, on_mouse_move);
				clearInterval( interval_id as uint);
				interval_id=null;
				state="";
			}
			
			mouse_over=false;
			invalidate(true);
		}
		private function on_press( event:Event):void{
			mouse_over=true;
			mouse_pressed=true;
			saved_pos=_track_pos;
			dy=1;
			stage.addEventListener( MouseEvent.MOUSE_UP, on_release);
			if( (!_horizontal && mouseY<=__width) ||(_horizontal && mouseX<=__height)){
				state="up";
				position_changed();
				interval_id=setInterval( position_changed, 100);
			}else if((!_horizontal && mouseY>=__height-__width)||( _horizontal && mouseX>=__width-__height)){
				state="down";
				position_changed();
				interval_id=setInterval( position_changed, 100);
			}else{
				state="drag";
				position_changed();
				stage.addEventListener( MouseEvent.MOUSE_MOVE, position_changed);
			}
		}
		private function on_release(event:Event):void{
			if( stage !=null){
				stage.removeEventListener( MouseEvent.MOUSE_UP, on_release);
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, position_changed);
			}
			if(interval_id != null){
				clearInterval(interval_id as uint);
				interval_id=null;
			}
			mouse_pressed=false;
			state="";
			if( ! (event.target == this || this.contains( DisplayObject( event.target)))){
				mouse_over=false;
				if( stage !=null) stage.removeEventListener( MouseEvent.MOUSE_MOVE, on_mouse_move);
			}
			invalidate(true);
		}

		
		/******************************
		 * Constructor/desrtructor
		 *******************************/
		
		public function Scrollbar():void{
			super();
			
			tabEnabled=false;
			tabChildren=false;
			mouseChildren=false;
			__width=DEFAULT_THIKNESS;
			__height=DEFAULT_LENGTH;
		}
		
		
		override protected function removed_from_stage( event:Event):void{
			if( stage.focus==this){
				stage.focus=null;
			}
			mouse_pressed=false;
			state="";
			mouse_over=false;
			stage.removeEventListener( MouseEvent.MOUSE_UP, on_release);
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, position_changed);
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, on_mouse_move);
			if( null !=interval_id){
				clearInterval(interval_id as uint);
			}
			super.removed_from_stage(event);
		}
		
		override public function remove():void{
			remove_from_stage();
			
			if( stage !=null){
				stage.removeEventListener( MouseEvent.MOUSE_UP, on_release);
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, position_changed);
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, on_mouse_move);
			}
			removeEventListener( MouseEvent.ROLL_OVER, on_mouse_over);
			removeEventListener( MouseEvent.ROLL_OUT, on_mouse_out);
			removeEventListener( MouseEvent.MOUSE_DOWN, on_press);
			if( null !=interval_id){
				clearInterval(interval_id as uint);
			}
			super.remove();
		}
	}
}



