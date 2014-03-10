package  
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author DWiz
	 */
	public class Tile extends Sprite
	{
		private var side:Number;
		private var color:uint;
		
		
		public function Tile(side:Number= GridGame.tileWidth,color:uint=GridGame.COLOR_TILE) 
		{
			this.color = color;
			this.side = side;
			
			graphics.beginFill(color);
			graphics.drawRect(0, 0, side, side);
			graphics.endFill();
		
		}
		
		public function setColor(color:uint):void
		{
			graphics.clear();
			graphics.beginFill(color);
			graphics.drawRect(0, 0, side, side);
			graphics.endFill();
			this.color = color;
		}
		
		public function getColor():uint
		{
			return this.color;
		}
		
	}

}