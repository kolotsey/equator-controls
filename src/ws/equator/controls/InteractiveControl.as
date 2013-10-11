package ws.equator.controls{
	import flash.events.FocusEvent;
	import flash.events.Event;
	import flash.display.Sprite;

	/**
	 * @author kolotsey
	 */
	public class InteractiveControl extends Control{
		protected var state: int=ControlState.create();
		protected var sprites:Object=new Object();
		protected var stateSprite:Sprite=new Sprite();
		protected var focusSprite:Sprite;
		private var focus:Boolean=false;
		
		private var bg:Sprite=new Sprite();
		
		protected var bgScale:Boolean=true;
		protected var bgAlign:int=ControlAlign.CENTER;
		protected var focusrectScale:Boolean=true;
		
		protected function getStateSprite():Sprite{
			return null;
		}
		
		protected function getFocusSprite():Sprite{
			return null;
		}
		
		internal function setVisibleSprite():void{
			if( stage){
				var s:*;
				var sprite:Sprite;
	
				for( s in sprites){
					if( int(s) !=state){
						(sprites[s] as Sprite).visible=false;
					}
				}
				if(sprites[state]==null){
					if( null !=(sprite=getStateSprite())){
						resizeSprite( sprite);
						sprites[state]=sprite;
						stateSprite.addChild( sprite);
					}
				}
				if( sprites[state] !=null){
					(sprites[state] as Sprite).visible=true;
				}
								
				if( focus){
					if( focusSprite==null){
						if( null !=(focusSprite=getFocusSprite())){
							focusSprite.mouseEnabled = false;
							focusSprite.mouseChildren = false;
							focusSprite.tabEnabled = false;
							focusSprite.tabChildren = false;
							resizeSprite( focusSprite);
							addChild( focusSprite);
						}
					}
					if( focusSprite !=null){
						focusSprite.visible=true;
					}
					
				}else{
					if(focusSprite !=null) focusSprite.visible=false;
				}
			}
		}
		
		private function positionSprite( sprite:Sprite):void{
			if( ((bgAlign & ControlAlign.LEFT) && (bgAlign & ControlAlign.RIGHT)) ||
			        (( !(bgAlign & ControlAlign.LEFT)) && ( !(bgAlign & ControlAlign.RIGHT))) ){
				//position in the center
				sprite.x=Math.round((__width-sprite.width)/2);
			}else if(bgAlign & ControlAlign.RIGHT){
				sprite.x=__width-sprite.width;
			}else{
				sprite.x=0;
			}
			if( ((bgAlign & ControlAlign.TOP) && (bgAlign & ControlAlign.BOTTOM)) ||
			        (( !(bgAlign & ControlAlign.TOP)) && ( !(bgAlign & ControlAlign.BOTTOM))) ){
				//position in the center
				sprite.y=Math.round((__height-sprite.height)/2);
			}else if(bgAlign & ControlAlign.BOTTOM){
				sprite.y=__height-sprite.height;
			}else{
				sprite.y=0;
			}
		}
		
		internal function resizeSprite( sprite:Sprite=null):void{
			var s:*;
			
			if( sprite==null){
				bg.width=__width;
				bg.height=__height;
				if(bgScale){
					for( s in sprites){
						sprite=(sprites[s] as Sprite);
						sprite.width=__width;
						sprite.height=__height;
					}
					if( focusSprite){
						focusSprite.width=__width;
						focusSprite.height=__height;
					}
				}else{
					for( s in sprites){
						sprite=(sprites[s] as Sprite);
						positionSprite(sprite);
					}
					if( focusSprite){
						positionSprite( focusSprite);
					}
				}
			}else{
				//trace( "sprite==focusRect="+(sprite==focusSprite)+", focusrectScale="+focusrectScale);
				if(bgScale || (focusrectScale && sprite==focusSprite)){
					sprite.width=__width;
					sprite.height=__height;
				}else{
					positionSprite(sprite);
				}
			}
		}
		
		
		private function on_focus_change( ev:FocusEvent):void{
			focus=false;
			setVisibleSprite();
			if( ev.type==FocusEvent.KEY_FOCUS_CHANGE && ev.relatedObject is InteractiveControl){
				(ev.relatedObject as InteractiveControl).focus=true;
				(ev.relatedObject as InteractiveControl).setVisibleSprite();
			}
		}
		
		public function InteractiveControl(){
			super(); 
			
			bg.graphics.beginFill( 0x00, 0);
			bg.graphics.drawRect(0, 0, 100, 100);
			bg.graphics.endFill();
			bg.mouseEnabled = false;
			bg.mouseChildren = false;
			bg.tabEnabled = false;
			bg.tabChildren = false;
			addChild(bg);
			
			stateSprite.mouseEnabled = false;
			stateSprite.mouseChildren = false;
			stateSprite.tabEnabled = false;
			stateSprite.tabChildren = false;
			addChild(stateSprite);
			
			addEventListener( FocusEvent.KEY_FOCUS_CHANGE, on_focus_change);
			addEventListener( FocusEvent.MOUSE_FOCUS_CHANGE, on_focus_change);
		}
		
		override protected function added_to_stage( event:Event):void{
			super.added_to_stage(event);
			setVisibleSprite();
		}
		
		override protected function removed_from_stage( event:Event):void{
			if( stage.focus && (stage.focus==this || this.contains( stage.focus))){
				stage.focus=null;
			}
			super.removed_from_stage( event);
		}
		
		override public function remove():void{
			var s:*;
			
			for( s in sprites){
				var sprite:Sprite=sprites[s];
				if( sprite !=null){
					stateSprite.removeChild( sprite);
					sprites[s]=null;
				}
			}
			sprites=null;
			removeChild(stateSprite);
			stateSprite=null;
			
			if( null !=focusSprite){
				removeChild( focusSprite);
				focusSprite=null;
			}
			
			removeEventListener( FocusEvent.KEY_FOCUS_CHANGE, on_focus_change);
			removeEventListener( FocusEvent.MOUSE_FOCUS_CHANGE, on_focus_change);
			
			super.remove();
		}
	}
}
