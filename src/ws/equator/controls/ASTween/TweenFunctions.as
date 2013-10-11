
package ws.equator.controls.ASTween{
	/**
	 * Class specifies easing equations
	 * Equations are borrowed from TweenNano class http://www.TweenNano.com
	 * 
	 */
	public class TweenFunctions {
		private static const HALF_PI:Number = Math.PI * 0.5;
		private static const TWO_PI:Number = Math.PI * 2;
		/* Back ease
		 */
		public static function BackEseIn (t:Number, b:Number, c:Number, d:Number, s:Number=1.70158):Number {
			return c*(t/=d)*t*((s+1)*t - s) + b;
		}
		public static function BackEaseOut (t:Number, b:Number, c:Number, d:Number, s:Number=1.70158):Number {
			return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
		}
		public static function BackEaseInOut (t:Number, b:Number, c:Number, d:Number, s:Number=1.70158):Number {
			if ((t/=d*0.5) < 1) return c*0.5*(t*t*(((s*=(1.525))+1)*t - s)) + b;
			return c*0.5*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b;
		}
		
		/* Bounce
		 */
		public static function BounceEaseOut (t:Number, b:Number, c:Number, d:Number):Number {
			if ((t/=d) < (1/2.75)) {
				return c*(7.5625*t*t) + b;
			} else if (t < (2/2.75)) {
				return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
			} else if (t < (2.5/2.75)) {
				return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
			} else {
				return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
			}
		}
		public static function BounceEaseIn (t:Number, b:Number, c:Number, d:Number):Number {
			return c - BounceEaseOut(d-t, 0, c, d) + b;
		}
		public static function BounceEaseInOut (t:Number, b:Number, c:Number, d:Number):Number {
			if (t < d*0.5) return BounceEaseIn (t*2, 0, c, d) * .5 + b;
			else return BounceEaseOut (t*2-d, 0, c, d) * .5 + c*.5 + b;
		}
		
		/* Cubic
		 */
		public static function cubicEaseIn (t:Number, b:Number, c:Number, d:Number):Number {
			return c*(t/=d)*t*t + b;
		}
		public static function cubicEaseOut (t:Number, b:Number, c:Number, d:Number):Number {
			return c*((t=t/d-1)*t*t + 1) + b;
		}
		public static function cubicEaseInOut (t:Number, b:Number, c:Number, d:Number):Number {
			if ((t/=d*0.5) < 1) return c*0.5*t*t*t + b;
			return c*0.5*((t-=2)*t*t + 2) + b;
		}
		
		/* Elastic ease
		 */
		static public function elasticEaseIn (t:Number, b:Number, c:Number, d:Number, a:Number, p:Number):Number {
			if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
			var s:Number;
			if (!a || (c > 0 && a < c) || (c < 0 && a < -c)) { a=c; s=p/4; }
			else s = p/TWO_PI * Math.asin (c/a);
			return -(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*TWO_PI/p )) + b;
		}
		public static function elasticEaseOut (t:Number, b:Number, c:Number, d:Number, a:Number, p:Number):Number {
			if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
			var s:Number;
			if (!a || (c > 0 && a < c) || (c < 0 && a < -c)) { a=c; s=p/4; }
			else s = p/TWO_PI * Math.asin (c/a);
			return (a*Math.pow(2,-10*t) * Math.sin( (t*d-s)*TWO_PI/p ) + c + b);
		}
		
		/* Exponential
		 */
		public static function ExpoEaseIn (t:Number, b:Number, c:Number, d:Number):Number {
			return (t==0) ? b : c * Math.pow(2, 10 * (t/d - 1)) + b - c * 0.001;
		}
		public static function ExpoEaseOut (t:Number, b:Number, c:Number, d:Number):Number {
			return (t==d) ? b+c : c * (-Math.pow(2, -10 * t/d) + 1) + b;
		}
		public static function ExpoEaseInOut (t:Number, b:Number, c:Number, d:Number):Number {
			if (t==0) return b;
			if (t==d) return b+c;
			if ((t/=d*0.5) < 1) return c*0.5 * Math.pow(2, 10 * (t - 1)) + b;
			return c*0.5 * (-Math.pow(2, -10 * --t) + 2) + b;
		}
		
		/* Sine
		 */
		public static function SineEaseIn (t:Number, b:Number, c:Number, d:Number):Number {
			return -c * Math.cos(t/d * HALF_PI) + c + b;
		}
		public static function SineEaseOut (t:Number, b:Number, c:Number, d:Number):Number {
			return c * Math.sin(t/d * HALF_PI) + b;
		}
		public static function SineEaseInOut (t:Number, b:Number, c:Number, d:Number):Number {
			return -c*0.5 * (Math.cos(Math.PI*t/d) - 1) + b;
		}
	}
}