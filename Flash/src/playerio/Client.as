﻿package playerio{	import flash.display.Stage;	/**	 * An instance of this class is returned to the callback function when successfully connecting to the PlayerIO webservice.	 * Contains references to all APIs currently exposed by the PlayerIO ActionScript API 	 * 	 * @see PlayerIO#connect PlayerIO.connect	 * 	 */		public interface Client{		function get connectUserId():String;		function get bigDB():BigDB;		/**		 * Collection used to access the Error log		 * @return An instance of ErrorLog		 * 		 */		function get errorLog():ErrorLog;		/**		 * Collection used for Multiplayer games		 * @return An instance of Multiplayer		 * 		 */		function get multiplayer():Multiplayer;		/**		 * Reference to the stage the Client is connected to		 * @return An instance of Stage		 * 		 */		function get stage():Stage;	}	}