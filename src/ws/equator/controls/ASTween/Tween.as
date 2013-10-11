package ws.equator.controls.ASTween{

	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.getTimer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.Shape;
	
	public class Tween extends EventDispatcher {
		
		
		private static const DEFAULT_DURATION:uint=300;
		//Array of target objects whoose fields should be changed while animation proceeds
		private var targets:Array;
		//Array of field names of the target objects with their start and end values
		private var attributes:Array;
		private static const tweener:Shape=new Shape(); 
		private var startTime:Object=null;
		private var _duration:Number;
		private var _ease:Function=null;
		//Timeout between the function is called and animation started
		private var _timeout: Number;
		private var intervalId: Object=null;
		
	
		/**
		 * Private animation function
		 */
		private static function easeOut(time:Number, b:Number, c:Number, duration:Number):Number{
			//This is to remove annoying warning about unused variables b and c  
			b;
			c;
			time=time/duration;
			return -time * (time - 2);
		}
	
	
		/*
		 * Setters and getters for changeable fields are defined below
		 */
		public function get duration():Number {
			return _duration;
		}
		public function set duration(param:Number):void {
			_duration = param;
		}
		public function get timeout():Number {
			return _timeout;
		}
		public function set timeout(param:Number):void {
			_timeout = param;
		}
		public function get ease():Function {
			return _ease;
		}
		public function set ease(param:Function):void {
			_ease = param;
		}
	
		
		/**
		 * Function adds an object to a list of animated objects
		 * @param targetObject An object or a MovieClip to animate
		 * @param attributes Object with fields and their final values that should be animated in targetObject 
		 */
		public function addObject( targetObject:Object, atts:Object):void{
			var fields:Object=null;
			var s:Object;
			
			for(s in atts){
				if( isNaN(Number(targetObject[s])) || isNaN(Number(atts[s]))){
					trace("One of the fields ("+s+") passed to Animator.addObject is NaN");
				}else{
					if(fields==null){
						fields=new Object();
					}
					fields[s]=new Array();
					//start values of an attribute
					fields[s][0]=Number(targetObject[s]);
					//end values of an attribute
					fields[s][1]=Number(atts[s]);
				}
			}
			if(fields !=null){
				targets.push(targetObject);
				attributes.push(fields);
			}
		}
		
		/**
		 * Function modifies target objects' fields accordingly to animation
		 */
		private function iteration( event:Event):void{
			var time:Number=getTimer();
			var ratio:Number;
			var i:Number;
			var s:Object;
			var e:TweenEvent=new TweenEvent( TweenEvent.ITERATE);
			
			if(time>=(startTime as int)+_duration){
				//the animation has finished
				//set final values to each field for every object
				ratio=1;
				for(i=0; i<targets.length; i++){
					for(s in attributes[i]){
						targets[i][s] =attributes[i][s][1];
					}
				}
			}else{
				ratio=_ease(getTimer()-(startTime as int), 0, 1, _duration);
				for(i=0; i<targets.length; i++){
					for(s in attributes[i]){
						targets[i][s] = 
								attributes[i][s][0]+ratio*(attributes[i][s][1]-attributes[i][s][0]);
					}
				}
			}
			
			e.ratio=ratio;
			dispatchEvent( e);
			if(ratio==1) stopAnimation();
		}
		
		/**
		 * Called when an animation is finished to stop it and release allocated objects and fields
		 */
		public function stopAnimation():void{
			if( null !=startTime || null !=intervalId){
				if( null !=intervalId){
					clearTimeout(intervalId as uint);
					intervalId=null;
				}
				
				var e:TweenEvent=new TweenEvent( TweenEvent.STOP);
				tweener.removeEventListener( Event.ENTER_FRAME, iteration);
				startTime=null;
				targets=new Array();
				attributes=new Array();
				
				e.ratio=1;
				dispatchEvent( e);
			}
			
		}
		
		/**
		 * Called to start the animation
		 */
		public function startAnimation():void{
			if( null==startTime){
				if(_timeout){
					intervalId=setTimeout( startAnimation, _timeout);
					_timeout=0;
	
				}else{
					if( null !=intervalId){
						clearTimeout(intervalId as uint);
						intervalId=null;
					}
					startTime=getTimer();
					iteration( null);
					tweener.addEventListener( Event.ENTER_FRAME, iteration);
				}
			}
		}
		
		/**
		* Function creates new Animator object and starts animation for passed target.
		* @param target Target object which attributes are chenged while animation proceeds
		* @param attributes Attributes of the targetObject to change
		* @param config Configuration object which may have the following fields
		*    duration - in milliseconds, default DEFAULT_DURATION
		*    timeout - timeout before animation is started in milliseconds
		*    ease - ease function, default easeOut
		*    onUpdateEvent - function that is called each frame
		*    onStopEvent - function that is called when animation is finished
		*/
		public static function create(targetObject:Object, attributes:Object, config:Object):Tween{
			if(targetObject && attributes){
				var a:Tween=new Tween( config);
				a.addObject(targetObject, attributes);
				a.startAnimation();
				return a;
			}else{
				return null;
			}
		}
		
		/**
		 * Constructor for Animator class create new object and populates parameters fields.
		 * Common use of the class:
		 * 
		 * var a:Animator=new Animator();
		 * a.duration=500;
		 * a.ease=Easing.simpleIn;
		 * a.onStop=function(){
		 *    trace("Animation finished");
		 * }
		 * a.startAnimation();
		 *  
		 * You may prefer to call animator as Animator.create(this, {_x:100, _y:200}, {duration:1000, onStop:function});
		 */
		public function Tween( config:Object=null):void{
			if(null==config){
				_duration=DEFAULT_DURATION;
				_ease=easeOut;
				_timeout=0;
			}else{
				_duration=config["duration"]==undefined? DEFAULT_DURATION : config["duration"];
				_ease=config["ease"]==undefined? easeOut : config["ease"];
				_timeout=config["timeout"]==undefined? 0 : config["timeout"];
			}
			targets=new Array();
			attributes=new Array();	
		}
		
		public function remove():void{
			if( null !=startTime){
				stopAnimation();
			}
			targets=null;
			attributes=null;
			tweener.removeEventListener( Event.ENTER_FRAME, iteration);
		}
	}
}