package ws.equator.controls{
	import flash.text.TextFieldType;
	import flash.text.TextFieldAutoSize;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	
	public class Label extends Control {
		//public fields
		//public var maximum_width:int=-1;
		//private fields
		private var _textField:TextField=createTextField();
		private var _caption:String=controlName();
		private var prepared_caption:String=_caption;
		
		
		static private function createTextField():TextField{
			var field:TextField=new TextField();
			field.autoSize=TextFieldAutoSize.NONE;
			field.background=false;
			field.border=false;
			field.selectable=false;
			field.type=TextFieldType.DYNAMIC;
			field.wordWrap = false;
			field.multiline=true;
			field.mouseWheelEnabled=false;
			field.embedFonts=false;
			field.mouseEnabled=false;
			field.tabEnabled=false;
			return field;
		}
		
		/************************
		 * Set/get functions    *
		 ************************/
		 
		public function set caption(param:String):void{
			if( _caption !=param){
				_caption=param;
				prepared_caption=html_prepare( _caption);
				invalidate( true); 
			} 
		}
		
		public function get caption():String{
			return _caption;
		}
		
		public function get textField():TextField{
			return _textField;
		}
		
		override internal function sizeRequest():Point{
			var w:int, h:int;
			
			if(_behaviourx==ControlBehaviour.FIXED){
				w=__width;
			}else{
				w=_textField.width;
			}
			if(_behavioury==ControlBehaviour.FIXED){
				h=__height;
			}else{
				h=_textField.height; 
			}
			return new Point( w, h);
		}
		
		
		override protected function refresh_control( event:Event=null, recursive:Boolean=false):void{
			super.refresh_control( event, recursive);
			
//			_textField.wordWrap = false;
			
			_textField.defaultTextFormat= controlStyle.controlTextFormat( ControlState.create( _enabled, false, false, false));
			_textField.htmlText=prepared_caption;
			
			_textField.width=Math.round(_textField.textWidth)+4;
			_textField.height=Math.round(_textField.textHeight)+4;
			
			if(_behaviourx==ControlBehaviour.AUTO){
//				if(-1 ==maximum_width && textField.width>maximum_width){
//					_textField.wordWrap = true;
//					_textField.width = maximum_width;
//					__width = maximum_width;
//					_textField.height = Math.round(_textField.textHeight) + 4;	
//				}else{
					__width = _textField.width;
//				}
			}else if(_behaviourx==ControlBehaviour.STRETCH){
				__width=Math.max(_textField.width, __width);
			}else if (_behaviourx == ControlBehaviour.FIXED) {
				if ( _textField.wordWrap) {
					_textField.width = __width;
					_textField.height = Math.round(_textField.textHeight) + 4;										
				}
			}
			
			if(_behavioury==ControlBehaviour.AUTO){
				__height=_textField.height;
			}else if(_behavioury==ControlBehaviour.STRETCH){
				__height=Math.max(_textField.height, __height);
			}
		}
		
		
		public function Label() {
			super();
			mouseEnabled=false;
			mouseChildren=false;
			tabEnabled=false;
			tabChildren=false;
			addChild( _textField);
		}
		
		
		override public function remove():void{
			remove_from_stage();
			removeChild( _textField);
			_textField=null;
			super.remove();
		}
	}
}