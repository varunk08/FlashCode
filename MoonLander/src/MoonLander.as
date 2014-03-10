package 
{
	
	import Box2D.Collision.b2AABB;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author DWiz
	 */
	public class MoonLander extends Sprite 
	{
		//box2D world vars
		static public const _physScale:int = 30;
		static public const GAME_STARTED:String = "GameStartedAndPlaying";
		static public const START_NEW_GAME:String ="StartNewGame_InitEverything";
		static public const GAME_OVER:String="PlayerCrashedOrLanded_GameOver";
		static public const THRUST:Number = 0.2;
		public var _gameState:String;
		private var _world:b2World;
		private var _dt:Number = 1 / 30;
		private var _posIter:Number = 10;
		private var _velIter:Number = 10;
		private var _gravity:b2Vec2 = new b2Vec2(0, 3);
		private var _doSleep:Boolean = true;
		private var _worldAABB:b2AABB;
		
		//debugdraw vars
		private var _debugSprite:Sprite;
		private var debugDraw:b2DebugDraw;
		private var terrain:Array;
		
		//game vars
		private var _ship:Ship;
		private var _shipBody:b2Body;
		private var _terrain:Terrain;
		private var leftPressed:Boolean = false;
		private var rightPressed:Boolean = false;
		private var upPressed:Boolean = false;
		
		public function MoonLander():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_gameState = new String(START_NEW_GAME);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
			switch (e.keyCode)
			{
			case Keyboard.UP:
				upPressed = false;
				break;
				
			case Keyboard.LEFT:
					leftPressed = false;
					break;
					
			case Keyboard.RIGHT:
					rightPressed = false;
					break;
			default:
				break;
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			switch (e.keyCode)
			{
			case Keyboard.UP:
				upPressed = true;
				//trace("Up Pressed");
				break;
				
			case Keyboard.LEFT:
					leftPressed = true;
					break;
					
			case Keyboard.RIGHT:
					rightPressed = true;
					break;
			default:
				break;
			}
			
		}
		

		
		private function setupDebugDraw():void 
		{
			_debugSprite = new Sprite();
			addChild(_debugSprite);
			debugDraw = new b2DebugDraw();
			debugDraw.SetSprite(_debugSprite);
			debugDraw.SetFillAlpha(0.5);
			debugDraw.SetDrawScale(_physScale);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			_world.SetDebugDraw(debugDraw);
		}
		
		private function onEnterFrame(e:Event):void 
		{
			switch(_gameState) {
				
				case START_NEW_GAME:
					setupBox2DWorld();
					setupDebugDraw();
					//createTerrain(1);
					_terrain = new Terrain(_world);
					var ver1:Array = [[[311.4, 165.25], [311.4, 191.5], [221.4, 191.5], [141.7, 191.35], [244, 165.25]], [[244, 136.6], [244, 165.25], [141.7, 191.35], [223, 136.6]], [[141.7, 301.95], [141.7, 191.35], [254.65, 301.95]], [[77.05, 188.35], [77.05, 353.35], [0.05, 397.9], [0.05, 257.95]], [[77.05, 353.35], [254.65, 353.35], [465.8, 397.9], [0.05, 397.9]], [[254.65, 353.35], [254.65, 301.95], [306.55, 324.3], [465.8, 397.9]], [[398.8, 324.3], [465.8, 397.9], [306.55, 324.3]], [[254.65, 301.95], [141.7, 191.35], [221.4, 233.5], [306.55, 324.3]], [[306.55, 233.5], [306.55, 324.3], [221.4, 233.5]], [[221.4, 233.5], [141.7, 191.35], [221.4, 191.5]]];
					var ver2:Array = [[[480.9, 367.2], [536.9, 377.5], [513.8, 397.9]], [[536.9, 377.5], [648.35, 377.5], [766.2, 397.9], [513.8, 397.9]], [[648.35, 377.5], [648.35, 321.65], [766.2, 397.9]], [[766.2, 397.9], [648.35, 321.65], [635.75, 211.2]], [[635.75, 98.45], [635.75, 211.2], [558.1, 98.45]], [[635.75, 211.2], [648.35, 321.65], [558.1, 210.9], [558.1, 98.45]], [[558.1, 210.9], [648.35, 321.65], [501.95, 277.85], [498.9, 210.9]], [[498.9, 97.9], [498.9, 210.9], [429.5, 277.85], [429.5, 97.9]], [[429.5, 277.85], [498.9, 210.9], [501.95, 277.85]], [[501.95, 321.65], [501.95, 277.85], [648.35, 321.65]]];
					var ver3:Array = [[[1245.7, 191.05], [1245.7, 304.2], [1106.3, 267.1]], [[981.1, 102.95], [981.1, 191.05], [907.1, 191.05], [907.1, 102.95]], [[981.1, 191.05], [1106.3, 267.1], [907.1, 191.05]], [[907.1, 191.05], [1106.3, 267.1], [840.5, 399], [840.5, 191.05]], [[1106.3, 267.1], [1245.7, 304.2], [840.5, 399]], [[1245.7, 304.2], [1363.35, 304.2], [1485.7, 399], [840.5, 399]], [[1485.7, 399], [1363.35, 304.2], [1396.7, 168.45]]];
					_terrain.generateTerrain(ver1);		
					_terrain.generateTerrain(ver2);
					_terrain.generateTerrain(ver3);
					createShip();
					_gameState = GAME_STARTED;
					break;
				case GAME_STARTED:
					//update everything
					_world.Step(_dt, _velIter, _posIter);
					_world.DrawDebugData();
					controlShip();
					screenUpdates();
					break;
				case GAME_OVER:
					break;
				
			}
		
		}
		
		private function screenUpdates():void 
		{
			//trace(localToGlobal(new Point(_shipBody.GetPosition().x * _physScale, _shipBody.GetPosition().y * _physScale)));
			//trace(stage.width);
			var shipPos:Point = localToGlobal(new Point(_shipBody.GetPosition().x * _physScale, _shipBody.GetPosition().y * _physScale));
			var rDiff:Number = 700 - shipPos.x;
			//trace(rDiff);
			if (rDiff < 250)
			{
				this.x-= (250-rDiff);
				//trace(_shipBody.GetPosition().x * _physScale);
			}
			else if(shipPos.x < 250) {
				 
				this.x += (250-shipPos.x);
			}
		}
		
		private function controlShip():void 
		{
			if (upPressed) {
				var ang:Number = _shipBody.GetAngle();
				trace(ang*180/Math.PI);
				var thrust:b2Vec2 = new b2Vec2(0, -THRUST);
				var rx:Number = Math.cos(ang) * thrust.x - Math.sin(ang) * thrust.y;
				var ry:Number = Math.cos(ang) * thrust.y + Math.sin(ang) * thrust.x;
				thrust.Set(rx, ry);
				_shipBody.ApplyImpulse(thrust, _shipBody.GetWorldCenter());
			}
			
			if (leftPressed) {
				_shipBody.SetAngle(_shipBody.GetAngle() - 0.05);
			}
			if (rightPressed) {
				_shipBody.SetAngle(_shipBody.GetAngle() + 0.05);
			}
		}
		
		private function createShip():void 
		{
			
			_ship = new Ship(_world);
			_shipBody = _ship.createShip();
			_shipBody.SetPosition(new b2Vec2(350 / _physScale, 100 / _physScale));
		}
		
		private function setupBox2DWorld():void 
		{
			_worldAABB = new b2AABB();
			_worldAABB.lowerBound.Set( -1000, 1000);
			_worldAABB.upperBound.Set( -1000, 1000);
			_world = new b2World(_gravity, _doSleep);
		}
		
		/***
		 * @param numPads Number of landing pads you want in the terrain
		 * 
		 */
		private function createTerrain(numPads:uint):void 
		{
			var body:b2Body;
			var fd:b2FixtureDef;
			terrain = [];
			
			var startX:int = 0;
			var startY:int = 400;
			var endX:int = 700;
			var endY:int = 400;
			var nextX:int = startX;
			
			//first point -left bottom of screen
			terrain[0] = new b2Vec2(startX / _physScale,startY / _physScale);
			
			
			
			for (var i:int = 0; i <= 20; i++)
			{
				
				var ranX:int = nextX;
				var ranY:int = Math.round(200 + Math.random() * 100);
				terrain[i+1] = new b2Vec2(ranX / _physScale, ranY / _physScale);
				nextX = ranX + 35;
			}
			
			//final point -right bottom of screen
			terrain.push(new b2Vec2(endX / _physScale, endY / _physScale));
			trace(terrain.length);
			
			var padsCreated:int = 0;
			var prevPadPos:int = -1;
			do{
				//randomly select landing pad position among points in terrain
				var landingPos:int = 1 + Math.floor(Math.random() * (terrain.length - 3));
				trace("landing pos: " + landingPos);
				if (prevPadPos != landingPos) {
					terrain[landingPos + 1 ].y = terrain[landingPos].y;
					createLandingPad(terrain[landingPos]);
					padsCreated++;
				}
				prevPadPos = landingPos;
				
				
			}while (padsCreated < numPads);
			
			var terrainArray:Array = [];
			var cntr:uint = 0;
			
			var a:b2Vec2;
			var b:b2Vec2;
			var c:b2Vec2;
			var d:b2Vec2;
			for (var j:uint = 1; j < terrain.length; j++)
			{
				if (j == 21) break;
				if (j == 1) {
					a = terrain[0];
					b = terrain[j];
					c = terrain[j + 1];
					d = new b2Vec2(c.x, 400 / _physScale);
					var block:Array = [];
					block[0] = a;
					block[1] = b;
					block[2] = c;
					block[3] = d;
					terrainArray.push(block);
					
				}
				else{
					a = d;
					b = terrain[j];
					c = terrain[j + 1];
					d = new b2Vec2(c.x, 400 / _physScale);
					var block:Array = [];
					block[0] = a;
					block[1] = b;
					block[2] = c;
					block[3] = d;
					terrainArray.push(block);
				}
				
			}
			trace(terrainArray.length);
			drawTerrain(terrain);
			
			for each(var block:Array in terrainArray) {
				var bodyDefP:b2BodyDef = new b2BodyDef();
				bodyDefP.type = b2Body.b2_staticBody;
				var polyDef:b2PolygonShape = new b2PolygonShape();
				
				polyDef.SetAsArray(block);
				body = _world.CreateBody(bodyDefP);
				body.CreateFixture2(polyDef, 1);
			}
			
		}
		
		private function createLandingPad(landingPadPoint:b2Vec2):void 
		{
			var padHWidth:Number = 35 / 2;
			var padHHeight:Number = 3;
			
			var body:b2Body;
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type = b2Body.b2_staticBody;
			var boxShape:b2PolygonShape = new b2PolygonShape();
			var fd:b2FixtureDef = new b2FixtureDef();
			fd.shape = boxShape;
			fd.density = 1.0;
			
			boxShape.SetAsBox(padHWidth / _physScale, padHHeight / _physScale);
			bodyDef.position.Set(landingPadPoint.x + (padHWidth / _physScale) , landingPadPoint.y - (padHHeight / _physScale));
			body = _world.CreateBody(bodyDef);
			body.CreateFixture(fd);
			
		}
		
		private function drawTerrain(terrain:Array):void 
		{
			graphics.lineStyle(1, 0x00ccff);
			graphics.moveTo(terrain[0].x * _physScale, terrain[0].y * _physScale);
			for (var i:uint = 1; i < terrain.length; i++)
			{
				graphics.lineTo(terrain[i].x * _physScale, terrain[i].y * _physScale);
			}
			
			graphics.lineTo(terrain[0].x * _physScale, terrain[0].y * _physScale);
		}
	}
	
}