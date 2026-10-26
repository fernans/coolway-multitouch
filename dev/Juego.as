package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import com.greensock.*;
	import flash.utils.getTimer;
	
	import mx.rpc.soap.*;
	import mx.rpc.events.*;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;
	
	public class Juego extends MovieClip {
		
		private const KEY="XXX-XXX-XXX"; // password (clave del web service del cliente)
		private const WEBSERVICE_URL="XXX-XXX-XXX"; // web service URL (privado del cliente)
		
		public var numPelotas=5;
		public var puntos=0;
		private var tiempo:int;
		private var refPelotas:Array=new Array();
		private var refCentro:Point;
		public var menu:Menu;
		
		private var webService:WebService;
		
		public function Juego(menu:Menu=null) {
			// constructor code
			stop();
			this.menu=menu;
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, fin);
			
			webService = new WebService();
			webService.loadWSDL(WEBSERVICE_URL);
			webService.addEventListener(LoadEvent.LOAD, function (e:Event){trace("web service connected");});
		}
		
		public function init(e:Event) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			var referencia:Point=new Point(x,y);
			referencia=this.localToGlobal(referencia);
			var p:Pelota;
			
			//pelota 1
			p=new Pelota(this);
			referencia=this.localToGlobal(new Point(x+p1.x,y+p1.y));
			p.x=referencia.x; p.y=referencia.y;
			refPelotas.push(p);
			refCentro=new Point(referencia.x,referencia.y);
			//pelota 2
			p=new Pelota(this);
			referencia=this.localToGlobal(new Point(x+p2.x,y+p2.y));
			p.x=referencia.x; p.y=referencia.y;
			refPelotas.push(p);
			//pelota 3
			p=new Pelota(this);
			referencia=this.localToGlobal(new Point(x+p3.x,y+p3.y));
			p.x=referencia.x; p.y=referencia.y;
			refPelotas.push(p);
			//pelota 4
			p=new Pelota(this);
			referencia=this.localToGlobal(new Point(x+p4.x,y+p4.y));
			p.x=referencia.x; p.y=referencia.y;
			refPelotas.push(p);
			//pelota 5
			p=new Pelota(this);
			referencia=this.localToGlobal(new Point(x+p5.x,y+p5.y));
			p.x=referencia.x; p.y=referencia.y;
			refPelotas.push(p);
			
			for (var i:int=numPelotas; i>0; i--) {
				(root as Desktop).frontal.addChild(refPelotas[i-1]);
			}
			
			// activar la primera
			(refPelotas[0] as Pelota).cambioEstado(Pelota.ESTADO_TURNO);
			
			// iniciar tiempo de juego
			tiempo=getTimer();
		}
		
		public function fin(e:Event) {
			while (refPelotas.length>0) {
				var r:Pelota=refPelotas.shift() as Pelota;
				r.parent.removeChild(r);
			}
		}
		
		public function completado() {
			//gotoAndStop(1);
			stop();
			trace("quien completado");
			menu.resetMenu();
		}
		
		public function informPelotaMenos() {
			if (numPelotas==0) { //fin juego
				tiempo=Math.floor((getTimer()-tiempo)/1000);
				this.nextFrame();
				//menu.resetMenu(); 
			}
		}
		
		public function informPuntos(p:Number=0) {
			puntos+=p;
			marcador.text=puntos.toString();
			refPelotas.shift();
			numPelotas--;
			if (numPelotas>0) {
				// recolocar y activar siguiente Pelota
				var nextP:Pelota=(refPelotas[0] as Pelota);
				TweenLite.to(nextP, 1, {x:refCentro.x});
				nextP.cambioEstado(Pelota.ESTADO_TURNO);
			}
		}
		
		public function enviar() {			
			// enviar datos
			var parametros:Object={};
			var operacion:String="SetRanking";
			parametros.key=KEY;
			parametros.name=teclado.nombre;
			parametros.email=teclado.email;
			parametros.score=puntos;
			parametros.seconds=tiempo;
			
			trace("---");
			trace(parametros.name);
			trace(parametros.email);
			trace(parametros.score);
			trace(parametros.seconds);
			trace("---");
			
			var serviceOperation:AbstractOperation = webService.getOperation(operacion);
			serviceOperation.removeEventListener(FaultEvent.FAULT, webserviceError);
			serviceOperation.removeEventListener(ResultEvent.RESULT, webserviceResult);
			serviceOperation.addEventListener(FaultEvent.FAULT, webserviceError);
			serviceOperation.addEventListener(ResultEvent.RESULT, webserviceResult);
			serviceOperation.arguments=parametros;
			serviceOperation.send();
			trace("enviado webservice: "+operacion);
			
			// enviado!
			
			this.nextFrame();
			//luego se llamará a "completado" y se cerrará todo
		}
		
		private function webserviceResult(e:ResultEvent) {
			trace("webservice result: "+e.result);
		}
		
		private function webserviceError(e:FaultEvent) {
			trace("webservice Error: "+e);
		}
		
		public function activity() {
			menu.activity();
		}
		
	}
	
}
