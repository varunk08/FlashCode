package  
{
	
	import Box2D.Collision.b2AABB;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	import flash.display.Sprite;
	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.sensors.Accelerometer;
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author DWiz
	 */
	public class BoxFun extends Sprite
	{
		public const _velIter:int = 10;
		public const _posIter:int = 10;
		public const _physScale:int = 30;
		public const _dt:Number = 1 / 30;
		private var _doSleep:Boolean = false;
		private var _world:b2World;
		private var _gravity:b2Vec2 = new b2Vec2(0, 9);
		private var _aabb:b2AABB;
		private var _debugSprite:Sprite;
		private var debugDraw:b2DebugDraw;
		
		
		private var accMeter:Accelerometer;
		private var screenHeight:Number=0;
		private var screenWidth:Number = 0;
		
		private var fps:FpsCounter = new FpsCounter();
		
		public function BoxFun() 
		{
			
			getDeviceParams();
			//set up world
			setUpWorld();
			setupDebugDraw();
			//create boundaries
			createBoundaries();
			//create objects
			createDynamicObject(screenWidth/2,screenHeight/2, 20, 20);
			createDynamicObject(screenWidth/2,screenHeight/2 - 100, 20, 20);
			createDynamicObject(screenWidth / 2, screenHeight / 2 + 100, 20, 20);
			createDynamicObject(screenWidth / 2 - 100, screenHeight / 2, 20, 20);
			createDynamicObject(screenWidth / 2 + 100, screenHeight / 2, 20, 20);
			createDynamicObject(screenWidth / 2 - 100, screenHeight + 100 / 2, 20, 20);
			createCircleObject(screenWidth / 2 - 100, screenHeight / 2 + 100, 15);
			createCircleObject(screenWidth / 2 + 100, screenHeight / 2 + 100, 15);
			createCircleObject(screenWidth / 2 + 100, screenHeight / 2 - 150, 15);
			createCircleObject(screenWidth / 2 - 100, screenHeight / 2 - 150, 15);
			//get accelerometer readings
			accMeter = new Accelerometer();
			accMeter.setRequestedUpdateInterval(30);
			accMeter.addEventListener(AccelerometerEvent.UPDATE, onAccUpdate);
			//change gravity
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onAccUpdate(e:AccelerometerEvent):void 
		{
			_gravity = new b2Vec2( -e.accelerationX * 20, e.accelerationY * 20);
			_world.SetGravity(_gravity);
		}
		
		private function getDeviceParams():void 
		{
			screenWidth = Capabilities.screenResolutionX;
			screenHeight = Capabilities.screenResolutionY;
			
			addChild(fps);
			fps.x = 0;
			fps.y = 0;
			//fps.scaleX = 0.5;
			//fps.scaleY = 0.5;
		}
		
		private function createBoundaries():void 
		{
			createStaticObject(screenWidth / 2, 10, screenWidth / 2, screenHeight - 10);
			createStaticObject(screenWidth / 2, 10, screenWidth / 2, 10);
			createStaticObject(10, screenHeight / 2, 10, screenHeight / 2);
			createStaticObject(10, screenHeight / 2, screenWidth - 10, screenHeight / 2);
		}
		
		private function createDynamicObject(x:Number,y:Number,hWidth:uint,hHeight:uint):void 
		{
			// Vars used to create bodies
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var boxShape:b2PolygonShape;
			
			// Add ground body
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(x/_physScale,y/_physScale);
			bodyDef.type = b2Body.b2_dynamicBody;
			boxShape = new b2PolygonShape();
			boxShape.SetAsBox(hWidth/_physScale, hHeight/_physScale);
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = boxShape;
			fixtureDef.friction = 0.3;
			fixtureDef.restitution = 0.2;
			fixtureDef.density = 1.0; // static bodies require zero density
			
			//Always create the body and then append the fixture to it.
			//Fixture contains the shape details and other data.
			body = _world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			
		}
		
		private function createCircleObject(x:Number,y:Number,r:uint):void 
		{
			// Vars used to create bodies
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var circleShape:b2CircleShape;
			
			// Add ground body
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(x/_physScale,y/_physScale);
			bodyDef.type = b2Body.b2_dynamicBody;
			circleShape = new b2CircleShape(r / _physScale);
			
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = circleShape;
			fixtureDef.friction = 0.3;
			fixtureDef.restitution = 0.2;
			fixtureDef.density = 1.0; // static bodies require zero density
			
			//Always create the body and then append the fixture to it.
			//Fixture contains the shape details and other data.
			body = _world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			
		}
		private function createStaticObject(hWidth:Number,hHeight:Number,posX:Number,posY:Number):void 
		{
		
			// Vars used to create bodies
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var boxShape:b2PolygonShape;
			
			// Add ground body
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(posX/_physScale,posY/_physScale);

			boxShape = new b2PolygonShape();
			boxShape.SetAsBox(hWidth/_physScale, hHeight/_physScale);
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = boxShape;
			fixtureDef.friction = 0.3;
			fixtureDef.restitution = 0.2;
			fixtureDef.density = 0; // static bodies require zero density
			
			//Always create the body and then append the fixture to it.
			//Fixture contains the shape details and other data.
			body = _world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			
			
			//trace("Body's position and body def's position are the same \n" + body.GetPosition().x * m_physScale + "\n" + body.GetPosition().y * m_physScale);
		}
		
		private function onEnterFrame(e:Event):void 
		{
			_world.Step(_dt, _velIter, _posIter);
			_world.DrawDebugData();
			fps.update();
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
		
		private function setUpWorld():void 
		{
			
			_aabb = new b2AABB();
			_aabb.lowerBound.Set( -1000, -1000);
			_aabb.upperBound.Set(1000, 1000);
			_world = new b2World(_gravity, _doSleep);
			
		}
		

		
	}

}