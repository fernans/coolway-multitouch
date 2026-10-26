package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import org.tuio.TouchEvent;
	import flash.events.TransformGestureEvent;
	import com.greensock.*;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	public class Foto extends MovieClip {
		
		public static const ESTADO_ESPERA=1;
		public static const ESTADO_ACTIVO=2;
		public static const ESTADO_ARRASTRE=3;
		public static const ESTADO_ZOOM=4;
		
		private static const PAGINA=0.125;	// ancho recorrido para salto de pagina
		
		protected var ref:Fotos;
		//public var refFoto:MovieClip;
		public var estado:Number=ESTADO_ESPERA;
		
		private var touchId:Number=0; 	// id del dedo que lo agarra
		private var touchId2:Number=0;  // id del 2o dedo que lo agarra (para zoom)
		private var offsetX:Number=0;	//offset en arrastre
		private var offsetY:Number=0;	//offset en arrastre
		private var origX:Number=0;	// inicio de arrastre (para distancia)
		private var origY:Number=0; // inicio de arrastre (para distancia)
		
		private var offsetX2:Number=0;	// 2o offset en arrastre
		private var offsetY2:Number=0;	// 2o offset en arrastre
		private var origX2:Number=0;	// 2o inicio de arrastre (para distancia)
		private var origY2:Number=0; // 2o inicio de arrastre (para distancia)
		
		private var distZoom:Number=0; // distancia anterior, para zoom + o -
		private var zoomed:Boolean=false;
		
		private var localwidth:Number=0; // ancho local (del marco... sin contar la foto recortada)
		
		public function Foto(f:Fotos=null) {
			// constructor code
			ref=f;
			localwidth=width;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addEventListener(TouchEvent.TOUCH_DOWN,touchDown);  // pulsa sobre
			addEventListener(TouchEvent.TOUCH_UP, touchUp);		// suelta sobre
			addEventListener(TouchEvent.TOUCH_MOVE, touchMove); // mueve sobre
			addEventListener(TouchEvent.TOUCH_OUT, touchUp);	// suelta fuera (pierde arrastre)
			
			//addEventListener(TransformGestureEvent.GESTURE_ZOOM, touchZoom);
			
		}
		
		public function getRefFoto():MovieClip {
			return refFoto;
		}
		
		public function touchDown(e:TouchEvent) {
			switch (estado) {
				case ESTADO_ACTIVO:
						touchId=e.tuioContainer.sessionID;
						offsetX=e.localX;
						offsetY=e.localY;
						origX=e.stageX;
						origY=e.stageY;
						estado=ESTADO_ARRASTRE;
						ref.activity();
				break;
				case ESTADO_ARRASTRE:
						if (e.tuioContainer.sessionID!=touchId) {
							touchId2=e.tuioContainer.sessionID;
							offsetX2=e.localX;
							offsetY2=e.localY;
							origX2=e.stageX;
							origY2=e.stageY;
							zoomed=false; // nuevo gesto de zoom
							estado=ESTADO_ZOOM; // con 2 dedos, zoom, pero ya no arrastre
							distZoom=Math.abs(origX2-origX)+Math.abs(origY2-origY);
							ref.activity();
						}
				break;
				default: break;
			}
		}
		
		public function touchUp(e:TouchEvent) {
			switch (estado) {
				case ESTADO_ARRASTRE:
					if (touchId==e.tuioContainer.sessionID) {//solo si lo suelta el mismo
						// volver al origen
						TweenLite.to(this, 1, {x:0});
						estado=ESTADO_ACTIVO;
						ref.activity();
					}
				break;
				case ESTADO_ZOOM:
					if (touchId==e.tuioContainer.sessionID) { //soltar el primero
						estado=ESTADO_ARRASTRE;
						// soltado el primero, paso 2o como unico
						touchId=touchId2;
						origX=origX2; offsetX=offsetX2;
						origY=origY2; offsetY=offsetY2;
						// borro el segundo
						touchId2=0;
					} else if (touchId2==e.tuioContainer.sessionID) { // soltar el segundo
						estado=ESTADO_ARRASTRE;
						// borro el segundo
						touchId2=0;
					}
				break;
				default: break;
			}
		}
		
		public function touchMove(e:TouchEvent) {
			switch (estado) {
				case ESTADO_ARRASTRE:
					if (touchId==e.tuioContainer.sessionID) { //solo si lo arrastra el mismo
						// situar nube en la posicion actual
						this.x+=e.localX-offsetX;
						// segun distancia recorrida
						var dist:Number=(Math.abs(origX-e.stageX));  // solo X
						if (dist>=(localwidth*PAGINA)) {
							// pasar pagina
							estado=ESTADO_ESPERA;
							if (e.stageX<origX) { // a izquierdas... avanzar
								ref.pasarPagina(true); 
							} else { // a derechas... retroceder
								ref.pasarPagina(false);
							}
						}
						ref.activity();
					}
				break;
				case ESTADO_ZOOM:
					if (!zoomed) {
						if (e.tuioContainer.sessionID==touchId || e.tuioContainer.sessionID==touchId2) {
							// segun distancia recorrida
							var newDist=Math.abs(origX2-origX)+Math.abs(origY2-origY);
							var zoomFactor=(newDist-distZoom); // + si alejar, - si acercar
							if (Math.abs(zoomFactor)>30) { // al menos 30 pixels de diferencia
								if (zoomFactor>0) TweenLite.to(this, 1, {scaleX:2, scaleY:2}); // aumentar
								else TweenLite.to(this, 1, {scaleX:1, scaleY:1}); // reducir
								// fin de zoom: obligo a soltar y volver a pulsar
								// (al menos uno de los 2 dedos)
								zoomed=true;
							}
							// actualizar origenes (para posterior arrastre simple)
							if (e.tuioContainer.sessionID==touchId) {
								origX=e.stageX; origY=e.stageY;
							} else {
								origX2=e.stageX; origY2=e.stageY;
							}
						}
					} // fin if !zoomed
				break;
				default: break;
			}
		}
		
		public function touchZoom(e:TransformGestureEvent) {
			if (estado==ESTADO_ACTIVO) {
				if (e.scaleX>0) {
					// aumentar
					TweenLite.to(this, 1, {scaleX:2, scaleY:2});
				} else {
					// reducir
					TweenLite.to(this, 1, {scaleX:1, scaleY:1});
				}
				/*
				scaleX+=(e.scaleX*parent.scaleX);
				scaleY+=(e.scaleY*parent.scaleY);
				if (scaleX>2) scaleX=2;
				if (scaleY>2) scaleY=2;
				if (scaleX<1) scaleX=1;
				if (scaleY<1) scaleY=1;
				//*/
			}
			ref.activity();
		}
	}
	
}
