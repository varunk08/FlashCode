package  
{
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;
	import flash.display.Sprite;
	import flash.display.Stage;
	/**
	 * ...
	 * @author DWiz
	 */
	public class Registry 
	{
		static public var r_stage:Stage;
		static public var r_world:b2World;
		static public const r_physScale:Number = 30.0;
		static public var r_effectsSprite:Sprite;
		static public var r_ship:b2Body;
		
		public function Registry() 
		{
			
		}
		
	}

}