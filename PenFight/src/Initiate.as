package  
{
	import adobe.utils.CustomActions;
	import Box2D.Common.Math.b2Vec2;
	import fl.data.DataProvider;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Dwiz
	 */

	 [SWF (width = '800',height='600',backgroundColor='0x000000')]

	public class Initiate extends Sprite
	{
		static public const MULTIPLAYER_MAX_NUM:int = 4;
		static public const GAME_HOST:int = 1; //used for starting new game.
		static public const GAME_JOIN:int = 2;
		static public const WELCOME_STATE:String = "Welcome";
		static public const GAME_LOBBY:String = "InGameLobby";
		static public const GAME_STARTED:String = "GameStarted";
		static public const GAME_OVER:String = "GameOver";
		static public const TEST_TURN:Boolean = false;
		//private var opScreen:OpeningScreen; //opening graphics sprite
		private var game:PFGame; //the actual game - extends sprite
		private var netHandler:NetHandler = new NetHandler(); // handles amf
		private var myName:String; //new host name sent to sever
		private var groupsList:Object;
		private var uiHandler:UIHandler;
		private var i_gameState:String;
		private var playersHandler:PlayersHandler;
		private var playersObject:Object;
		private var myDraw:int;
		private var orderArray:Array;
	
		public function Initiate() 
		{
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			//this.scaleX = 0.85;
			//this.scaleY = 0.85;
			WelcomePlayers(); 
			
		}
		
		private function WelcomePlayers():void 
		{
			i_gameState = new String();
			i_gameState = WELCOME_STATE;
			uiHandler = new UIHandler();
			this.addChildAt(uiHandler,0);
			uiHandler.createTextField();
			netHandler.dispTextField = uiHandler.textfield;
			
			/**
			 * Going straight away to mp game
			 */
			uiHandler.init();
			multiPlayerSelected();
			playersHandler = new PlayersHandler();
		//	singleOrMulti();
			
		}
		
	/*	private function singleOrMulti():void 
		{
			uiHandler.singleOrMulti();
			uiHandler.opScreen.singleBtn.addEventListener(MouseEvent.CLICK, singlePlayerSelected);
			uiHandler.opScreen.multiBtn.addEventListener(MouseEvent.CLICK, multiPlayerSelected);
			
		}*/
		
		private function multiPlayerSelected():void 
		{
			//uiHandler.opScreen.multiBtn.removeEventListener(MouseEvent.CLICK, multiPlayerSelected);
			uiHandler.multiPlayerSelected();
			
			uiHandler.opScreen.nameInput.addEventListener(KeyboardEvent.KEY_DOWN, onNameEnter);
		}
		
	/*	private function singlePlayerSelected(e:MouseEvent):void 
		{
			uiHandler.opScreen.singleBtn.removeEventListener(MouseEvent.CLICK, singlePlayerSelected);
			startGame(3);
		}*/
		
		private function hostGame(e:MouseEvent):void 
		{
			//Remove UI button listeners
			//uiHandler.opScreen.JoinGame.removeEventListener(MouseEvent.CLICK, joinGame);
			//uiHandler.opScreen.HostGame.removeEventListener(MouseEvent.CLICK, hostGame);
			uiHandler.joinBtn.removeEventListener(MouseEvent.CLICK, joinGame);
			uiHandler.createBtn.removeEventListener(MouseEvent.CLICK, hostGame);
			
			//display proper UI screen
			uiHandler.hostGameScreen();
			
			//uiHandler.opScreen.createGrpBtn.addEventListener(MouseEvent.CLICK, createNewGroupBTN);
			uiHandler.createNewGameBtn.addEventListener(MouseEvent.CLICK, createNewGroupBTN);
			
			
			
			
		}
		
		private function createNewGroupBTN(e:MouseEvent):void 
		{
			//uiHandler.opScreen.createGrpBtn.removeEventListener(MouseEvent.CLICK, createNewGroupBTN);
			uiHandler.createNewGameBtn.removeEventListener(MouseEvent.CLICK, createNewGroupBTN);
			netHandler.evtDispatcher.addEventListener("NewGameCreated", newGameCreated);
			var groupName:String = uiHandler.opScreen.groupNametxt.text;
			netHandler.createNewGroup(groupName);
			uiHandler.showLobby();
			uiHandler.opScreen.playersJoinedList.addItem( { label:myName} );
			lobby();
		}
		
		private function newGameCreated(e:Event):void 
		{
			trace(e);
			uiHandler.showLobby();
		}
		
		private function onNameEnter(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				myName = uiHandler.opScreen.nameInput.nameInputText.text;
				if (myName != "")
				{
					uiHandler.opScreen.nameInput.removeEventListener(KeyboardEvent.KEY_DOWN, onNameEnter);
					uiHandler.connectingScreen();
					
					netHandler.getPeerID(myName);
					netHandler.evtDispatcher.addEventListener("DBNameRegistered", playerRegisteredSuccessfully);
					netHandler.evtDispatcher.addEventListener("ConnectionFailed", connectionFailed);
				}
			}
		}
		
		private function connectionFailed(e:Event):void 
		{
			//singleOrMulti();
			multiPlayerSelected();
			
		}
		
		private function playerRegisteredSuccessfully(e:Event):void 
		{
			uiHandler.joinOrHost();
			uiHandler.joinBtn.addEventListener(MouseEvent.CLICK, joinGame);
			//uiHandler.opScreen.JoinGame.addEventListener(MouseEvent.CLICK, joinGame);
			//uiHandler.opScreen.HostGame.addEventListener(MouseEvent.CLICK, hostGame);
			uiHandler.createBtn.addEventListener(MouseEvent.CLICK, hostGame);
		}
		
		private function joinGame(e:MouseEvent):void
		{
			//Remove UI button listeners
			//uiHandler.joinBtn.removeEventListener(MouseEvent.CLICK, joinGame);
			//uiHandler.opScreen.JoinGame.removeEventListener(MouseEvent.CLICK, joinGame);
			netHandler.evtDispatcher.addEventListener("GotGamesList", gotList);
			netHandler.joinGame();
			
			
		}
		
		private function gotList(e:Event):void 
		{
			this.groupsList = netHandler.groupsList;
			//trace(e);
			var num:int = 0;
			for each(var game:Object in groupsList)
			{
				num++;
			}
			if (num > 0)
			{
				uiHandler.createBtn.removeEventListener(MouseEvent.CLICK, hostGame);
				uiHandler.joinBtn.addEventListener(MouseEvent.CLICK, joinGame);
				//uiHandler.opScreen.HostGame.removeEventListener(MouseEvent.CLICK, hostGame);
				netHandler.evtDispatcher.removeEventListener("GotGamesList", gotList);
				displayGamesOnline();
			}
			
			
		}
		
		private function displayGamesOnline():void 
		{
			uiHandler.showAvailableGames(groupsList);
			
			uiHandler.opScreen.gamesList.theList.addEventListener(Event.CHANGE, gameSelect);
		}
		
		//goes to lobby of selected game
		private function gameSelect(e:Event):void 
		{
			uiHandler.opScreen.gamesList.theList.removeEventListener(Event.CHANGE, gameSelect);
			trace(e.target.selectedItem.label + ": " + e.target.selectedItem.data);
			var groupName:String = e.target.selectedItem.label;
			netHandler.joinGroupAtLobby(groupName); //triggers join event in the others
			
			uiHandler.showLobby();
			uiHandler.opScreen.playersJoinedList.addItem( { label:myName } );
			
			lobby();
		}
		
		//wait for more players to join --chat enabled.
		private function lobby():void
		{
			i_gameState = GAME_LOBBY;
			uiHandler.opScreen.chatSendtxt.addEventListener(KeyboardEvent.KEY_DOWN, chatEntered);
			netHandler.evtDispatcher.addEventListener("ChatEvent", receiveChatMessage);
			netHandler.evtDispatcher.addEventListener("JoinEvent", newPlayerJoins);
			netHandler.evtDispatcher.addEventListener(NetHandler.PLYR_DISCONNECTED, playerDisconnected);
			netHandler.evtDispatcher.addEventListener(NetHandler.GOT_WELCOME_STATE_MSG, gotWelcomeMsg);
			netHandler.evtDispatcher.addEventListener("PlayerReady", opponentReady);
			//uiHandler.opScreen.startGamebtn.addEventListener(MouseEvent.CLICK, myPlayerReady);
			uiHandler.startGameBtn.addEventListener(MouseEvent.CLICK, myPlayerReady);
			playersHandler.addEventListener(PlayersHandler.ALL_READY, allReadyStartGame);
			playersObject = new Object(); //start of gathering players --at lobby
			playersHandler.playersObj = playersObject; //passing reference only to playersHandler
			addPlayerToGame(playersHandler.createPFPlayer(myName,netHandler.myPeerID));//creating myself and adding to playersobj
		}
		
		
		
		private function opponentReady(e:Event):void 
		{
			var name:String = netHandler.opponentReady.user;
			
			//ui changes for other opponents/neighbors
			uiHandler.playerReady(name, false);
			
			//assigns rand num received to player desig of opponent
			playersHandler.playerReady(name, netHandler.opponentReady.randomNumber);
			
			//sets playerType and changes state to READY
			playersObject[name].playerReady(false);
			
			//uiHandler.status("OpponentPlayerNumber: " + playersObject[name].playerDesig);
			
			//check each time
			playersHandler.checkAllReady();
			
		}
		
		
		private function allReadyStartGame(e:Event):void 
		{
			//playerDraw entered and gamePlayer created
			playersHandler.decidePlayingOrder();
			
			startGame(1);
		}		
		
		//player has clicked start game button
		//--show 'READY' next to name
		//post it to all other players
		private function myPlayerReady(e:MouseEvent):void 
		{
			//ui changes for this client
			uiHandler.playerReady(myName);
			//uiHandler.opScreen.startGamebtn.removeEventListener(MouseEvent.CLICK, myPlayerReady);
			uiHandler.startGameBtn.removeEventListener(MouseEvent.CLICK, myPlayerReady);
			
			//changes pfplayer's state and assign rand number to playerDesig
			playersObject[myName].playerReady(true);
			
			//send ready info to all
			netHandler.playerReady(playersObject[myName].playerDesig);
			
			//check if everyone's ready
			playersHandler.checkAllReady();
			
			uiHandler.status("Player Draw: " + playersObject[myName].playerDesig);
			
		}
		
		private function newPlayerJoins(e:Event):void 
		{
			var name:String = new String(netHandler.newPlayerName);
			var neibPeerID:String = new String(netHandler.neighborPeerID);
			trace("New player joins: " + neibPeerID);
			uiHandler.status(name + ": " + neibPeerID);
			
			uiHandler.addPlayerToLobby(name);
			
			addPlayerToGame(playersHandler.createPFPlayer(name, neibPeerID));
			
			//send state info to new comers
			netHandler.sendStateToAll(myName,playersObject[myName].playerState,playersObject[myName].playerDesig);
			

			
		}
		
		
		private function gotWelcomeMsg(e:Event):void 
		{
			if (netHandler.stateMsg.state == PFPlayer.READY)
			{
				playersObject[netHandler.stateMsg.name].playerReady(false);
				playersHandler.playerReady(netHandler.stateMsg.name, netHandler.stateMsg.desig);
				uiHandler.playerReady(netHandler.stateMsg.name, false);
			}
			if(TEST_TURN){
				trace("Corrected ID: " + netHandler.stateMsg.name +": " + netHandler.stateMsg.peerID);
				uiHandler.status("Corrected ID: " + netHandler.stateMsg.name +": " + netHandler.stateMsg.peerID);
			}
			playersObject[netHandler.stateMsg.name].peerID = netHandler.stateMsg.peerID;
			
		}
		
		private function receiveChatMessage(e:Event):void 
		{
			//trace(e);
			var message:Object = new Object();
			message = netHandler.receivedMsg;
			uiHandler.opScreen.chatDatatxt.text += message.user + ": " + message.text + "\n";
		}
		
		private function chatEntered(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				var chatMsg:String = uiHandler.opScreen.chatSendtxt.text;
				netHandler.sendChat(chatMsg);
				//trace(e.target.text)
			
			
				uiHandler.opScreen.chatSendtxt.text = "";
			
				uiHandler.opScreen.chatDatatxt.text += myName + ": " + chatMsg + "\n";
			}
		}
		
		
		//a pfplayer object per player according to the list
		private function addPlayerToGame(plyr:PFPlayer):void 
		{
			playersHandler.addPlayerToPlayersObj(plyr);
			if (plyr.userName == myName) playersObject[plyr.userName].playerType = PFPlayer.TYPE_MYSELF;
			else playersObject[plyr.userName].playerType = PFPlayer.TYPE_OPPONENT;
		
		}
		
		
		
		/**
		 *
		 * *********************GAME START******************
		 * 
		 * 
		 * */
		
		private function startGame(type:int):void //type 1:host 2:join 3:single
		{
			//remove unwanted event listeners and objects
			uiHandler.gameStarted(type); //removes the opScreen
			
			i_gameState = GAME_STARTED;
			
			if (type == 1 || type == 2)
			{
				addChild(game = new PFGame(this, type, this.playersObject));
				game.currentPlayer = playersHandler.getCurrentTurnPlayer();				
				game.handleShooting.shootEvtDispatch.addEventListener("ShotFired", sendMove);
				game.addEventListener(PFGame.PEN_FALLS, penFalls);
				
				netHandler.tellServerGameStarted();
				netHandler.evtDispatcher.addEventListener("PositionInfoReceived", receivedPositionInfo);
				netHandler.evtDispatcher.addEventListener("OpponentShoots", opponentFiresShot); 
				
				playersHandler.addEventListener(PlayersHandler.ALL_OUT, gameDrawAllOut);
				playersHandler.addEventListener(PlayersHandler.GAME_WON, somebodyWon);
				
				uiHandler.displayMessage(game.currentPlayer.userName, "Game Started!");
				uiHandler.gameOptions.quitBtn.addEventListener(MouseEvent.CLICK, quitGame);
				
				
			}
			else addChild(game = new PFGame(this, type));
			setChildIndex(game, 0);
			setChildIndex(uiHandler, 1);
		}
		
		private function quitGame(e:MouseEvent):void 
		{
			netHandler.quitGame();
			removeChild(game);
			removeChild(uiHandler);
			uiHandler = null;
			game = null;
			playersObject = null;
			netHandler = null;
			playersHandler = null;
			uiHandler = new UIHandler();
			uiHandler.init();
			this.addChildAt(uiHandler, 0);
			netHandler = new NetHandler();
			playersHandler = new PlayersHandler();
			playersObject = new Object();
			//uiHandler.welcomePlayers();
			//remove event listeners
			//singleOrMulti();
			multiPlayerSelected();
		}
		
		private function gameDrawAllOut(e:Event):void 
		{
			
			i_gameState = GAME_OVER;
			uiHandler.displayMessage(" ", "Game Draw!");
			trace("Game Draw");
			game.stopMultiGame();
		}
		
		private function somebodyWon(e:Event):void 
		{
			i_gameState = GAME_OVER;
			uiHandler.displayMessage(" ", playersHandler.winnerPlayer.userName + " wins!");
			trace("Someone won");
			game.stopMultiGame();
		}
		
		private function penFalls(e:Event):void 
		{
			//trace("I fall: " + playersObject[myName].userName);
			if (TEST_TURN) {
				trace("game current fall: " + game.currentPlayer.userName);
				trace("plyr handler current fall: " + playersHandler.currentTurnPlayer.userName);
			}
			
			playersHandler.currentTurnPlayer = game.currentPlayer;
			uiHandler.displayMessage(" ",game.fallenPlyr.userName + " fell!");
			if (game.currentPlayer == game.fallenPlyr)
			{
				game.removeEventListener(PFGame.ALL_PENS_STATIC, allAreStatic);
				if (TEST_TURN) {
					trace("Changing current cum fallen player " + game.currentPlayer.userName);
					uiHandler.status("Changing current cum fallen player " + game.currentPlayer.userName);
				}
				game.changeCurrentPlayer(playersHandler.nextTurnPlayer());
				uiHandler.displayMessage(game.currentPlayer.userName,"Oops!");
				uiHandler.status("Next Player: " + game.currentPlayer.userName +" " + game.currentPlayer.playerDraw);
				trace("Next Player: " + game.currentPlayer.userName +" " + game.currentPlayer.playerDraw);
			}
			
			playersHandler.removePlayerFromPlayersObj(game.fallenPlyr);
			playersHandler.removeFromGamePlayers(game.fallenPlyr);
			//trace("Fallen Pen: " + game.fallenPlyr.userName);
			game.removeChild(game.fallenPlyr.pen.body.GetUserData()); //remove user data
			uiHandler.playFallenEffect(game.effectPos);
			game.multiNumPlayers--;
			game.fallenPlyr = null;
			var l:uint = 0;
			for each(var plr:PFPlayer in playersObject)
			{
				l++;
			}
			trace("length after removal: " + l);
			
		}
		
		private function playerDisconnected(e:Event):void 
		{
			switch(i_gameState)
			{
				case GAME_LOBBY:
								disconnectFromLobby();
								
								break;
				case GAME_STARTED:
								
								performDisconnectionFromGame();
								
								break;
				case GAME_OVER:
								break;
			}
		}
		
		private function disconnectFromLobby():void 
		{
			for each(var plyr:PFPlayer in playersObject)
				{
					//trace("Plyr ID: " + plyr.peerID);
					uiHandler.status("Plyr ID: " + plyr.peerID);
					//update display
					if (netHandler.disconnectedPlayerID == plyr.peerID)
					{
						
						playersHandler.removePlayerFromPlayersObj(plyr);
						uiHandler.playerDisconnectedAtLobby(plyr.userName);
						break;
					}
					
				}
		}
		
		private function performDisconnectionFromGame():void 
		{
			playersHandler.currentTurnPlayer = game.currentPlayer;
			for each(var plyr:PFPlayer in playersObject)
			{
				uiHandler.status("Disconnects in game: "+ plyr.userName + " " +plyr.peerID);
				trace("Disconnects in game: "+ plyr.userName + " " +plyr.peerID);
				if (plyr.peerID == netHandler.disconnectedPlayerID)
				{
					uiHandler.displayMessage("",plyr.userName +" is disconnected.");
					if (plyr == game.currentPlayer)
					{
						game.changeCurrentPlayer(playersHandler.nextTurnPlayer());
						uiHandler.displayMessage(game.currentPlayer.userName,"");
					}
					game.effectPos = new Object();
					game.effectPos.x = plyr.pen.penPosX;
					game.effectPos.y = plyr.pen.penPosY;
					uiHandler.playFallenEffect(game.effectPos);
					game.removeChild(plyr.pen.body.GetUserData()); //remove user data
					game.multiNumPlayers--;
					playersHandler.removePlayerFromPlayersObj(plyr);
					playersHandler.removeFromGamePlayers(plyr);
					break;
				}
			}
					
			
			playersHandler.checkGameOver();
		}
			

		
		
		private function receivedPositionInfo(e:Event):void 
		{
			game.setPlayerPositions(netHandler.opponentPosition);
			//trace("Received Position Info: " + netHandler.opponentPosition.user +"\n"+netHandler.opponentPosition.positionObj.xpos +" "+netHandler.opponentPosition.positionObj.ypos+" "+netHandler.opponentPosition.positionObj.angle);
			//uiHandler.status("Received Position Info: " + netHandler.opponentPosition.user);
		}
		
		private function allAreStatic(e:Event):void
		{
			playersHandler.checkGameOver();
			game.removeEventListener(PFGame.ALL_PENS_STATIC, allAreStatic);//pos info sent--pens are static; Stop looking
			playersHandler.currentTurnPlayer = game.currentPlayer;
			game.changeCurrentPlayer(playersHandler.nextTurnPlayer());//next player's turn
			uiHandler.displayMessage(game.currentPlayer.userName,"");
			if (TEST_TURN) {
				trace("Changing player after all static " + game.currentPlayer.userName);
				uiHandler.status("Changing player after all satic " + game.currentPlayer.userName);
			}
			if (playersObject[myName] != undefined)//i'm not dead
			{
				var posInfo:Object = playersObject[myName].getPenPositionInfo();
				netHandler.sendPosInfo(posInfo);
				trace("Sending Position Info");
				uiHandler.status("Sending Position Info");
				
			}
			
		}
		
		private function opponentFiresShot(e:Event):void
		{
			var obj:Object = netHandler.opponentShot;
			trace("obj: " + obj.user + " " + obj.type +" " + obj.shot.distx);
			uiHandler.status("obj: " + obj.user + " " + obj.type +" " + obj.shot.distx);
			var dist:b2Vec2 = new b2Vec2(obj.shot.distx, obj.shot.disty);
			var point:b2Vec2 = new b2Vec2(obj.shot.pointx / PFGame.m_physScale, obj.shot.pointy / PFGame.m_physScale);
			playersObject[obj.user].pen.body.ApplyImpulse(dist.GetNegative(), point);
			//game.nextPlayerTurn(netHandler.opponentShot.user);
			game.addEventListener(PFGame.ALL_PENS_STATIC, allAreStatic);//opponent fired --start looking for static
		}
		
		private function sendMove(e:Event):void 
		{
			game.addEventListener(PFGame.ALL_PENS_STATIC, allAreStatic); //shot fired --start looking for static
			//game.nextPlayerTurn(myName);
			trace("Sending my shot " + playersObject[myName].userName); 
			netHandler.sendShotFired(game.handleShooting.shotFired);
			//keep checking pen velocities to determine next turn
			
		}
		
	}

}