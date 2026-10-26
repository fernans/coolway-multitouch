package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.xml.XMLDocument;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.xml.XMLNode;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	import flash.media.Sound;
	import com.greensock.*;
	
	
	public class Fotos extends MovieClip {
		
		private const VEL=0.5;	// velocidad de la transicion
		
		private var cargado:Boolean=false;
		private var menu:Menu;
		private var index:Number=0;
		private var fotos:Array;
		private var listaFotos:Array=new Array();
		private var loader:URLLoader;
		
		public function Fotos(menu:Menu=null) {
			// constructor code
			this.menu=menu;
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, fin);
			loader=new URLLoader();
			loader.addEventListener(Event.COMPLETE, cargaLista);
			loader.load(new URLRequest("fotos.xml"));
		}
		
		public function fin(e:Event) {
			// nothing
			fotos=null;
		}
		
		public function init(e:Event) {
			if (cargado) {	// SI YA TENGO EL XML... ADELANTE
				// crear elementos Foto
				fotos=new Array();
				var f:Foto;
				
				var acargar:Number;
				var l:Loader;
				
				// left
				f=new Foto1(this);
				f.x=refLeft.x;
				f.y=refLeft.y;
				f.scaleX=f.scaleY=0.5;
				fotos.push(f);
				addChild(f);
				// cargar
				acargar=index-1;
				if (acargar<0) acargar+=listaFotos.length;
				l=new Loader();	f.getRefFoto().addChild(l);
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, centerFoto);
				l.load(new URLRequest(listaFotos[acargar] as String));
				
				// central
				f=new Foto2(this);
				f.x=refCenter.x;
				f.y=refCenter.y;
				fotos.push(f);
				addChild(f);
				// cargar
				acargar=index;
				l=new Loader();	f.getRefFoto().addChild(l);
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, centerFoto);
				l.load(new URLRequest(listaFotos[acargar] as String));
				// agregar flecha de ayuda (solo al primero)
				var fle:FotoFlechaEstirar = new FotoFlechaEstirar();
				f.addChild(fle);
				
				// right
				f=new Foto3(this);
				f.x=refRight.x;
				f.y=refRight.y;
				f.scaleX=f.scaleY=0.5;
				fotos.push(f);
				addChild(f);
				// cargar
				acargar=index+1;
				if (acargar>=listaFotos.length) acargar-=listaFotos.length;
				l=new Loader();	f.getRefFoto().addChild(l);
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, centerFoto);
				l.load(new URLRequest(listaFotos[acargar] as String));
				
				// activar central
				(fotos[1] as Foto).estado=Foto.ESTADO_ACTIVO;
				// cambiar orden (central arriba... el ultimo)
				this.setChildIndex(fotos[1] as MovieClip,numChildren-1);
				
				// leer xml
				// poner fotos iniciales
				index=0;
			} else {
				cargado=true; // lanzar init, cuando termine la carga del xml
			}
		}
		
		public function pasarPagina(avanzar:Boolean) {
			trace("pasarPagina: "+avanzar);
			// lanzar sonido pasar
			var sPasar:Sound=new soundFotoPasar();
			sPasar.play();
			// fin sonido
			if (avanzar) {
				index++;
				if (index>=listaFotos.length) index-=listaFotos.length;
				// izquierdo (eliminar)
				var eliminar:MovieClip=fotos.splice(0,1)[0] as MovieClip;
				eliminar.parent.removeChild(eliminar);
				// central
				var central:Foto=fotos[0] as Foto;
				TweenLite.to(central, VEL, {x:refLeft.x, y:refLeft.y, scaleX:0.5, scaleY:0.5});
				central.estado=Foto.ESTADO_ESPERA;
				// derecho
				var derecho:Foto=fotos[1] as Foto;
				TweenLite.to(derecho, VEL, {x:refCenter.x, y:refCenter.y, scaleX:1, scaleY:1});
				setChildIndex(derecho,numChildren-1); //arriba
				derecho.estado=Foto.ESTADO_ACTIVO;
				// nuevo
				var nuevo:Foto;
				switch(Math.floor(Math.random()*3)) {
					case 0:
						nuevo=new Foto1(this); break;
					case 1:
						nuevo=new Foto2(this); break;
					case 2:
						nuevo=new Foto3(this); break;
					default: break;
				}
				nuevo.x=refRight.x;
				nuevo.y=refRight.y;
				nuevo.scaleX=nuevo.scaleY=0.5;
				fotos.push(nuevo);
				addChild(nuevo);
				setChildIndex(nuevo,0); // abajo del todo
				// cargar nuevo
				var acargar:Number=index+1;
				if (acargar>=listaFotos.length) acargar-=listaFotos.length;
				var l:Loader=new Loader();	nuevo.getRefFoto().addChild(l);
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, centerFoto);
				l.load(new URLRequest(listaFotos[acargar] as String));
			} else { // retroceder
				index--;
				if (index<0) index+=listaFotos.length;
				// derecho (eliminar)
				derecho=fotos.splice(2,1)[0] as Foto;
				derecho.parent.removeChild(derecho);
				// central
				central=fotos[1] as Foto;
				TweenLite.to(central, VEL, {x:refRight.x, y:refRight.y, scaleX:0.5, scaleY:0.5});
				central.estado=Foto.ESTADO_ESPERA;
				// izquierdo
				var izquierdo:Foto=fotos[0] as Foto;
				TweenLite.to(izquierdo, VEL, {x:refCenter.x, y:refCenter.y, scaleX:1, scaleY:1});
				setChildIndex(izquierdo,numChildren-1); //arriba
				izquierdo.estado=Foto.ESTADO_ACTIVO;
				// nuevo
				//var nuevo:Foto;
				switch(Math.floor(Math.random()*3)) {
					case 0:
						nuevo=new Foto1(this); break;
					case 1:
						nuevo=new Foto2(this); break;
					case 2:
						nuevo=new Foto3(this); break;
					default: break;
				}
				nuevo.x=refLeft.x;
				nuevo.y=refLeft.y;
				nuevo.scaleX=nuevo.scaleY=0.5;
				fotos.unshift(nuevo);
				addChild(nuevo);
				setChildIndex(nuevo,0); // abajo del todo
				// cargar nuevo
				acargar=index-1;
				if (acargar<0) acargar+=listaFotos.length;
				l=new Loader();	nuevo.getRefFoto().addChild(l);
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, centerFoto);
				l.load(new URLRequest(listaFotos[acargar] as String));
			}
		}
		
		public function cargaLista(e:Event) {
			var xml:XMLDocument=new XMLDocument(loader.data);
			var node:XMLNode=xml.firstChild;
			while (node!=null) {
				if (node.localName=="foto") {
					if (node.attributes.url!=null) {
						listaFotos.push(node.attributes.url);
						trace(node.attributes.url);
					}
				}
				trace("nodo: "+node.localName);
				node=node.nextSibling;
			}
			if (cargado) {
				// estaba esperando la carga del xml
				cargado=true;
				init(null);
			} else {
				cargado=true;
				// y listo... hasta el ADDED_TO_STAGE
			}
		}
		
		public function centerFoto(e:Event) {
			trace("centrar");
			var li:LoaderInfo=(e.target as LoaderInfo);
			var l:Loader=li.loader;
			var m:DisplayObject = li.content;
			
			//escalar al tamaño exacto de refFoto
			m.width=m.height=0; // para que no afecte al parent
			m.width=l.parent.width/l.parent.scaleX;
			m.height=l.parent.height/l.parent.scaleY;
			
			//  // escalar a la mitad
			//  // (ya son el doble de grandes, para tener mejor resolucion al ampliar)
			//  m.scaleX=m.scaleY=0.5;
			
			//centrar
			m.x=-m.width/2;
			m.y=-m.height/2;
			// permitir suavizado
			(m as Bitmap).smoothing=true;
			
			trace("tamaño marco orig: "+m.width+", "+m.height+" :"+m.scaleX);
		}
		
		public function activity() {
			menu.activity();
		}
		
	}
	
}
