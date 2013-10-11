package ws.equator.controls{



	/**
	 * @author kolotsey
	 */
	internal class StackBox extends BasicBox{
		private var _homogeneous:Boolean=false;
		private var _spacing:int=0;

		public function set spacing(param:int):void{
			if(_spacing !=param){
				_spacing=param;
				invalidate();
			}
		}

		public function get spacing():int{
			return _spacing;
		}

		public function set homogeneous(param:Boolean):void{
			if(param !=_homogeneous){
				_homogeneous=param;
				invalidate();
			}
		}

		public function get homogeneous():Boolean{
			return _homogeneous;
		}

		public function StackBox(){
			super(); 
		}
	}
}
