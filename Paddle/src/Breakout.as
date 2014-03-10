package 
{
	import Box2D.Collision.b2AABB;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactFilter;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.Joints.b2PrismaticJoint;
	import Box2D.Dynamics.Joints.b2PrismaticJointDef;
	import flash.display.Sprite;
	import flash.events.Event;


	import Main;
	
	/**
	 * ...
	 * @author Dwiz
	 */
	
	public class Breakout
	{
		private const BALL_VEL:Number = 15;
		public var world:b2World;
		private var worldAABB:b2AABB = new b2AABB();
		public var dbgSprite:Sprite;
		
		private var m_physScale:uint = 30;
		public var dbgDraw:b2DebugDraw;
		private var level:uint = 1;
		private var gameLevel:GameLevels;
		public var paddle:b2Body;
		public var ball:b2Body;
		public var floor:b2Body;
		public var ceiling:b2Body;
		public var leftWall:b2Body;
		public var rightWall:b2Body;
		public var myCL:MyContactListener;
		public var ballLost:Boolean = false;
		public var destroyBall:Boolean = false;
		
		public var m_velocityIterations:int = 10;
		public var m_positionIterations:int = 10;
		public var m_timeStep:Number = 1.0 / 30.0;
		
		public var fpsCounter:FpsCounter;
		public var bricks:Array;
		public var remSprite:Sprite;
		 
		
		public function Breakout(level:uint) {
			
			dbgSprite = Main.m_sprite;
			this.level = level;
			
			
			setFps();
			setUpWorld();
			setUpDebugDraw();
			
			createBoundary();
			createPaddle();
			createBall();
			
			
			gameLevel = new GameLevels(world);
			bricks = gameLevel.createBricks(level);
			trace("Bodies: " + world.GetBodyCount());
		}

		
		private function createBall():void 
		{
			ball = createCircularObject(400, 550, 10);
			ball.SetLinearDamping(0.0);
			ball.GetDefinition().userData = new Ball();
			
			ball.SetBullet(true);
			var sign:int = 0;
			if (Math.random() >= 0.5)
			{
				sign = 1;
			}
			else {
				sign = -1;
			}
			ball.ApplyImpulse(new b2Vec2(sign * Math.random()*6,Math.random()*-6), ball.GetWorldCenter());
		}
		
		private function createCircularObject(x:Number,y:Number,r:uint):b2Body 
		{
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var circleShape:b2CircleShape;
			
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(x/m_physScale,y/m_physScale);
			bodyDef.type = b2Body.b2_dynamicBody;
			circleShape = new b2CircleShape();
			circleShape.SetRadius(r/m_physScale); 
			//bodyDef.userData = new String("ball");
			
			//bodyDef.userData = new Ball();
			//bodyDef.userData.height = r * 2 * 30;
			//bodyDef.userData.width = r * 2 * 30;
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = circleShape;
			fixtureDef.friction = 0;
			fixtureDef.restitution = 1.0;
			fixtureDef.density = 1.0; // static bodies require zero density
			
			//Always create the body and then append the fixture to it.
			//Fixture contains the shape details and other data.
			body = world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			//body.SetFixedRotation(true);
			
			return body;
			
			
		}
		
		
		private function createPaddle():void 
		{
			paddle = createPaddle2(40);
			//paddle = createDynamicObject(400, 580, 80, 10);
			paddle.SetLinearDamping(6);
			
			var paddleJoint:b2PrismaticJoint;
			var paddleJointDef:b2PrismaticJointDef;
			paddleJointDef = new b2PrismaticJointDef();
			paddleJointDef.Initialize(paddle, floor, paddle.GetWorldCenter(), new b2Vec2(1.0, 0.0));
			paddleJointDef.lowerTranslation = -400.0 / m_physScale;
			paddleJointDef.upperTranslation =400.0 / m_physScale;
			paddleJointDef.enableLimit = true;
			
				
			paddleJoint = world.CreateJoint(paddleJointDef) as b2PrismaticJoint;
		}
		
		private function createPaddle2(paddleSize:uint):b2Body
		{
			var size:uint = paddleSize;
			var body:b2Body;
			var bodyDef:b2BodyDef = new b2BodyDef();
			var boxShape:b2PolygonShape = new b2PolygonShape();
					
			var cd1:b2CircleShape = new b2CircleShape();
			cd1.SetRadius(15.0/m_physScale);
			cd1.SetLocalPosition(new b2Vec2( (-30.0 - size) / m_physScale, 0.0 / m_physScale));
				
			var cd2:b2CircleShape = new b2CircleShape();
			cd2.SetRadius(15.0/m_physScale);
			cd2.SetLocalPosition(new b2Vec2((30.0 + size) / m_physScale, 0.0 / m_physScale));
			
			boxShape.SetAsBox((30 + size) / m_physScale, 15 / m_physScale);
						
			bodyDef.type = b2Body.b2_dynamicBody;			
			bodyDef.position.Set(400.0 / m_physScale, 575.0 / m_physScale); //paddle location
			
			body = world.CreateBody(bodyDef);
			body.SetLinearDamping(0.0);
			body.CreateFixture2(cd1, 1.0);
			body.CreateFixture2(cd2, 1.0);
			body.CreateFixture2(boxShape, 1.0);
			
			return body;
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
		
		private function setFps():void 
		{
			fpsCounter =  new FpsCounter();
			fpsCounter.x = 20;
			fpsCounter.y = 20;
			dbgSprite.addChildAt(fpsCounter, 0);
		}
		
		private function createDynamicObject(x:Number,y:Number,hWidth:uint,hHeight:uint):b2Body 
		{
			// Vars used to create bodies
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var boxShape:b2PolygonShape;
			
		
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(x/m_physScale,y/m_physScale);
			bodyDef.type = b2Body.b2_dynamicBody;
			boxShape = new b2PolygonShape();
			boxShape.SetAsBox(hWidth/m_physScale, hHeight/m_physScale);
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = boxShape;
			fixtureDef.friction = 0.0;
			fixtureDef.restitution = 0.2;
			fixtureDef.density = 1.0; // static bodies require zero density
			
			//Always create the body and then append the fixture to it.
			//Fixture contains the shape details and other data.
			body = world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			return body;
			
		}
		
		public function Update():void 
		{
			//trace("game update");
			movePaddle();
			world.DrawDebugData();
			world.Step(m_timeStep, m_velocityIterations, m_positionIterations);
			fpsCounter.update();
			checkCollision();
			controlBall();
			
			//trace("Ball velocity X: "+ball.GetLinearVelocity().x +" Y: "+ ball.GetLinearVelocity().y);
			
			
		}
		
		private function checkCollision():void 
		{
			
			ballLost = myCL.ballHitFloor;
			if (myCL.forDeletion != null)
			{
				remSprite = myCL.forDeletion.GetUserData();
				myCL.forDeletion.SetUserData(null);
				world.DestroyBody(myCL.forDeletion);
				bricks.splice(bricks.indexOf(myCL.forDeletion), 1);
				myCL.forDeletion = null;
			}
			if (bricks.length != 0) Main.msg_text.text = bricks.length.toString();
			
			
			
		}
		
		private function controlBall():void 
		{
			if (!destroyBall)
			{
				if (ball.GetLinearVelocity().y < 0) ball.SetLinearVelocity(new b2Vec2(ball.GetLinearVelocity().x, -BALL_VEL));
				if (ball.GetLinearVelocity().y > 0) ball.SetLinearVelocity(new b2Vec2(ball.GetLinearVelocity().x, BALL_VEL));
				if (Math.abs(ball.GetLinearVelocity().x) > 20 ) 
				{
					if (ball.GetLinearVelocity().x < 0) ball.SetLinearVelocity(new b2Vec2(-20, ball.GetLinearVelocity().y));
					if (ball.GetLinearVelocity().x > 0) ball.SetLinearVelocity(new b2Vec2(20,ball.GetLinearVelocity().y));
				}
				
			//trace(ball.GetLinearVelocity().x +" " + ball.GetLinearVelocity().y);
			}
			
			else {
				ball.SetUserData(null);
				world.DestroyBody(ball);
			}
		}
		
		private function movePaddle():void 
		{
			if (Input.isKeyDown(39)){ // Right Arrow
				//paddle.ApplyImpulse(new b2Vec2(20, 0), paddle.GetWorldCenter());
				paddle.SetLinearVelocity(new b2Vec2(20,0));

			}
			else if (Input.isKeyDown(37)){ // Left Arrow
				//paddle.ApplyImpulse(new b2Vec2(-20, 0), paddle.GetWorldCenter());
				paddle.SetLinearVelocity(new b2Vec2(-20,0));
			}
			
			//For making it tight i.e. no sliding
			//if (Input.isKeyReleased(39) || Input.isKeyReleased(37))
			//{
				//paddle.SetLinearVelocity(new b2Vec2(0,0));
			//}
			


		}
		
		private function createStaticObject(x:Number,y:Number,hWidth:uint,hHeight:uint):b2Body
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
			body = world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			return body;
			
			
			trace("Body's position and body def's position are the same \n" + body.GetPosition().x * m_physScale + "\n" + body.GetPosition().y * m_physScale);
		}
		
		private function setUpDebugDraw():void 
		{
			dbgDraw = new b2DebugDraw();
			dbgDraw.SetSprite(dbgSprite);
			dbgDraw.SetDrawScale(30.0);
			dbgDraw.SetFillAlpha(0.5);
			dbgDraw.SetLineThickness(1.0);
			dbgDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			world.SetDebugDraw(dbgDraw);
			
			
		}
		
		private function setUpWorld():void 
		{
			
			worldAABB.lowerBound.Set(-1000.0, -1000.0);
			worldAABB.upperBound.Set(1000.0, 1000.0);
			
			var gravity:b2Vec2 = new b2Vec2(0.0, 0.0);
			var doSleep:Boolean = false;
			
			world = new b2World(gravity, doSleep);
			myCL = new MyContactListener();
			world.SetContactListener(myCL);
			world.GetGroundBody().SetUserData(new String("ground"));
			world.SetWarmStarting(true);
		}
		
		public function breakoutDeInit():void
		{
			dbgSprite.removeChild(fpsCounter);
		}
			
	}
	
}