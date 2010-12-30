package com.destroytoday.net
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLStream;
	import flash.utils.getQualifiedClassName;
	
	import org.osflash.signals.Signal;

	public class GenericStreamLoader extends GenericLoader
	{
		private var _data:String;
		
		public function GenericStreamLoader()
		{
			super();
		}
		
		public function get data():String {
			return _data;
		}
		
		override protected function instantiateSignals():void {
			_openSignal		= new Signal(GenericStreamLoader);
			_completeSignal = new Signal(GenericStreamLoader, String);
			_errorSignal	= new Signal(GenericStreamLoader, String, String);
		}
		
		override protected function parseData(data:*):Boolean {
			var success:Boolean;
			
			try {
				var urlStream:URLStream = data as URLStream;
				var loadedMsg:String = urlStream.readUTFBytes(urlStream.bytesAvailable);
				
				_data = data as String;
				
				success = true;
			} catch (error:*) {
				_errorSignal.dispatch(this, GenericLoaderError.INSUFFICIENT_UTF_BYTES_LOADED, getQualifiedClassName(this) + " does not have sufficient bytes loaded to read a UTF message.");
			}
			
			return success;
		}
		
		override protected function dispatchData():void {
			_completeSignal.dispatch(this, _data);
		}
		
		override protected function disposeData():void {
			_data = null;
		}
		
		
		override protected function initLoader():void
		{
			_loader = new URLStream();
			_loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
		}
		
		override protected function completeHandler(event:Event):void
		{
		}
		
		override public function load(url:String=null, parameters:Object=null):void
		{
			super.load(url, parameters);
			
			var urlStream:URLStream = _loader as URLStream;
			urlStream.load(request);
		}
		
		override public function cancel():void
		{
			super.cancel();
			
			var urlStream:URLStream = _loader as URLStream;
			if (urlStream.connected)
				urlStream.close();
		}
		
//		override public function dispose():void
//		{
//			super.dispose();
//		}
		
		/** 
		 * @private
		 * @param event
		 */		
		protected function progressHandler(event:ProgressEvent):void
		{
			try
			{
				var urlStream:URLStream = _loader as URLStream;
				
				if (urlStream.bytesAvailable)
				{
					if (parseData(urlStream))
					{
						dispatchData();
					}
					
				}
			}
			catch (e:Error)
			{
				_errorSignal.dispatch(this, GenericLoaderError.INSUFFICIENT_UTF_BYTES_LOADED, getQualifiedClassName(this) + " does not have sufficient bytes loaded to read a UTF message.");
			}
		}
	}
}