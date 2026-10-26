package  {
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	//import org.tuio.TouchEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
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
			txtNombre.addEventListener(MouseEvent.MOUSE_DOWN, pulsarNombre);
			txtMail.addEventListener(MouseEvent.MOUSE_DOWN, pulsarMail);
		}
		
		public function pulsarNombre(e:Event) {
			activeName=true;
		}
		
		public function pulsarMail(e:Event) {
			activeName=false;
		}
		
		public function tecla(t:String) {
			switch(t) {
				case "arroba":
					t="@";
					break;
				case "guion":
					t="-";
					break;
				case "undeline":
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
					t="";
					break;
				case "intro":
					if (activeName) activeName=false;
					else comprobar();
					t="";
					return;
					break;
				default:
					break;
			}
			if (activeName) {
				txtNombre.appendText(t);
			} else {
				txtMail.appendText(t);
			}
			//if (parent is Juego) (parent as Juego).activity();
			//if (parent.parent is PS) 
			(parent.parent as PS).activity();
		}
		
		public function comprobar() {
			trace("comprobar");
			if (txtNombre.text=="") {
				activeName=true;
				noName.play();
			} else if (txtMail.text=="" || !IsEmail(txtMail.text)) {
				noMail.play();
			} else {
				nombre=txtNombre.text;
				email=txtMail.text;
				trace("valido");
				//if (parent is Juego) (parent as Juego).enviar();
				//else if (parent.parent is PS) 
				(parent.parent as PS).enviar();
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
