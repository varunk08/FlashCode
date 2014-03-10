package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author DWiz
	 */
	public class Game extends Sprite
	{
		private var _numPlayers:int;
		private var _playersArray:Array;
		
		public function Game(numPlayers:int,playersArray:Array) 
		{
			this._numPlayers = numPlayers;
			this._playersArray = playersArray;
			init();
		}
		
		public function init():void
		{
			for ( var i:uint = 0; i < _numPlayers; i++)
			{
				var cycle:CycleGraphic = new CycleGraphic();
				_playersArray[i].cycle = cycle;
				addChild(cycle);
				cycle.x = Math.random() * 500;
				cycle.y = Math.random() * 500;
				
			}
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void 
		{
			
		}
		
	}

}