package ws.equator.controls{
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldType;
	import flash.events.FocusEvent;
	import flash.text.TextField;

	public class Edit extends InteractiveControl {
		//private fields
		private var _textField:TextField=createTextField();
		private var _text:String="";
		private var _minWidth:int=150;


		static private function createTextField():TextField{
			var field:TextField=new TextField();

			field.autoSize=TextFieldAutoSize.NONE;
			field.background=false;
			field.border=false;
			field.selectable=true;
			field.type=TextFieldType.INPUT;
			field.wordWrap=field.multiline=false;
			field.mouseWheelEnabled=false;
			field.embedFonts=false;
			field.mouseEnabled=true;
			field.tabEnabled=false;
			return field;
		}
		
		/************************
		 * Set/get functions    *
		 ************************/
		 
		public function set text(param:String):void{
//FIXME: When user changes the text by typing it, the value of _text is not changed
//       Need to add a callback onChange() and set new value to variable _text there
//			if( _text !=param){
				_text=param;
				_textField.text=param;
				invalidate();
//			}
		}
		
		public function get text():String{
			return _textField.text;
		}
		
		public function set minWidth(param:Number):void{
			if( _minWidth !=param){
				_minWidth=Math.max(2*controlStyle.EDIT_PADDING, Math.round(param));
				invalidate( true);
			}
		}
		
		public function get minWidth():Number{
			return _minWidth;
		}
		
		public function get textField():TextField{
			return _textField;
		}
		
		override protected function makeEnabled():void{
			if(_enabled){
				tabEnabled = true;
				mouseEnabled = true;

				_textField.addEventListener(FocusEvent.FOCUS_IN, on_set_focus);
				_textField.addEventListener(FocusEvent.FOCUS_OUT, on_kill_focus);
				addEventListener(FocusEvent.FOCUS_IN, on_set_focus);
				addEventListener(FocusEvent.FOCUS_OUT, on_kill_focus);
				_textField.type=TextFieldType.INPUT;
				state = ControlState.create( true, false, false, false);

			}else{
				tabEnabled = false;
				mouseEnabled = true;
				
				_textField.removeEventListener(FocusEvent.FOCUS_IN, on_set_focus);
				_textField.removeEventListener(FocusEvent.FOCUS_OUT, on_kill_focus);
				removeEventListener(FocusEvent.FOCUS_IN, on_set_focus);
				removeEventListener(FocusEvent.FOCUS_OUT, on_kill_focus);
				_textField.type=TextFieldType.DYNAMIC;
				if( stage && stage.focus == this){
					stage.focus = null;
				}
				state = ControlState.create( false, false, false, false);
			}
			setVisibleSprite();
			_textField.defaultTextFormat=controlStyle.controlTextFormat(state);
			_textField.setTextFormat( controlStyle.controlTextFormat(state));
		}
		
		override protected function getStateSprite():Sprite{
			return controlStyle.edit(state); 
		}
		
		override protected function getFocusSprite():Sprite{
			return controlStyle.editFocusRect();
		}
			
		override internal function sizeRequest():Point{
			var w:int, h:int;
			
			if(_behaviourx==ControlBehaviour.FIXED){
				w=__width;
			}else{
				w=_minWidth;
			}
			if(_behavioury==ControlBehaviour.FIXED){
				h=__height;
			}else{
				h=_textField.textHeight+4+controlStyle.EDIT_PADDING * 2; 
			}
			return new Point( w, h);
		}
		
		
		override protected function refresh_control( event: Event = null, recursive:Boolean=false): void{
			var empty:Boolean=false;
			super.refresh_control( event, recursive);
			
			_textField.setTextFormat( controlStyle.controlTextFormat( state));
			_textField.defaultTextFormat= controlStyle.controlTextFormat( state);
			_textField.x=_textField.y=controlStyle.EDIT_PADDING;
			
			if(_behaviourx==ControlBehaviour.AUTO){
				__width=_minWidth;
			}else if(_behaviourx==ControlBehaviour.STRETCH){
				__width=Math.max(_minWidth, __width);
			}
			if( _textField.text==""){
				empty=true;
				_textField.text="|";
			}
			if(_behavioury==ControlBehaviour.AUTO){
				__height=_textField.textHeight+4+controlStyle.EDIT_PADDING * 2;
			}else if(_behavioury==ControlBehaviour.STRETCH){
				__height=Math.max(_textField.textHeight+4+controlStyle.EDIT_PADDING * 2, __height);
			}
			if( empty){
				_textField.text="";
			}
			
			_textField.width = __width-controlStyle.EDIT_PADDING * 2;
			_textField.height = __height-controlStyle.EDIT_PADDING * 2;
			
			resizeSprite();
		}
		
		private function on_set_focus( ev:Event):void{
			if( ev.target==_textField){
				
				setVisibleSprite();
				_textField.setTextFormat( controlStyle.controlTextFormat(state));
				_textField.defaultTextFormat=controlStyle.controlTextFormat(state);
			}else{
				stage.focus=_textField;
			}
		}
		
		private function on_kill_focus(ev:Event):void{
			if( ev.target==_textField){
				setVisibleSprite();
				_textField.setTextFormat( controlStyle.controlTextFormat(state));
				_textField.defaultTextFormat=controlStyle.controlTextFormat(state);
			}
		}
		
		private function textFieldChange(e:Event):void{
			dispatchEvent( new Event( Event.CHANGE));
		}
		
		public function Edit() {
			super();
			_textField.setTextFormat( controlStyle.controlTextFormat(state));
			_textField.defaultTextFormat=controlStyle.controlTextFormat(state);
			_textField.addEventListener( Event.CHANGE, textFieldChange);
			addChild( _textField);
		}
		
		override public function remove():void{
			remove_from_stage();
			
			_textField.removeEventListener( FocusEvent.FOCUS_IN, on_set_focus);
			_textField.removeEventListener( FocusEvent.FOCUS_OUT, on_kill_focus);
			removeEventListener( FocusEvent.FOCUS_IN, on_set_focus);
			removeEventListener( FocusEvent.FOCUS_OUT, on_kill_focus);
			_textField.removeEventListener( Event.CHANGE, textFieldChange);
			
			removeChild( _textField);
			_textField=null;
			
			super.remove();
		}
	}
}