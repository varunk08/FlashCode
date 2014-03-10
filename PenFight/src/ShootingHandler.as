package  
{
	import Box2D.Collision.b2AABB;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;
	import flash.display.CapsStyle;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Dwiz
	 */
	public class ShootingHandler 
	{
		static public const STRIKE_FORCE:uint = 30;
		public var effectSprite:Sprite;
		private var s_world:b2World;
		private var s_mousePVec:b2Vec2 = new b2Vec2();
		private var s_underMouse:b2Body;
		private var mouseXPhys:Number;
		private var mouseYPhys:Number;
		private var m_physScale:int = 30;
		private var enableDraw:Boolean = false;
		private var m_targetX:int;
		private var m_targetY:int;
		private var dist:b2Vec2;
		private var mousePVec:b2Vec2;
		private var tempBody:b2Body;
		public var legalBody:b2Body;
		public var shootEvtDispatch:EventDispatcher = new EventDispatcher();
		public var shotFired:Object;
		public var doneShooting:Boolean = false;
		
		public function ShootingHandler(world:b2World,m_effectSprite:Sprite) 
		{
			effectSprite = m_effectSprite;
			//this.pArray = penArray;
			shotFired = new Object();
			s_world = world;
		}
		
		public function Update():void 
		{
			mouseReactions();
		}
		
		private function mouseReactions():void 
		{
			effectSprite.graphics.clear();
			effectSprite.graphics.lineStyle(2, 0xcc0000,1,false,"normal",CapsStyle.ROUND);

			s_underMouse = GetBodyAtMouse(false);
			//trace(s_underMouse);
			mouseXPhys = Input.mouseX / m_physScale;
			mouseYPhys = Input.mouseY / m_physScale;
			
			//trace(Input.mousePressed);
			if (Input.mousePressed && s_underMouse) 
				{
					if ((s_underMouse == legalBody) && (s_underMouse.GetType() == b2Body.b2_dynamicBody) && (s_underMouse.GetAngularVelocity() < 0.1) && (s_underMouse.GetLinearVelocity().Length() < 0.1) )
					{
						
						tempBody = s_underMouse;
						m_targetX = s_underMouse.GetWorldPoint(s_underMouse.GetLocalPoint(new b2Vec2(mouseXPhys, mouseYPhys)) ).x * m_physScale;
						m_targetY = s_underMouse.GetWorldPoint(s_underMouse.GetLocalPoint(new b2Vec2(mouseXPhys, mouseYPhys)) ).y * m_physScale;
						enableDraw = true;

					}
				}
				if (Input.mouseDown && enableDraw)
				{
						effectSprite.graphics.moveTo(m_targetX  , m_targetY);
						effectSprite.graphics.lineTo(effectSprite.mouseX,effectSprite.mouseY);
						
						dist = new b2Vec2(Math.round(mouseXPhys - m_targetX/m_physScale), Math.round(mouseYPhys - m_targetY/m_physScale));
						dist.Multiply(STRIKE_FORCE);
						
				}		
				else if (enableDraw)
						{
							effectSprite.graphics.clear();
							tempBody.ApplyImpulse(dist.GetNegative(), new b2Vec2(m_targetX / m_physScale, m_targetY / m_physScale));
							trace("I fired");
							enableDraw = false;
							shotFired.distx = dist.x;
							shotFired.disty = dist.y;
							shotFired.pointx = m_targetX;
							shotFired.pointy = m_targetY;
							var evt:Event = new Event("ShotFired",true);
							shootEvtDispatch.dispatchEvent(evt);
						//after shooting
						doneShooting = true;
						}
				
		

		}
		
		//======================
		// GetBodyAtMouse
		//======================
		public function GetBodyAtMouse(includeStatic:Boolean = false):b2Body {
			// Make a small box.
			s_mousePVec.Set(mouseXPhys, mouseYPhys);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(mouseXPhys - 0.001, mouseYPhys - 0.001);
			aabb.upperBound.Set(mouseXPhys + 0.001, mouseYPhys + 0.001);
			var body:b2Body = null;
			var fixture:b2Fixture;
			
			// Query the world for overlapping shapes.
			function GetBodyCallback(fixture:b2Fixture):Boolean
			{
				var shape:b2Shape = fixture.GetShape();
				if (fixture.GetBody().GetType() != b2Body.b2_staticBody || includeStatic)
				{
					var inside:Boolean = shape.TestPoint(fixture.GetBody().GetTransform(), s_mousePVec); 
					if (inside)
					{
						body = fixture.GetBody();
						return false;
					}
				}
				return true;
			}
			s_world.QueryAABB(GetBodyCallback, aabb);
			return body;
		}
	}

}