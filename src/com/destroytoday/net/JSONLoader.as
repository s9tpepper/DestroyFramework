package com.destroytoday.net
{
	import ab.fl.utils.json.JSON;
	
	import org.osflash.signals.Signal;

	public class JSONLoader extends StringLoader
	{
		private var _data:JSON;
		
		public function JSONLoader()
		{
		}


		public function get json():JSON
		{
			return _data;
		}

		override protected function instantiateSignals():void 
		{
			_openSignal					= new Signal(JSONLoader);
			_completeSignal				= new Signal(JSONLoader, JSON);
			_errorSignal				= new Signal(JSONLoader, String, String);
		}
		
		override protected function parseData(data:*):Boolean 
		{
			var success:Boolean;
			
			try 
			{
				_data = new JSON(data);
				
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