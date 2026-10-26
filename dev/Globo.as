package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Globo extends Nube {
		
		
		public function Globo() {
			// constructor code
			trace("globo");
			puntos=300;
		}
		
		public override function init(e:Event) {
			trace("init globo");
			vy=((Math.random()*(VELOCIDAD_Y-VELOCIDAD_Y_MIN))+VELOCIDAD_Y_MIN);
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addEventListener(Event.ENTER_FRAME, frame);
		}
		
		public override function fin(e:Event) {
			removeEventListener(Event.REMOVED_FROM_STAGE, fin);
			// eliminar listeners pendientes
			removeEventListener(Event.ENTER_FRAME, frame);
			
			(root as Desktop).numNoNubes--;
			//eliminar de su contendor padre
			if (parent!=null) parent.removeChild(this);
		}
		
	}
	
}
