package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Dwiz
	 */
	public class GfxButton extends Sprite 
	{	
		static public const CLICK:String = "click";
		private var myBtn:GfxBtn_wEffects;
		private var mouseDown:Boolean;
		public var btnX:int;
		public var btnY:int;
		
		public function GfxButton(btn:GfxBtn_wEffects):void 
		{
			trace("Hello"+stage+this.parent);
			
			
			//myBtn = new GfxBtn_wEffects();
			this.myBtn = btn;
			//addChild(myBtn);
			//setBtnLabel(label);
			myBtn.buttonMode = true;
			myBtn.gfxBtn.labelTXT.mouseEnabled = false;
			myBtn.gotoAndStop(1);
			
			
			//trace(myBtn.gfxBtn.labelTXT.width);
			//trace(myBtn.gfxBtn.btnCentre.width);
			
			myBtn.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			myBtn.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			myBtn.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			myBtn.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			//trace("Mouse Up");
			//mouseDown = false;
			//trace(mouseX, mouseY);
			if (myBtn.hitTestPoint(mouseX, mouseY))
			{
				trace("Hit");
				myBtn.gotoAndStop(2);
				var clickEvt:MouseEvent = new MouseEvent(MouseEvent.CLICK,true);
				dispatchEvent(clickEvt); 
			}
			
			else 
			{
				//removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				myBtn.gotoAndStop(1);
			}
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			myBtn.gotoAndStop(3);
			//mouseDown = true;
		}
		
		private function onMouseOut(e:MouseEvent):void 
		{	
			myBtn.gotoAndStop(1);
			
		}
		
		private function onMouseOver(e:MouseEvent):void 
		{
			myBtn.gotoAndStop(2);
			//trace("Mouse Over");
		}
		
		public function setBtnWidth(btn_width:uint):void 
		{
			var old_width:uint = myBtn.gfxBtn.btnCentre.width;
			var diff:int;
			if (old_width < btn_width) //increasing
			{
				diff = btn_width - old_width;
				myBtn.gfxBtn.btnSide_R.x += diff;
			}
			
			else {//decreasing
				diff = old_width - btn_width;
				myBtn.gfxBtn.btnSide_R.x -= diff;
			}
			
			//trace(diff);
			myBtn.gfxBtn.labelTXT.width = btn_width;
			myBtn.gfxBtn.btnCentre.width = btn_width;
			
			
		}
		
		public function setBtnLabel(label_txt:String):void 
		{
			myBtn.gfxBtn.labelTXT.text = label_txt;
			setBtnWidth(myBtn.gfxBtn.labelTXT.width);
			
		}
		
		public function disableButton():void
		{
			myBtn.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			myBtn.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			myBtn.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			myBtn.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			myBtn.buttonMode = false;
			myBtn.gotoAndStop(4);
		}
		
	
		
	}
	
}