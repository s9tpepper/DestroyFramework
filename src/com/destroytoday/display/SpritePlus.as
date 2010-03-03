package com.destroytoday.display {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class SpritePlus extends Sprite {
		public var measureChildren:Boolean = true;
		
		public const sizeChanged:Signal = new Signal(SpritePlus, Number, Number);
		
		protected var _children:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		
		protected var _width:Number = 0.0;
		
		protected var _height:Number = 0.0;
		
		protected var _left:Number;
		
		protected var _right:Number;
		
		protected var _top:Number;
		
		protected var _bottom:Number;
		
		protected var _center:Number;
		
		protected var _middle:Number;
		
		protected var _marginLeft:Number = 0.0;
		
		protected var _marginRight:Number = 0.0;
		
		protected var _marginTop:Number = 0.0;
		
		protected var _marginBottom:Number = 0.0;
		
		protected var invalidateFlag:Boolean;
		
		protected var invalidatePropertiesFlag:Boolean;
		
		protected var invalidateDisplayListFlag:Boolean;
		
		protected var sizeChangedFlag:Boolean;
		
		public function SpritePlus() {
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		public function get children():Vector.<DisplayObject> {
			return _children;
		}
		
		override public function get width():Number {
			return (measureChildren) ? super.width : _width;
		}
		
		override public function set width(value:Number):void {
			if (measureChildren && value == super.width || !measureChildren && value == _width) {
				return;
			}
			
			if (measureChildren) {
				super.width = value;
			} else {
				_width = value;
			}
			
			sizeChangedFlag = true;
			
			invalidateDisplayList();
		}
		
		override public function get height():Number {
			return (measureChildren) ? super.height : _height;
		}
		
		override public function set height(value:Number):void {
			if (measureChildren && value == super.height || !measureChildren && value == _height) {
				return;
			}
			
			if (measureChildren) {
				super.height = value;
			} else {
				_height = value;
			}
			
			sizeChangedFlag = true;
			
			invalidateDisplayList();
		}
		
		public function get left():Number {
			return _left;
		}
		
		public function set left(value:Number):void {
			_left = value;
			
			invalidateDisplayList();
		}
		
		public function get right():Number {
			return _right;
		}
		
		public function set right(value:Number):void {
			_right = value;
			
			invalidateDisplayList();
		}
		
		public function get top():Number {
			return _top;
		}
		
		public function set top(value:Number):void {
			_top = value;
			
			invalidateDisplayList();
		}
		
		public function get bottom():Number {
			return _bottom;
		}
		
		public function set bottom(value:Number):void {
			_bottom = value;
			
			invalidateDisplayList();
		}
		
		public function get center():Number {
			return _center;
		}
		
		public function set center(value:Number):void {
			_center = value;
			
			invalidateDisplayList();
		}
		
		public function get middle():Number {
			return _middle;
		}
		
		public function set middle(value:Number):void {
			_middle = value;
			
			invalidateDisplayList();
		}
		
		public function get marginLeft():Number {
			return _marginLeft;
		}
		
		public function set marginLeft(value:Number):void {
			_marginLeft = value;
		}
		
		public function get marginRight():Number {
			return _marginRight;
		}
		
		public function set marginRight(value:Number):void {
			_marginRight = value;
		}
		
		public function get marginTop():Number {
			return _marginTop;
		}
		
		public function set marginTop(value:Number):void {
			_marginTop = value;
		}
		
		public function get marginBottom():Number {
			return _marginBottom;
		}
		
		public function set marginBottom(value:Number):void {
			_marginBottom = value;
		}
		
		public function invalidateDisplayList():void {
			if (stage && !invalidateFlag) {
				invalidateFlag = true;
				
				stage.invalidate();
				addEventListener(Event.RENDER, invalidateHandler);
			}
			
			invalidateDisplayListFlag = true;
		}
		
		public function invalidateProperties():void {
			if (stage && !invalidateFlag) {
				invalidateFlag = true;
				
				stage.invalidate();
				addEventListener(Event.RENDER, invalidateHandler);
			}
			
			invalidatePropertiesFlag = true;
		}
		
		public function setBounds(left:Number, top:Number, right:Number = NaN, bottom:Number = NaN, center:Number = NaN, middle:Number = NaN):void {
			_left = left;
			_top = top;
			_right = right;
			_bottom = bottom;
			_center = center;
			_middle = middle;
			
			invalidateDisplayList();
		}
		
		public function setMargin(left:Number, top:Number, right:Number = NaN, bottom:Number = NaN):void {
			_marginLeft = left;
			_marginTop = top;
			_marginRight = right;
			_marginBottom = bottom;
			
			//TODO - update parent if it's a Group with alignment
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			_children[_children.length] = child;
			
			child = super.addChild(child);
			
			invalidateDisplayList();
			
			return child;
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			var j:uint;
			
			for (var i:int = _children.length - 1; i > index - 1; --i) {
				j = i + 1;
				
				_children[j] = _children[i];
			}
			
			_children[index] = child;
			
			child = super.addChildAt(child, index);
			
			invalidateDisplayList();
			
			return child;
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject {
			_children.splice(_children.indexOf(child), 1);
			
			child = super.removeChild(child);
			
			invalidateDisplayList();
			
			return child;
		}
		
		override public function removeChildAt(index:int):DisplayObject {
			_children.splice(index, 1);
			
			var child:DisplayObject = super.removeChildAt(index);
			
			invalidateDisplayList();
			
			return child;
		}
		
		override public function setChildIndex(child:DisplayObject, index:int):void {
			var j:uint;
			
			_children.splice(_children.indexOf(child), 1);
			
			for (var i:int = _children.length - 1; i > index - 1; --i) {
				j = i + 1;
				
				_children[j] = _children[i];
			}
			
			_children[index] = child;
			
			super.setChildIndex(child, index);
			
			invalidateDisplayList();
		}
		
		public function commitProperties():void {
			
		}
		
		public function updateDisplayList():void {
			updateListeners();
			updateBounds();
			updateChildren();
			
			if (sizeChangedFlag) {
				sizeChangedFlag = false;
				
				sizeChanged.dispatch(this, width, height);
			}
		}
		
		public function updateChildren():void {
			// overriden by Group
		}
		
		public function updateBounds():void {
			if (!parent) return;
			
			var parentWidth:Number, parentHeight:Number;
			
			if (parent is Stage) {
				parentWidth = stage.stageWidth;
				parentHeight = stage.stageHeight;
			} else {
				parentWidth = parent.width;
				parentHeight = parent.height;
			}
			
			// width
			if ((_left < 0 || _left >= 0) && (_right < 0 || _right >= 0)) {
				width = parentWidth - (_left + _right);
			}
			
			// height
			if ((_top < 0 || _top >= 0) && (_bottom < 0 || _bottom >= 0)) {
				height = parentHeight - (_top + _bottom);
			}
			
			// x
			if (_left < 0 || _left >= 0) {
				x = _left;
			} else if (_right < 0 || _right >= 0) {
				x = parentWidth - (width + _right);
			} else if (_center < 0 || _center >= 0) {
				x = (parentWidth - width) * 0.5 + _center;
			}
			
			// y
			if (_top < 0 || _top >= 0) {
				y = _top;
			} else if (_bottom < 0 || _bottom >= 0) {
				y = parentHeight - (height + _bottom);
			} else if (_middle < 0 || _middle >= 0) {
				y = (parentHeight - height) * 0.5 + _middle;
			}
		}
		
		protected function updateListeners():void {
			if (parent && (_right < 0 || _right >= 0 || _bottom < 0 || _bottom >= 0 || _center < 0 || _center >= 0 || _middle < 0 || _middle >= 0)) {
				if (parent is SpritePlus) {
					(parent as SpritePlus).sizeChanged.add(parentResizeHandler);
				} else if (parent is Stage) {
					stage.addEventListener(Event.RESIZE, stageParentResizeHandler, false, 0, true);
				}
			} else if (parent && parent is SpritePlus) {
				(parent as SpritePlus).sizeChanged.remove(parentResizeHandler);
			}
		}
		
		protected function addedToStageHandler(event:Event):void {
			invalidateDisplayList();
		}
		
		protected function removedFromStageHandler(event:Event):void {
			updateListeners();
		}
		
		protected function parentResizeHandler(width:Number, height:Number):void {
			invalidateDisplayList();
		}
		
		protected function stageParentResizeHandler(event:Event):void {
			invalidateDisplayList();
		}
		
		protected function invalidateHandler(event:Event):void {
			removeEventListener(Event.RENDER, invalidateHandler);
			
			if (invalidatePropertiesFlag) {
				invalidatePropertiesFlag = false;
				
				commitProperties();
			}
			
			if (invalidateDisplayListFlag) {
				invalidateDisplayListFlag = false;
				
				updateDisplayList();
			}
			
			invalidateFlag = false;
		}
	}
}