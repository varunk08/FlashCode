package  
{
	
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
	/**
	 * ...
	 * @author DWiz
	 */
public class AccessNativeStuff extends Sprite
{
		
	public function AccessNativeStuff() 
	{

		// create the three sprites and their listeners
		var callButton:Sprite = createSprite(0xFF3300, 140, 150);
		callButton.addEventListener(MouseEvent.CLICK, callMe);
		addChild(callButton);
		var textButton:Sprite = createSprite(0x0099FF, 140, 350);
		textButton.addEventListener(MouseEvent.CLICK, textMe);
		addChild(textButton);
		var mailButton:Sprite = createSprite(0x00FF11, 140, 550);
		mailButton.addEventListener(MouseEvent.CLICK, mailMe);
		addChild(mailButton);
	}
	function createSprite(hue:int, xPos:int, yPos:int):Sprite 
	{
		var temp:Sprite = new Sprite();
		temp.graphics.beginFill(hue, 1);
		temp.graphics.drawRect(0, 0, 200, 100);
		temp.graphics.endFill();
		temp.x = xPos;
		temp.y = yPos;
		return temp;
	}
	function callMe(event:MouseEvent):void 
	{
		trace("calling");
		navigateToURL(new URLRequest('tel:18005551212'));
	}
	function textMe(event:MouseEvent):void 
	{
		trace("texting");
		navigateToURL(new URLRequest('sms:18005551212'));
	}
	function mailMe(event:MouseEvent):void 
	{
		trace("emailing");
		navigateToURL(new URLRequest('mailto:veronique@somewhere.com?subject=Hello&body=World'));
	}
}
}

