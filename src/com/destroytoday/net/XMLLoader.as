package com.destroytoday.net {
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.System;
	
	import org.osflash.signals.Signal;
	
	/**
	 * The XMLLoader class improves upon the URLLoader class, including additional features, Signal support and XML parsing.
	 * @author Jonnie Hallman
	 */	
	public class XMLLoader extends GenericLoader {
		private var _data:XML;
		
		/**
		 * Instantiates the XMLLoader class.
		 */		
		public function XMLLoader():void {
		}
		
		public function get data():XML {
			return _data;
		}
		
		override protected function instantiateSignals():void {
			_openSignal = new Signal(XMLLoader);
			_completeSignal = new Signal(XMLLoader, XML);
			_errorSignal = new Signal(XMLLoader, String, String);
		}
		
		override protected function parseData(data:*):Boolean {
			var success:Boolean;
			
			try {
				_data = new XML(data);
				
				success = true;
			} catch (error:*) {
				_errorSignal.dispatch(this, XMLLoaderError.DATA_PARSE, null);
			}
			
			return success;
		}
		
		override protected function dispatchData():void {
			_completeSignal.dispatch(this, _data);
		}
		
		override protected function disposeData():void {
			if (_data) System.disposeXML(_data);
			
			_data = null;
		}
		
		
		
		
		override protected function initLoader():void
		{
			_loader = new URLLoader();
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
		
		override public function cancel():void
		{
			super.cancel();
			
//			var urlLoader:URLLoader = _loader as URLLoader;
//			if (urlLoader) urlLoader.close();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			var urlLoader:URLLoader = _loader as URLLoader;
			urlLoader.data = null;
		}
	}
}