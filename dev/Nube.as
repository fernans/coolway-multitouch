package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import org.tuio.TouchEvent;
	import flash.events.TransformGestureEvent;
	import flash.sensors.Accelerometer;
	import com.greensock.*;
	
	public class Nube extends MovieClip {
		
		public static const ESTADO_LIBRE=1;
		public static const ESTADO_CHOQUE=2;
		public static const ESTADO_ARRASTRE=3;
		public static const ESTADO_MENU=4;
		public static const ESTADO_INVISIBLE=5;
		
		public var VELOCIDAD_X=-5;
		public var VELOCIDAD_X_MIN=-1;
		public var VELOCIDAD_Y=-2;
		public var VELOCIDAD_Y_MIN=-0.5;
		private static const TIEMPO_ESPERA=5;
		private static const TIEMPO_INVISIBLE=125;
		
		public var puntos:Number=100;
		
		public var vx:Number=0; //velocidad constante
		protected var vy:Number=0; //velocidad constante
		private var ax:Number=0; //aceleracion por lanzamiento
		private var ay:Number=0; //aceleracion por lanzamiento
		private var offsetX:Number=0;	//offset en arrastre
		private var offsetY:Number=0;	//offset en arrastre
		private var oldX:Number=0;	// posicion anterior (para margen)
		private var oldY:Number=0;	// posicion anterior (para margen)
		private var touchId:Number=0; 	// id del dedo que lo agarra
		protected var temporizador:Number=0; // contador de frames... para retrasar eventos
		var numPlace:Number=-1;
		
		private var flecha:MovieClip=null; // flecha indicador pulsable
		
		protected var estado:Number=ESTADO_LIBRE;
		
		public function Nube(p:Number=100) {
			// constructor code
			puntos=p;
			//velocidad x inicial, aleatoria
			vx=((Math.random()*(VELOCIDAD_X-VELOCIDAD_X_MIN))+VELOCIDAD_X_MIN);
			// eventos de touch
			addEventListener(Event.ADDED_TO_STAGE, init);
			cambioEstado(estado);
		}
		
		public function init(e:Event) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			//addEventListener(Event.REMOVED_FROM_STAGE, fin);
			// iniciar comportamiento animacion
			addEventListener(Event.ENTER_FRAME, frame);
			addEventListener(TouchEvent.TOUCH_DOWN,touchDown);  // pulsa sobre
			addEventListener(TouchEvent.TOUCH_UP, touchUp);		// suelta sobre
			addEventListener(TouchEvent.TOUCH_MOVE, touchMove); // mueve sobre
			addEventListener(TouchEvent.TOUCH_OUT, touchUp);	// suelta fuera (pierde arrastre)
		
			//addEventListener(TouchEvent.HOLD, touchHold); // pulsar y sujetar
			//addEventListener(TouchEvent.DOUBLE_TAP, touchHold);
		
			//addEventListener(TransformGestureEvent.GESTURE_ROTATE, function (e:Event) {trace("rotate");} );
			
			// elige si mostrar flecha (y cual)
			if (Math.random()>0.75) { // flecha solo el 25% de las veces
				switch (Math.floor(Math.random()*3)) {
					case 0:
						flecha=new Flecha1();
					break;
					case 1:
						flecha=new Flecha2();
					break;
					case 2:
						flecha=new Flecha3();
					break;
					default:
					break;
				}
				addChild(flecha);
			}
		}
		
		public function fin(e:Event) {
			removeEventListener(Event.REMOVED_FROM_STAGE, fin);
			// eliminar listeners pendientes
			removeEventListener(Event.ENTER_FRAME, frame);
			// eventos de touch
			removeEventListener(TouchEvent.TOUCH_DOWN,touchDown);	//pulsa sobre
			removeEventListener(TouchEvent.TOUCH_UP, touchUp); 		//suelta sogbre
			removeEventListener(TouchEvent.TOUCH_MOVE, touchMove);  //mueve sobre
			removeEventListener(TouchEvent.TOUCH_OUT, touchUp);		//suelta fuera (pierde arrastre)
			
			removeEventListener(TouchEvent.HOLD, touchHold); // pulsar y sujetar
			removeEventListener(TouchEvent.DOUBLE_TAP, touchHold);
			
			//eliminar posible menu abierto
			if (menuRef!=null) while (menuRef.numChildren>0) menuRef.removeChildAt(0);
			// marcar hueco como libre
			if (numPlace>-1) {
				var menuPlaces:Array=(root as Desktop).menuPlaces;
				menuPlaces[numPlace]=true;
			}
			
			//eliminar de su contendor padre
			if (parent!=null) parent.removeChild(this);
		}
		
		public function getEstado():Number {
			return estado;
		}
		
		public function cambioEstado(nuevoEstado:Number) {
			//accion automatica al salir del estado
			switch(estado) {
				case ESTADO_LIBRE:
					// salgo de libre... elimino la flecha (si hay)
					if (flecha!=null) {
						removeChild(flecha);
						flecha=null;
					}
				break;
				default: break;
			}
			
			estado=nuevoEstado;
			gotoAndStop(estado);
			
			//accion automatica al entrar al estado
			switch(estado) {
				case ESTADO_ARRASTRE:
					temporizador=TIEMPO_ESPERA;
				break;
				case ESTADO_MENU:
					//comprobar huecos de menu libres
					var menuPlaces:Array=(root as Desktop).menuPlaces;
					if (menuPlaces[0] || menuPlaces[1] || menuPlaces[2]) {
						// hay "al menos" un hueco libre
						if (x<(stage.stageWidth*0.35)) numPlace=0;
						else if (x>(stage.stageWidth*0.7)) numPlace=2;
						else numPlace=1;
						if (!menuPlaces[numPlace]) {
							numPlace++; if (numPlace>2) numPlace=0;
						} // primer intento fallido
						if (!menuPlaces[numPlace]) {
							numPlace++; if (numPlace>2) numPlace=0;
						} // segundo intento fallido
						// el tercero seguro que es valido, por la comprobacion inicial
						
						menuPlaces[numPlace] = false;
						
						(root as Desktop).menus.addChild(this);
						//crea la instancia de Menu
						while (menuRef.numChildren>0) menuRef.removeChildAt(0);
						var m:Menu=new Menu();
						m.x=menuRef.x;
						m.y=menuRef.y;
						menuRef.addChild(m);
						// crear tween de posicion
						// de la actual... al 0.85 del alto
						// a la coordenada X... segun el numPlace
						// recuperar tamaño original
						TweenLite.to(this, 1, {x:((numPlace*0.3)+0.2)*stage.stageWidth, y:(root as Desktop).stageHeight*0.85, scaleX:0.8, scaleY:0.8});
					} else {
						// no quedan "huecos" libres
						cambioEstado(Nube.ESTADO_LIBRE);
					}
				break;
				case ESTADO_CHOQUE:
					// lanzar sonido choque
					var sChoque:Sound=new soundNubesExplosion();
					sChoque.play();
					// fin sonido
					temporizador=(getChildAt(0) as MovieClip).totalFrames;
				break;
				case ESTADO_INVISIBLE:
					temporizador=TIEMPO_INVISIBLE;
				break;
				default: break;
			}
		}
		
		
		public function chocaCon(otro:Nube) {
			this.cambioEstado(ESTADO_CHOQUE);
			ax=0; ay=0; //fin de la aceleracion por lanzamiento
			//cambio de direccion
			// si +, y el otro estaba a mi derecha, cambio
			// si -, y el otro estaba a mi izquierda,cambio
			if (this.vx*(otro.x-this.x)>0) this.vx*=-1;
		}
		
		
		
		public function frame(e:Event) {
			switch (estado) {
				case ESTADO_ARRASTRE:
					temporizador--;
					if (temporizador<0) {
						cambioEstado(ESTADO_MENU);
					}
					break;
				case ESTADO_LIBRE:
					//avanzar segun velocidad
					x+=vx;
					y+=vy;
					//x+=(vx+ax); //+aceleracion por lanzamiento
					//y+=(vy+ay); //+aceleracion por lanzamiento
					// reducir la aceleracion adicional
					//ax=ax*0.9;
					//ay=ay*0.9;
					// cambio de direccion al salirse
					//if (x>(root as Desktop).stageWidth+width || x<-width) {vx*=-1;ax*=-1;}
					//if (y>(root as Desktop).stageHeight+height || y<-height) {vy*=-1;ay*=-1;}
					
					// al salirse entra de nuevo por la derecha
					//if (x<-width) x=(root as Desktop).stageWidth+width;
					
					// al salirse "muere" (ya se creará una nueva... por la derecha)
					if (x<-(width*2) || x>stage.stageWidth+(width*2)) fin(null);
					break;
				case ESTADO_CHOQUE:
					temporizador--;
					if (temporizador<=0) {
						//eliminar nube
						// (ya se creará otra nube nueva... sola
						fin(null);
						//avanzar (para que dejen de chocar)
						//this.x+=vx; this.y+=vy;
						//if (temporizador<-TIEMPO_ESPERA) { //tiempo margen, sin volver a chocar
						//	cambioEstado(ESTADO_LIBRE);
						//}
					}
					break;
				case ESTADO_INVISIBLE:
					temporizador--;
					if (temporizador<=0) {
						fin(null);
					}
					break;
				default: break;
			}
		}
		

		
		
		// eventos de touch
		public function touchDown(e:TouchEvent) {
			switch (estado) {
				case ESTADO_LIBRE:
					touchId=e.tuioContainer.sessionID;
					offsetX=e.stageX-this.x;
					offsetY=e.stageY-this.y;
					//ax=this.x; ay=this.y;
					oldX=this.x;
					oldY=this.y;
					cambioEstado(ESTADO_ARRASTRE);
					break;
				default: break;
			}
			
		}
		public function touchUp(e:TouchEvent) {
			switch (estado) {
				case ESTADO_ARRASTRE:
					if (touchId==e.tuioContainer.sessionID) { //solo si lo suelta el mismo
						//calcular aceleracion de lanzamiento;
						this.x=e.stageX-offsetX;
						this.y=e.stageY-offsetY;
						//no se lanzan
						//ax=this.x-ax;
						//ay=this.y-ay;
						//if ((vx*ax)<0) vx*=-1;
						//if ((vy*ay)<0) vy*=-1;
						cambioEstado(ESTADO_LIBRE);
					}
					break;
				default: break;
			}
			
		}
		
		public function touchMove(e:TouchEvent) {
			switch (estado) {
				case ESTADO_ARRASTRE:
					if (touchId==e.tuioContainer.sessionID) { //solo si lo arrastra el mismo
						//guardar(en aceleracion) la ultima posicion (para lanzamiento)
						//ax=this.x; ay=this.y;
						// situar nube en la posicion actual
						this.x=e.stageX-offsetX;
						this.y=e.stageY-offsetY;
						// reset temporizador (de abrir menu)
						if (Math.abs(e.stageX-oldX)>2 || Math.abs(e.stageY-oldY)>2) temporizador=TIEMPO_ESPERA;
						oldX=this.x;
						oldY=this.y;
					}
					break;
				default: break;
			}
		}
		
		public function touchHold(e:TouchEvent) {
			cambioEstado(Nube.ESTADO_MENU);
		}
		
	}
	
}
