package  
{
	
	import flash.display.MovieClip;
	import flash.filters.DropShadowFilter;
	/**
	 * ...
	 * @author Jay aka Dragon Lord
	 */
	public class Lighting 
	{
		private var mc:MovieClip;
		private const hw:Number = 400;
		private const hh:Number = 300;
		public function Lighting(movieClip:MovieClip) 
		{
			mc = movieClip;
		}
		
		public function update():void
		{
			
			
			
			// difference in total distance
			var dt:Number;
			
			//difference in x and y
			
			var dx:Number;
			var dy:Number;
			
			//Calculating the distance using the standard distance formula
			
			dx = hw - mc.x;
			dy = hh - mc.y;
			
			dt = Math.sqrt((dx * dx) + (dy * dy));
			
			//determine the angle of the mc wrt the center of the stage
			/*
			 * Im adding 180 degrees to the angle returned to get the shadow
			 * in the correct quadrant. W/O it the shadow is displaced by a
			 * phase angle of 180. U can either add or subtract it 
			 */
			var filterAngle:Number =  Math.atan2(dy, dx) * 180 / Math.PI + 180;
			
			//Now apply the new values in the filter array
			var dS:DropShadowFilter = new DropShadowFilter();
			dS.distance = (dt/500) * 30; // max distance of shadow is 30px and so, at the farthest distance from the center is where the shadow distance is maximum
			dS.strength= dt/500 * .8; //max strength is limited to 80%
			dS.blurX = 10;
			dS.blurY = 10;
			dS.quality = 3; //applying the filter three times. 
			dS.angle = filterAngle;
			//apply the filter
			mc.filters = new Array(dS);		}
	}

}