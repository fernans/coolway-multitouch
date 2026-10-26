package  {
	
	import flash.display.MovieClip;
	
	
	public class Foto3 extends Foto {
		
		
		public function Foto3(f:Fotos=null) {
			// constructor code
			ref=f;
		}
		
		override public function getRefFoto():MovieClip {
			return refFotoP;
		}
	}
	
}
