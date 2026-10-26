package  {
	
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	
	public class Foto1 extends Foto {
		
		public function Foto1(f:Fotos=null) {
			// constructor code
			ref=f;
		}
		
		override public function getRefFoto():MovieClip {
			return refFotoP;
		}
	}
	
}
