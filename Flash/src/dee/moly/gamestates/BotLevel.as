package dee.moly.gamestates {
	
	import dee.moly.gameobjects.Banana;
	import dee.moly.gameobjects.CharChain;
	import dee.moly.gameobjects.BotCityscape;
	import dee.moly.gameobjects.Gorilla;
	import dee.moly.ai.ProjectileEstimator;
	import dee.moly.textures.DrawingBitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import dee.moly.gameobjects.Sun;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import playerio.Client;
	
	/**
	 * the main level with the gorillas and the buildings and such
	 * @author moly
	 */
	
	public class BotLevel extends GameState{
		
		// the cityscape in the background
		private var cityScape:BotCityscape;
		
		// two gorillas
		private var gorilla1:Gorilla;
		private var gorilla2:Gorilla;
		
		// names
		private var player1NameText:CharChain;
		private var player2NameText:CharChain;
		
		// score
		private var player1Score:int;
		private var player2Score:int;
		private var scoreText:CharChain;
		
		// angle/velocity prompts
		private var angleText:CharChain;
		private var angleInput:CharChain;
		private var velocityText:CharChain;
		private var velocityInput:CharChain;
		private var angle:Number;
		private var velocity:Point;
		
		// the input to add to
		private var currentInput:CharChain;
		
		// which players turn it is
		private var playerTurn:int;
		
		// the projectile
		private var banana:Banana;
		
		// a smiley sun
		private var sun:Sun;

		private var state:int;
		
		// state constants
		private static const ANGLE_INPUT:int = 5;
		private static const VELOCITY_INPUT:int = 6;
		private static const BANANA_THROWN:int = 0;
		private static const GORILLA1_HIT:int = 1;
		private static const GORILLA2_HIT:int = 2;
		private static const BUILDING_HIT:int = 3;
		
		// AI for one player games
		private var projectileEstimator:ProjectileEstimator;
		
		private var client:Client;
		
		private var kongregate:*;
		
		public function BotLevel(client:Client, kongregate:*, player1Name:String, player1Hat:int, player1Shirt:int, player1Trousers:int) {
			
			this.client = client;
			this.kongregate = kongregate;
			
			gorilla1 = new Gorilla();
			gorilla1.setClothes(player1Hat, player1Shirt, player1Trousers);
			gorilla2 = new Gorilla();
			
			projectileEstimator = new ProjectileEstimator(9.8);
			
			player1NameText = new CharChain(player1Name, 0, 3);
			player2NameText = new CharChain("Bot", Main.SCREEN_WIDTH - ("Bot".length * 8) - 8, 3);
			
			player1Score = 0;
			player2Score = 0;
			
			scoreText = new CharChain("0>Score<0", 0, Main.SCREEN_HEIGHT - 38);
			scoreText.centre();
			
			angleText = new CharChain("Angle:", 0, 18);
			angleInput = new CharChain("", 0, 18, CharChain.SOLID, CharChain.NUMERIC);
			
			velocityText = new CharChain("Velocity:", 0, 33);
			velocityInput = new CharChain("", 0, 33, CharChain.SOLID, CharChain.NUMERIC);
			
			sun = new Sun();
			
			banana = new Banana();
			
			cityScape = new BotCityscape();
			
			playerTurn = 1;
			
			newGame();
			
		}
		
		// reset everything, build a new skyline etc
		private function newGame():void {
			
			cityScape.buildSkyline();
			cityScape.placeGorillas(gorilla1, gorilla2);
			
			angleInput.text = "";
			angleInput.showCursor();
			velocityInput.text = "";
			currentInput = angleInput;
			currentInput.x = (520 * (playerTurn - 1)) + 58;
			angleText.x = 520 * (playerTurn - 1);
			velocityText.x = 520 * (playerTurn - 1);
			
			scoreText.text = player1Score + ">Score<" + player2Score;
			
			sun.reset();
			
			projectileEstimator.reset();
			if (playerTurn == 2) {
				var t:Timer = new Timer(1000, 1);
				t.addEventListener(TimerEvent.TIMER_COMPLETE, cpuTurn, false, 0, true);
				t.start();
			}
			
			
			state = ANGLE_INPUT;
			
		}
		
		// move the banana around
		override public function update(elapsed:Number):void {
			
			switch(state) {
				
				// if the banana is in the air
				case BANANA_THROWN:
				
					banana.update(elapsed);
			
					if (banana.hasCollidedWith(sun))
						sun.shock();
				
					if (banana.hasCollidedWith(cityScape)){
						cityScape.createSmallExplosion(banana.x, banana.y);
						state = BUILDING_HIT;
					}
				
					if (banana.hasCollidedWith(gorilla1)) {
						cityScape.createBigExplosion(gorilla1.x, gorilla1.y);
						player2Score++;
						state = GORILLA1_HIT;
					}
				
					if (banana.hasCollidedWith(gorilla2)) {
						cityScape.createBigExplosion(gorilla2.x, gorilla2.y);
						player1Score++;
						state = GORILLA2_HIT;
					}
					
					// check if banana has left the screen
					if (banana.x > Main.SCREEN_WIDTH || banana.x < 0 || banana.y > Main.SCREEN_HEIGHT){
						state = BUILDING_HIT;
						nextStep();
					}
					
					break;
					
				case BUILDING_HIT:
				
					cityScape.update(elapsed);
					
					if (cityScape.explosionFinished)
						nextStep();
						
					break;
					
				case GORILLA1_HIT:
					
					if (cityScape.explosionFinished){
						gorilla2.danceAnimation();
						if (gorilla2.finishedDancing)
							nextStep();
					}
						
					break;
					
				case GORILLA2_HIT:
				
					if (cityScape.explosionFinished){
						gorilla1.danceAnimation();
						if (gorilla1.finishedDancing)
							nextStep();
					}
					
					break;
					
			}
					
		}
		
		// draw everything to the screen
		override public function draw(canvas:BitmapData):void {
			
			canvas.fillRect(canvas.rect, 0xFF0000AD);
			
			player1NameText.draw(canvas);
			player2NameText.draw(canvas);
			
			gorilla1.draw(canvas);
			gorilla2.draw(canvas);
			
			cityScape.draw(canvas);
			
			canvas.fillRect(new Rectangle(scoreText.x - 3, scoreText.y - 2, (scoreText.length * 8) + 5, 14), 0xFF0000AD);
			scoreText.draw(canvas);
			
			if (state == ANGLE_INPUT || state == VELOCITY_INPUT) {
				
				angleText.draw(canvas);
				angleInput.draw(canvas);
				
				if (state == VELOCITY_INPUT) {
					velocityText.draw(canvas);
					velocityInput.draw(canvas);
				}
				
			} 
			
			if (state == BANANA_THROWN){
				banana.draw(canvas);
			}
			
			sun.draw(canvas);
			
		}
		
		// put the input into the right places
		override public function onKeyDown(e:KeyboardEvent):void {
			
			if (state == BANANA_THROWN || (playerTurn == 2))
				return;
			
			currentInput.addChar(e.charCode);
			
			if (e.keyCode == Keyboard.ENTER && currentInput.text != "")
				nextStep();
				
			if (e.keyCode == Keyboard.BACKSPACE)
				currentInput.backspace();
			
		}
		
		// move on to the next step of the level
		private function nextStep():void {
			
			switch (state) {
				
				// if an angle has just been entered, change the active input to velocity
				case ANGLE_INPUT:
					angleInput.removeCursor();
					currentInput = velocityInput;
					currentInput.x = (520 * (playerTurn - 1)) + 82;
					state = VELOCITY_INPUT;
					break;
			
				// if a velocity has just been entered, throw the banana
				case VELOCITY_INPUT:
				
					var angle:int = int(angleInput.text);
					var velocity:int = int(velocityInput.text);
					var bananaTex:int = 0;
					
					if (playerTurn == 1){
						var startPoint:Point = new Point(gorilla1.x, gorilla1.y - 7);
						gorilla1.throwAnimation();
						if (gorilla1.isAsh)
							bananaTex = 1;
						if (gorilla1.isZombie)
							bananaTex = 2;
					}
				
					if (playerTurn == 2){
						angle = 180 - angle;
						startPoint = new Point(gorilla2.x + 25, gorilla2.y - 7);
						gorilla2.throwAnimation();
						if (gorilla2.isAsh)
							bananaTex = 1;
						if (gorilla2.isZombie)
							bananaTex = 2;
					}
				
					banana.launch(angle, velocity, 9.8, cityScape.windSpeed, startPoint, bananaTex);
					
					state = BANANA_THROWN;
					
					break;
			
				case GORILLA1_HIT:					
				case GORILLA2_HIT:
					playerTurn = 3 - playerTurn;
					if (player1Score + player2Score >= 3)
						gotoState(new ScoreOverview(client, kongregate, true, 1, player1NameText.text, player2NameText.text, player1Score, player2Score));
					else
						newGame();
					break;
					
				case BUILDING_HIT:
				
					if (playerTurn == 2) {
						projectileEstimator.projectileLanded(gorilla1.x - banana.x, gorilla1.y - banana.y);
					}
				
					playerTurn = 3 - playerTurn;
					angleInput.text = "";
					angleInput.showCursor();
					velocityInput.text = "";
					currentInput = angleInput;
					currentInput.x = (520 * (playerTurn - 1)) + 58;
					angleText.x = 520 * (playerTurn - 1);
					velocityText.x = 520 * (playerTurn - 1);
					sun.reset();
					state = ANGLE_INPUT;
					
					if (playerTurn == 2) {
						var t:Timer = new Timer(1000, 1);
						t.addEventListener(TimerEvent.TIMER_COMPLETE, cpuTurn, false, 0, true);
						t.start();
					}
					
					break;
					
			}
						
		}
		
		// have the AI take a turn
		private function cpuTurn(e:TimerEvent):void {
			
			var t:Timer = new Timer(1000, 1);
			t.addEventListener(TimerEvent.TIMER_COMPLETE, cpuTurn, false, 0, true);
			
			switch(state) {
				
				case ANGLE_INPUT:
					if (currentInput.text == "")
						currentInput.text = String(projectileEstimator.getAngle());
					else
						nextStep();
					t.start();
					break;
					
				case VELOCITY_INPUT:
					if (currentInput.text == ""){
						currentInput.text = String(projectileEstimator.getVelocity());
						t.start();
					} else {
						nextStep();
					}
					break;
			}
			
		}
		
	}

}