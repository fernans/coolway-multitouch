package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class Pajaro extends Nube {
		
		private static const target1X = 1144/1366;
		private static const target1Y = 88/728; // 93/514;
		private static const target2X = 331/1366;
		private static const target2Y = 350/728; // 239/514;
		
		private static const offsetX = -0;
		private static const offsetY = 0; // 58  29 30   15   
		
		private var targetX:Number=0;
		private var targetY:Number=0;
		private var currentX:Number=0;
		private var currentY:Number=0;
		private var subEstado:Number=0;
		
		public function Pajaro() {
			// constructor code
			trace("pajaro");
			puntos=500;
		}
		
		public override function init(e:Event) {
			trace("init pajaro");
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// iniciar comportamiento animacion
			var r:Desktop=(root as Desktop);
			if (this.scaleX>0) {
				// pajaro a derecha (target 1)
				targetX=(target1X*r.stageWidth)-(offsetX);
				targetY=(target1Y*r.stageHeight)-(offsetY);
			} else {
				// pajaro a izquierdas (target 2)
				targetX=(target2X*r.stageWidth)+(offsetX);
				targetY=(target2Y*r.stageHeight)-(offsetY);
			}
			// calculo velocidad Y (para que llegue cuando llegue la X)
			var tiempo:Number=(Math.abs(targetX-x)/Math.abs(vx));
			tiempo=Math.round(tiempo); // tiempo debe ser entero
			
			currentX=x;
			currentY=y;
			vx=(targetX-x)/tiempo;
			vy=(targetY-y)/tiempo;
			
			subEstado=0;
			addEventListener(Event.ENTER_FRAME, frame);
		}
		
		public override function frame(e:Event) {
			switch (estado) {
				case ESTADO_LIBRE:
					switch (subEstado) {
						case 0: // volar hacia destino
							//avanzar segun velocidad
							currentX+=vx;
							currentY+=vy;
							x=currentX;
							y=currentY;
							if (Math.abs(targetX-currentX)<Math.abs(vx) && Math.abs(targetY-currentY)<Math.abs(vy)) {
								subEstado++;
								trace("LLEGA");
								gotoAndStop(6);
								temporizador=(getChildAt(0) as MovieClip).totalFrames;
							}
						break;
						case 1: // aterrizar
							// parado
							temporizador--;
							if (temporizador<=0) {
								//continuar recorrido
								if (vy>0) vy*=-1;
								subEstado++;
							}
						break;
						case 2: // volar hacia afuera
							//avanzar segun velocidad
							x+=vx;
							y+=vy;
						break;
						default:
						break;
					}
					// al salirse "muere" (ya se creará una nueva... por la derecha)
					if (x<-(width*2) || x>stage.stageWidth+(width*2)) fin(null);
					break;
				case ESTADO_CHOQUE:
					if (scaleX<0) scaleX*=-1;
					temporizador--;
					if (temporizador<=0) {
						//eliminar nube
						// (ya se creará otra nube nueva... sola
						fin(null);
					}
					break;
				default: break;
			}
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
