package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	public class SimpleBoton extends MovieClip {
		
		
		public function SimpleBoton() {
			// constructor code
			addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		public function init(e:Event) {
			addEventListener(MouseEvent.MOUSE_DOWN, down);
			addEventListener(MouseEvent.MOUSE_UP, up);
			addEventListener(MouseEvent.CLICK, mclick);
		}
		
		public function down(e:MouseEvent) {
			trace("boton down: "+e.stageX+","+e.stageY+" ("+e.localX+","+e.localY+")->"+e.target.name);
			gotoAndStop(2);
		}
		
		public function up(e:MouseEvent) {
			trace("boton up   : "+e.stageX+","+e.stageY+" ("+e.localX+","+e.localY+")->"+e.target.name);
			gotoAndStop(1);
		}
		
		public function mclick(e:MouseEvent) {
			trace("boton click: "+e.stageX+","+e.stageY+" ("+e.localX+","+e.localY+")->"+e.target.name);
			gotoAndPlay(3);
		}
		
	}
	
}
