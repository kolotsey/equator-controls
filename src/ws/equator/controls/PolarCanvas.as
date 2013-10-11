package ws.equator.controls{

	import flash.display.Shape;
	import flash.text.TextFormatAlign;
	import flash.text.TextFormat;
	import flash.geom.Matrix;
	import flash.display.SpreadMethod;
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.geom.Rectangle;



	public class PolarCanvas extends Control{
		private static var CANVAS_SIZE:int=1000; 
		private static var CANVAS_COLOR:int=0x000000;
		private static var CANVAS_ALPHA:Number=1;
		private static var GRID_BORDER_COLOR:int=0x229900;
		private static var GRID_LINE_COLOR:int=0x229900;
		private static var GRID_LINE_ALPHA:Number=0.5;
		private static var ANGLE_TEXT_COLOR:int=0x000000;
		private static var DISTANCE_TEXT_COLOR:int=0x229900;
		
		public static var calibrate_shift:Number=Math.PI/2;
		public static var calibrate_is_clockwise:Boolean=false;
		public static var calibrate_overload:Number=Math.PI;
		
		private static var MIN_SIZE:int=200;
		
		private var gridmc:Sprite;
		private var canvasArray:Array=new Array();
		private var canvas:Sprite;
		private var smask:Shape;
		private var bgmc:Sprite;
		private var afields:Array;
		private var xfields:Array;
		
		public var mina:int=0;
		public var maxa:int=90;
		public var minx:int=0;
		public var maxx:int=100;
		
		private static var textFormatAngle:TextFormat=new TextFormat( "_sans", 16, ANGLE_TEXT_COLOR, false, false, false, null, null, TextFormatAlign.CENTER);
		private static var textFormatDistance:TextFormat=new TextFormat( "_sans", 14, DISTANCE_TEXT_COLOR, false, false, false, null, null, TextFormatAlign.CENTER);
		
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
		 * Cobvert absolute coordinates to relative to the canvas
		 */
		public function coord2polar(c:Point):Point{
			var x:int=c.x;
			var y:int=c.y;
			var a:Number;
			var r:Number=minx+((maxx-minx)*Math.sqrt(x*x+y*y)*2/canvasConstraints.width);
			if( calibrate_is_clockwise){
				a=Math.atan2(y, x);
				a+=calibrate_shift;
			}else{
				a=-Math.atan2(y, x);
				a-=calibrate_shift;
			}
			
			while( a>calibrate_overload){
				a-=Math.PI*2;
			}
			while( a<calibrate_overload-Math.PI*2){
				a+=Math.PI*2;
			}
			
			return new Point( r, a);
		}
		
		
		/**
		 * Convert relative coordinates to absolute
		 */
		public function polar2coord(c:Point):Point{
			var x:int=(c.x-minx)*canvasConstraints.width/(2*(maxx-minx));
			if( calibrate_is_clockwise){
				return new Point( x*Math.cos( -c.y+calibrate_shift), -x*Math.sin( -c.y+calibrate_shift));
			}else{
				return new Point( x*Math.cos( c.y+calibrate_shift), -x*Math.sin( c.y+calibrate_shift));
			}
		}

		
		/**
		 * Function returns canvas movieclip
		 */
		public function addCanvas():Sprite{
			var ret:Sprite=new Sprite();
			ret.x=canvasConstraints.x+Math.round(canvasConstraints.width/2);
			ret.y=canvasConstraints.y+Math.round(canvasConstraints.height/2);
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
				w=MIN_SIZE;
			}
			if(_behavioury==ControlBehaviour.FIXED){
				h=__height;
			}else{
				h=MIN_SIZE; 
			}
			return new Point( w, h);
		}
		
		override protected function refresh_control( event:Event=null, recursive:Boolean=false):void{
			super.refresh_control( event, recursive);
		
			if(_behaviourx==ControlBehaviour.AUTO){
				__width=MIN_SIZE;
			}else if(_behaviourx==ControlBehaviour.STRETCH){
				__width=Math.max(MIN_SIZE, __width);
			}
			if(_behavioury==ControlBehaviour.AUTO){
				__height=MIN_SIZE;
			}else if(_behavioury==ControlBehaviour.STRETCH){
				__height=Math.max(MIN_SIZE, __height);
			}
	
			canvasConstraints=drawGrid();
			//modify canvasmc to match the container
			for( var i:String in canvasArray){
				(canvasArray[i] as Sprite).x=canvasConstraints.x+Math.round(canvasConstraints.width/2);
				(canvasArray[i] as Sprite).y=canvasConstraints.y+Math.round(canvasConstraints.height/2);
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
			var i:int, j:Number;
			var field:TextField;
			var fieldWidth:int;
			var fieldHeight:int;
			var ret:Rectangle=new Rectangle();
			var xgrid:Object;
			var agrid:Object;
			var spanx:Number=maxx-minx;
			var spana:Number=maxa-mina;
			var cx:int;
			var cy:int;
			var cr:int;
			
			gridmc.graphics.clear();
			
			xgrid=GetDelta.getDelta(minx, maxx, Math.max(2, Math.floor( (Math.min(__width, __height)/2)/80)));
			agrid=GetDelta.getDelta(mina, maxa, Math.max(Math.floor(spana/30), Math.floor( (Math.min(__width, __height)/2)/20)), true);
			
			//check count of lines in the grid and remove non-needed textfields
			while(xfields.length>xgrid["count"]-1){
				field=xfields.pop();
				gridmc.removeChild(field);
			}
			while(afields.length>agrid["count"]){
				field=afields.pop();
				gridmc.removeChild(field);
			}
			
			//textFormatAngle.size=(__width<300? 14 : __width<500? 16 : __width<800? 18 : 20);
			//textFormatDistance.size=(__width<300? 12 : __width<500? 14 : __width<800? 16 : 18);
			//create textfields  that do not exist, set their text and 
			for(i=0; i<xgrid["count"]-1; i++){
				j=xgrid["min"]+xgrid["delta"]*i;
				if(i<xfields.length){
					field=xfields[i];
				}else{
					field=createField();
					gridmc.addChild( field);
					xfields.push(field);
				}
				field.setTextFormat( textFormatDistance);
				field.defaultTextFormat=textFormatDistance;
				
				field.text=String(toFixed(j, 10));
				field.width=field.textWidth+4;
				field.height=field.textHeight+4;
			}
			//create textfields  that do not exist, set their text and 
			//determine maximum width and height of textfields
			fieldWidth=fieldHeight=0;
			for(i=0; i<agrid["count"]; i++){
				j=agrid["min"]+agrid["delta"]*i;
				if(i<afields.length){
					field=afields[i];
				}else{
					field=createField();
					gridmc.addChild( field);
					afields.push(field);
				}
				field.setTextFormat( textFormatAngle);
				field.defaultTextFormat=textFormatAngle;
				
				field.text=String(toFixed(j, 10));
				field.width=field.textWidth+4;
				field.height=field.textHeight+4;
				fieldWidth=Math.max(fieldWidth, field.width);
				fieldHeight=Math.max(fieldHeight, field.height);
			}
			
			ret.x=Math.ceil(fieldWidth+5);
			ret.y=Math.ceil(fieldHeight+5);
			var w:int=Math.min( Math.floor(__width-ret.x*2), Math.floor(__height-ret.y*2)); 
			ret.width=w;
			ret.height=w;
			ret.x=Math.floor((__width-ret.width)/2);
			ret.y=Math.floor((__height-ret.height)/2);
			
			cr=Math.round(ret.width/2);
			cx=ret.x+cr;
			cy=ret.y+cr;
			
			//draw circles
			for(i=0; i<xgrid["count"]; i++){
				var r:int;
				j=xgrid["min"]+xgrid["delta"]*i;
				r=Math.round((j-minx)*cr/spanx);
				gridmc.graphics.lineStyle(0, GRID_LINE_COLOR, Math.min(GRID_LINE_ALPHA, (r*GRID_LINE_ALPHA*2)/cr));
				gridmc.graphics.drawCircle(cx, cy, r);
				
				
				if( i<xgrid["count"]-1){
					field=xfields[i];
					field.x=cx+2;
					field.y=cy-r-fieldHeight;
				}
			}
			//draw grid for angle axis
			for(i=0; i<agrid["count"]; i++){
				var ang:Number;
				var c:Number;
				var s:Number;
				var matrix:Matrix=new Matrix();
				
				j=agrid["min"]+agrid["delta"]*i;
				if(calibrate_is_clockwise){
					ang=-j*Math.PI/180+calibrate_shift;
				}else{
					ang=j*Math.PI/180+calibrate_shift;
				}
				
				s=Math.sin(ang);
				c=Math.cos(ang);
				
				matrix.createGradientBox( __width, __height, 0, 0, 0);
				gridmc.graphics.lineStyle(0, GRID_LINE_COLOR, GRID_LINE_ALPHA);
				gridmc.graphics.lineGradientStyle(GradientType.RADIAL, [GRID_LINE_COLOR, GRID_LINE_COLOR], [0, GRID_LINE_ALPHA], [0, 127], matrix, SpreadMethod.PAD);
				gridmc.graphics.moveTo(cx, cy);
				
				gridmc.graphics.lineTo(cx+cr*c, cy-cr*s);
				
				field=afields[i];
				if( c>0){
					field.x=cx+cr*c+3;
				}else{
					field.x=cx+cr*c-field.width-3;
				}
				if(s>0){
					field.y=cy-cr*s-fieldHeight-3;
				}else{
					field.y=cy-cr*s+3;
				}
			}
			//draw border
			gridmc.graphics.lineStyle( 4, GRID_BORDER_COLOR, GRID_LINE_ALPHA);
			gridmc.graphics.drawCircle( cx, cy, cr);
				
			return ret;
		}
		
		public function redraw():void{
			canvasConstraints=drawGrid();
		}
		
		public function PolarCanvas(){
			super();
			xfields=new Array();
			afields=new Array();
			
			bgmc=new Sprite();
			bgmc.graphics.beginFill(CANVAS_COLOR, CANVAS_ALPHA);
			bgmc.graphics.drawCircle(CANVAS_SIZE/2, CANVAS_SIZE/2, CANVAS_SIZE/2);
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
			smask.graphics.beginFill(CANVAS_COLOR, CANVAS_ALPHA);
			smask.graphics.drawCircle(CANVAS_SIZE/2, CANVAS_SIZE/2, CANVAS_SIZE/2);
			smask.graphics.endFill();
			addChild(smask);
			canvas.mask=smask;
			
			gridmc=new Sprite();
			gridmc.mouseEnabled=false;
			gridmc.tabEnabled=false;
			addChild(gridmc);
			
			mouseEnabled=true;
			mouseChildren=true;
			tabEnabled=false;
			tabChildren=false;
			
			__width=MIN_SIZE;
			__height=MIN_SIZE;
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
