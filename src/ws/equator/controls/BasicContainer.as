package ws.equator.controls{
	import flash.events.Event;
	import flash.display.DisplayObject;

	internal class BasicContainer extends Control{
		
		override protected function makeEnabled():void{
			var i:int;
			var child:DisplayObject;
			for(i=0; i<numChildren; i++){
				child=getChildAt( i);
				if( child is Control) ( child as Control).enabled=_enabled;
			}
		}
				
		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void{
			super.swapChildren(child1, child2);
			invalidate( true);
		}
		
		override public function swapChildrenAt(index1:int, index2:int):void{
			super.swapChildrenAt(index1, index2);
			invalidate( true);
		}
		
		private function childAddRemove( event:Event):void{
			var i:int;
			var target:DisplayObject=event.target as DisplayObject;
			for( i=0; i<numChildren; i++){
				if(getChildAt( i)==target){
					invalidate_recursive();
					break;
				}
			}
		}
		
		
		public function BasicContainer(){
			super();
		}
		
		override protected function added_to_stage( event:Event):void{
			super.added_to_stage(event);
			addEventListener( Event.ADDED, childAddRemove);
			addEventListener( Event.REMOVED, childAddRemove);
		}
		
		override protected function removed_from_stage( event:Event):void{
			removeEventListener( Event.ADDED, childAddRemove);
			removeEventListener( Event.REMOVED, childAddRemove);
			super.removed_from_stage(event);
		}
		
		override public function remove():void{
			var child:DisplayObject;

			remove_from_stage();
						
			removeEventListener( Event.ADDED, childAddRemove);
			removeEventListener( Event.REMOVED, childAddRemove);
			while( numChildren){
				child=getChildAt(0);
				if( child is Control){
					(child as Control).remove();
				}else{
					removeChild(child);
				}
			}
			super.remove();
		}

	}
}	
	
	

