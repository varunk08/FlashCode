package  
{
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	/**
	 * ...
	 * @author DWiz
	 */
	public class Terrain 
	{
		private var _world:b2World;
		public function Terrain(world:b2World) 
		{
			this._world = world;
		}
		
		public function generateTerrain(vertexArr:Array):void
		{
			var body:b2Body;
			var vertices:Array = vertexArr;

			vertices = convertToVectors(vertices);
			for (var i:uint; i < vertices.length; i++)
			{
				var bodyDef:b2BodyDef = new b2BodyDef();
				bodyDef.type = b2Body.b2_staticBody;
				var polydef:b2PolygonShape = new b2PolygonShape();
				
				polydef.SetAsArray(vertices[i]);
				body = _world.CreateBody(bodyDef);
				body.CreateFixture2(polydef);
			}
		}
		
		private function convertToVectors(verticesArray:Array):Array
		{
			trace("function "+verticesArray);
			var polys:Array = [];
			for (var i:uint = 0; i < verticesArray.length; i++)//each polygon
			{
				
				var vertex:Array = []; 
				for (var j:uint = 0; j < verticesArray[i].length; j++)//each vertex
				{
					vertex[j] = new b2Vec2(verticesArray[i][j][0] / MoonLander._physScale,verticesArray[i][j][1] / MoonLander._physScale);
					
				}
				polys[i] = vertex;
			}
			trace(polys);
			return polys;
		}
		
	}

}