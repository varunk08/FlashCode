package  
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Dwiz
	 */
	public class PlayersHandler extends EventDispatcher
	{
		public static const ALL_READY:String = "AllAreReady";
		static public const ALL_OUT:String = "AllOut";
		static public const GAME_WON:String = "gameWon";
		public var playersObj:Object;
		//public var playersOutObj:Object;
		//public var playersInGameObj:Object;
		public var playersDisconnectedObj:Object;
		public var gamePlayer:Object;
		public var currentTurnPlayer:PFPlayer;
		public var maxNumPlayers:int = 0;
		public var winnerPlayer:PFPlayer;
		
		public function PlayersHandler() 
		{
			//this.playersOutObj = new Object();
			//this.playersInGameObj = new Object();
		}
		
		public function addPlayerToPlayersObj(plyr:PFPlayer):void
		{
			maxNumPlayers++;
			trace("Max Num Players: " + maxNumPlayers);
			playersObj[plyr.userName] = plyr;
			playersObj[plyr.userName].peerID = plyr.peerID;
			
			
			playersObj[plyr.userName].playerState = PFPlayer.NOT_READY;
			trace("Added to game: " + playersObj[plyr.userName].userName);
		}
		
		public function removePlayerFromPlayersObj(plyr:PFPlayer):void
		{
			playersObj[plyr.userName] = null;
			delete playersObj[plyr.userName];
		}
		
	/*	//those who are in the game and not out or disconnected
		public function addPlyrToPlayersInGameObj(plyr:PFPlayer):void
		{
			playersInGameObj[plyr.userName] = plyr;
		}
		
		//those who are not in the game through getting out or disconnection
		public function addPlayerToPlayersOutObj(plyr:PFPlayer):void
		{
			playersOutObj[plyr.userName] = plyr;
			
		}*/
		
	/*	public function getNextTurnPlayer(currentTurnPlyr:PFPlayer):PFPlayer
		{
			
		}*/
		
		public function playerReady(name:String, randNum:Number):void 
		{
			playersObj[name].playerDesig = randNum;
		}
		
		public function createPFPlayer(userName:String, peerID:String):PFPlayer
		{
			var plyr:PFPlayer = new PFPlayer(userName);
			plyr.peerID = peerID;
			return plyr;
		}
		
		public function checkAllReady():void 
		{
			var num:int = 0;
			var readyNum:int = 0;
			for each(var plyr:PFPlayer in playersObj)
			{
				num++;
				if (plyr.playerState == PFPlayer.READY)
				{
					
					readyNum++;
				}
				else {
					//trace("Someone's not ready");
					break;
				}
			}
			if (num == readyNum)
			{
				trace("All are ready");
				dispatchEvent(new Event(PlayersHandler.ALL_READY));
			}
		}
		
		public function decidePlayingOrder():void 
		{
			gamePlayer = new Object();
			var randDrawArray:Array = new Array();
			for each(var plr:PFPlayer in playersObj)
			{
				trace(plr.userName + ": " + plr.playerDesig);
				
				randDrawArray.push(plr.playerDesig);
			}
			//sort the objects based on the numbers
			randDrawArray.sort(Array.NUMERIC);
			trace("Sorted: " + randDrawArray);
			//assign to the players
			for each(var plyr:PFPlayer in playersObj)
			{
				for (var i:int = 0; i < randDrawArray.length; i++)
				{
					if (plyr.playerDesig == randDrawArray[i])
					{
						plyr.playerDraw = i + 1;
						gamePlayer[i + 1] = plyr;
						//trace(i + 1 +": " + plyr.userName); 
						//trace("gamePlayer[" + i + 1 +"]: " + gamePlayer[i + 1].userName);
						break;
					}
					
				}
				//trace("Player " +plyr.playerDraw + " " + plyr.userName);
				
			}
			
		}

		public function getCurrentTurnPlayer():PFPlayer
		{
			for each(var plyr:PFPlayer in gamePlayer)
			{
				if (plyr.myTurn)
				{
					currentTurnPlayer = plyr;
					return plyr;
					
				}
			}
			return null;
		}
		
		public function nextTurnPlayer():PFPlayer 
		{
			currentTurnPlayer.myTurn = false;
			var drawArray:Array = new Array();
			var currDraw:int = currentTurnPlayer.playerDraw;
			var nextDraw:int = 0;
			var num:int = 0;
			//get playerDraw into an array
			for each(var plr:PFPlayer in gamePlayer)
			{
				drawArray.push(plr.playerDraw);
				num++;
			}
			//trace(drawArray);
			
			for (var i:int = 0; i < drawArray.length; i++)
			{
				//check which pos current turn is in array
				if (currDraw == drawArray[i])
				{
					//assign next pos as current turn
					if ( i +1 != drawArray.length)
					{
						nextDraw = drawArray[i + 1];
						break;
					}
					else {
						nextDraw = drawArray[0];
						break;
					}
				}
			}
			if(num!=0){
				//change current player
				currentTurnPlayer = gamePlayer[nextDraw];
				currentTurnPlayer.myTurn = true;
				return currentTurnPlayer;
			}
			else return null;
			
		}
		
		public function removeFromGamePlayers(fallenPlyr:PFPlayer):void 
		{
			gamePlayer[fallenPlyr.playerDraw] = null;
			delete gamePlayer[fallenPlyr.playerDraw];
		}
		
		public function checkGameOver():void 
		{
			var num:int = 0;
			for each(var plr:PFPlayer in gamePlayer)
			{
				num++;
				winnerPlayer = plr;
			}
			
			if (num == 0)
			{
				dispatchEvent(new Event(PlayersHandler.ALL_OUT));
			}
			else if (num == 1)
			{
				dispatchEvent(new Event(PlayersHandler.GAME_WON));
				
			}
		}
	}

}