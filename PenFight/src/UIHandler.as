package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	/**
	 * ...
	 * @author Dwiz
	 */
	public class UIHandler extends Sprite
	{
		static public const QUIT_GAME:String = "quitGame";
		static public const JOIN_HOST_SCREEN:String = "JoinOrHost";
		
		
		private var multiPlayInfoDis:InGameDisplay;
		public var opScreen:OpeningScreen;
		public var textfield:TextField;
		public var effectsArray:Array = new Array();
		public var dispInfo:InfoDisplay;
		public var gameOptions:InGameOptions;
		
		
		//buttons
		public var joinBtn:GfxButton;
		public var createBtn:GfxButton;
		public var createNewGameBtn:GfxButton;
		public var startGameBtn:GfxButton;
		
		
		
		public function UIHandler() 
		{	
			opScreen  = new OpeningScreen();
			addEventListener(Event.ENTER_FRAME, gfxUpdate);
		}
		
		private function gfxUpdate(e:Event):void 
		{
			if (effectsArray.length > 0)
			{
				var i:uint = 0;
				for each(var eff:Effect1 in effectsArray)
				{
					if (eff.currentFrame == 14)
					{
						eff.stop();
						removeChild(eff);
						eff = null;
						effectsArray.splice(i, 1);
						i--;
					}
					i++;
				}
				
			}
		}
		
		public function showNewgameLobby():void 
		{
			opScreen.gotoAndStop(25);
		}
		
		public function init():void 
		{
			addChild(opScreen);
			opScreen.x = 400;
			opScreen.y = 250;
		}
		
		public function singleOrMulti():void 
		{
			opScreen.gotoAndStop(15);
			opScreen.singleBtn.buttonMode = true;
			opScreen.multiBtn.buttonMode = true;
		}
		
		public function multiPlayerSelected():void 
		{
			//enter name text input
			trace("Multi selected");
			opScreen.gotoAndStop(5);
			opScreen.nameInput.nameInputText.setFocus();
			
		}
		
		public function joinOrHost():void 
		{
			opScreen.gotoAndStop(1);
			//opScreen.JoinGame.buttonMode = true;
			//opScreen.HostGame.buttonMode = true;
			
			joinBtn = new GfxButton(opScreen.op_joinGame);
			joinBtn.setBtnLabel("Join game");
			createBtn = new GfxButton(opScreen.op_createGame);
			createBtn.setBtnLabel("Create game");

		}
		
		private function mouseOutBtn(e:MouseEvent):void 
		{
			trace(e.target);
			e.target.useHandCursor = false;
			e.target.gotoAndStop(1);
		}
		
		private function mouseOverBtn(e:MouseEvent):void 
		{trace("Target: "+e.target);
			e.target.useHandCursor = true;
			e.target.gotoAndStop(2);
		}
		
		private function mouseCickOnBtn(e:MouseEvent):void 
		{
			e.target.gotoAndStop(3);
		}
		
		public function hostGameScreen():void 
		{
			opScreen.gotoAndStop(20);
			createNewGameBtn = new GfxButton(opScreen.createGrpBtn);
			createNewGameBtn.setBtnLabel("Create new game");
		}
		
		public function showAvailableGames(groupsList:Object):void 
		{
			opScreen.gotoAndStop(10);
			
				for each(var element:Object in groupsList)
				{
					
					opScreen.gamesList.theList.addItem({label:element.groupName,data:element.numPlayers});
					
				}
			
		}
		
		public function gameStarted(gameType:int):void 
		{
			removeChild(opScreen);
			opScreen = null;
			if (gameType != 3)
			{
				dispInfo = new InfoDisplay();
				dispInfo.x = 400;
				dispInfo.y = 25;
				addChild(dispInfo);
			}
			gameOptions = new InGameOptions();
			gameOptions.x = 50;
			gameOptions.y = 550;
			addChild(gameOptions);
			trace("options: " + getChildIndex(gameOptions));
			trace("options: " + gameOptions.x);
			trace("options: " + gameOptions.y);
		}
		
		public function showLobby():void 
		{
			opScreen.gotoAndStop(25);
			opScreen.chatSendtxt.addEventListener(FocusEvent.FOCUS_IN, clearInstruction);
			startGameBtn = new GfxButton(opScreen.startGamebtn);
			startGameBtn.setBtnLabel("Start game");
		}
		
		public function addPlayerToLobby(newPlayerName:String):void 
		{
			opScreen.playersJoinedList.addItem( { label:newPlayerName} );
		}
		
		//add READY to player names
		public function playerReady(playerName:String,self:Boolean = true):void 
		{
			if (self)
			{
				
				//opScreen.startGamebtn.enabled = false;
				startGameBtn.disableButton();
				
			}
		
			for (var i:uint = 0; i < opScreen.playersJoinedList.length; i++)
			{
				if (opScreen.playersJoinedList.getItemAt(i).label == playerName || opScreen.playersJoinedList.getItemAt(i).label == playerName + "--READY")
				{
					opScreen.playersJoinedList.removeItemAt(i);
				}
			}
			opScreen.playersJoinedList.addItem( { label:playerName +"--READY" } );
		}
		
		private function clearInstruction(e:FocusEvent):void 
		{
			opScreen.chatSendtxt.text = "";
		}
		public function createTextField():void
		{
			
			textfield = new TextField();
			textfield.x = 150;
			textfield.y = 400;
			textfield.height = 200;
			textfield.width = 500;
			textfield.textColor = 0x00cc88;
			textfield.border = true;
			textfield.borderColor = 0x888888;
			textfield.mouseWheelEnabled = true;
			textfield.type = TextFieldType.DYNAMIC;
			textfield.multiline = true;
			textfield.mouseEnabled = true;
			textfield.text = "Status...\n";
			addChild(textfield);
			textfield.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		private function onMouseWheel(e:MouseEvent):void 
		{
			if (e.delta < 0) textfield.scrollV++; 
			if (e.delta > 0) textfield.scrollV--; 
			//trace(textfield.scrollV);
		}
		
		public function status(text:String):void
		{
			
			//textfield.appendText(text + "\n");
		}
		
		public function connectingScreen():void 
		{
			opScreen.gotoAndStop(30);
		}
		
		public function playFallenEffect(effectPos:Object):void 
		{
			var effect:Effect1 = new Effect1();
			addChild(effect);
			effect.x = effectPos.x * PFGame.m_physScale;
			effect.y = effectPos.y * PFGame.m_physScale;
			effectsArray.push(effect);
		}
		
		public function playerDisconnectedAtLobby(userName:String):void 
		{
			for (var i:uint = 0; i < opScreen.playersJoinedList.length; i++)
			{
				if (opScreen.playersJoinedList.getItemAt(i).label == userName || opScreen.playersJoinedList.getItemAt(i).label == userName + "--READY")
				{
					opScreen.playersJoinedList.removeItemAt(i);
				}
			}
			//opScreen.playersJoinedList.addItem( { label:userName +"--DISCONNECTED" } );
			
		}
		
		public function displayMessage(userName:String, msg:String):void 
		{
			if (userName != "")
			{
				dispInfo.turnDisplaytxt.text = userName + "'s turn";
			}
			
			if (msg != "")
			{
				dispInfo.msgDisplaytxt.text = msg;
			}
		}
		
	}

}