package ws.equator.controls{

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class VerticalBox extends StackBox{ 
		
		override internal function sizeRequest():Point{
			var w:int=0;
			var h:int=0;
			var i:int;
			var p:Point;
			var child:DisplayObject;
			
			if(numChildren==0){
				w=(_behaviourx==ControlBehaviour.FIXED? __width  : paddingLeft+paddingRight);
				h=(_behavioury==ControlBehaviour.FIXED? __height : paddingTop+paddingBottom);
				
			}else{
				if(homogeneous){
					w=h=0;
					for(i=0; i<numChildren; i++){
						child=getChildAt( i);
						if( child is Control){
							p=(child as Control).sizeRequest();
							w=Math.max(w, p.x);
							h=Math.max(h, p.y);
						}else{
							w=Math.max(w, Math.round(child.width));
							h=Math.max(h, Math.round(child.height));
						}
					}
					
					if( _behaviourx==ControlBehaviour.FIXED){
						w=__width;
					}else{
						w=w+paddingLeft+paddingRight;
					}
					if(_behavioury==ControlBehaviour.FIXED){
						h=__height;
					}else{
						h=h*numChildren+paddingTop+paddingBottom+spacing*(numChildren-1);
					}
					
				}else{
					w=h=0;
					for(i=0; i<numChildren; i++){
						child=getChildAt( i);
						if( child is Control){
							p=(child as Control).sizeRequest();
							w = Math.max(w, p.x);
							h += p.y;
						}else{
							w = Math.max(w, Math.round( child.width));
							h += Math.round( child.height);
						}
					}
					
					if( _behaviourx==ControlBehaviour.FIXED){
						w=__width;
					}else{
						w=w+paddingLeft+paddingRight;
					}
					if(_behavioury==ControlBehaviour.FIXED){
						h=__height;
					}else{
						h=h+paddingTop+paddingBottom+spacing*(numChildren-1);
					}
				}
			}
			return new Point( w, h);
		}
		
		private function positionChild( object:DisplayObject, x:int, y:int, w:int, h:int):void{
			if( object is Control){
				var child_x:int;
				var child_y:int;
				var child:Control=(object as Control);
				
				if( ((child.align & ControlAlign.LEFT) && (child.align & ControlAlign.RIGHT)) ||
				        (( !(child.align & ControlAlign.LEFT)) && ( !(child.align & ControlAlign.RIGHT))) ){
					//position in the center
					child_x=x+(w-child.width)/2;
				}else if(child.align & ControlAlign.RIGHT){
					child_x=x+w-child.width;
				}else{
					child_x=x;
				}
				if( ((child.align & ControlAlign.TOP) && (child.align & ControlAlign.BOTTOM)) ||
				        (( !(child.align & ControlAlign.TOP)) && ( !(child.align & ControlAlign.BOTTOM))) ){
					//position in the center
					child_y=y+(h-child.height)/2;
				}else if(child.align & ControlAlign.BOTTOM){
					child_y=y+h-child.height;
				}else{
					child_y=y;
				}
				child.move( child_x, child_y);
				
			}else{
				//Position in the center
				object.x=x+Math.round((w-object.width)/2);
				object.y=y+Math.round((h-object.height)/2);
			}
		}
		
		private function resizeChild( object:DisplayObject, w:int, h:int):void{
			if( object is Control){
				var child_width:int;
				var child_height:int;
				var child:Control=(object as Control);
				if( child.behaviourX ==ControlBehaviour.FIXED){
					child_width=child.width;
				}else{
					child_width=w;
				}
				if( child.behaviourY ==ControlBehaviour.FIXED){
					child_height=child.height;
				}else{
					child_height=h;
				}
				child.setSize( child_width, child_height);
			}
		}
		
		private function setSize_a( w:int, h:int):void{
			var i:int;
			var point:Point;
			var cur:int;
			var child:DisplayObject;
			var control:Control;
			var space:int;//space is the width of each child control
			var s:int, smin:int, cnt:int;
			
			if(numChildren==0){
				if(_behaviourx==ControlBehaviour.AUTO){
					__width=paddingLeft+paddingRight;
				}else if(_behaviourx==ControlBehaviour.STRETCH){
					__width=w;
				}
				if(_behavioury==ControlBehaviour.AUTO){
					__height=paddingTop+paddingBottom;
				}else if(_behavioury==ControlBehaviour.STRETCH){
					__height=h;
				}
				
			}else{
				if(homogeneous){
					point=sizeRequest();
					w=(_behaviourx==ControlBehaviour.AUTO? point.x: (_behaviourx==ControlBehaviour.FIXED? __width  : Math.max( point.x, w)));
					h=(_behavioury==ControlBehaviour.AUTO? point.y: (_behavioury==ControlBehaviour.FIXED? __height : Math.max( point.y, h)));
					
					cur=paddingTop;
					space=Math.round((h-paddingTop-paddingBottom-(numChildren-1)*spacing)/numChildren);
					space=Math.max(space, 0);
					for(i=0; i<numChildren; i++){
						child=getChildAt(i);
						if(i) cur+=spacing;
						resizeChild( child, w-paddingLeft-paddingRight, space);
						positionChild(child, paddingLeft, cur, w-paddingLeft-paddingRight, space);
						cur+=space;
					}
					__width=w;
					__height=h;
					
					
				}else{
					
					point=sizeRequest();

					w=(_behaviourx==ControlBehaviour.AUTO? point.x: (_behaviourx==ControlBehaviour.FIXED? __width : Math.max( point.x, w)));
					
					if(_behavioury==ControlBehaviour.AUTO ||_behavioury==ControlBehaviour.FIXED){
						h=_behavioury==ControlBehaviour.AUTO? point.y : __height;
						cur=paddingTop;
						//space=Math.max(0, Math.round((h-paddingTop-paddingBottom-(childQueue.length-1)*spacing)/childQueue.length));
						for(i=0; i<numChildren; i++){
							child=getChildAt( i);
							if(i) cur+=spacing;
							if( child is Control){
								space=(child as Control).sizeRequest().y;
							}else{
								space=Math.round(child.height);
							}
							resizeChild( child, w-paddingLeft-paddingRight, space);
							positionChild(child, paddingLeft, cur, w-paddingLeft-paddingRight, space);
							cur+=space;
						}
						
					}else{
						//check how many items should be stretched
						//check children elements
						
						
						s=0;
						smin=0;
						cnt=0;
						for(i=0; i<numChildren; i++){
							child=getChildAt( i);
							if( child is Control){
								control=(child as Control);
								point=control.sizeRequest();
								if( (control.behaviourY==ControlBehaviour.AUTO || control.behaviourY==ControlBehaviour.FIXED)){
									resizeChild( control, w-paddingLeft-paddingRight, control.height);
									s+=point.y;
									cnt++;
								}else{
									smin=Math.max( smin, point.y);
								}
							}else{
								resizeChild( child, w-paddingLeft-paddingRight, Math.round(child.height));
								s+=Math.round( child.height);
								cnt++;
							}
						}
						s=Math.round((h-paddingTop-paddingBottom-(numChildren-1)*spacing-s)/(numChildren-cnt));
						s=Math.max( s, smin);
						
						cur=paddingTop;
						for(i=0; i<numChildren; i++){
							if(i) cur+=spacing;
							child=getChildAt( i);
							
							if( child is Control){
								control=(child as Control);
								if( control.behaviourY==ControlBehaviour.STRETCH){
									resizeChild( control, w-paddingLeft-paddingRight, s);
									positionChild( control, paddingLeft, cur, w-paddingLeft-paddingRight, s);
									cur+=s;
									
								}else if( control.behaviourY==ControlBehaviour.AUTO){
									point=control.sizeRequest();
									positionChild( control, paddingLeft, cur, w-paddingLeft-paddingRight, point.y );
									cur+=point.y;
									
								}else{//Fixed
									positionChild( control,  paddingLeft, cur,  w-paddingLeft-paddingRight, control.height);
									cur+=control.height;
								}
							}else{
								positionChild( child,  paddingLeft, cur,  w-paddingLeft-paddingRight, Math.round(child.height));
								cur+=Math.round(control.height);
							}
						}
					}
					__width=w;
					__height=h;
				}
			}
		}
				
		override protected function refresh_control( event:Event=null, recursive:Boolean=false):void{
			super.refresh_control(event, recursive);
			setSize_a(__width, __height);
		}
		
		
		public function VerticalBox(){
			super();
		}
	}
}	
	

