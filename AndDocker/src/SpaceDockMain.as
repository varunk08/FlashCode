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
	import flash.events.Event;
	
	/**
	 * ...
	 * @author DWiz
	 */
	public class SpaceDockMain extends Sprite 
	{
		static public const _physScale:int = 30;
		private var _world:b2World;
		private var _worldAABB:b2AABB;
		private var _gravity:b2Vec2;
		private var _doSleep:Boolean = false;
		private var _dt:Number = 1.0 / 30.0;
		private var _velocityItrs:Number = 10;
		private var _positionItrs:Number = 10;
		private var _debugDraw:b2DebugDraw;
		private var _debugSprite:Sprite;
		private var _effectsSprite:Sprite;
		private var shootin:SpaceDock_Shooting;
		
		public function SpaceDockMain():void 
		{
			if (stage) {
				Registry.r_stage = stage;
				init();
			}
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			Registry.r_stage = stage;
			removeEventListener(Event.ADDED_TO_STAGE, init);
			_effectsSprite = new Sprite();
			addChild(_effectsSprite);
			
			var bgSprite:Sprite = new Sprite();
			bgSprite.graphics.beginFill(0Xffffff);
			for (var i:int = 0; i < 300; i++)
			{
				bgSprite.graphics.drawCircle(Math.random() * 700, Math.random() * 500, 1);
			}
			bgSprite.graphics.endFill();
			addChildAt(bgSprite,0);
			Registry.r_effectsSprite = _effectsSprite;
			_debugSprite = new Sprite();
			addChild(_debugSprite);
			setupWorld();
			setDebugDraw();
			shootin = new SpaceDock_Shooting();
			createShapes(350, 200, 50, 20);
			createRandomBlocks();
			//Registry.r_ship.SetAngle(-90 * Math.PI / 180);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function createRandomBlocks():void 
		{
			var body:b2Body;
			var fd:b2FixtureDef;
			
			for (var i:int = 0; i < 20; i++){
				var bodyDefP:b2BodyDef = new b2BodyDef();
				bodyDefP.type = b2Body.b2_dynamicBody;
				bodyDefP.linearDamping = 1.0;
				bodyDefP.angularDamping = 0.8;
				//bodyDefP.isBullet = true;
				var polyDef:b2PolygonShape = new b2PolygonShape();
				//if (Math.random() > 0.66) {
					polyDef.SetAsArray([
						new b2Vec2((-10 -Math.random()*10) / _physScale, ( 10 +Math.random()*10) / _physScale),
						new b2Vec2(( -5 -Math.random()*10) / _physScale, (-10 -Math.random()*10) / _physScale),
						new b2Vec2((  5 +Math.random()*10) / _physScale, (-10 -Math.random()*10) / _physScale),
						new b2Vec2(( 10 +Math.random() * 10) / _physScale, ( 10 +Math.random() * 10) / _physScale)
						]);
						
						
					fd = new b2FixtureDef();
				fd.shape = polyDef;
				fd.density = 1.0;
				fd.friction = 0.3;
				fd.restitution = 0.1;
				bodyDefP.position.Set((Math.random() * 700 ) / _physScale, (Math.random() * 500) / _physScale);
				bodyDefP.angle = Math.random() * Math.PI;
				body = _world.CreateBody(bodyDefP);
				body.CreateFixture(fd);
			}		
		}
		
		/**
		 * @param x x-position of body
		 * @param y y-position of body
		 * @param hWidth Half-width of body
		 * @param hHeight Half-height of body
		 */
		private function createShapes(x:int, y:int, hWidth:uint,hHeight:uint):void 
		{
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var boxShape:b2PolygonShape;
			
			
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(x/_physScale,y/_physScale);
			bodyDef.type = b2Body.b2_dynamicBody;
			boxShape = new b2PolygonShape();
			boxShape.SetAsBox(hWidth/_physScale, hHeight/_physScale);
			bodyDef.linearDamping = 1.5;
			bodyDef.angularDamping = 1.5;
			
			var cd2:b2CircleShape = new b2CircleShape();
			cd2.SetRadius(hHeight/_physScale);
			cd2.SetLocalPosition(new b2Vec2((-hWidth) / _physScale, 0.0 / _physScale));
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = boxShape;
			//fixtureDef.friction = 0.5;
			fixtureDef.restitution = 0.2;
			fixtureDef.density = 1; // static bodies require zero density
			
			//Always create the body and then append the fixture to it.
			//Fixture contains the shape details and other data.
			body = _world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			body.CreateFixture2(cd2, 1);
			Registry.r_ship = body;
		}
		
		private function setDebugDraw():void 
		{
			
			_debugDraw = new b2DebugDraw();
			_debugDraw.SetSprite(_debugSprite);
			_debugDraw.SetDrawScale(_physScale);
			_debugDraw.SetFillAlpha(0.5);
			_debugDraw.SetLineThickness(1.0);
			_debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			_world.SetDebugDraw(_debugDraw);
		}
		
		private function onEnterFrame(e:Event):void 
		{
			shootin.Update();
			_world.DrawDebugData();
			_world.Step(_dt, _velocityItrs, _positionItrs);
		}
		
		private function setupWorld():void 
		{
			_worldAABB = new b2AABB();
			_worldAABB.upperBound.Set(1000, 1000);
			_worldAABB.lowerBound.Set( -1000, -1000);
			_gravity = new b2Vec2(0,0);
			_world = new b2World(_gravity, _doSleep);
			Registry.r_world = _world;
		}
		
	}
	
}