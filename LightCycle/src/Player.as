package  
{
	/**
	 * ...
	 * @author DWiz
	 */
	public class Player extends Tile
	{
		public var curGridX:uint;
		public var curGridY:uint;
		public var currentDirection:uint = 0;
		public var tailGridX:uint;
		public var tailGridY:uint;
		public var prevColor:uint = GridGame.COLOR_TILE;
		public var dead:Boolean = false;
		public var edgeCollided:Boolean = false;
		private var playerColor:uint;
		private var p_tileWidth:Number;
		
		
		public function Player(width:Number = 10,color:uint=0xff0000) 
		{
			this.playerColor = color;
			this.p_tileWidth = width;
			super(width, color);
		}
		
		public function adjustTail():void
		{
			tailGridX = curGridX;
			tailGridY = curGridY;
		}
		
	}

}