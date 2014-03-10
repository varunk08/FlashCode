package 
{
	import Box2D.Collision.b2AABB;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	import flash.display.BitmapData;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	
	/**
	 * ...
	 * @author Dwiz
	 */
	public class PFGame extends Sprite
	{
		static public const PEN_FALLS:String = "PenFallen";
		
		static public const ALL_PENS_STATIC:String = "AllAreStaticEvent";
		
		
		public var m_world:b2World;
		public static var m_physScale:int = 30;
		private var m_worldAABB:b2AABB = new b2AABB();
		private var m_dt:Number = 1.0 / 30.0;
		private var m_velocityIterations:Number = 10;
		private var m_positionIterations:Number = 10;
		private var m_input:Input;
		private var dbgDraw:b2DebugDraw;
		
		private var floor:b2Body;
		private var ceiling:b2Body;
		private var leftWall:b2Body;
		private var rightWall:b2Body;
		
		public var m_sprite:Sprite;
		private var table:TableBg;
		public var handleShooting:ShootingHandler;
		private var m_effectSprite:Sprite;
		
		private var penArray:Array = new Array();
		public var turn:String = null;
		
		private var myl1:Lighting;
		private var myl2:Lighting;
		private var t_aabb:b2AABB;
		private var infoDis:InGameDisplay;
		private var selectNumMenu:SelectNumPlayers;
		private var numberPlayers:uint;
		private var fallenEffectX:Number;
		private var fallenEffectY:Number;
		private var fallenEffectSprite:Effect1 = new Effect1();
		private var opScreen:OpeningScreen;
		private var pf_netHandler:NetHandler;
		private var _playersObject:Object;
		private var gameType:int;
		public var multiNumPlayers:int;				//for finding number of players in multiplayer game
		private var blueFiltersArray:Array;
		private var redGlowFilter:GlowFilter;
		private var redFiltersArray:Array;
		private var blueGlowFilter:GlowFilter;
		private var drawArray:Array;
		
		//game states
		public var gameState:String;
		public static const NEWGAME_LOBBY:String = "NewGame_Lobby";
		public var effectPos:Object;
		
		public var fallenPlyr:PFPlayer;;
		public var disconPlyr:PFPlayer;
		public var winnerPlyr:PFPlayer;
		public var currentPlayer:PFPlayer;
		
		public function PFGame(stage:Sprite,type:int,plyrObj:Object = null):void 
		{
			this.gameType = type;
			m_sprite = stage;
			m_input = new Input(m_sprite);
			
			setUpworld();
			//setDbgDraw();
			this.playersObject = plyrObj;
			switch(type)
			{
				//type 1:host 2:join 3:single
				case 1:
				case 2:
						multiPlayerGameInit();
						break;
				case 3:
						askForNumPlayers();
						break;
				
			}
		}
		
		
		/***************Multiplayer section*****************************/
		private function multiPlayerGameInit():void 
		{
			multiNumPlayers = 0;
			//drawArray = new Array();
			setGraphics();
			handleShooting = new ShootingHandler(m_world, m_effectSprite);
			for each(var plyr:PFPlayer in playersObject)
			{
				//create pens for each player
				plyr.createPlayerPen(m_world); //positions hard-coded. Later pass table edge
				plyr.createUserData();
				
				this.addChild(plyr.pen.body.GetUserData());
				multiNumPlayers++;
				//drawArray.push(multiNumPlayers);
				if (plyr.playerDraw == 1) 
				{
					if (plyr.playerType == PFPlayer.TYPE_MYSELF) handleShooting.legalBody = plyr.pen.body;
					plyr.myTurn = true;
					currentPlayer = plyr;
					
				}
				
				if (plyr.playerType == PFPlayer.TYPE_MYSELF)
				{
					
					plyr.pen.body.GetUserData().filters = blueFiltersArray;
				}
				else if(plyr.playerType == PFPlayer.TYPE_OPPONENT) plyr.pen.body.GetUserData().filters = redFiltersArray;
			}
			//infoDis.turnIndicator.text = currentPlayer.userName + "'s turn";
			trace("PFGame NumPlayers: " + multiNumPlayers);
			
			tableEdge();
			
			addEventListener(Event.ENTER_FRAME, mutltiPlayerGameLoop);
			
		}
		
		
		//multiplayer enter frame handler
		private function mutltiPlayerGameLoop(e:Event):void 
		{
			handleShooting.Update();
			Input.update();
			m_world.Step(m_dt, m_velocityIterations, m_positionIterations);
			
			
			multi_penUpdate(); //velocity constraints & static pens checking
			multi_checkFallenPens();
			updateMultiPlayerGraphics();
			
		}
		
		
		public function setPlayerPositions(opponentPosition:Object):void 
		{
			for each(var plr:PFPlayer in playersObject)
			{
				if (opponentPosition.user == plr.userName)
				{
					plr.setPenPosition(opponentPosition.positionObj.xpos, opponentPosition.positionObj.ypos, opponentPosition.positionObj.angle);
				}
			}
		}
		
		
		
		public function changeCurrentPlayer(nextTurnPlayer:PFPlayer):void 
		{
			handleShooting.legalBody = null;
			this.currentPlayer = null;
			if (nextTurnPlayer != null)
			{
				this.currentPlayer = nextTurnPlayer;
				
				if (currentPlayer.playerType == PFPlayer.TYPE_MYSELF)
				{
					handleShooting.legalBody = currentPlayer.pen.body;
					
				}
				//infoDis.turnIndicator.text = currentPlayer.userName + "'s turn";
			}

		}
		
		private function multi_checkFallenPens():void 
		{
			//upperbound -- bottom b2Vec2
			//lowerbound -- top b2vec2
			for each(var plyr:PFPlayer in playersObject)
			{
				
				var fallenEvt:Event = new Event(PFGame.PEN_FALLS);
				//right
				if (plyr.pen.penPosX > t_aabb.upperBound.x)
				{
					fallenPlyr = plyr; 
					//trace("right side");
					effectPos = new Object();
					effectPos.x = plyr.pen.penPosX;
					effectPos.y = plyr.pen.penPosY;
					dispatchEvent(fallenEvt);				
					break;
					
				}
				//left
				if (plyr.pen.penPosX < t_aabb.lowerBound.x)
				{
					//var fallenEvt:Event = new Event("PenFallen");
					//trace("left side");
					effectPos = new Object();
					effectPos.x = plyr.pen.penPosX;
					effectPos.y = plyr.pen.penPosY;
					fallenPlyr = plyr; trace(fallenPlyr.userName);
					dispatchEvent(fallenEvt);
					break;
				}
				//top
				if (plyr.pen.penPosY < t_aabb.lowerBound.y)
				{
					//var fallenEvt:Event = new Event("PenFallen");
					//trace("top side");
					effectPos = new Object();
					effectPos.x = plyr.pen.penPosX;
					effectPos.y = plyr.pen.penPosY;
					fallenPlyr = plyr;
					dispatchEvent(fallenEvt);
					break;
				}
				//bottom
				if (plyr.pen.penPosY > t_aabb.upperBound.y)
				{
					//var fallenEvt:Event = new Event("PenFallen");
					//trace("bottom side");
					effectPos = new Object();
					effectPos.x = plyr.pen.penPosX;
					effectPos.y = plyr.pen.penPosY;
					fallenPlyr = plyr;
					dispatchEvent(fallenEvt);
					break;
				}
			}
		}
		
		private function multi_penUpdate():void 
		{
			var numStatic:int = 0;
			for each(var plr:PFPlayer in playersObject)
			{
				plr.pen.penUpdate(); //velocity constraints
				if (plr.pen.penStatic) numStatic++; //checkin all are static?
			}
			/*game over- numStatic becomes 0 and event fires. so prevention*/
			if (numStatic != 0 && numStatic == multiNumPlayers) 
			{
				
				//all are static so?
				var staticEvt:Event = new Event(PFGame.ALL_PENS_STATIC);
				dispatchEvent(staticEvt);
				
			}
		}
		
		//render
		private function updateMultiPlayerGraphics():void 
		{
			
			for each(var plyr:PFPlayer in playersObject)
			{
				plyr.pen.body.GetUserData().x = plyr.pen.penPosX * m_physScale;
				plyr.pen.body.GetUserData().y = plyr.pen.penPosY * m_physScale;
				plyr.pen.body.GetUserData().rotation = plyr.pen.body.GetAngle() * (180 / Math.PI);
				
			}
		}
		
		public function stopMultiGame():void
		{
			removeEventListener(Event.ENTER_FRAME, mutltiPlayerGameLoop);
		}
		
		/*********************Single player section*********************/
		private function askForNumPlayers():void 
		{
			selectNumMenu = new SelectNumPlayers();
			addChild(selectNumMenu);
			selectNumMenu.gotoAndStop(1);
			selectNumMenu.x = 400;
			selectNumMenu.y = 300;
			
			
			selectNumMenu.numSelectGoBtn.buttonMode = true;
			selectNumMenu.numSelectGoBtn.mouseFocusEnabled = true;
			selectNumMenu.numSelectGoBtn.addEventListener(MouseEvent.CLICK, init);
			
			
		}
		
		private function tableEdge():void 
		{
			t_aabb = new b2AABB();
			t_aabb.upperBound.Set((table.x + table.width/2)/m_physScale, (table.y + table.height/2)/m_physScale);
			t_aabb.lowerBound.Set( (table.x - table.width/2) / m_physScale, (table.y - table.height/2) / m_physScale);
		}
		
		private function setDbgDraw():void 
		{
			dbgDraw = new b2DebugDraw();
			dbgDraw.SetSprite(m_sprite);
			dbgDraw.SetDrawScale(m_physScale);
			dbgDraw.SetFillAlpha(0.5);
			dbgDraw.SetLineThickness(1.0);
			dbgDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			m_world.SetDebugDraw(dbgDraw);
		}
		
		private function init(e:MouseEvent):void 
		{
			selectNumMenu.numSelectGoBtn.removeEventListener(MouseEvent.CLICK, init);
			numberPlayers = selectNumMenu.numStepper.value;
			removeChild(selectNumMenu);
			createPlayers(numberPlayers);
			setGraphics();
			
			
			
			tableEdge();
			handleShooting = new ShootingHandler(m_world, m_effectSprite);
			addEventListener(Event.ENTER_FRAME, m_update, false, 0, true);
		}

		//for both multiplayer and single player
		private function setGraphics():void 
		{
			m_effectSprite = new Sprite();
			addChild(m_effectSprite);
			table = new TableBg();
			addChildAt(table, 0);
			//table.alpha = 0.5;
			table.x = 400;
			table.y = 300;
			if (this.gameType == 3)
			{
				//turn display
				infoDis = new InGameDisplay();
				addChild(infoDis);
				infoDis.width = 300;
			}
			//pen glow green--mypen //red--opponent
			blueGlowFilter = new GlowFilter(0x33FF00);
			//shadowFilter = new DropShadowFilter(5);
			blueFiltersArray = new Array(blueGlowFilter,new DropShadowFilter(10));
			
			redGlowFilter = new GlowFilter(0xCC3300);
			redFiltersArray = new Array(redGlowFilter,new DropShadowFilter(10));
		}
		
		private function createPlayers(numberPlayers:uint):void 
		{
			
			trace(numberPlayers);
			for (var i:uint = 0; i < numberPlayers; i++)
			{
				var newPen:Pen = new Pen(m_world);
				newPen.createPen((100 + Math.random() * 600), (100 + Math.random() * 400), 50, 5);
				newPen.setAngle(Math.random() * 180);
				newPen.setAngDamping(1.2);
				newPen.setLinearDamping(1.6);
				
				newPen.body.SetUserData(new PenBlue());
				addChild(newPen.body.GetUserData());
				newPen.body.GetUserData().width = 110;
				newPen.body.GetUserData().height = 20;
				newPen.p_userName = "Player-" + i;
				penArray.push(newPen);
				
			}
			//turn = penArray[0].p_userName;
			
			/*
			myl1 = new Lighting(myPen.body.GetUserData());
			myl2 = new Lighting(myPen2.body.GetUserData());
			*/
			
		}
		
		
		private function createBoundary():void 
		{
			floor = createStaticObject(400, 600, 400, 10);
			floor.SetUserData(new String("Floor"));
			ceiling = createStaticObject(400, 0, 400, 10);
			ceiling.SetUserData(new String("ceiling"));
			leftWall = createStaticObject(0, 300, 10, 300);
			leftWall.SetUserData(new String("leftWall"));
			rightWall = createStaticObject(800, 300, 10, 300);
			rightWall.SetUserData(new String("rightWall"));
		}
		
		private function createStaticObject(x:Number, y:Number, hWidth:Number, hHeight:Number):b2Body 
		{
			// Vars used to create bodies
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var boxShape:b2PolygonShape;
			
			// Add ground body
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(x/m_physScale,y/m_physScale);

			boxShape = new b2PolygonShape();
			boxShape.SetAsBox(hWidth/m_physScale, hHeight/m_physScale);
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = boxShape;
			fixtureDef.friction = 0.5;
			fixtureDef.restitution = 0.2;
			fixtureDef.density = 0; // static bodies require zero density
			
			//Always create the body and then append the fixture to it.
			//Fixture contains the shape details and other data.
			body = m_world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			return body;
		}
		
		private function m_update(e:Event):void 
		{
			handleShooting.Update();
			Input.update();
			playByTurns();
			
			for (var i:uint = 0; i < penArray.length; i++)
			{
				penArray[i].penUpdate();
			}
			
			
			//myl1.update();
			//myl2.update();
			m_world.Step(m_dt, m_velocityIterations, m_positionIterations);
			//m_world.DrawDebugData();
			
			checkFallenPens();
			removeFallenPens();
			updateGraphics();
			checkWinner();
		}
		
		private function checkWinner():void 
		{
			//trace(penArray.length);
			if (penArray.length == 1)
			{
				
				finishGame();
			}
			
			
		}
		
		private function playByTurns():void 
		{
			if (turn == null)
			{
				penArray[0].shootingEnabled = true;
				turn = penArray[0].p_userName;
				handleShooting.legalBody = penArray[0].body;
			}
			
			if (handleShooting.doneShooting)
			{
				handleShooting.doneShooting = false;
				handleShooting.legalBody = null;
				for (var i:uint = 0; i < penArray.length; i++)
				{
					if (penArray[i].shootingEnabled)
					{
						//trace(penArray[i].p_userName);
						penArray[i].shootingEnabled = false;
						
						if (++i < penArray.length)
						{
							//trace(++i);
							penArray[i].shootingEnabled = true;
							turn = penArray[i].p_userName;
							handleShooting.legalBody = penArray[i].body;
							break;
						}
						else {
							penArray[0].shootingEnabled = true;
							turn = penArray[0].p_userName;
							handleShooting.legalBody = penArray[0].body;
							break;
						}
						
					}
				}
			}
			//trace("turn : " + turn);
			
		}
		
		private function checkFallenPens():void 
		{
			for (var i:uint = 0; i < penArray.length; i++)
			{
				if (penArray[i].body.GetPosition().x < t_aabb.lowerBound.x)
				{
					//trace(penArray[i].p_userName + " left side fall");
					penArray[i].fallenPen = true;
					fallenEffectX = penArray[i].body.GetPosition().x * m_physScale;
					fallenEffectY = penArray[i].body.GetPosition().y * m_physScale;
				}
				if (penArray[i].body.GetPosition().x > t_aabb.upperBound.x)
				{
					//trace(penArray[i].p_userName + " right side fall");
					penArray[i].fallenPen = true;
					fallenEffectX = penArray[i].body.GetPosition().x * m_physScale;
					fallenEffectY = penArray[i].body.GetPosition().y * m_physScale;
				}
				if (penArray[i].body.GetPosition().y < t_aabb.lowerBound.y)
				{
					//trace(penArray[i].p_userName + " top side fall");
					penArray[i].fallenPen = true;
					fallenEffectX = penArray[i].body.GetPosition().x * m_physScale;
					fallenEffectY = penArray[i].body.GetPosition().y * m_physScale;
				}
				if (penArray[i].body.GetPosition().y > t_aabb.upperBound.y)
				{
					//trace(penArray[i].p_userName + " bottom side fall");
					penArray[i].fallenPen = true;
					fallenEffectX = penArray[i].body.GetPosition().x * m_physScale;
					fallenEffectY = penArray[i].body.GetPosition().y * m_physScale;
				}
				
				
			}
		}
		
		private function removeFallenPens():void
		{
			for (var i:int = 0; i < penArray.length; i++)
			{
				//trace(i);
				if (penArray[i].fallenPen)
				{
					trace(penArray[i].p_userName);
					this.removeChild(penArray[i].body.GetUserData());
					m_world.DestroyBody(penArray[i].body);
					//make sure this pen is not next turn
					if (penArray[i].shootingEnabled)
					{
						if ((i + 1) < penArray.length)
						{
							penArray[i +1].shootingEnabled = true;
							turn = penArray[i + 1].p_userName;							
							handleShooting.legalBody = penArray[i+1].body;
						}
						else
						{
							penArray[0].shootingEnabled = true;
							turn = penArray[0].p_userName;							
							handleShooting.legalBody = penArray[0].body;
							//turn = null;
						}
					}
					showFallenEffect();
					penArray.splice(i, 1);
					i--;
				}
			}
			
		}
		
		private function showFallenEffect():void 
		{
			addChild(fallenEffectSprite);
			fallenEffectSprite.x = fallenEffectX;
			fallenEffectSprite.y = fallenEffectY;
		}
		
		
		
		
		
		private function updateGraphics():void 
		{
			this.setChildIndex(m_effectSprite, this.numChildren - 1);
			//trace("effects " + this.getChildIndex(m_effectSprite));
			for (var i:uint = 0; i < penArray.length; i++)
			{
				
				penArray[i].body.GetUserData().x = penArray[i].body.GetPosition().x * m_physScale;
				penArray[i].body.GetUserData().y = penArray[i].body.GetPosition().y * m_physScale;
				penArray[i].body.GetUserData().rotation = penArray[i].body.GetAngle() * (180 / Math.PI);
				
				if (penArray[i].shootingEnabled)
				{
					penArray[i].body.GetUserData().filters = blueFiltersArray;
				}
				else { penArray[i].body.GetUserData().filters = null; }
			}
			
			if (this.contains(fallenEffectSprite))
			{
				trace("effect");
				if (fallenEffectSprite.currentFrame + 1 == 15)
				{
					this.removeChild(fallenEffectSprite);
				}
			}
			
			infoDis.turnIndicator.text = turn + "'s turn";
		}
		
		private function finishGame():void
		{
			
			removeEventListener(Event.ENTER_FRAME, m_update);
			infoDis.turnIndicator.text = penArray[0].p_userName + " wins!";
			trace("Game Over");
			if (this.contains(fallenEffectSprite)) this.removeChild(fallenEffectSprite);
			penArray = null;
			this.removeChild(table);
			//this.removeChild(infoDis);
			
			
		}
		
		private function setUpworld():void 
		{
			m_worldAABB.lowerBound.Set(-1000.0, -1000.0);
			m_worldAABB.upperBound.Set(1000.0, 1000.0);
			
			var m_gravity:b2Vec2 = new b2Vec2(0.0, 0.0);
			var m_doSleep:Boolean = false;
			
			m_world = new b2World(m_gravity, m_doSleep);
			
		}
		
		public function get playersObject():Object 
		{
			return _playersObject;
		}
		
		public function set playersObject(value:Object):void 
		{
			_playersObject = value;
		}

		
	}
	
}