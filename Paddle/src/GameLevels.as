package  
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	/**
	 * ...
	 * @author Dwiz
	 */
	public class GameLevels
	{
		private var currentLevel:uint;
		private var m_physScale:uint = 30;
		private var m_world:b2World;
		
		public function GameLevels(world:b2World)
		{
			this.m_world = world;
		}
		
		public function createBricks(curLevel:uint):Array
		{
			
			var bricks:Array = new Array();
			var x:int = 0;
			var y:int = 0;
			switch(curLevel)
			{
			case 1:
					//simple line
					x = 130;
					y = 150;
					for (var i3:uint = 0; i3 < 10; i3++)
					{
						bricks.push(createStaticObject(x + 60 *i3 ,y,20,10));
					}
					break;
			case 2:
					//sin wave
					/*******
					 * In Radians
					 * sin(0) = 0;
					 * sin(n * pi) = 0;
					 * sin(45 degrees) = sin(0.7853 radians) = 0.707 = 1/root2
					 * 
					 * ******/
					x = 150;
					y = 150;
					var ix1:Number = x;
					var iy1:Number = y;
					for (var i1:Number = 0; i1 <= 2 * Math.PI; i1 += Math.PI/4 )
					{
						iy1 = y + (Math.sin(i1) * 100);
						bricks.push(createStaticObject(ix1, iy1, 20, 10));
						ix1 += 60;
					}
					break;
					
			case 3:
					//circle
					x = 400;
					y = 200;
					var ix4:Number = x;
					var iy4:Number = y;
					for (var i4:Number = 0; i4 <= (2 * Math.PI);i4 += Math.PI/8)
					{
						ix4 = x + (Math.sin(i4) * 150);
						iy4 = y + (Math.cos(i4) * 150);
						bricks.push(createStaticObject(ix4, iy4, 20, 10));
					}
					break;
			case 4:
					//double line
					x = 130;
					y = 150;
					var ix:Number = x;
					var iy:Number = y;
					for (var i2:uint = new uint(); i2 < 30; i2++) {
						
						if (i2 < 10)
						{
							ix = x + 60 * i2;
							bricks.push(createStaticObject(ix, iy , 20, 10));
						}
						if (i2 > 9 && i2 < 20) {
								ix = x + 60 * (i2-10);
								iy = y + 30;
								bricks.push(createStaticObject(ix, iy, 20, 10));
							}
						//if (i2 > 19)
						//{
							//ix = x +60 * (i2 - 20);
							//iy = y + 60;
							//bricks.push(createStaticObject(ix,iy,20,10));
						//}
					}
					break;		
					
			
			default:
					break;		
			}			
			return bricks;
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
			fixtureDef.friction = 0.0;
			fixtureDef.restitution = 0.2;
			fixtureDef.density = 10; // static bodies require zero density
			bodyDef.type = b2Body.b2_kinematicBody;
			//Always create the body and then append the fixture to it.
			//Fixture contains the shape details and other data.
			body = m_world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			return body;
			
			
			//trace("Body's position and body def's position are the same \n" + body.GetPosition().x * m_physScale + "\n" + body.GetPosition().y * m_physScale);
		}
		
	}

}