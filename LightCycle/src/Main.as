package 
{
	import com.bit101.components.Label;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import com.bit101.components.TextArea;
	import fl.controls.Button;
	import flash.automation.MouseAutomationAction;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author DWiz
	 */
	[SWF (width="700",height="500",backgroundColor="0x000000")]
	public class Main extends Sprite 
	{
		private var openingScreen:Sprite;	
		private var game:GridGame;
		private var numPlayers:Number = 2;
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			if (stage) {
				//stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				init();
			}
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			
			openingScreen = new Sprite();
			addChild(openingScreen);
			getNumPlayer();
			
			
		}
		
		private function getNumPlayer():void 
		{
			var welcomeStr:String = new String( "      Welcome to VROOM \n The Flash LightCycle game");
			var title:Label = new Label(openingScreen, stage.stageWidth / 2 - 90, 50, welcomeStr);
			title.scaleX = title.scaleY = 1.5;
			var instStr:String = new String("Select the number of players.");
			var instText:Label = new Label(openingScreen, stage.stageWidth / 2 - 60, 140, instStr);
			var numStepper:NumericStepper = new NumericStepper(openingScreen, stage.stageWidth / 2 - 40, 170, function(e:Event):void {
				numPlayers = numStepper.value;
				if (e.target.value == 3)
				{
					
					keyTxt.text = keyDisp_3player;
				}
				else {
					keyTxt.text = keyDisp;
				}
			});
			numStepper.maximum = 3;
			numStepper.minimum = 2;
			var keyDisp_3player:String = new String("3 Player game:\nPlayer 1 is assigned the keys W,A,S,D\nPlayer 2 is assigned arrow keys LEFT,UP,RIGHT,DOWN\nPlayer 3 is assigned the keys I,J,K,L");
			var keyDisp:String = new String("2 Player game:\nPlayer 1 is assigned the keys W,A,S,D\nPlayer 2 is assigned arrow keys LEFT,UP,RIGHT,DOWN");
			var keyTxt:Label = new Label(openingScreen, stage.stageWidth / 2 - 60, 200, keyDisp);
			
			var startBtn:PushButton = new PushButton(openingScreen, stage.stageWidth / 2 - 50, 300, "Start Game", onStartGame);
			
			var creditStr:String = new String("\tCredits:\nCreated by DWiz\nConcept by Bril");
			var credits:Label = new Label(openingScreen, stage.stageWidth / 2 - 30, 400, creditStr);
			var kpStr:String = new String("http://www.minimalcomps.com/");
			var kpThanks:Label = new Label(openingScreen, stage.stageWidth / 2 - 50, 440, kpStr);
			kpThanks.buttonMode = true;
			kpThanks.useHandCursor = true;
			kpThanks.enabled = true;
			kpThanks.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
					navigateToURL(new URLRequest(kpStr));
			});
			
			
			
		}
		
		private function onStartGame(e:Event):void 
		{
			removeChild(openingScreen);
			openingScreen = null;
			stage.stageFocusRect = false;
			
			game = new GridGame(numPlayers);
			addChild(game);
			stage.focus = game;
			
		}
		
	
	}
	
}