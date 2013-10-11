package ws.equator.controls{
	import flash.display.Graphics;
	import flash.text.TextFormatAlign;
	import flash.text.TextFormat;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;


	public class ControlStyle implements IControlStyle{
		private static const GRADIENT_BORDER: Object = { up:{ colors:[ 0x999999, 0x000000], alphas:[ 1, 1], ratios:[ 0, 175]}, over:{ colors:[ 0x0099ff, 0x0033ff], alphas:[ 1, 1], ratios:[ 0, 175]}, down:{ colors:[ 0x999999, 0x000000], alphas:[ 1, 1], ratios:[ 0, 175]}, disabled:{ colors:[ 0x999999, 0x999999], alphas:[ 0.7, 0.7], ratios:[ 0, 175]}};
		private static const GRADIENT_BG: Object = { up:{ colors:[ 0xffffff, 0xbbddee], alphas:[ 0.50, 0.75], ratios:[ 110, 150]}, over:{ colors:[ 0xffffff, 0xbbddee], alphas:[ 0.75, 1.0], ratios:[ 110, 150]}, down:{ colors:[ 0xaaccee, 0xaaccee], alphas:[ 1, 1], ratios:[ 0, 255]}, disabled:{ colors:[ 0xffffff, 0xbbbbbb], alphas:[ 0.50, 0.75], ratios:[ 110, 150]}};
		private static const GRADIENT_REFLEX: Object = { colors:[ 0xffffff, 0xffffff], alphas:[ 0.85, 0], ratios:[ 0, 255]};
		private static const COLOR_SELECTION: uint=0x66BBEE;
		private static const COLOR_PANEL: uint=0xE7F7FF;
		private static const ELLIPSE_WIDTH: int = 10;

		static private function drawTab( target:Graphics, rect:Rectangle, radius:int):void{
			target.moveTo( rect.x, rect.y+rect.height);
			target.lineTo( rect.x, rect.y+radius);
			target.curveTo( rect.x, rect.y, rect.x+radius, rect.y);
			target.lineTo( rect.x+rect.width-radius, rect.y);
			target.curveTo( rect.x+rect.width, rect.y, rect.x+rect.width, rect.y+radius);
			target.lineTo( rect.x+rect.width, rect.y+rect.height);
			target.lineTo( rect.x, rect.y+rect.height);
		}

		static private function makeButtonSkin(state:int, rectangle:Rectangle=null, scale9grid:Rectangle=null):Sprite{
			var sprite:Sprite;
			var matrix: Matrix;
			var stateName: String;
			var rect:Rectangle;
			
			sprite=new Sprite();
			
			if( rectangle==null){
				rect=new Rectangle( 0, 0, 100, 50);
			}else{
				rect=rectangle.clone();
			}
			if( scale9grid==null){
				scale9grid=rect.clone();
				scale9grid.inflate( -ELLIPSE_WIDTH/2, -ELLIPSE_WIDTH/2);
			}

			if(state & ControlState.ENABLED){
				if( state & ControlState.DOWN || state & ControlState.SELECTED){
					stateName = "down";
				} else if( state &ControlState.OVER){
					stateName = "over";
				} else{
					stateName = "up";
				}
			} else{
				stateName = "disabled";
			}
			// ------------------
			// border
			// ------------------
			matrix = new Matrix();
			matrix.createGradientBox( rect.width, rect.height, Math.PI / 2, rect.x, rect.y);
			sprite.graphics.beginGradientFill( GradientType.LINEAR, GRADIENT_BORDER[stateName]["colors"], GRADIENT_BORDER[stateName]["alphas"], GRADIENT_BORDER[stateName]["ratios"], matrix, SpreadMethod.PAD);
			sprite.graphics.drawRoundRect( rect.x, rect.y, rect.width, rect.height, ELLIPSE_WIDTH);
			rect.inflate( -1, -1);
			sprite.graphics.drawRoundRect( rect.x, rect.y, rect.width, rect.height, ELLIPSE_WIDTH-2);
			sprite.graphics.endFill();
			// ---------------
			// background
			// ---------------
			matrix = new Matrix();
			matrix.createGradientBox( rect.width, rect.height, Math.PI / 2, rect.x, rect.y);
			sprite.graphics.beginGradientFill( GradientType.LINEAR, GRADIENT_BG[stateName]["colors"], GRADIENT_BG[stateName]["alphas"], GRADIENT_BG[stateName]["ratios"], matrix, SpreadMethod.PAD);
			sprite.graphics.drawRoundRect( rect.x, rect.y, rect.width, rect.height, ELLIPSE_WIDTH-2);
			sprite.graphics.endFill();
			// -------------
			// Reflex
			// -------------
			if( stateName != "down"){
				matrix = new Matrix();
				matrix.createGradientBox( rect.width, rect.height / 2, 0, rect.x, rect.y + rect.height - rect.height / 4);
				sprite.graphics.beginGradientFill( GradientType.RADIAL, GRADIENT_REFLEX["colors"], GRADIENT_REFLEX["alphas"], GRADIENT_REFLEX["ratios"], matrix, SpreadMethod.PAD);
				sprite.graphics.drawRect( rect.x, rect.y, rect.width, rect.height);
				sprite.graphics.endFill();
			}
			sprite.scale9Grid=scale9grid;
			
			return sprite;
		}

		static private function makeFocusRect( rectangle:Rectangle=null, scale9grid:Rectangle=null):Sprite{
			var sprite:Sprite=new Sprite();
			var rect:Rectangle;
			
			if( rectangle==null){
				rect=new Rectangle(0, 0, 100, 50);
			}else{
				rect=rectangle.clone();
			}
			if( scale9grid==null){
				scale9grid=rect.clone();
				scale9grid.inflate( -ELLIPSE_WIDTH/2, -ELLIPSE_WIDTH/2);
			}
			sprite.graphics.beginFill( 0xffffff, 1);
			sprite.graphics.drawRoundRect( rect.x, rect.y, rect.width, rect.height, ELLIPSE_WIDTH);
			sprite.graphics.endFill();
			sprite.filters = new Array( new flash.filters.GlowFilter( COLOR_SELECTION/*color*/, 0.9/*alpha*/, 2/*blurx*/, 2/*blury*/, 2/*strength*/, 3/*quality*/, false/*inner*/, true/*knockout*/));
			sprite.scale9Grid=scale9grid;
			return sprite;
		}

		static private function makeEditSkin( state:int, rectangle:Rectangle=null, scale9grid:Rectangle=null):Sprite{
			var sprite:Sprite;
			var matrix: Matrix;
			var stateName: String;
			var rect:Rectangle;
			
			sprite=new Sprite();
			
			if( rectangle==null){
				rect=new Rectangle( 0, 0, 100, 50);
			}else{
				rect=rectangle.clone();
			}
			if( scale9grid==null){
				scale9grid=rect.clone();
				scale9grid.inflate( -ELLIPSE_WIDTH/2, -ELLIPSE_WIDTH/2);
			}

			if(state & ControlState.ENABLED){
				stateName = "up";
			} else{
				stateName = "disabled";
			}
			
			//draw outline
			matrix = new Matrix();
			matrix.createGradientBox( rect.width, rect.height, Math.PI/2, rect.x, rect.y);
			sprite.graphics.beginGradientFill( GradientType.LINEAR, GRADIENT_BORDER[stateName]["colors"], GRADIENT_BORDER[stateName]["alphas"], GRADIENT_BORDER[stateName]["ratios"], matrix, SpreadMethod.PAD);
			sprite.graphics.drawRoundRect( rect.x, rect.y, rect.width, rect.height, ELLIPSE_WIDTH-2);
			rect.inflate( -1, -1);
			sprite.graphics.drawRoundRect( rect.x, rect.y, rect.width, rect.height, ELLIPSE_WIDTH-2);
			sprite.graphics.endFill();
			//---------------
			// background
			//---------------
			if( state & ControlState.ENABLED){
				sprite.graphics.beginFill(0xffffff, 0.66);
			}else{
				sprite.graphics.beginFill(0xeeeeee, 0.5);
			}
			sprite.graphics.drawRoundRect( rect.x, rect.y, rect.width, rect.height, ELLIPSE_WIDTH-2);
			sprite.graphics.endFill();
			sprite.scale9Grid=scale9grid;
			return sprite;
		}
		
		
		
		
		public function get BUTTON_HORIZ_PADDING():int{ return 6;}
		public function get BUTTON_VERT_PADDING():int{ return 3;}
		public function get BUTTON_ICON_HORIZ_PADDING():int{ return 6;}
		public function get BUTTON_ICON_VERT_PADDING():int{ return 4;}
		
		public function get COMBOBOX_PADDING():int{ return 3;}
		public function get COMBOBOX_BUTTON_WIDTH():int{ return 18;}
		public function get COMBOBOX_BORDER_WIDTH():int{ return 1;}
		
		public function get CHECKBOX_ICON_SIZE():int{ return 16;}
		public function get CHECKBOX_PADDING():int{ return 18;}
		public function get CHECKBOX_BG_SCALE():Boolean{ return false;}
		public function get CHECKBOX_BG_ALIGN():int{ return ControlAlign.LEFT;}
		public function get CHECKBOX_FOCUSRECT_SCALE():Boolean{ return false;}
		
		public function get EDIT_PADDING():int{ return 3;}
		
		public function get PANEL_BORDER_WIDTH():int{ return ELLIPSE_WIDTH/2;}
		
		

		public function button( state:int):Sprite{
			return makeButtonSkin( state);
		}
	
		public function buttonFocusRect():Sprite{
			return makeFocusRect();
		}
	
		public function checkbox(state:int):Sprite{
			var rect:Rectangle=new Rectangle(0, 0, CHECKBOX_ICON_SIZE, CHECKBOX_ICON_SIZE);
			var sprite:Sprite=makeButtonSkin( state, rect);
			
			if( state & ControlState.SELECTED){
				var x:int, y:int;
				
				sprite.graphics.beginFill( state & ControlState.ENABLED? 0x000000 : 0x333333);
				y=rect.y+Math.floor(rect.height/2)-5;
				x=rect.x+Math.floor(CHECKBOX_ICON_SIZE/2)-6;
				sprite.graphics.moveTo(x+2, y+4);
				sprite.graphics.lineTo(x+5, y+9);
				sprite.graphics.lineTo(x+7, y+9);
				sprite.graphics.lineTo(x+12, y-2);
				sprite.graphics.lineTo(x+11, y-2);
				sprite.graphics.lineTo(x+6, y+6);
				sprite.graphics.lineTo(x+4, y+4);
				sprite.graphics.endFill();
			}
			return sprite;
		}
	
		public function checkboxFocusRect():Sprite{
			var rect:Rectangle=new Rectangle(0, 0, CHECKBOX_ICON_SIZE, CHECKBOX_ICON_SIZE);
			return makeFocusRect( rect);
		} 
	
		public function edit( state:int): Sprite{
			return makeEditSkin(state);
		}
		
		public function editFocusRect():Sprite{
			return makeFocusRect();		
		}
	
		public function combobox( state:int):Sprite{
			var rect:Rectangle=new Rectangle(0, 0, 100, 25);
			var sprite:Sprite=makeButtonSkin( state, rect);
			// -----------------
			// arrow delimiter
			// ----------------
			var ax: int, ay: int;
			var w: int = rect.width - 2;
			var arrow_w: int = Math.round( COMBOBOX_BUTTON_WIDTH / 6);

			sprite.graphics.lineStyle( 1, 0x000000, 33);
			sprite.graphics.moveTo( w - COMBOBOX_BUTTON_WIDTH, COMBOBOX_PADDING);
			sprite.graphics.lineTo( w - COMBOBOX_BUTTON_WIDTH, rect.height - COMBOBOX_PADDING);
			sprite.graphics.lineStyle( 1, 0xffffff, 66);
			sprite.graphics.moveTo( w - COMBOBOX_BUTTON_WIDTH+1, COMBOBOX_PADDING);
			sprite.graphics.lineTo( w - COMBOBOX_BUTTON_WIDTH+1, rect.height - COMBOBOX_PADDING);

			// ------------------
			// arrow
			// ------------------
			ax = Math.round( w - COMBOBOX_BUTTON_WIDTH + (rect.width - w + COMBOBOX_BUTTON_WIDTH) / 2 - 1);
			if( state &ControlState.DOWN){
				ay = Math.round( rect.height / 2 + 1);
				
			} else{
				ay = Math.round( rect.height / 2);
			}
			sprite.graphics.lineStyle( 1, 0x00, 66);
			sprite.graphics.moveTo( ax - arrow_w, ay - arrow_w);
			sprite.graphics.lineTo( ax, ay - arrow_w * 2);
			sprite.graphics.lineTo( ax + arrow_w, ay - arrow_w);
			sprite.graphics.moveTo( ax - arrow_w, ay + arrow_w);
			sprite.graphics.lineTo( ax, ay + arrow_w * 2);
			sprite.graphics.lineTo( ax + arrow_w, ay + arrow_w);
			sprite.graphics.lineStyle();
			sprite.scale9Grid=new Rectangle(ELLIPSE_WIDTH/2, ELLIPSE_WIDTH/2, rect.width/2, rect.height-ELLIPSE_WIDTH);
			return sprite;
		}
	
		public function comboboxFocusRect():Sprite{
			return makeFocusRect();
		}
	
		public function comboboxDrawer():Sprite{
			var sprite:Sprite=new Sprite();
			var matrix:Matrix = new Matrix();
			var colors:Array, alphas:Array, ratios:Array;
			var rect:Rectangle=new Rectangle(0, 0, 100, 50);
			var scale9grid:Rectangle=rect.clone();
			scale9grid.inflate(-ELLIPSE_WIDTH/2, -ELLIPSE_WIDTH/2);

			//--------------------
			// outline
			//--------------------
			matrix.createGradientBox( rect.width, rect.height, Math.PI/2, 0, rect.y+rect.height/2);
			sprite.graphics.beginGradientFill( GradientType.LINEAR, GRADIENT_BORDER["up"]["colors"], GRADIENT_BORDER["up"]["alphas"], GRADIENT_BORDER["up"]["ratios"], matrix, SpreadMethod.PAD);
			sprite.graphics.drawRoundRect(rect.x, rect.y, rect.width, rect.height, ELLIPSE_WIDTH);
			
			//-------------
			// continue outline
			//--------------
			rect.inflate( -1, -1);
			sprite.graphics.drawRoundRect( rect.x, rect.y, rect.width, rect.height, ELLIPSE_WIDTH-2);
			sprite.graphics.endFill();
			
			//---------------
			// background
			//---------------
			
			colors=[0xffffff, 0xbbddee];
			alphas=[0.9, 0.9];
			ratios=[0, 255];
			sprite.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix, SpreadMethod.PAD);
			sprite.graphics.drawRoundRect( rect.x, rect.y, rect.width, rect.height, ELLIPSE_WIDTH-2);
			sprite.graphics.endFill();
			sprite.scale9Grid=scale9grid;
			return sprite;
		}
	
		public function comboboxDrawerItemsMask():Sprite{
			var shape:Sprite=new Sprite();
			var rect:Rectangle=new Rectangle( 0, 0, 100, 100);
			var scale9grid:Rectangle=rect.clone();
			scale9grid.inflate(-ELLIPSE_WIDTH/2, -ELLIPSE_WIDTH/2);
			
			shape.graphics.beginFill( 0xffffff, 0);
			shape.graphics.drawRect( rect.x, rect.y, rect.width, rect.height);
			shape.graphics.endFill();
			rect.inflate( -COMBOBOX_BORDER_WIDTH, -COMBOBOX_BORDER_WIDTH);
			shape.graphics.beginFill( 0x000000, 1);
			shape.graphics.drawRoundRect( rect.x, rect.y, rect.width, rect.height, ELLIPSE_WIDTH-COMBOBOX_BORDER_WIDTH*2);
			shape.graphics.endFill();
			shape.scale9Grid=scale9grid;
			return shape;
		}
	
		public function drawComboboxItem( sprite:Sprite, rect:Rectangle, state:int):void{
			if( state & ControlState.OVER || state & ControlState.SELECTED){
				if( state & ControlState.OVER){
					sprite.graphics.beginFill( COLOR_SELECTION, 1);
				}else{
					sprite.graphics.beginFill( COLOR_SELECTION, 0.3);
				}
				sprite.graphics.drawRoundRect(rect.x+COMBOBOX_BORDER_WIDTH, rect.y+COMBOBOX_BORDER_WIDTH, rect.width-2*COMBOBOX_BORDER_WIDTH, rect.height-2*COMBOBOX_BORDER_WIDTH, ELLIPSE_WIDTH-2*COMBOBOX_BORDER_WIDTH);
				sprite.graphics.endFill();
			}
		}

		public function tab( state:int):Sprite{
			var sprite:Sprite;
			var matrix: Matrix;
			var stateName: String;
			var rect:Rectangle;
			var scale9grid:Rectangle;
			
			sprite=new Sprite();
			
			rect=new Rectangle( 0, 0, 100, 50);
			scale9grid=rect.clone();
			scale9grid.inflate( -ELLIPSE_WIDTH/2, -ELLIPSE_WIDTH/2);
			
			if(state & ControlState.ENABLED){
				if( state & ControlState.DOWN || state & ControlState.SELECTED){
					stateName = "down";
				} else if( state &ControlState.OVER){
					stateName = "over";
				} else{
					stateName = "up";
				}
			} else{
				stateName = "disabled";
			}
			// ------------------
			// border
			// ------------------
			matrix = new Matrix();
			matrix.createGradientBox( rect.width, rect.height, Math.PI / 2, rect.x, rect.y);
			sprite.graphics.beginGradientFill( GradientType.LINEAR, GRADIENT_BORDER[stateName]["colors"], GRADIENT_BORDER[stateName]["alphas"], GRADIENT_BORDER[stateName]["ratios"], matrix, SpreadMethod.PAD);
			drawTab( sprite.graphics, rect, ELLIPSE_WIDTH/2);
			rect.inflate( -1, -1);
			drawTab( sprite.graphics, rect, ELLIPSE_WIDTH/2-1);
			sprite.graphics.endFill();
			// ---------------
			// background
			// ---------------
			if( state & ControlState.SELECTED){
				sprite.graphics.beginFill( COLOR_PANEL, 1);
				rect.height++;
				drawTab( sprite.graphics, rect, ELLIPSE_WIDTH/2-1);
				sprite.graphics.endFill();
			}else{
				matrix = new Matrix();
				matrix.createGradientBox( rect.width, rect.height, Math.PI / 2, rect.x, rect.y);
				sprite.graphics.beginGradientFill( GradientType.LINEAR, GRADIENT_BG[stateName]["colors"], GRADIENT_BG[stateName]["alphas"], GRADIENT_BG[stateName]["ratios"], matrix, SpreadMethod.PAD);
				drawTab( sprite.graphics, rect, ELLIPSE_WIDTH/2-1);
				sprite.graphics.endFill();
			}
			// -------------
			// Reflex
			// -------------
			if( stateName != "down"){
				matrix = new Matrix();
				matrix.createGradientBox( rect.width, rect.height / 2, 0, rect.x, rect.y + rect.height - rect.height / 4);
				sprite.graphics.beginGradientFill( GradientType.RADIAL, GRADIENT_REFLEX["colors"], GRADIENT_REFLEX["alphas"], GRADIENT_REFLEX["ratios"], matrix, SpreadMethod.PAD);
				sprite.graphics.drawRect( rect.x, rect.y, rect.width, rect.height);
				sprite.graphics.endFill();
			}
			sprite.scale9Grid=scale9grid;
			
			return sprite;
		}
		
		public function tabFocusRect():Sprite{
			return null;
		}
		
		public function tabPanel(): Sprite{
			var rect:Rectangle=new Rectangle(0, 0, 100, 50);
			var sprite:Sprite=new Sprite();
			var scale9grid:Rectangle=rect.clone();
			scale9grid.inflate(-ELLIPSE_WIDTH/2, -ELLIPSE_WIDTH/2);
						
			sprite.graphics.beginFill( GRADIENT_BORDER[ "up"]["colors"][1], GRADIENT_BORDER[ "up"]["alphas"][1]);
			sprite.graphics.drawRect( rect.x, rect.y, rect.width, rect.height);
			rect.inflate( -1, -1);
			sprite.graphics.drawRect( rect.x, rect.y, rect.width, rect.height);
			sprite.graphics.endFill();
			
			sprite.graphics.beginFill( COLOR_PANEL, 1);
			sprite.graphics.drawRect( rect.x, rect.y, rect.width, rect.height);
			sprite.graphics.endFill();
			
			
			sprite.scale9Grid=scale9grid;
			return sprite;
		}
		
		public function panel(): Sprite{
			return tabPanel();
		}
		
		public function controlTextFormat( state: int):TextFormat{
			var ret: TextFormat = new TextFormat();
			ret.font = "_sans";
			ret.size = 12;
			ret.align = TextFormatAlign.LEFT;
			if(state &ControlState.ENABLED){
				if( state & ControlState.DOWN){
					ret.color = 0x000000;
				} else if( state &ControlState.OVER){
					ret.color = 0x000000;
				} else{
					ret.color = 0x333333;
				}
			} else{
				ret.color = 0x777777;
			}
			return ret;
		}

		public function ControlStyle(){
		} 
		
	}
}
