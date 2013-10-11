package ws.equator.controls{
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;


	internal class BasicButton extends InteractiveControl{
		protected var textField: TextField=createTextField(); 
		protected var key_pressed: Boolean = false;
		private var _caption: String = controlName();
		protected var prepared_caption: String = _caption;
		protected var _toggle:Boolean=false;
		protected var _selected:Boolean=false;
		

		static private function createTextField():TextField{
			var field:TextField = new TextField();
			field.autoSize = TextFieldAutoSize.NONE;
			field.background = false;
			field.border = false;
			field.selectable = false;
			field.textColor = 0x00;
			field.type = TextFieldType.DYNAMIC;
			field.wordWrap = false;
			field.multiline = true;
			field.mouseWheelEnabled = false;
			field.embedFonts = false;
			field.width = 100;
			field.height = 20;
			field.mouseEnabled = false;
			field.tabEnabled = false;
			return field;
		}

		/************************
		 * Set/get functions    *
		 ************************/
		public function set caption( param: String): void{
			if( _caption != param){
				_caption = param;
				prepared_caption=html_prepare( _caption);
				invalidate( true);
			}
		}

		public function get caption(): String{
			return _caption;
		}

		public function set toggle( param:Boolean):void{
			if(_toggle !=param){
				_toggle=param==true;
				invalidate(true);
			}
		}
		
		public function get toggle():Boolean{
			return _toggle;
		}
		
		public function set selected(param:Boolean):void{
			if( _selected !=param){
				_selected=param;
				if(_selected){
					state |=ControlState.SELECTED;
				}else{
					state &=~ControlState.SELECTED;
				}
				setVisibleSprite();
				textField.setTextFormat( controlStyle.controlTextFormat( state));
				invalidate();
			}
		}
		
		public function get selected():Boolean{
			return _selected;
		}

		override protected function makeEnabled():void{
			if(_enabled){
				tabEnabled = true;
				mouseEnabled = true;

				addEventListener( MouseEvent.ROLL_OVER, on_mouse_over);
				addEventListener( MouseEvent.ROLL_OUT, on_mouse_out);
				addEventListener( MouseEvent.MOUSE_DOWN, on_press);
				addEventListener( KeyboardEvent.KEY_DOWN, on_key_down);
				addEventListener( KeyboardEvent.KEY_UP, on_key_up);
				addEventListener( FocusEvent.FOCUS_IN, on_focus);
				addEventListener( FocusEvent.FOCUS_OUT, on_blur);
				addEventListener( MouseEvent.CLICK, on_click);
				state = ControlState.create( true, _selected, false, false);
				
			} else{
				tabEnabled = false;
				mouseEnabled = false;

				removeEventListener( MouseEvent.ROLL_OVER, on_mouse_over);
				removeEventListener( MouseEvent.ROLL_OUT, on_mouse_out);
				removeEventListener( MouseEvent.MOUSE_DOWN, on_press);
				removeEventListener( KeyboardEvent.KEY_DOWN, on_key_down);
				removeEventListener( KeyboardEvent.KEY_UP, on_key_up);
				removeEventListener( FocusEvent.FOCUS_IN, on_focus);
				removeEventListener( FocusEvent.FOCUS_OUT, on_blur);
				removeEventListener( MouseEvent.CLICK, on_click);
				state = ControlState.create( false, _selected, false, false);

				key_pressed = false;
				if( stage && stage.focus == this){
					stage.focus = null;
				}
			}
			setVisibleSprite();
			textField.setTextFormat( controlStyle.controlTextFormat( state));
			invalidate();
		}

		override internal function sizeRequest(): Point{
			var w: int, h: int;

			if(_behaviourx == ControlBehaviour.FIXED){
				w = __width;
			} else{
				w = textField.width + 2 * controlStyle.BUTTON_HORIZ_PADDING;
			}
			if(_behavioury == ControlBehaviour.FIXED){
				h = __height;
			} else{
				h = textField.height + 2 * controlStyle.BUTTON_VERT_PADDING;
			}
			return new Point( w, h);
		}

		/****************************************************************
		 * Private functions responsible for control's layout and style *
		 ****************************************************************/
		 
		protected function resize_control():void{
			// set size
			if(_behaviourx == ControlBehaviour.AUTO){
				__width = textField.width;
			} else if(_behaviourx == ControlBehaviour.STRETCH){
				__width = Math.max( textField.width, __width);
			}
			if(_behavioury == ControlBehaviour.AUTO){
				__height = textField.height;
			} else if(_behavioury == ControlBehaviour.STRETCH){
				__height = Math.max( textField.height, __height);
			}

			// position items
			textField.x = Math.max( 0, Math.round( (__width - textField.width) / 2));
			if((state & ControlState.DOWN) || (state & ControlState.SELECTED)){
				textField.y = Math.max( 1, Math.round( (__height - textField.height) / 2) + 1);
			} else{
				textField.y = Math.max( 0, Math.round( (__height - textField.height) / 2));
			}
		}
		
		override protected function refresh_control( event: Event = null, recursive:Boolean=false): void{
			super.refresh_control( event, recursive);
			
			textField.defaultTextFormat= controlStyle.controlTextFormat( state);
			textField.htmlText=prepared_caption;
			textField.width = Math.round( textField.textWidth) + 4;
			textField.height = Math.round( textField.textHeight) + 4;

			resize_control();
			
			resizeSprite();
		}

		/************************
		 * Mouse/focus actions  *
		 ************************/
		
		override protected function getStateSprite():Sprite{
			return null;
		}
		
		override protected function getFocusSprite():Sprite{
			return null;
		}
				
		private function on_mouse_over( event: Event): void{
			if( !key_pressed){
				state |= ControlState.OVER;
				setVisibleSprite();
				textField.setTextFormat( controlStyle.controlTextFormat( state));
			}
		}

		private function on_mouse_out( event: Event): void{
			if( !key_pressed){
				state &= ~ControlState.OVER;
				setVisibleSprite();
				textField.setTextFormat( controlStyle.controlTextFormat( state));
			}
		}

		protected function on_press( event: Event): void{
			if( !(state &ControlState.DOWN)){
				state |= ControlState.DOWN;
								
				stage.addEventListener( MouseEvent.MOUSE_UP, on_release);
				setVisibleSprite();
				textField.setTextFormat( controlStyle.controlTextFormat( state));
			}
		}

		protected function on_release( event: Event): void{
			stage.removeEventListener( MouseEvent.MOUSE_UP, on_release);
			if(event.target == this || this.contains( DisplayObject( event.target))){
				// on_relese
				if((state & ControlState.DOWN) && (false == key_pressed)){
					state &= ~ControlState.DOWN;
					if( _toggle){
						if( _selected){
							_selected=false;
							state &= ~ControlState.SELECTED;
						}else{
							_selected=true;
							state |= ControlState.SELECTED;
						}
					} 
					setVisibleSprite();
					textField.setTextFormat( controlStyle.controlTextFormat( state));
					if( event is KeyboardEvent){
						dispatchEvent( new Event( MouseEvent.CLICK));
					}
					if( _toggle){
						dispatchEvent( new Event( Event.CHANGE));
					}
				}
			} else{
				// on_release_outside
				if( false == key_pressed){
					state &= ~(ControlState.DOWN |ControlState.OVER);
					setVisibleSprite();
					textField.setTextFormat( controlStyle.controlTextFormat( state));
				}
			}
		}

		private function on_key_down( event: KeyboardEvent): void{
			var k: uint = event.keyCode;
			if((k == Keyboard.SPACE /*|| k==Key.ENTER*/) && ( !(state &ControlState.DOWN))){
				on_press( null);
				key_pressed = true;
			}
		}

		private function on_key_up( event: KeyboardEvent): void{
			var k: uint = event.keyCode;
			if(k == Keyboard.SPACE /*|| k==Key.ENTER*/ && key_pressed){
				key_pressed = false;
				on_release( event);
			}
		}

		private function on_click( event: Event): void{
			if( key_pressed){
				event.stopImmediatePropagation();
			}
		}

		private function on_focus( event: Event): void{
			textField.setTextFormat( controlStyle.controlTextFormat( state));
		}

		private function on_blur( event: Event): void{
			if( key_pressed || (state & ControlState.DOWN)){
				event.stopImmediatePropagation();
				stage.focus = this;
			} else{
				textField.setTextFormat( controlStyle.controlTextFormat( state));
			}
		}


		/*******************************
		 * Constructor/desrtructor     *
		 *******************************/
		public function BasicButton(): void{
			super();
			addChild( textField);
		}
		
		override protected function removed_from_stage( event:Event):void{
			stage.removeEventListener( MouseEvent.MOUSE_UP, on_release);
			super.removed_from_stage(event);
		}
		
		override public function remove():void{
			remove_from_stage();
			
			removeEventListener( MouseEvent.ROLL_OVER, on_mouse_over);
			removeEventListener( MouseEvent.ROLL_OUT, on_mouse_out);
			removeEventListener( MouseEvent.MOUSE_DOWN, on_press);
			removeEventListener( FocusEvent.FOCUS_IN, on_mouse_over);
			removeEventListener( FocusEvent.FOCUS_OUT, on_mouse_out);
			removeEventListener( KeyboardEvent.KEY_DOWN, on_key_down);
			removeEventListener( KeyboardEvent.KEY_UP, on_key_up);
			removeEventListener( FocusEvent.FOCUS_IN, on_focus); 
			removeEventListener( FocusEvent.FOCUS_OUT, on_blur);
			removeEventListener( MouseEvent.CLICK, on_click);
			if( stage) stage.removeEventListener( MouseEvent.MOUSE_UP, on_release);

			removeChild( textField);
			textField=null;
						
			super.remove();
		}
	}
}	
	

