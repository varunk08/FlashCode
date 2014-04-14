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
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Dwiz
	 */
	public class SpaceDock_Shooting
	{
		static public const STRIKE_FORCE:uint =2;
		public var effectSprite:Sprite;
		private var s_world:b2World;
		private var s_mousePVec:b2Vec2 = new b2Vec2();
		private var s_underMouse:b2Body;
		private var mouseXPhys:Number;
		private var mouseYPhys:Number;
		private var m_physScale:int = 30;
		private var m_targetX:int;
		private var m_targetY:int;

		private var mousePVec:b2Vec2;

		
		
		private var mousePressed:Boolean = false;
		private var spaceBarPressed:Boolean = false;
		
		
		public function SpaceDock_Shooting() 
		{
			effectSprite = Registry.r_effectsSprite;
			effectSprite.graphics.lineStyle(1, 0xcc3300, 1);
			s_world = Registry.r_world;
			Registry.r_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			Registry.r_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			Registry.r_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Registry.r_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
		}
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
			spaceBarPressed = false;
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.SPACE)
			{
				spaceBarPressed = true;
				
			}
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			mousePressed = false;
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			mousePressed = true;
		}
		
		public function Update():void 
		{
		
			mouseReactions();
			keyboardReactions();
		}
		
		private function keyboardReactions():void 
		{
			if (spaceBarPressed)
			{
				var ang:Number = Registry.r_ship.GetAngle();
				var thrust:b2Vec2 = new b2Vec2( -STRIKE_FORCE, 0);
				var rx:Number = Math.cos(ang) * thrust.x - Math.sin(ang) * thrust.y;
				var ry:Number = Math.cos(ang) * thrust.y + Math.sin(ang) * thrust.x;
				thrust.Set(rx, ry);
				Registry.r_ship.ApplyImpulse(thrust, Registry.r_ship.GetWorldCenter());
			}
		}
		
		private function mouseReactions():void 
		{

			s_underMouse = GetBodyAtMouse(false);
			//trace(s_underMouse);
			mouseXPhys = Registry.r_stage.mouseX / Registry.r_physScale;
			mouseYPhys = Registry.r_stage.mouseY / Registry.r_physScale;
			
			
			if (mousePressed && s_underMouse!=null) 
				{
					
					var localVec:b2Vec2 = s_underMouse.GetLocalPoint(new b2Vec2(mouseXPhys, mouseYPhys));
					m_targetX = s_underMouse.GetWorldPoint(s_underMouse.GetLocalPoint(new b2Vec2(mouseXPhys, mouseYPhys)) ).x;// *  Registry.r_physScale;;
					m_targetY = s_underMouse.GetWorldPoint(s_underMouse.GetLocalPoint(new b2Vec2(mouseXPhys, mouseYPhys)) ).y;// *  Registry.r_physScale;;
					
					var impVec:b2Vec2;
					//left side of body
					if (localVec.x < 0)
					{
						//left side top
						if(localVec.y < 0)
						{
							trace("left top");
							impVec = new b2Vec2(0, STRIKE_FORCE);
						}
						
						//left side bottom
						else {
							trace("left bot");
							impVec = new b2Vec2(0, -STRIKE_FORCE);
						}
					}
					
					//right side of body
					else if(localVec.x > 0)
					{
						//right side top
						if(localVec.y < 0)
						{
							trace("right top");
							impVec = new b2Vec2(0, STRIKE_FORCE);
						}
						
						//left side bottom
						else {
							trace("right bot");
							impVec = new b2Vec2(0, -STRIKE_FORCE);
						}
					}
					
					var x1:Number = Math.cos(s_underMouse.GetAngle()) * impVec.x - Math.sin(s_underMouse.GetAngle()) * impVec.y;
					var y1:Number = Math.cos(s_underMouse.GetAngle()) * impVec.y + Math.sin(s_underMouse.GetAngle()) * impVec.x;
					impVec.Set(x1, y1);
					
					effectSprite.graphics.moveTo(m_targetX*Registry.r_physScale, m_targetY*Registry.r_physScale);
					var tx:Number = m_targetX * Registry.r_physScale- impVec.x*10;
					var ty:Number = m_targetY * Registry.r_physScale - impVec.y*10;
					effectSprite.graphics.lineTo(tx, ty);
					trace(s_underMouse.GetAngle() *180/Math.PI);
					s_underMouse.ApplyImpulse(impVec,new b2Vec2(m_targetX, m_targetY));
						
					trace("Tx: " + m_targetX);
					trace("Ty: " + m_targetY);
					//trace("Lx: " + s_underMouse.GetLocalPoint(new b2Vec2(mouseXPhys, mouseYPhys)).x * Registry.r_physScale);
					//trace("Ly: " + s_underMouse.GetLocalPoint(new b2Vec2(mouseXPhys, mouseYPhys)).y * Registry.r_physScale);
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