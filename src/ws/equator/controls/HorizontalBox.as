package ws.equator.controls{

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class HorizontalBox extends StackBox{
		
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
						w=w*numChildren+paddingLeft+paddingRight+spacing*(numChildren-1);
					}
					if(_behavioury==ControlBehaviour.FIXED){
						h=__height;
					}else{
						h=h+paddingTop+paddingBottom;
					}
					
				}else{
					w=h=0;
					for(i=0; i<numChildren; i++){
						child=getChildAt( i);
						if( child is Control){
							p=(child as Control).sizeRequest();
							w += p.x;
							h = Math.max(h, p.y);
						}else{
							w += Math.round(child.width);
							h = Math.max(h, Math.round(child.height));
						}
					}
					
					if( _behaviourx==ControlBehaviour.FIXED){
						w=__width;
					}else{
						w=w+paddingLeft+paddingRight+spacing*(numChildren-1);
					}
					if(_behavioury==ControlBehaviour.FIXED){
						h=__height;
					}else{
						h=h+paddingTop+paddingBottom;
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
					
					cur=paddingLeft;
					space=Math.round((w-paddingLeft-paddingTop-(numChildren-1)*spacing)/numChildren);
					space=Math.max(space, 0);
					for(i=0; i<numChildren; i++){
						child=getChildAt(i);
						if(i) cur+=spacing;
						resizeChild( child, space, h-paddingTop-paddingBottom);
						positionChild(child, cur, paddingTop, space, h-paddingTop-paddingBottom);
						cur+=space;
					}
					__width=w;
					__height=h;
					
				}else{
					point=sizeRequest();
					h=(_behavioury==ControlBehaviour.AUTO? point.y: (_behavioury==ControlBehaviour.FIXED? __height : Math.max( point.y, h)));
					
					if(_behaviourx==ControlBehaviour.AUTO ||_behaviourx==ControlBehaviour.FIXED){
						w=_behaviourx==ControlBehaviour.AUTO? point.x : __width;
						cur=paddingLeft;

						for(i=0; i<numChildren; i++){
							child=getChildAt( i);
							if(i) cur+=spacing;
							if( child is Control){
								space=(child as Control).sizeRequest().x;
							}else{
								space=Math.round(child.width);
							}
							resizeChild( child, space, h-paddingTop-paddingBottom);
							positionChild(child, cur, paddingTop, space, h-paddingTop-paddingBottom);
							cur+=space;
						}
						
					}else{
						//check how many items should be stretched
						//check child elements
						s=0;
						smin=0;
						cnt=0;
						for(i=0; i<numChildren; i++){
							child=getChildAt( i);
							if( child is Control){
								control=(child as Control);
								point=control.sizeRequest();
								if( (control.behaviourX==ControlBehaviour.AUTO || control.behaviourX==ControlBehaviour.FIXED)){
									resizeChild( control, control.width, h-paddingTop-paddingBottom);
									s+=point.x;
									cnt++;
								}else{
									smin=Math.max( smin, point.x);
								}
							}else{
								resizeChild( child, Math.round(child.width), h-paddingTop-paddingBottom);
								s+=Math.round(child.width);
								cnt++;
							}
						}

						s=Math.round((w-paddingLeft-paddingRight-(numChildren-1)*spacing-s)/(numChildren-cnt));
						s=Math.max( s, smin);
						
						cur=paddingLeft;
						for(i=0; i<numChildren; i++){
							if(i) cur+=spacing;
							child=getChildAt( i);
							
							if( child is Control){
								control=(child as Control);
								if( control.behaviourX==ControlBehaviour.STRETCH){
									resizeChild( control, s, h-paddingTop-paddingBottom);
									positionChild( control, cur, paddingTop, s, h-paddingTop-paddingBottom);
									cur+=s;
									
								}else if( control.behaviourX==ControlBehaviour.AUTO){
									point=control.sizeRequest();
									positionChild( control, cur, paddingTop, point.x, h-paddingTop-paddingBottom);
									cur+=point.x;
									
								}else{//Fixed
									positionChild( control, cur, paddingTop, control.width, h-paddingTop-paddingBottom);
									cur+=control.width;
								}
							}else{
								positionChild( child, cur, paddingTop, Math.round(child.width), h-paddingTop-paddingBottom);
								cur+=Math.round(child.width);
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
		
		
		public function HorizontalBox(){
			super();
		}
	}
}	
	

