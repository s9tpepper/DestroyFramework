package com.destroytoday.net {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.System;
	import flash.utils.getQualifiedClassName;
	
	import org.osflash.signals.Signal;
	
	/**
	 * The GenericLoader class improves upon the URLLoader class, including additional features and Signal support.
	 * @author Jonnie Hallman
	 */	
	public class GenericLoader {
		/**
		 * Signal(target)
		 * @private 
		 */		
		protected var _openSignal:Signal;
		
		/**
		 * Signal(target, data)
		 * @private 
		 */		
		protected var _completeSignal:Signal;
		
		/**
		 * Signal(target, errorType, errorMessage)
		 * @private 
		 */		
		protected var _errorSignal:Signal;
		
		/**
		 * @private 
		 */		
		protected var _loader:EventDispatcher;
		
		/**
		 * @private 
		 */	
		protected var _request:URLRequest;
		
		/**
		 * @private 
		 */	
		private var _data:*;
		
		/**
		 * @private 
		 */	
		protected var _retryCount:uint;
		
		/**
		 * @private 
		 */	
		protected var _currentRetryCount:uint;
		
		/**
		 * @private 
		 */	
		protected var _includeResponseInfo:Boolean;
		
		/**
		 * @private 
		 */	
		protected var _responseStatus:int = -1;
		
		/**
		 * @private 
		 */	
		protected var _responseHeaders:Array;
		
		/**
		 * @private 
		 */		
		protected var loading:Boolean;
		
		public var storage:Object;

		/**
		 * Instantiates the StringLoader class.
		 */		
		public function GenericLoader():void
		{
			init();
		}
		
		protected function init():void
		{
			// instantiate instances
			initLoader();
			
			// add listeners
			_loader.addEventListener(Event.COMPLETE, completeHandler);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			
			instantiateSignals();
		}
		
		/**
		 * Starts the loader object. This method must be overridden and implemented to use the right loader object, URLLoader, Loader, URLStream, etc.
		 */
		protected function initLoader():void
		{
			//_loader = new EventDispatcher();
			// This method must be overridden and implemented to use the right loader object, URLLoader, Loader, URLStream, etc.
		}
		
		//
		// Signal getters
		//
		
		/**
		 * The Signal that dispatches when the load begins.
		 * @return 
		 */		
		public function get openSignal():Signal {
			return _openSignal;
		}
		
		/**
		 * The Signal that dispatches when the load is complete.
		 * @return 
		 */		
		public function get completeSignal():Signal {
			return _completeSignal;
		}
		
		/**
		 * The Signal that dispatches when an error occurs.
		 * @return 
		 */		
		public function get errorSignal():Signal {
			return _errorSignal;
		}
		
		//
		// Instance getters
		//
		
		/**
		 * The loader object used to perform the load, this method returns an
		 * EventDispatcher.  Each GenericLoader sub-class should implement its own
		 * getter, such as public function get stringLoader():StringLoader to 
		 * access it by strong type.
		 * 
		 * @return 
		 */		
		public function get loader():EventDispatcher {
			return _loader;
		}
		
		/**
		 * The URLRequest used to set the load parameters.
		 * @return 
		 */		
		public function get request():URLRequest {
			if (!_request) {
				_request = new URLRequest();
				
				// preset request with common values
				_request.manageCookies = false;
				_request.cacheResponse = false;
				_request.useCache = false;
				_request.authenticate = false;
			}
			
			return _request;
		}
		
		/**
		 * @private
		 * @param value
		 */		
		public function set request(value:URLRequest):void {
			if (loading) {
				// dispatch error
			}
			
			_request = value;
		}
		
		//
		// Property getters/setters
		//
		
		/**
		 * The number of times to retry a load before calling it quits.
		 * @return 
		 */		
		public function get retryCount():uint {
			return _retryCount;
		}
		
		/**
		 * @private
		 */		
		public function set retryCount(value:uint):void {
			_retryCount = value;
		}
		
		/**
		 * The current number of times the load has been retried.
		 * @return 
		 */		
		public function get currentRetryCount():uint {
			return _currentRetryCount;
		}
		
		/**
		 * Specifies whether to get the responseStatus and responseHeaders.
		 * @return 
		 */		
		public function get includeResponseInfo():Boolean {
			return _includeResponseInfo;
		}
		
		/**
		 * @private
		 */		
		public function set includeResponseInfo(value:Boolean):void {
			_includeResponseInfo = value;
			
			if (_includeResponseInfo) {
				_loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, responseStatusHandler);
			} else {
				_loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, responseStatusHandler);
			}
		}
		
		/**
		 * Returns the response status code if <code>includeResponseInfo</code> is true.
		 * @return 
		 */		
		public function get responseStatus():int {
			return _responseStatus;
		}
		
		/**
		 * Returns the response headers if <code>includeResponseInfo</code> is true.
		 * @return 
		 */		
		public function get responseHeaders():Array {
			return _responseHeaders;
		}
		
		//
		// Methods
		//
		
		/**
		 * @private
		 * Instantiates Signal instances.
		 * The instantiation isn't in the constructor because it must be overriden by subclasses, specifying the appropriate value classes.
		 */		
		protected function instantiateSignals():void {
			_openSignal = new Signal(GenericLoader);
			_completeSignal = new Signal(GenericLoader, String);
			_errorSignal = new Signal(GenericLoader, String, String);
		}
		
		/**
		 * @private
		 * Parses loaded data. Must be overriden by subclasses.
		 * @param data
		 * @return whether the data was parsed successfully
		 */		
		protected function parseData(data:*):Boolean {
			return false;
		}
		
		/**
		 * @private 
		 * Dispatches completeSignal. Must be overriden to maintain strong-typed data.
		 */		
		protected function dispatchData():void {
		}
		
		/**
		 * @private 
		 * Frees the data from memory. Must be overriden by subclasses
		 */		
		protected function disposeData():void {
		}
		
		/**
		 * Loads a URL.
		 * If a load is in progress, it is cancelled.
		 * @param url the URL to load
		 * @param parameters the parameters to send
		 * If <code>parameters</code> is not of class type URLVariables, its properties are set on an URLVariables instance.
		 */		
		public function load(url:String = null, parameters:Object = null):void {
			cancel();
			disposeData();
			
			_responseStatus = -1;
			_responseHeaders = null;
			if (url) request.url = url;
			
			if (parameters && !(parameters is URLVariables)) {
				var variables:URLVariables = new URLVariables ();
				
				for (var property:String in parameters) {
					variables[property] = parameters[property];
				}
				
				request.data = variables;
			} else if (parameters) {
				request.data = parameters;
			}
			
			loading = true;
			
			if (_currentRetryCount == 0) {
				_openSignal.dispatch(this);
			}
		}
		
		/**
		 * Cancels the load.
		 */		
		public function cancel():void {
			if (!loading) return;
			
			loading = false;
			
			_errorSignal.dispatch(this, GenericLoaderError.CANCEL, null);
		}
		
		/**
		 * Reverts the loader to its factory settings, as if it were just instantiated.
		 */		
		public function dispose():void {
			cancel();
			
			disposeData();
			_openSignal.removeAll();
			_completeSignal.removeAll();
			_errorSignal.removeAll();
			
			storage = null;
			_includeResponseInfo = false;
			_responseStatus = -1;
			_responseHeaders = null;
			_currentRetryCount = 0;
			_retryCount = 0;
			
			if (_request) {
				_request.method = URLRequestMethod.GET;
				_request.data = null;
				_request.url = null;
			}
		}
		
		/**
		 * @private
		 * @param event
		 */		
		protected function completeHandler(event:Event):void {
			// Implement in subclasses to handler complete event appropriately
		}
		
		protected function processData(rawData:Object):void
		{
			loading = false;
			
			if (parseData(rawData)) {
				dispatchData();
			} else {
				// retry if allowed
				if (_currentRetryCount++ < _retryCount) {
					load();
				} else if (_retryCount > 0) {
					_errorSignal.dispatch(this, GenericLoaderError.RETRY_COUNT, getQualifiedClassName(this) + " exceeded " + _retryCount + (_retryCount > 1 ? " tries" : " try"));
				}
			}
		}
		
		
		/**
		 * @private
		 * @param event
		 */		
		protected function errorHandler(event:*):void {
			loading = false;
			
			if (event is IOErrorEvent) {
				_errorSignal.dispatch(this, GenericLoaderError.IO, (event as IOErrorEvent).text);
			} else if (event is SecurityErrorEvent) {
				_errorSignal.dispatch(this, GenericLoaderError.SECURITY, (event as SecurityErrorEvent).text);
			}
			
			// retry if allowed
			if (_currentRetryCount++ < _retryCount) {
				load();
			} else if (_retryCount > 0) {
				_errorSignal.dispatch(this, GenericLoaderError.RETRY_COUNT, getQualifiedClassName(this) + " exceeded " + _retryCount + (_retryCount > 1 ? " tries" : " try"));
			}
		}

		/**
		 * @private
		 * @param event
		 */		
		protected function responseStatusHandler(event:HTTPStatusEvent):void {
			_responseStatus = event.status;
			_responseHeaders = event.responseHeaders;
		}
	}
}