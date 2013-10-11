
package ws.equator.controls{
	internal class GetDelta {
		
		static private function firstOf(str:String):uint{
			var i:uint;
			var retval:uint;
			
			retval=str.length-1;
			for(i=0; i<str.length; i++){
				if((str.charAt(i)=='0') ||(str.charAt(i)=='.')){
					continue;
				}else{
					retval=i;
					break;
				}
			}
			return retval;
		}
		
		//return deltas fro the value array
		static public function getDelta(bottom:Number, top:Number, count:uint, base60:Boolean=false):Object{
			var tok:int;
			var exp:uint;
			var dig:uint;
			var delta:Number;
			var min:Number;
			var max:Number;
			var o:Object=new Object();
			var temp:String;
			
			//delta=(top-bottom)/count
			temp=Math.abs( (top-bottom)/count).toString();
			tok=temp.indexOf('e');
			
			if(tok==-1){
				tok=temp.indexOf('.');	
				if (tok==-1){
					exp=temp.length-1;
					dig=Number(temp.charAt(0));
				}else{			
					if (temp.charAt(0)=='0'){				
						tok=firstOf(temp);	
						exp=-tok+1;
						dig=Number(temp.charAt(tok));
					}else{
						temp=temp.slice(0, tok);
						exp=temp.length-1;
						dig=Number(temp.charAt(0));
					}
				}
			}else{
				exp=Number(temp.slice(tok+1));
				dig=Number(temp.charAt(0));
			}
			if(base60){
				if((dig>=2) &&(dig<3)){
					dig=3;
				}else if((dig>=3) &&(dig<6)){
					dig=3;
				}else if((dig>=6) &&(dig<9)){
					dig=6;
				}else if(dig==1){
					dig=1;		
				}else{
					dig=1;
					exp+=1;
				}
				min=Math.floor(bottom/Math.pow(60, exp+1))*Math.pow(60, exp+1);
			}else{
				if((dig>=2) &&(dig<5)){
					dig=2;
				}else if((dig>=5) &&(dig<9)){
					dig=5;				
				}else if(dig==1){
					dig=1;		
				}else{
					dig=1;
					exp+=1;
				}
				min=Math.floor(bottom/Math.pow(10, exp+1))*Math.pow(10, exp+1);
			}
				
			delta=dig*Math.pow(10, exp);
			while(min<bottom){
				min+=delta;
			}
			
			count=Math.floor((top-min)/delta+1);
			max=min+count*delta;
			o["min"]=min;
			o["delta"]=delta;
			o["count"]=count;
			o["max"]=max;
			return o;
		}
	}
}