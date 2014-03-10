package  
{
	import com.bit101.components.NumericStepper;
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import com.bit101.utils.MinimalConfigurator;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author DWiz
	 */
	public class CompExp extends Sprite
	{
		public var button:PushButton;
		public var numChooser:NumericStepper;
		public var config:MinimalConfigurator;
		public var txt:Text;
		public function CompExp() 
		{
			config = new MinimalConfigurator(this);
			txt = new Text(this, 100, 100, "This is a set of instructions. Follow this or perish");
			txt.editable = false;
			button = new PushButton(this, stage.stageWidth / 2, stage.stageHeight / 2 + 100, "Start Game",onClick);
			
			numChooser = new NumericStepper(this, stage.stageWidth / 2, stage.stageHeight / 2, onChoose);
			numChooser.maximum = 3;
			numChooser.minimum = 2;
		}
		
		private function onChoose(e:Event):void 
		{
			trace("Choose" + e);
		}
		
		private function onClick(e:MouseEvent):void 
		{
			trace("click");
		}
		
	}

}