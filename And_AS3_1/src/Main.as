package 
{
	import flash.desktop.NativeApplication;
	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.sensors.Accelerometer;
	import flash.system.Capabilities;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	/**
	 * ...
	 * @author DWiz
	 */
	[SWF(backgroundColor="0x000000")]
	public class Main extends Sprite 
	{
		private var accMeter:Accelerometer;
		private var box:Sprite;
		private var arrow:Arrow = new Arrow();
		
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			// entry point
			init();
		}
		
		private function init():void 
		{
			if (Capabilities.cpuArchitecture == "ARM")
			{
				trace("Phone is connected");
			}
			
			trace("DPI: " + Capabilities.screenDPI);
			var ScreenX:int  = Capabilities.screenResolutionX;
			var ScreenY:int  = Capabilities.screenResolutionY;
			
			box = new Sprite();
			box.graphics.lineStyle(3,0x880000);
			box.graphics.drawRect(0, 0, ScreenX, ScreenY);
			box.graphics.endFill();
			addChild(box);
			
			trace("Accelerometer: " + Accelerometer.isSupported);
			accMeter = new Accelerometer();
			accMeter.addEventListener(AccelerometerEvent.UPDATE, onAccUpdate);
			accMeter.setRequestedUpdateInterval(50);
			
			addChild(arrow);
			arrow.x = stage.stageWidth / 2;
			arrow.y = stage.stageHeight / 2;
		}
		
		private function onAccUpdate(e:AccelerometerEvent):void 
		{
			graphics.clear();
			//trace("X: "+e.accelerationX*10);
			//trace("Y: "+e.accelerationY*10);
			//trace("Z: " + e.accelerationZ);
			//trace("Time: " + e.timestamp);
			var accX:Number = e.accelerationX * 10;
			var accY:Number = e.accelerationY * 10;
			
			var radians:Number = Math.atan2(accY,-accX);
			arrow.rotation = radians * 180 / Math.PI;
			
		}
		
		private function deactivate(e:Event):void 
		{
			// auto-close
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}