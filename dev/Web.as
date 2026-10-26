package  {
	
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.display.InteractiveObject;
	import org.tuio.TouchEvent;
	import org.tuio.debug.TuioDebugCursor;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.ui.Mouse;
	
	public class Web extends MovieClip {
		
		//private const HOME:String="file://c:/DATOS/Proyectos/hampa/pantallaMultitouch/simpleWeb/simpleWeb.swf";
		//private const HOME="XXX-XXX-XXX"; // web service URL (privado del cliente)
		private const HOME="microsite.swf"; // local
		
		private var menu:Menu;
		private var contenido:Loader;
		
		public function Web(menu:Menu=null) {
			// constructor code
			this.menu=menu;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event) {
			// crear el navegado
			// (hijo de refWeb)
			contenido=new Loader();
			
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.checkPolicyFile = true;
			loaderContext.allowCodeImport = true;
			contenido.contentLoaderInfo.addEventListener(Event.COMPLETE, cargado);
			contenido.load(new URLRequest(HOME));//,loaderContext);
		
			// botones de navegacion
			botonHome.addEventListener(TouchEvent.TAP, bHome);
			botonPrev.addEventListener(TouchEvent.TAP, bPrev);
			botonNext.addEventListener(TouchEvent.TAP, bNext);
			activity();
		}
		
		public function cargado(e:Event) {
			trace("aqui");
			refWeb.addChild(contenido); //contenido.content);
			contenido.content.addEventListener(TouchEvent.TOUCH_DOWN,touchDown);  // pulsa sobre
			contenido.content.addEventListener(TouchEvent.TOUCH_UP,touchUp);  // pulsa sobre
			contenido.content.addEventListener(TouchEvent.TAP,touchTap);  // pulsa sobre
			contenido.content.addEventListener(CoolwayEvent.SHOPPER, shopper);
			
			trace("escalar");
			var l:Loader=contenido;
			var m:DisplayObject = contenido.content;
			
			//escalar al tamaño exacto de refWeb
			m.width=m.height=0; // para que no afecte al parent
			m.width=l.parent.width/l.parent.scaleX;
			m.height=l.parent.height/l.parent.scaleY;
			
			//  // escalar a la mitad
			//  // (ya son el doble de grandes, para tener mejor resolucion al ampliar)
			//  m.scaleX=m.scaleY=0.5;
			
			//centrar
			//m.x=-m.width/2;
			//m.y=-m.height/2;
			// permitir suavizado
			(m as Bitmap).smoothing=true;
			
			trace("tamaño marco orig: "+m.width+", "+m.height+" :"+m.scaleX);
		}
		
		public function bHome(e:Event) {
			contenido.content.dispatchEvent(new CoolwayEvent(CoolwayEvent.HOME));
			activity();
		}
		
		public function bPrev(e:Event) {
			contenido.content.dispatchEvent(new CoolwayEvent(CoolwayEvent.BACK));
			activity();
		}
		
		public function bNext(e:Event) {
			contenido.content.dispatchEvent(new CoolwayEvent(CoolwayEvent.NEXT));
			activity();
		}
		
		/*
		public function webComplete(e:Event) {
			trace("cargado: "+web.contentWidth+", "+web.contentHeight);
		}
		//*/
		
		public function activity() {
			menu.activity();
		}
		
		
		public function touchDown(e:TouchEvent) {
			trace("touchDown");
			dispatch(new MouseEvent(MouseEvent.MOUSE_DOWN, true,false,e.stageX,e.stageY,null,false,false,false,true));
			activity();
		}
		
		public function touchUp(e:TouchEvent) {
			trace("touchUp");
			dispatch(new MouseEvent(MouseEvent.MOUSE_UP, true,false,e.stageX,e.stageY,null,false,false,false,false));
			activity();
		}
		
		public function touchTap(e:TouchEvent) {
			trace("touchTap");
			dispatch(new MouseEvent(MouseEvent.CLICK, true,false,e.stageX,e.stageY,null,false,false,false,false));
			activity();
		}
		
		public function dispatch(ev:MouseEvent) {
			var p:Point=new Point(ev.localX,ev.localY);
			var objs:Array=stage.getObjectsUnderPoint(p);
			var ob:InteractiveObject=null;
			var nev:MouseEvent;
			for (var i:int=objs.length-1;i>=0;i--) {
				if (objs[i] is InteractiveObject) ob=objs[i] as InteractiveObject;
				else ob=(objs[i].parent) as InteractiveObject;
				if (ob is TuioDebugCursor) {ob=null;continue;}	//ignorar el cursor (TuioDebugCursor)
				//ev.stageX=ev.localX;
				//ev.stageY=ev.localY;
				//p=parent.localToGlobal(p);
				//p=contenido.globalToLocal(p);
				p=ob.localToGlobal(p);
				//ev.localX=p.x;
				//ev.localY=p.y;
				nev=new MouseEvent(ev.type,ev.bubbles,ev.cancelable,p.x,p.y,ob,ev.ctrlKey,ev.altKey,ev.shiftKey,ev.buttonDown,ev.delta);
				ob.dispatchEvent(nev);
				trace(">> "+ev.type+": "+ev.stageX+","+ev.stageY+" ("+ev.localX+","+ev.localY+")->"+ob.name);
				break; // solo al de primer plano
			}
			if (ob==null) {//llegamos al stage
				trace(">> stage");
				stage.dispatchEvent(ev);
			}
		}
		
		public function shopper(e:CoolwayEvent) {
			trace("WEB:SHOPPER");
			menu.callShopper(e);
		}
		
	}
	
}
