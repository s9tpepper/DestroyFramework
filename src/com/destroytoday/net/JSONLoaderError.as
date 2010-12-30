package com.destroytoday.net {
	/**
	 * The JSONLoaderError class houses error constants for the JSONLoader class.
	 * @author Omar Gonzalez
	 */	
	public class JSONLoaderError {
		/**
		 * Dispatched when the JSON is malformed. 
		 */		
		public static const DATA_PARSE:String = "JSONLoaderError.DATA_PARSE";
		
		/**
		 * @private
		 */		
		public function JSONLoaderError() {
			throw Error("The JSONLoaderError class cannot be instantiated.");
		}
	}
}