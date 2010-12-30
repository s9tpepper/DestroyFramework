package com.destroytoday.net {
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.osflash.signals.Signal;
	
	/**
	 * The StringLoader class improves upon the URLLoader class, including additional features and Signal support.
	 * @author Jonnie Hallman
	 */	
	public class StringLoader extends GenericLoader {
		public function StringLoader() {
		}
		
		private var _data:String;
		
		public function get data():String {
			return _data;
		}
		
		override protected function initLoader():void
		{
			_loader = new URLLoader();
		}

		override protected function instantiateSignals():void {
			_openSignal = new Signal(StringLoader);
			_completeSignal = new Signal(StringLoader, String);
			_errorSignal = new Signal(StringLoader, String, String);
		}
		
		override protected function parseData(data:*):Boolean {
			_data = data;
			
			return true;
		}
		
		override protected function dispatchData():void {
			_completeSignal.dispatch(this, _data);
		}
		
		override protected function disposeData():void {
			_data = null;
		}
		
		override public function cancel():void
		{
			super.cancel();
			
			var urlLoader:URLLoader = _loader as URLLoader;
			urlLoader.close();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			var urlLoader:URLLoader = _loader as URLLoader;
			urlLoader.data = null;
		}
		
		override protected function completeHandler(event:Event):void
		{
			var urlLoader:URLLoader = _loader as URLLoader;
			processData(urlLoader.data);
		}
		
		override public function load(url:String=null, parameters:Object=null):void
		{
			super.load(url, parameters);
			
			var urlLoader:URLLoader = _loader as URLLoader;
			urlLoader.load(request);
		}
	}
}