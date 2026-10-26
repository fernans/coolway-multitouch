package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import org.tuio.TouchEvent;
	import flash.events.TransformGestureEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	
	public class Menu extends MovieClip {
		
		private static const TIEMPO_CERRAR=60*1000;
		
		private var estado:String="menu";
		private var contenido:MovieClip;
		private var timer:Timer;
		private var bloqueado:Boolean=false;
		
		public function Menu() {
			// constructor code
			stop();
			contenido=new MovieClip();
			contenido.y=-80;	// descentrar hacia arriba
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE,fin);
			bJuego.addEventListener(TouchEvent.TAP, optionJuego);
			bFotos.addEventListener(TouchEvent.TAP, optionFotos);
			bWeb.addEventListener(TouchEvent.TAP, optionWeb);
			bTienda.addEventListener(TouchEvent.TAP, optionTienda);
			bCerrar.addEventListener(TouchEvent.TAP, optionCerrar);
		}
		
		public function init(e:Event) {
			timer=new Timer(TIEMPO_CERRAR,1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, cerrarMenu);
			timer.start();
			parent.parent.addChild(bCerrar); // boton cerrar "sobre" la nube
			parent.parent.addChild(contenido); //parent=MenuRef parent.parent=Nube
		}
		
		public function activity() {
			timer.reset();
			timer.start();
		}
		
		public function fin(e:Event) {
			// destructor (remove listeners)
			removeEventListener(Event.REMOVED_FROM_STAGE,fin);
			bJuego.removeEventListener(TouchEvent.TAP, optionJuego);
			bFotos.removeEventListener(TouchEvent.TAP, optionFotos);
			bWeb.removeEventListener(TouchEvent.TAP, optionWeb);
			bTienda.removeEventListener(TouchEvent.TAP, optionTienda);
			bCerrar.removeEventListener(TouchEvent.TAP, optionCerrar);
		}
		
		public function cerrarMenu(e:Event) {
			var p:Nube=parent.parent as Nube;
			setContenido(null);
			this.addChild(bCerrar);
			bCerrar.visible=false;
			if (p!=null) p.cambioEstado(Nube.ESTADO_INVISIBLE);
			fin(null);
		}
		
		public function optionCerrar(e:Event) {
			if (!bloqueado) {
				trace("cierra");
				activity();
				cerrarMenu(null);
				//resetMenu();
			}
		}
		
		public function optionJuego(e:Event) {
			if (estado!="juego" && !bloqueado) {
				activity();
				estado="juego";
				trace("juego");
				gotoAndStop("juego");
				// crear juego 5 pelotas
				var j:Juego = new Juego(this);
				//j.x=parent.parent.x; 
				//j.y=(root as Desktop).stageHeight*0.9;
				//(root as MovieClip).addChild(j); //parent=nube parent.parent=container
				setContenido(j);
			}
			//cerrarMenu();
		}
		
		public function optionFotos(e:Event) {
			if (estado!="fotos" && !bloqueado) {
				activity();
				estado="fotos";
				trace("fotos");
				gotoAndStop("fotos");
				var f:Fotos = new Fotos(this);
				setContenido(f);
			}
			//cerrarMenu();
		}
		
		public function optionWeb(e:Event) {
			if (estado!="web" && !bloqueado) {
				activity();
				estado="web";
				trace("web");
				gotoAndStop("web");
				var w:Web = new Web(this);
				setContenido(w);
				//cerrarMenu();
			}
		}
		
		public function optionTienda(e:Event) {
			if (estado!="tienda" && !bloqueado) {
				activity();
				estado="tienda";
				trace("tienda");
				gotoAndStop("tienda");
				var ps:PS = new PS(this);
				setContenido(ps);
			}
			//cerrarMenu();
		}
		
		private function setContenido(c:MovieClip) {
			while (contenido.numChildren>0) contenido.removeChildAt(0);
			if (c!=null) contenido.addChild(c);
		}
		
		public function resetMenu() {
			if (estado!="menu") {
				setContenido(null);
				activity();
				estado="menu";
				trace("menu");
				gotoAndStop("menu");
			}
		}
		
		public function callShopper(e:CoolwayEvent) {
			activity();
			estado="tienda";
			trace("tienda");
			gotoAndStop("tienda");
			var ps:PS = new PS(this,e);
			setContenido(ps);
		}
		
		public function bloquear(estado:Boolean=true) {
			bloqueado=estado;
		}
		
		public function desbloquear() {
			bloquear(false);
		}
	}
	
}
