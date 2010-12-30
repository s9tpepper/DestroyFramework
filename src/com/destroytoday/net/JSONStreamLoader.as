package com.destroytoday.net
{
	import ab.fl.utils.json.JSON;
	
	import flash.net.URLStream;
	
	import org.osflash.signals.Signal;

	public class JSONStreamLoader extends GenericStreamLoader
	{
		private var _data:JSON;
		
		public function JSONStreamLoader()
		{
			super();
		}


		public function get json():JSON
		{
			return _data;
		}

		override protected function instantiateSignals():void 
		{
			_openSignal					= new Signal(JSONStreamLoader);
			_completeSignal				= new Signal(JSONStreamLoader, JSON);
			_errorSignal				= new Signal(JSONStreamLoader, String, String);
		}
		
		override protected function parseData(data:*):Boolean 
		{
			// Call super to get JSON UTF string out of the URLStream 
//			super.parseData(data);
			
			var success:Boolean;
			// Check if the JSON string is valid
			try 
			{
				trace("JSONStreamLoader.parseData :: super.data = " + super.data);
				trace("JSONStreamLoader.parseData :: data = " + data);
				var urlStream:URLStream = data as URLStream;
				var loadedMsg:String = urlStream.readUTFBytes(urlStream.bytesAvailable);
				trace("JSONStreamLoader.parseData :: loadedMsg = " + loadedMsg);
				
				_data = new JSON(loadedMsg);
				
				success = true;
			} 
			catch (error:*)
			{
				_errorSignal.dispatch(this, JSONLoaderError.DATA_PARSE, null);
			}
			
			return success;
		}
		
		override protected function dispatchData():void
		{
			_completeSignal.dispatch(this, _data);
		}
		
		override protected function disposeData():void
		{
			_data = null;
		}
	}
}