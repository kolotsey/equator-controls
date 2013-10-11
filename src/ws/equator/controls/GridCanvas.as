package ws.equator.controls{

	import flash.display.Shape;
	import flash.text.TextFormatAlign;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.Sprite;

	public class GridCanvas extends Control {
		/* Colors and fonts could be changed by user. 
		 * resise() should be called to update colors  
		 */
		private static var CANVAS_SIZE:int=1000; 
		private static var CANVAS_COLOR:int=0xffffff;
		private static var CANVAS_ALPHA:Number=1;
		private static var GRID_BORDER_COLOR:int=0x000033;
		private static var GRID_LINE_COLOR:int=0x000099;
		private static var GRID_LINE_ALPHA:Number=0.5;
		private static var TEXT_COLOR:int=0x000000;
		
		private static var MIN_WIDTH:int=200;
		private static var MIN_HEIGHT:int=200;
		
		
		/* Movieclips and textfields
		 */
		private var gridmc:Sprite;
		private var canvasArray:Array=new Array();
		private var canvas:Sprite;
		private var smask:Shape;
		private var bgmc:Sprite;
		private var xfields:Array;
		private var yfields:Array;
		
		/* minimum and maximum values of the field is set before the gridmc is created
		 */
		public var minx:Number=0;
		public var maxx:Number=100;
		public var miny:Number=0;
		public var maxy:Number=100;
		
		private static var textFormat:TextFormat=new TextFormat( "_sans", 16, TEXT_COLOR, false, false, false, null, null, TextFormatAlign.CENTER);
		
		private var canvasConstraints:Rectangle;
		
		
		static private function toFixed( n:Number, factor:int):Number{
			factor=Math.pow(10, factor);
			return (Math.round(n * factor)/factor);
		}
		
		static private function createField():TextField{
			var field:TextField;
			field=new TextField();
			field.autoSize=TextFieldAutoSize.LEFT;
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
			
		
		/**
		 * Calculate absolute coordinates to relative to the canvas
		 */
		public function coord2x(c:Number):Number{
			return canvasConstraints.width*(c-minx)/(maxx-minx);
		}
		public function coord2y(c:Number):Number{
			return canvasConstraints.height-canvasConstraints.height*(c-miny)/(maxy-miny);
		}
		
		/**
		 * Calculate relative coordinates to absolute
		 */
		public function x2coord(x:Number):Number{
			return x*(maxx-minx)/canvasConstraints.width+minx;
		}
		public function y2coord(y:Number):Number{
			return (canvasConstraints.height-y)*(maxy-miny)/canvasConstraints.height+miny;
		}
		
		
		
		
		
		
		
		/**
		 * Function returns canvas movieclip
		 */
		public function addCanvas():Sprite{
			var ret:Sprite=new Sprite();
			ret.x=canvasConstraints.x;
			ret.y=canvasConstraints.y;
			canvas.addChild( ret);
			canvasArray.push(ret); 
			return ret;
		}
		
		public function getGlobalCanvasConstraints():Rectangle{
			var ret:Rectangle=new Rectangle();
			var o:Point=new Point( canvasConstraints.x, canvasConstraints.y);
			o=localToGlobal(o);
			ret.x=o.x;
			ret.y=o.y;
			ret.width=canvasConstraints.width;
			ret.height=canvasConstraints.height;
			return ret;
		}
		
		public function getCanvasConstraints():Rectangle{
			return canvasConstraints;
		}
		
		
		override internal function sizeRequest():Point{
			var w:int, h:int;
			
			if(_behaviourx==ControlBehaviour.FIXED){
				w=__width;
			}else{
				w=MIN_WIDTH;
			}
			if(_behavioury==ControlBehaviour.FIXED){
				h=__height;
			}else{
				h=MIN_HEIGHT; 
			}
			return new Point( w, h);
		}
		
		override protected function refresh_control( event:Event=null, recursive:Boolean=false):void{
			super.refresh_control( event, recursive);
			
			if(_behaviourx==ControlBehaviour.AUTO){
				__width=MIN_WIDTH;
			}else if(_behaviourx==ControlBehaviour.STRETCH){
				__width=Math.max(MIN_WIDTH, __width);
			}
			if(_behavioury==ControlBehaviour.AUTO){
				__height=MIN_HEIGHT;
			}else if(_behavioury==ControlBehaviour.STRETCH){
				__height=Math.max(MIN_HEIGHT, __height);
			}
			
			canvasConstraints=drawGrid();
			//modify canvasmc to match the container
			for( var i:String in canvasArray){
				(canvasArray[i] as Sprite).x=canvasConstraints.x;
				(canvasArray[i] as Sprite).y=canvasConstraints.y;
			}
			bgmc.x=canvasConstraints.x;
			bgmc.y=canvasConstraints.y;
			bgmc.width=canvasConstraints.width;
			bgmc.height=canvasConstraints.height;
			smask.x=canvasConstraints.x;
			smask.y=canvasConstraints.y;
			smask.width=canvasConstraints.width;
			smask.height=canvasConstraints.height;
		}
		
		
		/**
		 * Draws a grid on 'gridmc' movieclip and returns object that
		 * specifies canvas position and size
		 * @return Object with the fields x,y,w,h that specifies position
		 *    and size of the canvas
		 */
		private function drawGrid():Rectangle{
			var i:Number, j:Number, a:int;
			var field:TextField;
			var leftfield_width:int;
			var bottomfield_height:int;
			var ret:Rectangle=new Rectangle();
			var xgrid:Object;
			var ygrid:Object;
			var spanx:Number=maxx-minx;
			var spany:Number=maxy-miny;
			
			gridmc.graphics.clear();
			
			xgrid=GetDelta.getDelta(minx, maxx, Math.max(2, Math.floor(__width/80)));
			ygrid=GetDelta.getDelta(miny, maxy, Math.max(2, Math.floor(__height/40)));
			
			//check count of lines in the grid and remove non-needed textfields
			while(xfields.length>xgrid["count"]){
				field=xfields.pop();
				gridmc.removeChild(field);
			}
			while(yfields.length>ygrid["count"]){
				field=yfields.pop();
				gridmc.removeChild(field);
			}
			
			//create textfields  that are not exist, set their text and 
			//determine maximum width and height of textfields
			bottomfield_height=0;
			for(i=0; i<xgrid["count"]; i++){
				j=xgrid["min"]+xgrid["delta"]*i;
				if(i<xfields.length){
					field=xfields[i];
				}else{
					field=createField();
					gridmc.addChild( field);
					xfields.push(field);
				}
				field.setTextFormat( textFormat);
				field.defaultTextFormat=textFormat;
				
				field.text=String(toFixed(j, 10));
				field.width=field.textWidth+4;
				field.height=field.textHeight+4;
				
				bottomfield_height=Math.max(bottomfield_height, field.height);
			}
			leftfield_width=0;
			for(i=0; i<ygrid["count"]; i++){
				j=ygrid["min"]+ygrid["delta"]*i;
				if(i<yfields.length){
					field=yfields[i];
				}else{
					field=createField();
					gridmc.addChild( field);
					yfields.push(field);
				}
				field.setTextFormat( textFormat);
				field.defaultTextFormat=textFormat;
				
				field.text=String(toFixed(j, 10));
				field.width=field.textWidth+4;
				field.height=field.textHeight+2;
				
				leftfield_width=Math.max(leftfield_width, field.width);
			}
			
			ret.x=Math.ceil(leftfield_width+5);
			ret.y=0;
			ret.width=Math.floor(__width-ret.x);
			ret.height=Math.floor(__height-bottomfield_height-5);
			
			gridmc.graphics.lineStyle(0, GRID_LINE_COLOR, GRID_LINE_ALPHA);
			
			//draw grid for x axis
			for(i=0; i<xgrid["count"]; i++){
				j=xgrid["min"]+xgrid["delta"]*i;
				a=Math.round(ret.x+((j-minx)*ret.width/spanx));
				gridmc.graphics.moveTo(a, ret.y);
				gridmc.graphics.lineTo(a, ret.y+ret.height);
				field=xfields[i];
				field.x=a-Math.round(field.width/2);
				field.y=ret.y+ret.height+5;
			}
			//draw grid for y axis
			for(i=0; i<ygrid["count"]; i++){
				j=ygrid["min"]+ygrid["delta"]*i;
				a=Math.round(ret.y+ret.height-((j-miny)*ret.height/spany));
				gridmc.graphics.moveTo(ret.x, a);
				gridmc.graphics.lineTo(ret.x+ret.width, a);
				field=yfields[i];
				field.x=ret.x-field.width-5;
				field.y=a-Math.round(field.height/2);
			}
			
			//draw grid border
			gridmc.graphics.lineStyle(0, GRID_BORDER_COLOR, 1);
			gridmc.graphics.drawRect( ret.x, ret.y, ret.width, ret.height);
			return ret;
		}
		
		public function redraw():void{
			canvasConstraints=drawGrid();
		} 
		
		
		function GridCanvas():void{
			super();
			
			xfields=new Array();
			yfields=new Array();
			
			bgmc=new Sprite();
			bgmc.graphics.beginFill(CANVAS_COLOR, CANVAS_ALPHA);
			bgmc.graphics.drawRect(0, 0, CANVAS_SIZE, CANVAS_SIZE);
			bgmc.graphics.endFill();
			bgmc.tabEnabled=false;
			bgmc.mouseEnabled=true;
			addChild(bgmc);
			
			canvas=new Sprite();
			canvas.mouseEnabled=true;
			canvas.mouseChildren=true;
			canvas.tabEnabled=false;
			canvas.tabChildren=false;
			addChild(canvas);
			
			smask=new Shape();
//			smask.graphics.beginFill(0x00);
//			bgmc.graphics.drawRect(0, 0, CANVAS_SIZE, CANVAS_SIZE);
//			smask.graphics.endFill();
//			addChild(smask);
//			canvas.mask=smask;
			
			gridmc=new Sprite();
			gridmc.mouseEnabled=false;
			gridmc.tabEnabled=false;
			addChild(gridmc);
			
			mouseEnabled=true;
			mouseChildren=true;
			tabEnabled=false; 
			tabChildren=false;
			
			__width=MIN_WIDTH;
			__height=MIN_HEIGHT;
			redraw();
		}
		
		override public function remove():void{
			removeChild(bgmc);
			bgmc=null;
			
			for( var i:String in canvasArray){
				removeChild(canvasArray[i]);
				canvasArray[i]=null;
			}
			canvasArray=null;
			removeChild( canvas);
			canvas.mask=null;
			canvas=null;
			
			removeChild( smask);
			smask=null;
			
			removeChild(gridmc);
			gridmc=null;
			super.remove();
		}
	}
}
