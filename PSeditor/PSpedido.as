package  {
	
	import flash.display.MovieClip;
	import com.greensock.*;
	import flash.events.Event;
	//import org.tuio.TouchEvent;
	import flash.events.MouseEvent;
	
	public class PSpedido extends MovieClip {
		
		
		public function PSpedido() {
			// constructor code
			addEventListener(MouseEvent.MOUSE_DOWN, cerrar);
		}
		
		public function init() {
			TweenLite.to(this, 1, {y:height});
		}
		
		public function cerrar(e:Event) {
			parent.removeChild(this);
		}
	}
	
}
