package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.tuio.TouchEvent;
	import flash.xml.XMLDocument;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.xml.XMLNode;
	import flash.display.Loader;
	
	import mx.rpc.soap.*;
	import mx.rpc.events.*;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;
	import flash.display.LoaderInfo;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.display.Bitmap;
	
	public class PS extends MovieClip {
		
		private const KEY="XXX-XXX-XXX"; // password (clave del web service del cliente)
		private const WEBSERVICE_URL="XXX-XXX-XXX"; // web service URL (privado del cliente)
	
		private var menu:Menu; // :Menu;

		private var loader:URLLoader;
		private var xml:XMLDocument
		private var panelHome:String="";
		
		private var loaderExtern:URLLoader=null;
		private var urlExtern:String=null;
		private var idExtern:String=null;
		
		private var layerFondo:Loader=new Loader();
			private var usedFondo:Boolean=false;
		private var layerOpciones:MovieClip=new MovieClip();
			private var usedOpciones:Array=new Array(); // de Loaders
		private var layerAdornos:MovieClip=new MovieClip();
			private var usedAdornos:Array=new Array(); // de Loaders
		private var layerNavegacion:MovieClip=new MovieClip();
			private var bBack:Loader=new Loader();
			private var bNext:Loader=new Loader();
			private var bHome:Loader=new Loader();
			private var usedBack:Boolean=false;
			private var usedNext:Boolean=false;
			private var usedHome:Boolean=false;
		private var layerTeclado:MovieClip=new MovieClip();
			
		private var historial:Array=new Array(); // de IDs
		private var historialIndex:Number=-1;
		
		private var pedido:Object={modelo:"", referencia:"", talla:"", color:"", nombre:"", email:""};
		
		private var webService:WebService;
		
		
		public function PS(menu:Menu=null, extern:CoolwayEvent=null) { //:Menu
			trace("Personal Shopper");
			// constructor code
			this.menu=menu;
			addEventListener(Event.ADDED_TO_STAGE, init);
			// posible documento externo
			if (extern!=null) {
				urlExtern=extern.url;
				idExtern=extern.id;
			}
			// cargar documento base
			loader=new URLLoader();
			loader.addEventListener(Event.COMPLETE, cargado);
			loader.load(new URLRequest("personalshopper.xml"));
			
			layerNavegacion.addChild(bBack);
			layerNavegacion.addChild(bNext);
			layerNavegacion.addChild(bHome);
			addChild(layerFondo);
			addChild(layerOpciones);
			addChild(layerAdornos);
			addChild(layerNavegacion);
			addChild(layerTeclado);
			
			layerFondo.contentLoaderInfo.addEventListener(Event.COMPLETE, centrarContenido);
			bBack.contentLoaderInfo.addEventListener(Event.COMPLETE, centrarContenido);
			bNext.contentLoaderInfo.addEventListener(Event.COMPLETE, centrarContenido);
			bHome.contentLoaderInfo.addEventListener(Event.COMPLETE, centrarContenido);
			
			bBack.addEventListener(TouchEvent.TOUCH_DOWN, fBack);
			bNext.addEventListener(TouchEvent.TOUCH_DOWN, fNext);
			bHome.addEventListener(TouchEvent.TOUCH_DOWN, fHome);
			
			webService = new WebService();
			webService.loadWSDL(WEBSERVICE_URL);
			webService.addEventListener(LoadEvent.LOAD, function (e:Event){trace("web service connected");});
		}
		
		public function cargado(e:Event) {
			xml=new XMLDocument(loader.data);
			// buscar el primer nodo PANEL
			// y usarlo como Home
			var n:XMLNode=xml.firstChild;
			while (n!=null) {
				if (n.localName=="panel" && n.attributes.id!=null) {
					//encontrado
					panelHome=n.attributes.id;
					break; // salir el bucle (con el primero)
				}
				n=n.nextSibling;
			}
			// ningun panel tiene ID
			// nada a cargar
			
			// si tenemos documento externo
			if (urlExtern!=null) {
				// cargar el nuevo documento (para agregarlo y usarlo como inicio
				loaderExtern=new URLLoader();
				loaderExtern.addEventListener(Event.COMPLETE, cargadoExtern);
				loaderExtern.load(new URLRequest(urlExtern));
			} else {
				// si tenemos id de inicio... saltar a ese
				if (idExtern!=null) {
					historial=new Array(); //borrar historial
					historial.push(idExtern); //guardar id inicial
					historialIndex=0;
					cargarPanel(idExtern);
				} else {
					// si no hay adicionales... saltar al Home encontrado
					fHome(null);
				}
			}
			
			// lanzar sonido inicio
			var sInicio:Sound=new soundPSinicio();
			sInicio.play();
		}
		
		public function cargadoExtern(e:Event) {
			var xmlExtern:XMLDocument=new XMLDocument(loaderExtern.data);
			// agregar al documento actual
			var node:XMLNode=xmlExtern.firstChild;
			var inicial:String=node.attributes.id; // guardarme el ID del primero (inicial)
			while (node!=null) { // agregar nuevos al documento principal
				xml.appendChild(node);
				node=node.nextSibling;
			}
			if (idExtern!=null) {
				// si tenemos id de inicio... saltar a ese
				inicial=idExtern;
			}
			// saltar al primero de este (conservar el Home del BASE)
			historial=new Array();
			historial.push(inicial);
			historialIndex=0;
			cargarPanel(inicial);
		}
		
		private function cargarPanel(id:String) {
			activity();
			trace("=== "+id);
			// vaciar lista de usados (adornos, opciones, fondo, navegacion)
			usedFondo=false;
			usedAdornos=new Array();
			usedOpciones=new Array();
			usedBack=false;
			usedNext=false;
			usedHome=false;
			//teclado eliminar/recargar siempre
			while (layerTeclado.numChildren>0)  layerTeclado.removeChildAt(0);
			
			//crear retilizando
			leerPanel(id); 
			
			// eliminar los no reutilizados
			if (!usedFondo) layerFondo.unload();
			if (!usedBack) bBack.unload();
			if (!usedNext) bNext.unload();
			if (!usedHome) bHome.unload();
			// buscar todos... y si no en used... eliminar
			var i:int;
			for (i=0;i<layerOpciones.numChildren;i++) {
				if (usedOpciones.indexOf(layerOpciones.getChildAt(i))==-1) {
					layerOpciones.removeChildAt(i);
					i--;
				}
			}
			for (i=0;i<layerAdornos.numChildren;i++) {
				if (usedAdornos.indexOf(layerAdornos.getChildAt(i))==-1) {
					layerAdornos.removeChildAt(i);
					i--;
				}
			}
			trace("---");
		}
		
		private function leerPanel(id:String) {
			var node:XMLNode=buscarPanel(id);
			if (node!=null) {
				trace("creando: "+id);
				// crear plantilla
				if (node.attributes.ref!=null) leerPanel(node.attributes.ref);
				// crear panel
				node=node.firstChild;
				while (node!=null) {
					if (node.localName=="fondo") { // fondo
						if (node.attributes.url!=null) {
							if (layerFondo.contentLoaderInfo.url==null || layerFondo.contentLoaderInfo.url.indexOf(node.attributes.url)==-1)
								layerFondo.load(new URLRequest(node.attributes.url));
						}
						if (node.attributes.x!=null) layerFondo.x=node.attributes.x;
						if (node.attributes.y!=null) layerFondo.y=node.attributes.y;
						if (node.attributes.sx!=null) layerFondo.scaleX=node.attributes.sx;
						if (node.attributes.sy!=null) layerFondo.scaleY=node.attributes.sy;
						usedFondo=true;
					} else if (node.localName=="adorno") { // adorno
						if (node.attributes.url!=null) {
							var adorno:Loader=buscar(layerAdornos,node.attributes.url);
							if (adorno==null) {
								adorno=new Loader();
								adorno.contentLoaderInfo.addEventListener(Event.COMPLETE, centrarContenido);
								adorno.load(new URLRequest(node.attributes.url));
							}
							layerAdornos.addChild(adorno);
							usedAdornos.push(adorno);
							if (node.attributes.x!=null) adorno.x=node.attributes.x;
							if (node.attributes.y!=null) adorno.y=node.attributes.y;
							if (node.attributes.sx!=null) adorno.scaleX=node.attributes.sx;
							if (node.attributes.sy!=null) adorno.scaleY=node.attributes.sy;
						}
					} else if (node.localName=="opcion") {
						if (node.attributes.url!=null) {
							var opcion:PSenlace=(buscar(layerOpciones,node.attributes.url) as PSenlace);
							if (opcion==null) {
								opcion=new PSenlace();
								opcion.contentLoaderInfo.addEventListener(Event.COMPLETE, centrarContenido);
								opcion.load(new URLRequest(node.attributes.url));
							}
							layerOpciones.addChild(opcion);
							usedOpciones.push(opcion);
							if (node.attributes.x!=null) opcion.x=node.attributes.x;
							if (node.attributes.y!=null) opcion.y=node.attributes.y;
							if (node.attributes.sx!=null) opcion.scaleX=node.attributes.sx;
							if (node.attributes.sy!=null) opcion.scaleY=node.attributes.sy;
							if (node.attributes.ref!=null) {
								opcion.ref=node.attributes.ref;
								opcion.addEventListener(TouchEvent.TOUCH_DOWN,enlace);
							}
						}
					} else if (node.localName=="back") {
						if (node.attributes.url!=null) {
							if (bBack.contentLoaderInfo.url==null || bBack.contentLoaderInfo.url.indexOf(node.attributes.url)==-1)
								bBack.load(new URLRequest(node.attributes.url));
						}
						if (node.attributes.x!=null) bBack.x=node.attributes.x;
						if (node.attributes.y!=null) bBack.y=node.attributes.y;
						if (node.attributes.sx!=null) bBack.scaleX=node.attributes.sx;
						if (node.attributes.sy!=null) bBack.scaleY=node.attributes.sy;
						usedBack=true;
					} else if (node.localName=="next") {
						if (node.attributes.url!=null) {
							if (bNext.contentLoaderInfo.url==null || bNext.contentLoaderInfo.url.indexOf(node.attributes.url)==-1)
								bNext.load(new URLRequest(node.attributes.url));
						}
						if (node.attributes.x!=null) bNext.x=node.attributes.x;
						if (node.attributes.y!=null) bNext.y=node.attributes.y;
						if (node.attributes.sx!=null) bNext.scaleX=node.attributes.sx;
						if (node.attributes.sy!=null) bNext.scaleY=node.attributes.sy;
						usedNext=true;
					} else if (node.localName=="home") {
						if (node.attributes.url!=null) {
							if (bHome.contentLoaderInfo.url==null || bHome.contentLoaderInfo.url.indexOf(node.attributes.url)==-1)
								bHome.load(new URLRequest(node.attributes.url));
						}
						if (node.attributes.ref!=null) panelHome=node.attributes.ref;
						if (node.attributes.x!=null) bHome.x=node.attributes.x;
						if (node.attributes.y!=null) bHome.y=node.attributes.y;
						if (node.attributes.sx!=null) bHome.scaleX=node.attributes.sx;
						if (node.attributes.sy!=null) bHome.scaleY=node.attributes.sy;
						usedHome=true;
					} else if (node.localName=="fin") {
						//*
						var tec:Teclado=new Teclado();
						layerTeclado.addChild(tec);
						if (node.attributes.x!=null) tec.x=node.attributes.x;
						if (node.attributes.y!=null) tec.y=node.attributes.y;
						if (node.attributes.sx!=null) tec.scaleX=node.attributes.sx;
						if (node.attributes.sy!=null) tec.scaleY=node.attributes.sy;
						//*/
						// rellenar atributos del cartel
						pedido.modelo=""; pedido.talla=""; pedido.color=""; pedido.nombre=""; pedido.email="";
						var att:XMLNode=node.firstChild;
						while (att!=null) {
							if (att.localName=="modelo" && att.attributes.txt!=null) pedido.modelo=att.attributes.txt;
							if (att.localName=="talla" && att.attributes.txt!=null) pedido.talla=att.attributes.txt;
							if (att.localName=="color" && att.attributes.txt!=null) pedido.color=att.attributes.txt;
							//if (att.localName=="referencia" && att.attributes.txt!=null) pedido.referencia=att.attributes.txt;
							att=att.nextSibling;
						}
					} else if (node.localName=="info") {
						var serviceOperation:AbstractOperation;
						var parametros:Object={};
						var operacion:String=null;
						if (node.attributes.target!=null) {
							if (node.attributes.target=="ViewProduct") {
								operacion=node.attributes.target;
								parametros.key=KEY;
								if (node.attributes.product!=null) parametros.product=node.attributes.product; else parametros.product="";
							} else if (node.attributes.target=="ViewCategory") {
								operacion=node.attributes.target;
								parametros.key=KEY;
								if (node.attributes.level1!=null) parametros.level1=node.attributes.level1; else parametros.level1="0";
								if (node.attributes.level2!=null) parametros.level2=node.attributes.level2; else parametros.level2="0";
								if (node.attributes.level3!=null) parametros.level3=node.attributes.level3; else parametros.level3="0";
								if (node.attributes.level4!=null) parametros.level4=node.attributes.level4; else parametros.level4="0";
							}
						}
						if (operacion!=null) {
							serviceOperation = webService.getOperation(operacion);
							serviceOperation.removeEventListener(FaultEvent.FAULT, webserviceError);
							serviceOperation.removeEventListener(ResultEvent.RESULT, webserviceResult);
							serviceOperation.addEventListener(FaultEvent.FAULT, webserviceError);
							serviceOperation.addEventListener(ResultEvent.RESULT, webserviceResult);
							serviceOperation.arguments=parametros;
							serviceOperation.send();
							trace("enviado webservice: "+operacion);
						}
					}
					node=node.nextSibling;
				}
				// fin
			}
		}
		
		private function webserviceResult(e:ResultEvent) {
			trace("webservice result: "+e.result);
		}
		
		private function webserviceError(e:FaultEvent) {
			trace("webservice Error: "+e);
		}
		
		private function buscar(layer:MovieClip, url:String):Loader {
			if (url!=null) {
				var l:Loader;
				for (var i:int=0;i<layer.numChildren;i++) {
					l=(layer.getChildAt(i) as Loader);
					if (l.contentLoaderInfo.url!=null && l.contentLoaderInfo.url.indexOf(url)!=-1)
						return l; // encontrado
				}
				// no encontrado, crear nuevo
				return null;
			} else {
				return null;
				// no url... cargador vacio
			}
		}
		
		private function centrarContenido(e:Event) {
			var li:LoaderInfo=(e.target as LoaderInfo);
			if (li.contentType!="application/x-shockwave-flash") {
				li.content.x=-li.content.width/2;
				li.content.y=-li.content.height/2;
				(li.content as Bitmap).smoothing=true;
			}
		}
		
		private function enlace(e:Event) {
			// lanzar sonido boton
			var sBoton:Sound=new soundPSboton();
			sBoton.play();
			// fin sonido
			var ref:String=(e.target as PSenlace).ref;
			cargarPanel(ref);
			historial.splice(historialIndex+1); //borrar los posteriores del historial
			historial.push(ref);historialIndex++;
		}
		
		private function fBack(e:Event) {
			if (historialIndex>0) {
				// lanzar sonido boton
				var sBoton:Sound=new soundPSboton();
				sBoton.play();
				// fin sonido
				historialIndex--;
				cargarPanel(historial[historialIndex] as String);
			}
		}
		
		private function fNext(e:Event) {
			if (historialIndex<(historial.length-1)) {
				// lanzar sonido boton
				var sBoton:Sound=new soundPSboton();
				sBoton.play();
				// fin sonido
				historialIndex++;
				cargarPanel(historial[historialIndex] as String);
			}
		}
		
		private function fHome(e:Event) {
			// lanzar sonido boton
			var sBoton:Sound=new soundPSboton();
			sBoton.play();
			// fin sonido
			historial=new Array();
			historial.push(panelHome);
			historialIndex=0;
			cargarPanel(panelHome);
		}
		
		private function buscarPanel(id:String):XMLNode {
			var node:XMLNode=xml.firstChild;
			while (node!=null) {
				if (node.localName=="panel") {
					if (node.attributes.id!=null && node.attributes.id==id) {
						return node;
					}
				}
				node=node.nextSibling;
			}
			return null;
		}
		
		public function init(e:Event) {
			activity();
		}
		
		public function activity() {
			menu.activity();
		}
		
		public function enviar() {
			// recoger datos del teclado
			var tec:Teclado=(layerTeclado.getChildAt(0) as Teclado);
			pedido.nombre=tec.nombre;
			pedido.email=tec.email;

			// enviar datos
			var parametros:Object={};
			var operacion:String="DemandProduct";
			parametros.key=KEY;
			parametros.name=pedido.nombre;
			parametros.size=pedido.talla;
			parametros.email=pedido.email;
			parametros.product=pedido.modelo;
			parametros.color=pedido.color;

			trace("FIN:");
			trace(parametros.key);
			trace(parametros.name);
			trace(parametros.size);
			trace(parametros.email);
			trace(parametros.product);
			trace(parametros.color);
			
			var serviceOperation:AbstractOperation = webService.getOperation(operacion);
			serviceOperation.removeEventListener(FaultEvent.FAULT, webserviceError);
			serviceOperation.removeEventListener(ResultEvent.RESULT, webserviceResult);
			serviceOperation.addEventListener(FaultEvent.FAULT, webserviceError);
			serviceOperation.addEventListener(ResultEvent.RESULT, webserviceResult);
			serviceOperation.arguments=parametros;
			serviceOperation.send();
			trace("enviado webservice: "+operacion);
			
			// mostrar letrero
			var r:Desktop=root as Desktop;
			var cartel:PSpedido=new PSpedido();
			cartel.txtNombre.text=pedido.nombre;
			cartel.txtModelo.text=pedido.modelo;
			cartel.txtTalla.text=pedido.talla;
			cartel.txtColor.text=pedido.color;
			//cartel.txtReferencia.text=pedido.referencia;
			r.frontal.addChild(cartel);
			var p:Point=this.localToGlobal(new Point(x,y));
			cartel.x=p.x;
			cartel.y=p.y;
			cartel.init();
			
			// reiniciar menu
			trace("PS completado");
			menu.resetMenu();
		}
	
	}
	
}
