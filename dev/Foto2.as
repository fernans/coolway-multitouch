package  {
	
	import flash.display.MovieClip;
	
	
	public class Foto2 extends Foto {
		
		
		public function Foto2(f:Fotos=null) {
			// constructor code
			ref=f;
		}
		
		override public function getRefFoto():MovieClip {
			return refFotoP;
		}
	}
	
}
