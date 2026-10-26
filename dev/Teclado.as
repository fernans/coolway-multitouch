package  {
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import org.tuio.TouchEvent;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	
	public class Teclado extends MovieClip {
		
		public var activeName:Boolean=true;
		public var nombre:String="";
		public var email:String="";
		
		public function Teclado() {
			// constructor code
			//addEventListener(KeyboardEvent.KEY_DOWN,tecla);
			addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		public function init(e:Event) {
			removeEventListener(Event.ADDED_TO_STAGE,init);
			txtNombre.addEventListener(TouchEvent.TOUCH_DOWN, pulsarNombre);
			txtMail.addEventListener(TouchEvent.TOUCH_DOWN, pulsarMail);
		}
		
		public function pulsarNombre(e:Event) {
			activeName=true;
			gotoAndStop("frameName");
		}
		
		public function pulsarMail(e:Event) {
			activeName=false;
			gotoAndStop("frameMail");
		}
		
		public function tecla(t:String) {
			switch(t) {
				case "arroba":
					t="@";
					break;
				case "guion":
					t="-";
					break;
				case "underline":
					t="_";
					break;
				case "punto":
					t=".";
					break;
				case "espacio":
					t=" ";
					break;
				case "borrar":
					if (activeName) txtNombre.text=txtNombre.text.substr(0,txtNombre.text.length-1);
					else txtMail.text=txtMail.text.substr(0,txtMail.text.length-1);
					t=null;
					break;
				case "intro":
					if (activeName) {
						activeName=false;
						gotoAndStop("frameMail");
					} else comprobar();
					t=null;
					return;
					break;
				default:
					break;
			}
			if (t!=null) {
				if (activeName) {
					txtNombre.appendText(t);
				} else {
					txtMail.appendText(t);
				}
			}
			if (parent is Juego) (parent as Juego).activity();
			if (parent.parent is PS) (parent.parent as PS).activity();
		}
		
		public function comprobar() {
			trace("comprobar");
			if (txtNombre.text=="") {
				activeName=true;
				gotoAndStop("frameName");
				noName.play();
			} else if (txtMail.text=="" || !IsEmail(txtMail.text)) {
				gotoAndStop("frameMail");
				noMail.play();
			} else {
				nombre=txtNombre.text;
				email=txtMail.text;
				trace("valido");
				if (parent is Juego) (parent as Juego).enviar();
				else if (parent.parent is PS) (parent.parent as PS).enviar();
			}
		}

		public function IsEmail(sEmail:String):Boolean {
				//Dim Expression As New System.Text.RegularExpressions.Regex("\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*")
				//Return Expression.IsMatch(sEmail)
				var e:RegExp= new RegExp("\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*","i");
				return e.test(sEmail);
		}
	}
	
}
