package  {
	
	import flash.events.Event;
	
	public class CoolwayEvent extends Event {

		public static const BACK="coolwayevent.back";
		public static const NEXT="coolwayevent.next";
		public static const HOME="coolwayevent.home";
		public static const SHOPPER="coolwayevent.shopper";
		
		public var url:String=null;
		public var id:String=null;
		
		public function CoolwayEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			// constructor code
			super(type,bubbles,cancelable);
		}

	}
	
}
