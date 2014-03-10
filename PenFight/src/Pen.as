package  
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	/**
	 * ...
	 * @author Dwiz
	 */
	public class Pen 
	{
		private var p_angDamping:Number;
		private var P_linearDamping:Number;
		private var p_world:b2World;
		public var p_userName:String;
		public var m_physScale:Number = 30;
		public var body:b2Body;
		private var p_angle:Number;
		public var shootingEnabled:Boolean = false;
		public var linearVelThreshold:Number = 0.5;
		public var angVelThreshold:Number = 0.5;
		public var fallenPen:Boolean = false;
		public var penStatic:Boolean = true;
		public var penPosX:Number;
		public var penPosY:Number;
		
		public function Pen(m_world:b2World)
		{
			p_world = m_world;
		}
		
		public function createPen(x:Number, y:Number, hWidth:Number, hHeight:Number):void
		{
			// Vars used to create bodies
			var bodyDef:b2BodyDef;
			var boxShape:b2PolygonShape;
			
			// Add ground body
			bodyDef = new b2BodyDef();

			boxShape = new b2PolygonShape();
			boxShape.SetAsBox(hWidth / m_physScale, hHeight / m_physScale);
			
			var cd1:b2CircleShape = new b2CircleShape();
			cd1.SetRadius(hHeight / m_physScale);
			
			cd1.SetLocalPosition(new b2Vec2( (-hWidth) / m_physScale, 0.0 / m_physScale));
				
			var cd2:b2CircleShape = new b2CircleShape();
			cd2.SetRadius(hHeight/m_physScale);
			cd2.SetLocalPosition(new b2Vec2((hWidth) / m_physScale, 0.0 / m_physScale));
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = boxShape;
			fixtureDef.friction = 0.50;
			fixtureDef.restitution = 0.1;
			fixtureDef.density = 5; // static bodies require zero density
			bodyDef.type = b2Body.b2_dynamicBody;
			
			//Always create the body and then append the fixture to it.
			//Fixture contains the shape details and other data.
			body = p_world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			body.CreateFixture2(cd1, 5);
			body.CreateFixture2(cd2, 5);
			body.SetPosition(new b2Vec2(x / m_physScale, y / m_physScale));
			body.SetBullet(true);
		}
		
		public function setAngDamping(value:Number):void 
		{
			p_angDamping = value;
			body.SetAngularDamping(p_angDamping);
		}
		
		public function setLinearDamping(value:Number):void 
		{
			P_linearDamping = value;
			body.SetLinearDamping(P_linearDamping);
		}
		
		public function setAngle(value:Number):void 
		{
			p_angle = value;
			body.SetAngle(p_angle/180 * Math.PI);
		}
		
		public function penUpdate():void
		{
			penPosX = this.body.GetPosition().x;
			penPosY = this.body.GetPosition().y;
			if ((this.body.GetAngularVelocity() < angVelThreshold) && (this.body.GetAngularVelocity() > -angVelThreshold))
			{
				this.body.SetAngularVelocity(0);
			}
			
			if (this.body.GetLinearVelocity().Length() < linearVelThreshold)
			{
				this.body.SetLinearVelocity(new b2Vec2());
			}
			if (this.body.GetAngularVelocity() == 0 && this.body.GetLinearVelocity().Length() == 0) {
				penStatic = true;
			}
			else penStatic = false;
			
			//trace("ang vel:" + this.body.GetAngularVelocity());
			//trace("linear vel:" + penArray[0].body.GetLinearVelocity().x);
			//trace("linear vel:" + penArray[0].body.GetLinearVelocity().y);
			//trace("linear vel:" + this.body.GetLinearVelocity().Length());
		}
	}

}