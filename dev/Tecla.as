package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import org.tuio.TouchEvent;
	import flash.media.Sound;
	
	
	public class Tecla extends MovieClip {
		
		
		public function Tecla() {
			// constructor code
			addEventListener(TouchEvent.TOUCH_DOWN, pulsar);
		}
		
		public function pulsar(e:Event) {
			// lanzar sonido tecla
			var sTecla:Sound=new soundTecladoTecla();
			sTecla.play();
			// fin sonido
			(parent as Teclado).tecla(this.name.substr(1));
		}
		
	}
	
}
