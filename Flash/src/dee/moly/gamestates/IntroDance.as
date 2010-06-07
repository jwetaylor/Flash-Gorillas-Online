﻿package dee.moly.gamestates {
	
	import dee.moly.gameobjects.CharChain;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import dee.moly.gameobjects.Gorilla
	import flash.media.Sound;
	
	/**
	 * a short intro with the gorillas dancing
	 * @author moly
	 */
	
	public class IntroDance extends GameState{
		
		// dance music
		[Embed(source="/dee/moly/sounds/danceMusic.mp3")] private static const DanceMusic:Class;
		private static const danceMusic:Sound = new DanceMusic();
		
		// the game settings to pass to the level
		private var gameSettings:GameSettings;
		
		// two gorillas
		private var gorilla1:Gorilla;
		private var gorilla2:Gorilla;
		
		// text
		private static const titleText:CharChain = new CharChain("F L A S H   G O R I L L A S", 218, 16);
		private static const starringText:CharChain = new CharChain("STARRING:", 290, 55);
		private var namesText:CharChain;
		
		// dance timer
		private var danceTimer:Timer;
		
		// interval for first stage of the dance
		private static const INTERVAL_1:int = 3000;
		
		// interval for second stage of the dance
		private static const INTERVAL_2:int = 300;
		
		public function IntroDance(gameSettings:GameSettings) {
			
			this.gameSettings = gameSettings;
			
			namesText = new CharChain(gameSettings.player1Name + " AND " + gameSettings.player2Name, 0, 114);
			namesText.centre();
			
			gorilla1 = new Gorilla();
			gorilla1.x = 269;
			gorilla1.y = 199;
			gorilla1.raiseRightArm();
			
			gorilla2 = new Gorilla();
			gorilla2.x = 329;
			gorilla2.y = 199;
			gorilla2.raiseLeftArm();
			
			danceTimer = new Timer(INTERVAL_1, 0);
			danceTimer.addEventListener(TimerEvent.TIMER, dance);
			danceTimer.start();
			
			danceMusic.play();
		}
		
		// change which arm the gorillas have raised to make them dance
		private function dance(e:TimerEvent):void {
			
			gorilla1.swapArms();
			gorilla2.swapArms();
			
			if (danceTimer.currentCount == 4)
				danceTimer.delay = INTERVAL_2;
				
			if (danceTimer.currentCount == 11) {
				danceTimer.stop();
				danceTimer.removeEventListener(TimerEvent.TIMER, dance);
				gotoState(new Level(gameSettings));
			}
			
		}
		
		override public function draw(canvas:BitmapData):void {
			
			canvas.fillRect(canvas.rect, 0xFF0000AD);
			
			titleText.draw(canvas);
			starringText.draw(canvas);
			namesText.draw(canvas);
			
			gorilla1.draw(canvas);
			gorilla2.draw(canvas);
			
		}
		
	}

}