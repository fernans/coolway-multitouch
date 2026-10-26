package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;	
	
	public class Simple extends MovieClip {
		
		private var baseUrl:String="";
		
		public function Simple() {
			// constructor code
			addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		public function init(e:Event) {			
			baseUrl=loaderInfo.url.substring(0,loaderInfo.url.lastIndexOf("/")+1);
			trace("BASEURL="+baseUrl);
			
			fondo.addEventListener(MouseEvent.MOUSE_DOWN, down);
			fondo.addEventListener(MouseEvent.MOUSE_UP, up);
			fondo.addEventListener(MouseEvent.CLICK, mclick);
			
			//enlace a PS
			bPS.addEventListener(MouseEvent.MOUSE_DOWN, gotoPersonalShopper);
			// recibir navegacion
			addEventListener(CoolwayEvent.BACK, navegar);
			addEventListener(CoolwayEvent.NEXT, navegar);
			addEventListener(CoolwayEvent.HOME, navegar);
		}
		
		public function gotoPersonalShopper(e:Event) {
			trace("gotoPersonalShopper");
			var cwEv:CoolwayEvent=new CoolwayEvent(CoolwayEvent.SHOPPER);
			cwEv.url=null;
			dispatchEvent(cwEv);
		}
		
		public function navegar(e:CoolwayEvent) {
			trace("::: navegar ::: "+e.type);
		}
		
		public function down(e:MouseEvent) {
			trace("stage down");
		}
		
		public function up(e:MouseEvent) {
			trace("stage up");
		}
		
		public function mclick(e:MouseEvent) {
			trace("stage click:");
		}
		
	}
	
}
