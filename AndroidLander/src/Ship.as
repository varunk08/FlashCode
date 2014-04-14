package
{
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author DWiz
	 */
	public class Ship extends Sprite
	{
		private var _world:b2World;
		private var _physScale:Number;
		
		public function Ship(world:b2World) 
		{
			this._world = world;
			this._physScale = MoonLander._physScale;
		}
		
		public function createShip():b2Body
		{
			
			var body:b2Body;
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type = b2Body.b2_dynamicBody;
			bodyDef.linearDamping = 0.5;
			bodyDef.angularDamping = 0.5;
			var hull:b2PolygonShape = new b2PolygonShape();
			var leftLeg:b2PolygonShape = new b2PolygonShape();
			var rightLeg:b2PolygonShape = new b2PolygonShape();
			var hullArray:Array = [];
			hullArray[0] = new b2Vec2(8 / _physScale, -8 / _physScale);
			hullArray[1] = new b2Vec2(16 / _physScale, 8 / _physScale);
			hullArray[2] = new b2Vec2( -16 / _physScale, 8 / _physScale);
			hullArray[3] = new b2Vec2( -8 / _physScale, -8 / _physScale);
			hull.SetAsArray(hullArray);
			
			leftLeg.SetAsOrientedBox(3 / _physScale, 6 / _physScale, new b2Vec2(8 / _physScale, 8 / _physScale));
			rightLeg.SetAsOrientedBox(3 / _physScale, 6 / _physScale, new b2Vec2(-8 / _physScale, 8 / _physScale));
			body = _world.CreateBody(bodyDef);
			body.CreateFixture2(hull, 1);
			body.CreateFixture2(leftLeg, 1);
			body.CreateFixture2(rightLeg, 1);
			return body;
		}
	}

}