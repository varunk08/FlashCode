package  
{
	import Box2D.Dynamics.Controllers.b2GravityController;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.NetStream;
	import flash.net.Responder;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.text.TextField;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Dwiz
	 */
	public class NetHandler
	{
		static public const WEBHOST_URL:String = "http://www.dragonixonline.com/PenFight/zindex.php";
		static public const LOCALHOST:String = "http://localhost/zendamf/zindex.php"
		static public const PLYR_DISCONNECTED:String = "PlayerDisconnected";
		static public const GOT_WELCOME_STATE_MSG:String = "GotWelcomeState";
		static public const GOT_CHAT:String = "ChatEvent";
		
		private var cirrusNetConnection:NetConnection;
		public var phpNetConn:NetConnection; //name register webservice
		public var responder:Responder;
		public var joinResponder:Responder;
		public var groupsList:Object = null;
		public var evtDispatcher:EventDispatcher = new EventDispatcher();
		private var nameResponder:Responder;
		//cirrus
		private const CirrusAddress:String = "rtmfp://p2p.rtmfp.net/a6b0c32e3ac937186f2de658-3c5d2e518ab1";
		private const DeveloperKey:String = "a6b0c32e3ac937186f2de658-3c5d2e518ab1";
		public var myPeerID:String;
		public var myPlayerName:String;
		private var groupSpec:GroupSpecifier;
		private var netGroup:NetGroup;
		public var newPlayerName:String;		
		public var receivedMsg:Object;
		public var opponentReady:Object;
		public var neighborPeerID:String;
		private var grpCreate:Object;
		public var orderMessage:Object;
		public var dispTextField:TextField;
		public var opponentShot:Object;
		public var opponentPosition:Object;
		public var disconnectedPlayerID:String = new String();
		public var stateMsg:Object;
		public var regRenewTimer:Timer;
		public var currentGameGroupName:String;
		
		
		public function NetHandler() 
		{
			phpNetConn = new NetConnection();
			
			//phpNetConn.connect(LOCALHOST);     //localhost or webserver
			phpNetConn.connect(WEBHOST_URL);
			
			phpNetConn.addEventListener(NetStatusEvent.NET_STATUS, phpNetConHandler);
			responder = new Responder(onResult,onError);
			joinResponder = new Responder(onJoinResult, onError);
			nameResponder = new Responder(onNameResult, onError);
			
		}
		
			
		//php net status handler
		private function phpNetConHandler(e:NetStatusEvent):void 
		{
			trace(e.info.toString());
			trace("PHP: " + e.info.code);
			dispStatus("PHP: " + e.info.code);
		}
		
		//get peerID of self --register with adobe cirrus
		public function getPeerID(name:String):void
		{
			myPlayerName = name;
			trace("My name: " +name);
			cirrusNetConnection = new NetConnection();
			cirrusNetConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			cirrusNetConnection.connect(CirrusAddress);
			
		}
		
		//create new 'table' or 'game' or 'group'
		public function createNewGroup(groupName:String):void
		{
			currentGameGroupName = new String(groupName);
			grpCreate = new Object();
			grpCreate.groupName = groupName;
			grpCreate.name = myPlayerName;
			phpNetConn.call("PenFight.newGroup", responder, grpCreate);
		}
		
		//join a created 'table' or 'game' or 'group'
		public function joinGame():void
		{
			
			phpNetConn.call("PenFight.joinGame", joinResponder, myPlayerName);
			
			
		}
		
		//cirrus conn event handler
		private function netStatus(e:NetStatusEvent):void 
		{
			trace("Cirrus: " + e.info.code);
			dispStatus("Cirrus: " + e.info.code);
			switch(e.info.code){
				case "NetConnection.Connect.Success":
					myPeerID = cirrusNetConnection.nearID;
					registerPlayer();
					break;
				case "NetConnection.Connect.Failed":
					var conFailedEvt:Event = new Event("ConnectionFailed");
					evtDispatcher.dispatchEvent(conFailedEvt);
					break;
		 
				case "NetGroup.Connect.Success":
					var evt:Event = new Event("NewGameCreated");
					evtDispatcher.dispatchEvent(evt);
					break;
		 
				case "NetGroup.Posting.Notify": 
					switch(e.info.message.type) 
						{
						
							case "Chat":
										receivedMsg = e.info.message;
										var chatEvt:Event = new Event(NetHandler.GOT_CHAT);
										evtDispatcher.dispatchEvent(chatEvt);
										
										break;
							case "PlayerReady":
										opponentReady = new Object();
										opponentReady = e.info.message;
										var readyEvt:Event = new Event("PlayerReady");
										evtDispatcher.dispatchEvent(readyEvt);
										
										break;
							case "StateMsg":
										trace(e.info.message.state);
										trace(e.info.message.name);
										stateMsg = new Object();
										stateMsg = e.info.message;
										//dispStatus("StateMsg: " + e.info.message.state);
										
										var stEvt:Event = new Event("GotWelcomeState");
										evtDispatcher.dispatchEvent(stEvt);
										break;
							case "OrderDecider":
										orderMessage = new Object();
										orderMessage = e.info.message;
										var orderEvt:Event = new Event("OrderMessageEvent");
										evtDispatcher.dispatchEvent(orderEvt);
										break;
							case "ShotFired":
										opponentShot = new Object();
										opponentShot = e.info.message;
										var shotEvt:Event = new Event("OpponentShoots");
										evtDispatcher.dispatchEvent(shotEvt);
										break;
							case "PositionInfo":
										opponentPosition = new Object();
										opponentPosition = e.info.message;
										var posRecEvt:Event = new Event("PositionInfoReceived");
										evtDispatcher.dispatchEvent(posRecEvt);
										break;
						}
						break;
					
				case "NetGroup.Neighbor.Connect":
					trace("Original Connection from: " + e.info.peerID);
					neighborPeerID = new String(e.info.peerID);
					findUserName(neighborPeerID);
					trace("Connection from: " + neighborPeerID);
					break;
					
				case "NetGroup.Neighbor.Disconnect":
					disconnectedPlayerID = new String(e.info.peerID);
					trace("DisConnection by: " + disconnectedPlayerID);
					
					var disconEvt:Event = new Event(NetHandler.PLYR_DISCONNECTED);
					evtDispatcher.dispatchEvent(disconEvt);
					break;
			}
		}
		
		//translate peerID to user name using web service
		private function findUserName(newPlayerID:String):void 
		{
			phpNetConn.call("PenFight.findUserName",nameResponder, newPlayerID);
		}
		
		//got back name from web service --using it to join lobby
		private function onNameResult(e:Object):void 
		{
			//trace("Name Responder:" + e);
			newPlayerName = new String(e.playerName);
			var joinEvt:Event = new Event("JoinEvent");
			evtDispatcher.dispatchEvent(joinEvt);
		
		}
		
		//registering player in DB
		private function registerPlayer():void 
		{
			var player:Object = new Object();
			player.name = myPlayerName;
			player.peerID = cirrusNetConnection.nearID;
			phpNetConn.call("PenFight.registerPlayer", responder, player);
			regRenewTimer = new Timer(15000);
			regRenewTimer.addEventListener(TimerEvent.TIMER, renewRegistration);
			regRenewTimer.start();
		}
		
		private function renewRegistration(e:TimerEvent):void 
		{
			try {
				var renewObj:Object = new Object();
				renewObj.name = myPlayerName;
				phpNetConn.call("PenFight.renewRegistration", responder, renewObj);
			}
			catch(e:Error) {
				trace("renewal error");
				trace(e);
			}
		}
		
		//join responder result
		private function onJoinResult(e:Object):void
		{
			trace("Join Result: " + e);
			if (e == "NO_GAMES_ONLINE")
			{
				trace("EMPTY LIST");
			}
			else
			{
				groupsList = new Object();			
				groupsList = e;
				
				var evt:Event = new Event("GotGamesList");
				evtDispatcher.dispatchEvent(evt);
			}

		}
		
		private	function onResult(e:Object):void
		{
			trace("PHP responder Result: " + e);
			dispStatus("PHP responder Result: " + e);
			switch(e)
			{
					
				case "Player registered":
						trace("Player name registered at DB");
						var regEvt:Event = new Event("DBNameRegistered");
						evtDispatcher.dispatchEvent(regEvt);
						break;
				case "Group Created at DB":
						setupGroup(grpCreate.groupName);
						break;
						
				case "Renewed":
						trace("Renewed");
						break;
						
				case "RenewalError":
						trace("Unable to renew");
						break;
			}
	
		}
		
		//creates the net group
		private function setupGroup(groupName:String):void 
		{
				groupSpec = new GroupSpecifier(groupName);
				groupSpec.postingEnabled = true;
				groupSpec.serverChannelEnabled = true;
				
				netGroup = new NetGroup(cirrusNetConnection,groupSpec.groupspecWithoutAuthorizations());
				netGroup.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
		}
		
		//responder error
		private	function onError(e:Object):void
		{
			trace("Error: " + e);
			dispStatus("Error:" + e);
		}
		
		
		public function joinGroupAtLobby(groupName:String):void 
		{
			currentGameGroupName = new String(groupName);
			setupGroup(groupName);
			var gameSelectObj:Object = new Object();
			gameSelectObj.name = myPlayerName;
			gameSelectObj.group = groupName;
			phpNetConn.call("PenFight.gameSelect", responder, gameSelectObj);
		}
		
		//send chat via message object using post
		public function sendChat(text:String):void 
		{
			var message:Object = new Object();
			message.sender = netGroup.convertPeerIDToGroupAddress(cirrusNetConnection.nearID);
			message.type = "Chat";
			message.user = myPlayerName;
			message.text = text;
						 
			netGroup.post(message);
		}
		
		//this player is ready --posting to others
		public function playerReady(playerDesig:int):void 
		{
			var message:Object = new Object();
			message.user = myPlayerName;
			message.type = "PlayerReady";
			message.randomNumber = playerDesig;
			netGroup.post(message);
		}
		
		public function sendStateToAll(name:String,state:String,desigRanNum:int):void 
		//public function sendStateToAll(myPlyr:PFPlayer):void 
		{
			var stateMsg:Object = new Object();
			stateMsg.type = "StateMsg";
			stateMsg.peerID = myPeerID;
			stateMsg.state = state;
			stateMsg.name = name;
			stateMsg.desig = desigRanNum;
			netGroup.post(stateMsg);
			newPlayerName = null;
			neighborPeerID = null;
		}
		
		public function dispStatus(text:String):void
		{
			dispTextField.appendText(text + "\n");
		}
		
		public function sendShotFired(shotFired:Object):void 
		{
			var message:Object = new Object();
			message.type = "ShotFired";
			message.shot = shotFired;
			message.user = myPlayerName;
			netGroup.post(message);
		}
		
		public function sendPosInfo(posInfo:Object):void 
		{
			var message:Object = new Object();
			message.type = "PositionInfo";
			message.user = myPlayerName;
			message.positionObj = posInfo;
			netGroup.post(message);
		}
		
		public function quitGame():void 
		{
			netGroup.close();
			phpNetConn.call("PenFight.quitMyGame", responder, myPlayerName);
			phpNetConn.close();
		}
		
		public function tellServerGameStarted():void 
		{
			var gameName:String = currentGameGroupName;
			phpNetConn.call("PenFight.gameStarted", responder, gameName);
		}
		
		
		
	}

}