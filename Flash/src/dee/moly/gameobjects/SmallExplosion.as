package dee.moly.gameobjects {
	
	import dee.moly.textures.DrawingBitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.media.Sound;
	
	/**
	 * The explosion when a banana hits a building
	 * @author moly
	 */
	
	public class SmallExplosion extends GameObject{
		
		[Embed(source="/dee/moly/sounds/buildingExplosion.mp3")] private static const ExplosionSound:Class;
		private static const explosionSound:Sound = new ExplosionSound();
		
		private var currentRadius:Number;
		
		// whether the explosion is currently exploding outwards or inwards
		private var stage:int;
		
		public function get finished():Boolean {
			return stage == FINISHED;
		}
		
		private static const STAGE_1:int = 0;
		private static const STAGE_2:int = 1;
		private static const FINISHED:int = 3;
		
		private static const MAX_RADIUS:int = Main.SCREEN_HEIGHT / 50;
		private static const EXPLOSION_COLOUR:uint = 0xFFFC0054;
		
		public function SmallExplosion() {
			stage = FINISHED;
			currentRadius = -1;
		}
		
		// start a new explosion
		public function create(x:int, y:int):void {
			
			position = new Point(x, y);
			stage = STAGE_1;
			currentRadius = 0;
			explosionSound.play();
			
		}
		
		override public function draw(canvas:BitmapData):void {
			
			if (finished) return;
			
			if (stage == STAGE_1){
				currentRadius += 0.5;
				if (currentRadius >= MAX_RADIUS)
					stage = STAGE_2;
			}else if (stage == STAGE_2){
				currentRadius -= 0.5;
				if (currentRadius <= 0)
					stage = FINISHED;
			}
			
			DrawingBitmap(canvas).circle(position.x, position.y, currentRadius, stage == STAGE_1 ? EXPLOSION_COLOUR : 0x00);
		}
		
	}

}