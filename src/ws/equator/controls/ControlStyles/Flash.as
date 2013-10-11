package ws.equator.controls.ControlStyles {
	import ws.equator.controls.ControlStyle;
	import ws.equator.controls.ControlState;
	import ws.equator.controls.IControlStyle;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	/**
	 * @author kolotsey
	 */
	public class Flash extends ControlStyle implements IControlStyle{
		
		
		//Button
		[Embed(source="Flash.swf", symbol="Button_emphasizedSkin")]
		static private const Button_emphasizedSkin:Class;
		[Embed(source="Flash.swf", symbol="Button_upSkin")]
		static private const Button_upSkin:Class;
		[Embed(source="Flash.swf", symbol="Button_overSkin")]
		static private const Button_overSkin:Class;
		[Embed(source="Flash.swf", symbol="Button_downSkin")]
		static private const Button_downSkin:Class;
		[Embed(source="Flash.swf", symbol="Button_disabledSkin")]
		static private const Button_disabledSkin:Class;
		[Embed(source="Flash.swf", symbol="Button_selectedUpSkin")]
		static private const Button_selectedUpSkin:Class;
		[Embed(source="Flash.swf", symbol="Button_selectedOverSkin")]
		static private const Button_selectedOverSkin:Class;
		[Embed(source="Flash.swf", symbol="Button_selectedDownSkin")]
		static private const Button_selectedDownSkin:Class;
		[Embed(source="Flash.swf", symbol="Button_selectedDisabledSkin")]
		static private const Button_selectedDisabledSkin:Class;
		
		//Checkbox
		[Embed(source="Flash.swf", symbol="CheckBox_upIcon")]
		static private const CheckBox_upIcon:Class;
		[Embed(source="Flash.swf", symbol="CheckBox_overIcon")]
		static private const CheckBox_overIcon:Class;
		[Embed(source="Flash.swf", symbol="CheckBox_downIcon")]
		static private const CheckBox_downIcon:Class;
		[Embed(source="Flash.swf", symbol="CheckBox_disabledIcon")]
		static private const CheckBox_disabledIcon:Class;
		[Embed(source="Flash.swf", symbol="CheckBox_selectedUpIcon")]
		static private const CheckBox_selectedUpIcon:Class;
		[Embed(source="Flash.swf", symbol="CheckBox_selectedOverIcon")]
		static private const CheckBox_selectedOverIcon:Class;
		[Embed(source="Flash.swf", symbol="CheckBox_selectedDownIcon")]
		static private const CheckBox_selectedDownIcon:Class;
		[Embed(source="Flash.swf", symbol="CheckBox_selectedDisabledIcon")]
		static private const CheckBox_selectedDisabledIcon:Class;
		
		//Combobox
		[Embed(source="Flash.swf", symbol="ComboBox_upSkin")]
		static private const ComboBox_upSkin:Class;
		[Embed(source="Flash.swf", symbol="ComboBox_overSkin")]
		static private const ComboBox_overSkin:Class;
		[Embed(source="Flash.swf", symbol="ComboBox_downSkin")]
		static private const ComboBox_downSkin:Class;
		[Embed(source="Flash.swf", symbol="ComboBox_disabledSkin")]
		static private const ComboBox_disabledSkin:Class;
		[Embed(source="Flash.swf", symbol="List_skin")]
		static private const List_skin:Class;
		
		//Tabs and panels
		[Embed(source="Flash.swf", symbol="Tab_panelSkin")]
		static private const Tab_panelSkin:Class;
		[Embed(source="Flash.swf", symbol="Panel_skin")]
		static private const Panel_skin:Class;
		[Embed(source="Flash.swf", symbol="Tab_upSkin")]
		static private const Tab_upSkin:Class;
		[Embed(source="Flash.swf", symbol="Tab_overSkin")]
		static private const Tab_overSkin:Class;
		[Embed(source="Flash.swf", symbol="Tab_downSkin")]
		static private const Tab_downSkin:Class;
		[Embed(source="Flash.swf", symbol="Tab_selectedUpSkin")]
		static private const Tab_selectedUpSkin:Class;
		
		//edit
		[Embed(source="Flash.swf", symbol="TextInput_upSkin")]
		static private const TextInput_upSkin:Class;
		[Embed(source="Flash.swf", symbol="TextInput_disabledSkin")]
		static private const TextInput_disabledSkin:Class;
		
		override public function get CHECKBOX_FOCUSRECT_SCALE():Boolean{ return true;}
		

		private function focusRect():Sprite{
			return new flashFocusRect();
		}
		
		override public function buttonFocusRect():Sprite{
			return focusRect();
		}
		
		override public function button( state:int):Sprite{
			if( state &  ControlState.SELECTED){
				if( state & ControlState.ENABLED){
					if( state & ControlState.DOWN){
						return new Button_selectedDownSkin();
					}else if( state & ControlState.OVER){
						return new Button_selectedOverSkin();
					}else{
						return new Button_selectedUpSkin();
					}
				}else{
					return new Button_selectedDisabledSkin();
				}
				
			}else{
				if( state & ControlState.ENABLED){
					if( state & ControlState.DOWN){
						return new Button_downSkin();
					}else if( state & ControlState.OVER){
						return new Button_overSkin();
					}else{
						return new Button_upSkin();
					}
				}else{
					return new Button_disabledSkin();
				}
			}
		}
		
		override public function checkboxFocusRect():Sprite{
			return focusRect();
		}
		
		override public function checkbox( state:int):Sprite{
			if( state &  ControlState.SELECTED){
				if( state & ControlState.ENABLED){
					if( state & ControlState.DOWN){
						return new CheckBox_selectedDownIcon();
					}else if( state & ControlState.OVER){
						return new CheckBox_selectedOverIcon();
					}else{
						return new CheckBox_selectedUpIcon();
					}
				}else{
					return new CheckBox_selectedDisabledIcon();
				}
				
			}else{
				if( state & ControlState.ENABLED){
					if( state & ControlState.DOWN){
						return new CheckBox_downIcon();
					}else if( state & ControlState.OVER){
						return new CheckBox_overIcon();
					}else{
						return new CheckBox_upIcon();
					}
				}else{
					return new CheckBox_disabledIcon();
				}
			}
		}
		
		override public function comboboxFocusRect():Sprite{
			return focusRect();
		}
		
		override public function combobox( state:int):Sprite{
			if( state & ControlState.ENABLED){
				if( state & ControlState.DOWN){
					return new ComboBox_downSkin();
				}else if( state & ControlState.OVER){
					return new ComboBox_overSkin();
				}else{
					return new ComboBox_upSkin();
				}
			}else{
				return new ComboBox_disabledSkin();
			}
		}
		
		override public function comboboxDrawer():Sprite{
			 return new List_skin();
		}
		
		override public function comboboxDrawerItemsMask():Sprite{
			var shape:Sprite=new Sprite();
			var rect:Rectangle=new Rectangle( 0, 0, 100, 100);
			var scale9grid:Rectangle=rect.clone();
			scale9grid.inflate(-8, -8);
			
			shape.graphics.beginFill( 0xffffff, 0);
			shape.graphics.drawRect( rect.x, rect.y, rect.width, rect.height);
			shape.graphics.endFill();
			rect.inflate( -COMBOBOX_BORDER_WIDTH, -COMBOBOX_BORDER_WIDTH);
			shape.graphics.beginFill( 0x000000, 1);
			shape.graphics.drawRoundRect( rect.x, rect.y, rect.width, rect.height, 6);
			shape.graphics.endFill();
			shape.scale9Grid=scale9grid;
			return shape;
		}
		
		override public function drawComboboxItem( sprite:Sprite, rect:Rectangle, state:int):void{
			if( state & ControlState.OVER || state & ControlState.SELECTED){
				if( state & ControlState.OVER){
					sprite.graphics.beginFill( 0x9AD8FF, 1);
				}else{
					sprite.graphics.beginFill( 0x9AD8FF, 0.3);
				}
				sprite.graphics.drawRect(rect.x+COMBOBOX_BORDER_WIDTH, rect.y+COMBOBOX_BORDER_WIDTH, rect.width-2*COMBOBOX_BORDER_WIDTH, rect.height-2*COMBOBOX_BORDER_WIDTH);
				sprite.graphics.endFill();
			}
		}
		
		override public function tabPanel(): Sprite{
			return new Tab_panelSkin();
		}
		
		override public function panel(): Sprite{
			return new Panel_skin();
		}
		
		override public function tabFocusRect():Sprite{
			return focusRect(); 
		}
		
		override public function tab( state:int):Sprite{
			if( state & ControlState.ENABLED){
				if( state & ControlState.SELECTED){
					return new Tab_selectedUpSkin();
				}else{
					if( state & ControlState.DOWN){
						return new Tab_downSkin();
					}else if( state & ControlState.OVER){
						return new Tab_overSkin();
					}else{
						return new Tab_upSkin();
					}
				}
			}else{
				return new Tab_upSkin();
			}
		}
		
		override public function editFocusRect():Sprite{
			return focusRect(); 
		}
		
		override public function edit( state:int):Sprite{
			if( state & ControlState.ENABLED){
				return new TextInput_upSkin();
			}else{
				return new TextInput_disabledSkin();
			}
		}
		
		
		public function Flash(){
			super();
		}
	}
}



import flash.display.Sprite;

class flashFocusRect extends Sprite{
	//Focus for any component
	[Embed(source="Flash.swf", symbol="focusRectSkin")]
	static private const focusRectSkin:Class; 
	
	private var s:Sprite=new focusRectSkin();
	private var __width:int=0;
	private var __height:int=0;
	
	override public function set width(param:Number):void{
		if( __width !=param){
			__width=param;
		}
		refresh();
	}
	
	override public function get width():Number{
		return __width;
	}
	
	override public function set height(param:Number):void{
		if( __height !=param){
			__height=param;
		}
		refresh();
	}
	
	override public function get height():Number{
		return __height;
	}
	
	private function refresh():void{
		s.width=__width+4;
		s.height=__height+4;
	}
	
	
	public function flashFocusRect():void{
		addChild( s);
		s.x=s.y=-2;
		refresh();
	}
}
