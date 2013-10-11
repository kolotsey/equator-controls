package ws.equator.controls{
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Sprite;



	/**
	 * @author kolotsey
	 */
	internal class TabButton extends BasicButton{ 

		override public function set toggle( param:Boolean):void{
			//do nothing
		}
		
		override protected function getStateSprite():Sprite{
			return controlStyle.tab( state);
		}
		
		override protected function getFocusSprite():Sprite{
			return controlStyle.tabFocusRect();
		}
		
		override protected function on_press( event: Event): void{
			if( !(state &ControlState.DOWN) && !_selected){
				state |= ControlState.DOWN;
								
				stage.addEventListener( MouseEvent.MOUSE_UP, on_release);
				setVisibleSprite();
				textField.setTextFormat( controlStyle.controlTextFormat( state));
			}
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
		 
		override protected function resize_control():void{
			if(_behaviourx == ControlBehaviour.AUTO){
				__width = textField.width + 2 * controlStyle.BUTTON_HORIZ_PADDING;
			} else if(_behaviourx == ControlBehaviour.STRETCH){
				__width = Math.max( textField.width + 2 * controlStyle.BUTTON_HORIZ_PADDING, __width);
			}
			if(_behavioury == ControlBehaviour.AUTO){
				__height = textField.height + 2 * controlStyle.BUTTON_VERT_PADDING;
			} else if(_behavioury == ControlBehaviour.STRETCH){
				__height = Math.max( textField.height + 2 * controlStyle.BUTTON_VERT_PADDING, __height);
			}

			// position items
			textField.x = Math.max( controlStyle.BUTTON_HORIZ_PADDING, Math.round( (__width - textField.width) / 2));
			textField.y = Math.max( controlStyle.BUTTON_VERT_PADDING, Math.round( (__height - textField.height) / 2));
		}
		
		public function TabButton(): void{
			super();
			_toggle=true;
		}
	}
}
