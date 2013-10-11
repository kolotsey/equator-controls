package ws.equator.controls{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;


	public class Button extends BasicButton{ 
		private var _icon: DisplayObject = null;
		

		/************************
		 * Set/get functions    *
		 ************************/
		
		public function set icon( param: DisplayObject): void{
			if(_icon != null){
				removeChild( _icon);
				if( _icon is Control){
					(_icon as Control).remove();
				}
				_icon = null;
			}
			if(param !=null){
				_icon = param;
				addChild( _icon);
			}
			invalidate( true);
		}

		override internal function sizeRequest(): Point{
			var w: int, h: int;

			if(_behaviourx == ControlBehaviour.FIXED){
				w = __width;
			} else{
				if(_icon != null){
					var iconwidth: int = _icon.width;
					if( prepared_caption ==""){
						w = iconwidth + 2 * controlStyle.BUTTON_ICON_HORIZ_PADDING;
					}else{
						w = iconwidth + textField.width + 2 * controlStyle.BUTTON_ICON_HORIZ_PADDING + controlStyle.BUTTON_HORIZ_PADDING;
					}
				} else{
					w = textField.width + 2 * controlStyle.BUTTON_HORIZ_PADDING;
				}
			}
			if(_behavioury == ControlBehaviour.FIXED){
				h = __height;
			} else{
				if(_icon != null){
					var iconheight: int = _icon.height;
					h = Math.max( textField.height+2 * controlStyle.BUTTON_VERT_PADDING, iconheight + 2* controlStyle.BUTTON_ICON_VERT_PADDING);
				} else{
					h = textField.height + 2 * controlStyle.BUTTON_VERT_PADDING;
				}
			}
			return new Point( w, h);
		}

		/****************************************************************
		 * Private functions responsible for control's layout and style *
		 ****************************************************************/
		 
		override protected function resize_control():void{
			if( _icon==null){
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
				if(state &ControlState.DOWN || state & ControlState.SELECTED){
					textField.y = Math.max( controlStyle.BUTTON_VERT_PADDING + 1, Math.round( (__height - textField.height) / 2) + 1);
				} else{
					textField.y = Math.max( controlStyle.BUTTON_VERT_PADDING, Math.round( (__height - textField.height) / 2));
				}
				
			}else{
				var iconwidth: int = _icon.width;
				var iconheight: int = _icon.height;
				
				// set element's size
				if(_behaviourx == ControlBehaviour.AUTO){
					if( prepared_caption==""){
						__width = iconwidth + 2 * controlStyle.BUTTON_ICON_HORIZ_PADDING;
					}else{
						__width = iconwidth + textField.width + 2 * controlStyle.BUTTON_ICON_HORIZ_PADDING + controlStyle.BUTTON_HORIZ_PADDING;
					}
				} else if(_behaviourx == ControlBehaviour.STRETCH){
					if( prepared_caption==""){
						__width = Math.max( iconwidth + 2 * controlStyle.BUTTON_ICON_HORIZ_PADDING, __width);
					}else{
						__width = Math.max( iconwidth + textField.width + 2 * controlStyle.BUTTON_ICON_HORIZ_PADDING + controlStyle.BUTTON_HORIZ_PADDING, __width);
					}
				}
				if(_behavioury == ControlBehaviour.AUTO){
					if(prepared_caption==""){
						__height = iconheight + 2 * controlStyle.BUTTON_ICON_VERT_PADDING;
					}else{
						__height = Math.max( textField.height + 2 * controlStyle.BUTTON_VERT_PADDING, iconheight + 2 * controlStyle.BUTTON_ICON_VERT_PADDING);
					}
				} else if(_behavioury == ControlBehaviour.STRETCH){
					if(prepared_caption==""){
						__height = Math.max(iconheight + 2 * controlStyle.BUTTON_ICON_VERT_PADDING, __height);
					}else{
						__height = Math.max( textField.height + 2 * controlStyle.BUTTON_VERT_PADDING, iconheight + 2 * controlStyle.BUTTON_ICON_VERT_PADDING, __height);
					}
					
				}

				// position items
				if( prepared_caption==""){
					_icon.x = Math.round((__width - iconwidth) / 2);
				}else{
					_icon.x = controlStyle.BUTTON_ICON_HORIZ_PADDING;
				}
				textField.x = _icon.x + iconwidth + controlStyle.BUTTON_ICON_HORIZ_PADDING;
				if(state & ControlState.DOWN || state & ControlState.SELECTED){
					_icon.y = Math.round((__height - iconheight) / 2) + 1;
					textField.y = Math.round((__height - textField.height) / 2) + 1;
				} else{
					_icon.y = Math.round((__height - iconheight) / 2);
					textField.y = Math.round((__height - textField.height) / 2);
				}
				
				_icon.alpha = (state & ControlState.ENABLED? 1 : 0.5);
				if( _icon is Control){
					(_icon as Control).enabled= state & ControlState.ENABLED? true : false;
				}
			}
		}
		
		override protected function getStateSprite():Sprite{
			return controlStyle.button( state); 
		} 
		
		override protected function getFocusSprite():Sprite{
			return controlStyle.buttonFocusRect();
		}
		

		/*******************************
		 * Constructor/desrtructor     *
		 *******************************/
		public function Button(): void{
			super();
		}
		
		override public function remove():void{
			remove_from_stage();

			icon=null;
			
			super.remove();
		}
	}
}	
	

