package  {
	
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import org.tuio.TouchEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	
	
	public class Pelota extends MovieClip {
		
		public static const ESTADO_ESPERA=1;
		public static const ESTADO_TURNO=2;
		public static const ESTADO_AGARRADA=3;
		public static const ESTADO_LANZADA=4;
		public static const ESTADO_ELIMINAR=5;
		
		private var estado:Number=ESTADO_ESPERA;
		private var juego:Juego=null;
		private var contador:Number=25; // notica 1 segundos despues
		private var modelo:Number=0;
		private var vx:Number=0;
		private var vy:Number=0;
		private var vg:Number=20;
		private var acumPuntos:Number=0;
		public var puntos:Number=200;
		
		public var idTouch:Number=0;
		
		public function Pelota(j:Juego=null) {
			// constructor code
			juego=j;
			modelo=Math.floor(Math.random()*5)+1;	//1-5
			
			addEventListener(Event.REMOVED_FROM_STAGE, fin);
			cambioEstado(estado);
			
			addEventListener(Event.ENTER_FRAME, frame);		// mover
		}
		
		public function fin(e:Event) {
			// destructor (remove listeners)
			removeEventListener(Event.REMOVED_FROM_STAGE, fin);
			removeEventListener(TouchEvent.TOUCH_DOWN, pulsar); //pulsar sobre la pelota
			removeEventListener(TouchEvent.TOUCH_UP, soltar); // soltar sobre la pelota (sin arrastrar fuera)
			removeEventListener(TouchEvent.TOUCH_OUT, lanzar); // arrastras fuera (lanzar)
			removeEventListener(Event.ENTER_FRAME, frame);		// mover
		}
		
		public function cambioEstado(e:Number) {
			estado=e;
			switch (estado) {
				case ESTADO_ESPERA:
					gotoAndStop(1);
					if (ref!=null) ref.gotoAndStop(modelo);
				break;
				case ESTADO_TURNO:
					juego.menu.desbloquear(); // asegurar menu libre
					gotoAndStop(2);
					if (ref!=null) ref.gotoAndStop(modelo);
					mango.gotoAndStop((mango.totalFrames)/2);
					goma.scaleY=1;
					goma.rotation=0;
					ref.addEventListener(TouchEvent.TOUCH_DOWN, pulsar); //pulsar sobre la pelota
					
				break;
				case ESTADO_AGARRADA:
					ref.removeEventListener(TouchEvent.TOUCH_DOWN, pulsar); //pulsar sobre la pelota
					juego.menu.bloquear(); //bloquear menu
					
					ref.addEventListener(TouchEvent.TOUCH_MOVE, apuntar); // arrastrar para apuntar
					ref.addEventListener(TouchEvent.TOUCH_UP, lanzar); // soltar sobre la pelota (se lanza)
					parent.parent.addEventListener(TouchEvent.TOUCH_UP, lanzar); // arrastrrs fuera (apuntar)
					parent.parent.addEventListener(TouchEvent.TOUCH_MOVE, apuntar); //parent=ref posicion
					
					//addEventListener(TouchEvent.TOUCH_UP, soltar); // soltar sobre la pelota (sin arrastrar fuera)
					//addEventListener(TouchEvent.TOUCH_OUT, lanzar); // arrastras fuera (lanzar)
				break;
				case ESTADO_LANZADA:
					gotoAndStop(3);
					if (ref!=null) ref.gotoAndStop(modelo);
					ref.removeEventListener(TouchEvent.TOUCH_MOVE, apuntar); // arrastrar para apuntar
					ref.removeEventListener(TouchEvent.TOUCH_UP, lanzar); // soltar sobre la pelota (se lanza)
					parent.removeEventListener(TouchEvent.TOUCH_MOVE, apuntar);
					//ref.removeEventListener(TouchEvent.TOUCH_OUT, apuntar); // arrastrrs fuera (apuntar)
					//removeEventListener(TouchEvent.TOUCH_UP, soltar); // soltar sobre la pelota (sin arrastrar fuera)
					//removeEventListener(TouchEvent.TOUCH_OUT, lanzar); // arrastras fuera (lanzar)
				break;
				case ESTADO_ELIMINAR:
					juego.menu.desbloquear(); // menu libre
					
					juego.informPuntos(acumPuntos);
					gotoAndStop(4);
				break;
			}
		}
		
		public function getEstado():Number {
			return estado;
		}
		
		public function pulsar(e:TouchEvent) {
			if (estado==ESTADO_TURNO) {
				juego.activity();
				idTouch=e.tuioContainer.sessionID;
				cambioEstado(ESTADO_AGARRADA)
			};
		}
		
		public function soltar(e:TouchEvent) {
			if (estado==ESTADO_AGARRADA && idTouch==e.tuioContainer.sessionID)  {
				trace("SOLTAR");
				juego.activity();
				cambioEstado(ESTADO_TURNO)
			};
		}
		
		public function apuntar(e:TouchEvent) {
			if (estado==ESTADO_AGARRADA && idTouch==e.tuioContainer.sessionID) {
				juego.activity();
				var p:Point=new Point(e.stageX,e.stageY);
				p=globalToLocal(p);
				ref.x=p.x;
				ref.y=p.y;
				// distancia
				var d:Number=Math.sqrt((ref.x*ref.x)+(ref.y*ref.y));
				goma.scaleY=1+(2*d/ref.height);
				// angulo
				var ang:Number=Math.atan2(ref.y,ref.x);
				ang=(180*ang/Math.PI)-90;
				goma.rotation=ang;
				// angulo mango
				var mang:Number;
				mang=7-Math.floor((mango.totalFrames)*(ang/180));
				while (mang>mango.totalFrames) mang-=mango.totalFrames;
				mango.gotoAndStop(mang);
			}
		}
		
		public function lanzar(e:TouchEvent) {
			if (estado==ESTADO_AGARRADA && idTouch==e.tuioContainer.sessionID) {
				juego.activity();
				var p:Point=new Point(e.stageX,e.stageY);
				p=globalToLocal(p);
				ref.x=p.x;
				ref.y=p.y;
				var d:Number=Math.sqrt((ref.x*ref.x)+(ref.y*ref.y));
				// reset pelota
				ref.x=0;
				ref.y=0;
				if (d>25) {
					vx=(x-e.stageX)/2;
					vy=(y-e.stageY)/2;
					if (Math.abs(vx)>125) vx=(vx/Math.abs(vx))*125;
					if (Math.abs(vy)>125) vx=(vy/Math.abs(vy))*125;
					cambioEstado(ESTADO_LANZADA);
				} else {
					//nada... se queda suelta
					cambioEstado(ESTADO_TURNO);
				}
			}
		}
		
		public function frame(e:Event) {
			//if (ref!=null) ref.gotoAndStop(modelo);
			if (estado==ESTADO_LANZADA) {
				x+=vx;
				y+=vy;
				rotation+=vg;
				if (x<0 || x>(root as Desktop).stageWidth) {cambioEstado(ESTADO_ELIMINAR);return;} //vx*=-1;
				if (y<0) {cambioEstado(ESTADO_ELIMINAR);return;} // vy*=-1;
				if (y>(root as Desktop).stageHeight) vy*=-1;
				
				var viva:Boolean=true;
				// comprobar choques con nubes
				var c:MovieClip = (root as Desktop).nubesContainer;
				for (var i:int=0; i<c.numChildren && viva; i++) {
					var n:Nube=(c.getChildAt(i) as Nube);
					if (n!=null && n.getEstado()==Nube.ESTADO_LIBRE && hitTestObject(n)) {
						trace("con Nube");
						// nube golpeada, eliminar nube y pelota
						acumPuntos+=n.puntos;
						n.cambioEstado(Nube.ESTADO_CHOQUE);
						//cambioEstado(Pelota.ESTADO_ELIMINAR);
						viva=false;
						//break; //no comprobar mas choques
						
						// cambio de direccion
						if (Math.abs((n.x-x)/(n.scaleX*scaleX)) > Math.abs((n.y-y)/(n.scaleY*scaleY))) {
							// rebote horizontal
							vx*=-1;
						} else {
							// rebote vertical
							vy*=-1;
						}
						
					}
				}
				if (viva) {
					// comprobar choques con otras Pelotas
					c=(root as Desktop).frontal;
					for (i=0;i<c.numChildren && viva; i++) {
						var p:Pelota=(c.getChildAt(i) as Pelota);
						if (p!=null && p!=this && p.getEstado()==Pelota.ESTADO_LANZADA && hitTestObject(p)) {
							trace("con Pelota: "+p.getEstado());
							// pelota golpeada, eliminar ambas pelotas
							//acumPuntos=0; //+=p.puntos;	// ninguna gana puntos
							//p.acumPuntos=0; // que aquella "no" gane puntos
							p.cambioEstado(Pelota.ESTADO_ELIMINAR);
							cambioEstado(Pelota.ESTADO_ELIMINAR);
							viva=false;
							break;
						}
					}
				}
				/*	No chocar con obstaculos
				if (viva) {
					// comprobar choque con "obstaculos"
					c=(root as Desktop).obstaculos;
					for (i=0;i<c.numChildren;i++) {
						var o:DisplayObject=(c.getChildAt(i) as DisplayObject);
						if (o!=null && hitTestObject(o)) {
							trace("con Obstaculo");
							// rebotar (horizontal o vertical)?
							var dispX:Number=Math.abs(o.x-x)/n.width;
							var dispY:Number=Math.abs(o.y-y)/n.height;
							//trace("nube: "+n.x+","+n.y+"  pelt: "+x+","+y+"  disp: "+dispX+","+dispY);
							if (dispX>dispY) vx*=-1; else vy*=-1;
							break; // no rebotar con varios a la vez (permitir alguna salida)
						}
					}
				}
				//*/
			} else if (estado==ESTADO_ELIMINAR) {
				contador--;
				if (contador==0) {// eliminar bola
					if (juego!=null) juego.informPelotaMenos();
					parent.removeChild(this); 
				}
			}
		}
		
	}
	
}
