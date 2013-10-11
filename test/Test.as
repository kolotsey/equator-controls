package {
	import flash.events.MouseEvent;
	import flash.events.FullScreenEvent;
	import ws.equator.controls.Button;
	import flash.display.StageDisplayState;
	import ws.equator.controls.BasicBox;
	import flash.events.Event;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import ws.equator.controls.GUI;
	import flash.display.Sprite;

	public class Test extends Sprite{
		
		private var gui:String="<gui>" +
		               "<Box padding='10' name='root_box' behaviour='stretch'>" +
		               "	<VBox align='0' spacing='5'>" +
		               "		<Button toggle='true' caption='Full Screen' name='fullscreen'/>" +
		               "		<Button caption='Accept' name='exit'/>" +
		               "        <Combobox>" +
		               "            <Item caption=\"Moscow\"/>" +
					   "            <Item caption=\"New York\"/>" +
					   "            <Item caption=\"Sydney\"/>" +
		               "        </Combobox>" +
		               "	</VBox>" +
		               "</Box>" +
		               "</gui>";
		
		private var controls:Object;
		//private var b:BasicBox=null;


		private function stageResize( event:Event):void{
			if( null !=controls){
				var box:BasicBox=controls["root_box"];
				box.width=stage.stageWidth;
				box.height=stage.stageHeight;
			}
		}
		
		private function fullscreenPress( ev: Event): void{
			trace("Called");
			if( (controls["fullscreen"] as Button).selected){
				stage.displayState = StageDisplayState.FULL_SCREEN;
				(controls["fullscreen"] as Button).icon=new Resources.arrow_in();
			}else{
				stage.displayState = StageDisplayState.NORMAL;
				(controls["fullscreen"] as Button).icon=new Resources.arrow_out();
			}
			stageResize( null);
		}
		
		private function fullscreenChange( ev:Event):void{
			(controls["fullscreen"] as Button).icon=stage.displayState == StageDisplayState.FULL_SCREEN? new Resources.arrow_in() : new Resources.arrow_out();
			(controls["fullscreen"] as Button).selected==stage.displayState == StageDisplayState.FULL_SCREEN;
			stageResize( null);
		}
		
		private function configControls():void{
			(controls["fullscreen"] as Button).icon=new Resources.arrow_out(); 
			(controls["fullscreen"] as Button).addEventListener( Event.CHANGE, fullscreenPress);
			(controls["exit"] as Button).icon=new Resources.accept(); 
			stage.addEventListener( FullScreenEvent.FULL_SCREEN, fullscreenChange);
			stageResize( null);
		}
		
		private function init():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, stageResize);
			stage.stageFocusRect=false;
			
			controls=GUI.parseXML( this, new XML(gui));
			configControls();
		}
	
		private function addedToStage(ev:Event):void{
			this.removeEventListener( Event.ADDED_TO_STAGE, addedToStage);
			init();
		}
		
		public function Test(){
			if( this.root==null){
				this.addEventListener( Event.ADDED_TO_STAGE, addedToStage);
			}else{
				init();
			}
		}
	}
}
