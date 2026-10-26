package  {
	
	import flash.display.MovieClip;
	import com.greensock.*;
	import flash.events.Event;
	import org.tuio.TouchEvent;
	
	public class PSpedido extends MovieClip {
		
		
		public function PSpedido() {
			// constructor code
			addEventListener(TouchEvent.TOUCH_DOWN, cerrar);
		}
		
		public function init() {
			TweenLite.to(this, 1, {y:height/2});
		}
		
		public function cerrar(e:Event) {
			parent.removeChild(this);
		}
	}
	
}
