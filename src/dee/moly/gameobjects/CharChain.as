﻿package dee.moly.gameobjects {
	
	import dee.moly.textures.ContentManager;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

	/**
	 * Contains the CharChain class code.  This class is the text input 
	 * controls used throughout the game that have the look and feel
	 * of DOS input lines. This class is a custom flash control created to further mimic the look
	 * and feel of the original Gorilla game.
	 * @author moly
     */
	
	public class CharChain extends GameObject{

		// CONSTANTS
		// Stop lock interval is the amount of time we lock out the text object before it accepts another character.
		// Set in milliseconds.
		private static const STOP_LOCK_INTERVAL:int = 75;
		
		// types of chain
		public static const ALPHANUMERIC:int = 0;
		public static const NUMERIC:int = 1;
		
		// Cursor state machine items
		private static const CURSOR_HIDE:Boolean  = false;
		private static const CURSOR_SHOW:Boolean = true;
		// cursors location on the font sheet
		private static const CURSOR_X:int = 240;
		private static const CURSOR_Y:int = 48;
		
		private static const TILE_WIDTH:int = 16;
		private static const TILE_HEIGHT:int = 16;
		
		private static const CHAR_WIDTH:int = 8;
		private static const CHAR_HEIGHT:int = 14;
		
		//Current state. The cursor is blinking by default.
		private var cursorState:Boolean;
		
		private var blinkTimer:Timer;
		
		//The string we are displaying
		private var string:String = "";
		//Is this chain read only? 
		private var locked:Boolean = false;
		
		//What is the maximum number of characters allowed in this string?  -1 for unlimited.
		private var maxStringLength:int = -1;
		//What input filter is set on this box?  0=everything, 1=numeric only
		private var filter:int;
		
		//What is the number of characters in this box?
		public function get length():int
		{
			return string.length;
		}
		
		//Set the maximum amout of characters for this box
		public function set maxLength(value:int):void
		{
			maxStringLength = value;
		}
		
		//Return the string representation of this text box
		public function get text():String {
			return string;
		}
		public function set text(value:String):void {
			string = value;
		}
		
		// font colour
		private var colour:ColorTransform;
		
		public function CharChain(text:String = "", x:int = 0, y:int = 0, showCursor:Boolean = false, type:int = 1, colour:uint = 0xFFFFFF, maxLength:int = -1) {
			
			texture = ContentManager.fontTex;
			this.colour = new ColorTransform(0, 0, 0, 1, colour >> 16 & 0xFF, colour >> 8 & 0xFF, colour & 0xFF);
			
			string = text;
			position = new Point(x, y);
			filter = type;
			maxStringLength = maxLength;
			
			if (showCursor == true) {
				blinkTimer = new Timer(700);
				blinkTimer.addEventListener(TimerEvent.TIMER, blinkCursor);
				blinkTimer.start();
			} else {
				cursorState = CURSOR_HIDE;
			}
				
		}
		
		// centre the chain horizontally
		public function centre():void {
			
			position.x = (Main.SCREEN_WIDTH / 2) - (string.length * CHAR_WIDTH / 2);
			
		}
		
		public function removeCursor():void {
			if (blinkTimer != null) {
				blinkTimer.removeEventListener(TimerEvent.TIMER, blinkCursor);
				blinkTimer.stop();
			}
			cursorState = CURSOR_HIDE;
		}
		
		//Show the blinking underscore cursor
		private function blinkCursor(e:TimerEvent):void {
			cursorState = !cursorState;					
		}

		//stops locking and cancels the set interval that called it
		private function stopLock(e:TimerEvent = null):void {
			locked = false;
		}
		
		//Add a character to the end of this string
		public function addChar(charCode:int):void {
					
			if(locked) return;
			
			// check some basic parameters.  If the ascii number is less than 32 or greater than 126 it's not a character
			// we support so exit
			if (charCode < 32 || charCode > 126) return;
			
			// if the max length has been reached already exit the function
			if (maxStringLength >= 0 && string.length >= maxStringLength) return;
			
			// if the filter has been set to numeric only and the ascii character is higher than 57,
			// lower than 48 or not the decimal (46) than it isnt a number and it violates the input filter.
			if (filter == 1) {
				if (charCode > 57) return;
				if (charCode < 48) if (charCode != 46) return;
			}
		
			// set the lock so we only can enter one character for a certain period of time.				
			locked = true;
			
			// we set the stopLock event to fire after 1 second.  That stops the input box from
			// getting hundreds of the same character if the user holds the keyboard button down 
			// for too long.		
			var lockTimer:Timer = new Timer(STOP_LOCK_INTERVAL, 1);
			lockTimer.addEventListener(TimerEvent.TIMER_COMPLETE, stopLock);
			lockTimer.start();
			
			string = string.concat(String.fromCharCode(charCode));
		}
		
		//This function removes the last character from the string
		public function backspace():void {
			//Check if this box even has any characters in it
			if(string.length > 0) {
				string = string.slice(0, string.length - 1);
			}
		}
		
		//draw the string from a spritesheet
		override public function draw(canvas:BitmapData):void {
			
			texture.colorTransform(texture.rect, colour);
			
			for (var i:int = 0; i < string.length; i++) {
				var code:int = string.charCodeAt(i) - 32;
				canvas.copyPixels(texture, new Rectangle(int(code % 16) * TILE_WIDTH + 4, int(code / 16) * TILE_HEIGHT + 2, CHAR_WIDTH, CHAR_HEIGHT), new Point(position.x + (i * CHAR_WIDTH), position.y));
			}
			if (cursorState == CURSOR_SHOW)
				canvas.copyPixels(texture, new Rectangle(CURSOR_X + 4, CURSOR_Y + 2, CHAR_WIDTH, CHAR_HEIGHT), new Point(position.x + (string.length * CHAR_WIDTH), position.y));
				
		}
	}
}
