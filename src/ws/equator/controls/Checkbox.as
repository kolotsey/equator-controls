package ws.equator.controls{

	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class Checkbox extends BasicButton{
		
		override public function set toggle( param:Boolean):void{
			//do nothing
		}
				
		/***********************
		 * private functions
		 ***********************/
		
		override internal function sizeRequest():Point{
			var w: int, h: int;

			if(_behaviourx == ControlBehaviour.FIXED){
				w = __width;
				
			} else{
				w = textField.width + controlStyle.CHECKBOX_PADDING;
			}
			if(_behavioury == ControlBehaviour.FIXED){
				h = __height;
			} else{
				h = Math.max(textField.height, controlStyle.CHECKBOX_ICON_SIZE);
			}
			return new Point( w, h);
		}
		
		override protected function resize_control():void{
			if(_behaviourx == ControlBehaviour.AUTO){
				__width = textField.width + controlStyle.CHECKBOX_PADDING;
			} else if(_behaviourx == ControlBehaviour.STRETCH){
				__width = Math.max( textField.width + controlStyle.CHECKBOX_PADDING, __width);
			}
			if(_behavioury == ControlBehaviour.AUTO){
				__height = Math.max(textField.height, controlStyle.CHECKBOX_ICON_SIZE);
			} else if(_behavioury == ControlBehaviour.STRETCH){
				__height = Math.max( textField.height, controlStyle.CHECKBOX_ICON_SIZE, __height);
			}

			// position items
			textField.x = controlStyle.CHECKBOX_PADDING;
			textField.y = Math.max( 0, Math.round( (__height - textField.height) / 2));
		}
		
		override protected function getStateSprite():Sprite{
			return controlStyle.checkbox( state);
		}
		
		override protected function getFocusSprite():Sprite{
			return controlStyle.checkboxFocusRect();
		}
		
		/******************************
		 * Constructor/desrtructor
		 *******************************/
		
		function Checkbox(){
			super();
			bgScale=controlStyle.CHECKBOX_BG_SCALE;
			bgAlign=controlStyle.CHECKBOX_BG_ALIGN;
			focusrectScale=controlStyle.CHECKBOX_FOCUSRECT_SCALE;
			_toggle=true;
		}
	}
}	
	
	

