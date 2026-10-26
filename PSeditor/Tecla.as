package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	//import org.tuio.TouchEvent;
	
	
	public class Tecla extends MovieClip {
		
		
		public function Tecla() {
			// constructor code
			addEventListener(MouseEvent.MOUSE_DOWN, pulsar);
		}
		
		public function pulsar(e:Event) {
			(parent as Teclado).tecla(this.name.substr(1));
		}
		
	}
	
}
