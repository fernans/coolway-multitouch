package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.ui.Mouse;
	
	import org.tuio.*;
	import org.tuio.gestures.*;
	import org.tuio.connectors.*;
	import org.tuio.debug.*;
	import org.tuio.TouchEvent;
	import org.tuio.mouse.*;

	
	public class Desktop extends MovieClip {
		
		private static const DEBUG:Boolean=false;
		private static const MOUSE:Boolean=false;
		
		public static const NUMNUBES=10;
		
		public var stageWidth:Number;
		public var stageHeight:Number;
		
		public var fondo:MovieClip;
		public var nubesContainer:MovieClip;
		public var numNoNubes:Number=0;
		public var overlay:MovieClip;
		public var menus:MovieClip;
		public var frontal:MovieClip;
		public var mosca:MovieClip;
		public var obstaculos:MovieClip;
		
		public var menuPlaces:Array=new Array(true,true,true);
		
		private var lc:Boolean = true;
		private var tc:TuioClient;
		private var tmanager:TuioManager;
		
		public function Desktop() {
			// constructor code
			stop();
			trace("-----INIT-----");
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stageWidth=stage.stageWidth;
			stageHeight=stage.stageHeight;
			trace(stageWidth+", "+stageHeight);
			
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			stage.align=StageAlign.TOP_LEFT;
			
			stage.stageWidth=stageWidth;
			stage.stageHeight=stageHeight;
			//stageWidth=stage.stageWidth;
			//stageHeight=stage.stageHeight;
			trace(stageWidth+", "+stageHeight);
			
			//econder cursor de raton natural
			if (!MOUSE)	Mouse.hide();
			
			/*
			// inicialicar "obstaculos" (invisibles)
			obstaculos=new Obstaculos();
			obstaculos.x=stageWidth/2;
			obstaculos.y=stageHeight/2;
			addChild(obstaculos);
			//*/
			
			// inicializar fondo
			fondo=new Fondo();
			fondo.x=stageWidth/2;
			fondo.y=stageHeight/2;
			addChild(fondo);
			
			// contenedor de Nubes (controla los choques entre ellas)
			nubesContainer=new MovieClip();
			addChild(nubesContainer);
			//nubesContainer.addEventListener(Event.ENTER_FRAME, nubesChocar); // no chocan entre ellas
			nubesContainer.addEventListener(Event.ENTER_FRAME, numeroNubes);
			//crear nubes
			numeroNubes(null);
			
			// capa de overlay
			overlay=new Overlay();
			overlay.x=stageWidth/2;
			overlay.y=stageHeight/2;
			addChild(overlay);
			
			// capa menus (delante)
			menus=new MovieClip();
			addChild(menus);
			
			// capa frontal (primer plano)
			frontal=new MovieClip();
			addChild(frontal);
			
			mosca = new Logo();
			addChild(mosca);
			
			// TUIO
			this.tc = new TuioClient(new LCConnector());
			//this.tc = new TuioClient(new UDPConnector()); // UDP en AIR?
			
			//this.tmanager = TuioManager.init(stage,tc);
			GestureManager.init(stage,tc);
			GestureManager.addGesture(new RotateGesture());
			
			TuioManager.getInstance().holdTimeout=1000;
			//this.tmanager.dispatchNativeTouchEvents=true;
			if (DEBUG) this.tc.addListener(TuioDebug.init(stage));		// solo para DEBUG
			if (MOUSE) var winTouch:MouseToTouchDispatcher = new MouseToTouchDispatcher(stage);

		}

		public function numeroNubes(e:Event) {
			if (nubesContainer.numChildren<NUMNUBES) {
				//crear nube nueva (a la derecha)
				var max:Number=10;
				if (numNoNubes>0) max=8; // solo nubes
				var tipo:Number=Math.floor(Math.random()*max);
				var nube:Nube;
				
				//tipo=8;

				if (tipo==0) nube=new NubeG1();
				if (tipo==1) nube=new NubeG2();
				if (tipo==2) nube=new NubeG3();
				if (tipo==3) nube=new NubeG4();
				if (tipo==4) {nube=new NubeP1();nube.puntos=150;}
				if (tipo==5) {nube=new NubeP2();nube.puntos=150;}
				if (tipo==6) {nube=new NubeP3();nube.puntos=150;}
				if (tipo==7) {nube=new NubeP4();nube.puntos=150;}
				if (tipo==8) {nube=new Pajaro();nube.puntos=500;}
				if (tipo==9) {nube=new Globo();nube.puntos=300;}
				
				if (tipo<=3) { //nubes grandes (hacia la izquierda)
					nube.scaleX=nube.scaleY=0.5;
					nube.y=stageHeight*Math.random()*0.6; // solo en los 2/3 superiores
					nube.x=stageWidth+nube.width;
				} else if (tipo>3 && tipo<=7) {
					// nubes pequeñas (hacia la derecha)
					nube.x=-nube.width;
					//nube.VELOCIDAD_X*=-1;
					//nube.VELOCIDAD_X_MIN*=-1;
					nube.vx*=-1;
					nube.scaleX=nube.scaleY=0.5;
					nube.y=stageHeight*Math.random()*0.6; // solo en los 2/3 superiores
				} else if (tipo==8) {
					// pajaros
					numNoNubes++;
					// elegir derecha (normal) o izquierda (invertido)
					if (Math.random()>=0.5) { //derechos (normal)
						nube.scaleX=nube.scaleY=0.25;
						nube.x=-nube.width;
						nube.vx*=-1;
					} else { //izquierdos (invertidos)
						nube.scaleX=nube.scaleY=0.25;
						nube.x=stageWidth+nube.width;
						nube.scaleX*=-1;
					}
					nube.y=stageHeight*Math.random()*0.3; // solo en los 1/3 superiores
				} else if (tipo==9) {
					// globo
					numNoNubes++;
					// elegir derecha o izquierda
					nube.vx*=0.2;
					if (Math.random()>=0.5) {
						nube.vx*=-1;
					}
					nube.x=(stageWidth/2)+(Math.random()*(2*nube.width))-nube.width;
					nube.y=stageHeight+nube.height; // aparece por debajo
					//nube.y=stageHeight*((Math.random()*0.3)+0.3); // solo en el 1/3 central
					nube.scaleX=nube.scaleY=0.5;
				}
				
				nubesContainer.addChild(nube);
			}
		}
		
		
		public function nubesChocar(e:Event) {
			var num=nubesContainer.numChildren;
			for (var a:int=0;a<num;a++) {
				var NubeA:Nube=(nubesContainer.getChildAt(a) as Nube);
				if (NubeA.getEstado()==Nube.ESTADO_LIBRE) { //solo si es nube libre
					for (var b:int=(a+1);b<num;b++) {
						var NubeB:Nube=(nubesContainer.getChildAt(b) as Nube);
						if (NubeB.getEstado()==Nube.ESTADO_LIBRE) { //solo chocar contra nubes libres
							if (NubeA.hitTestObject(NubeB)) {
								//chocar
								NubeA.chocaCon(NubeB);
								NubeB.chocaCon(NubeA);
							}
						}
					}
				}
			}
		}

	} // end-class
	
} //end-package
