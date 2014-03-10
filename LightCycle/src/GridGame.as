package 
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author DWiz
	 */
	//[SWF (width="700",height="500",backgroundColor="0x000000")]
	public class GridGame extends Sprite 
	{
		static public const slowness:Number = 0.05;
		static public const tileGap:uint = 1;
		static public const tileWidth:uint = 5;
		static public const COLOR_TILE:uint = 0x111111;
		static public const COLOR_TAIL:uint = 0xffff00;
		static public const COLOR_PLAYER:Array = new Array(0xff0000,0x00ff00,0x0000ff);
		
		
				
		private var nWidth:int;
		private var nHeight:int;
		private var theGrid:Vector.<Vector.<Tile>> = new Vector.<Vector.<Tile>>();
		private var players:Vector.<Player>;
		//private var curGridX:uint;
		//private var curGridY:uint;
		private var timer:Timer;
		private var curDirection:uint;
		private var tailVec:Vector.<Tile>;
		//private var prevColor:uint;
		private var numPlayers:uint;
		
		public function GridGame(numPlayers:uint):void 
		{
			this.numPlayers = numPlayers;
			trace(COLOR_PLAYER);
			if (stage)
			{
				//stage.scaleMode = StageScaleMode.NO_SCALE;
				//stage.align = StageAlign.LEFT;
				init();
			}
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			nWidth = stage.stageWidth / (tileGap + tileWidth);
			//nWidth = 800 / (tileGap + tileWidth);
			//nHeight = 600 / (tileGap + tileWidth);
			nHeight = stage.stageHeight / (tileGap + tileWidth);
			createGrid();
			createPlayer(numPlayers);
			
			createTimer();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);

			
			
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function createTimer():void 
		{
			timer = new Timer(slowness * 1000);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		private function onTimer(e:TimerEvent):void 
		{
			for each(var plr:Player in players)
			{
				plr.adjustTail();
				moveInGrid(plr, plr.currentDirection);
				//adjustTail();
				theGrid[plr.tailGridX][plr.tailGridY].setColor(COLOR_TAIL);
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			//trace(e);
			switch(e.keyCode)
			{
				case 37:players[0].currentDirection = 1;
						break;
				case 38:
						players[0].currentDirection = 2;
						break;
				case 39:
						players[0].currentDirection = 3;
						break;
				case 40:
						players[0].currentDirection = 4;
						break;
				case 65:players[1].currentDirection = 1;
						break;
				case 87:
						players[1].currentDirection = 2;
						break;
				case 68:
						players[1].currentDirection = 3;
						break;
				case 83:
						players[1].currentDirection = 4;
						break;
				default: break;
			}
			
			if (numPlayers == 3) 
			{
				switch(e.keyCode)
				{
					case 74: players[2].currentDirection = 1;
							break;
					case 73:
							players[2].currentDirection = 2;
							break;
					case 76:
							players[2].currentDirection = 3;
							break;
					case 75:
							players[2].currentDirection = 4;
							break;
					default: break;
				}	
			}
			
		}
		// 1-left 2-up 3-right 4-down
		private function moveInGrid(plyr:Player, dir:Number):void 
		{
			if(!plyr.dead){
			switch (dir)
			{
				//left
				case 1: if (plyr.curGridX == 0)
						{
							//trace("parked");
							plyr.edgeCollided = true;
							break;
						}
						else {
							plyr.curGridX--;
							plyr.prevColor = theGrid[plyr.curGridX][plyr.curGridY].getColor();						
							plyr.x = theGrid[plyr.curGridX][plyr.curGridY].x;
							
						}
						break;
				//up
				case 2: if (plyr.curGridY == 0)
						{
							//trace("parked top");
							plyr.edgeCollided = true;
							break;
						}
						else {
							plyr.curGridY--;							
							plyr.prevColor = theGrid[plyr.curGridX][plyr.curGridY].getColor();							
							plyr.y = theGrid[plyr.curGridX][plyr.curGridY].y;
							
						}
						break;
				//right
				case 3: if (plyr.curGridX == nWidth - 1)
						{
							//trace("parked right");
							plyr.edgeCollided = true;
							break;
						}
						else {
							plyr.curGridX++;
							plyr.prevColor = theGrid[plyr.curGridX][plyr.curGridY].getColor();							
							plyr.x = theGrid[plyr.curGridX][plyr.curGridY].x;							
						}
						break;
				//down
				case 4: if (plyr.curGridY == nHeight - 1)
						{
							//trace("parked bottom");
							plyr.edgeCollided = true;
							break;
						}
						else {
							plyr.curGridY++;
							plyr.prevColor = theGrid[plyr.curGridX][plyr.curGridY].getColor();							
							plyr.y = theGrid[plyr.curGridX][plyr.curGridY].y;							
						}
						break;
						
				default: break;
			}
			}
		}
		
		private function onMouseOver(e:MouseEvent):void 
		{
			if (e.relatedObject is Tile)
			{
				e.target.setColor(0xff0000);
			}
		}
		
		private function createGrid():void 
		{
		
			for (var i:uint = 0; i < nWidth; i++)
			{
				theGrid[i] = new Vector.<Tile>();
				for (var j:uint = 0; j < nHeight; j++)
				{
					var tile:Tile = new Tile(GridGame.tileWidth,GridGame.COLOR_TILE);
					addChild(tile);
					tile.y = j * (tileGap + tileWidth);
					tile.x = i * (tileGap + tileWidth);
					theGrid[i][j] = tile;
				}
				
			}
			
		}
		
		private function createPlayer(numPlyrs:uint):void
		{
			trace("Num Players: " + numPlyrs);
			players = new Vector.<Player>();
			//tailVec = new Vector.<Tile>();
			for (var i:uint = 0; i < numPlyrs; i++)
			{
						players[i] = new Player(GridGame.tileWidth, GridGame.COLOR_PLAYER[i]);
						//trace(players[i].width);
						var ranGridX:uint = Math.floor(Math.random() * nWidth);
						var ranGridY:uint = Math.floor(Math.random() * nHeight);
						var ran:Tile = theGrid[ranGridX][ranGridY];
						//trace(ran);
						players[i].curGridX = players[i].tailGridX = ranGridX;
						players[i].curGridY = players[i].tailGridY = ranGridY;
						
						addChild(players[i]);
						players[i].x = ran.x;
						players[i].y = ran.y;
						//trace(players[i].curGridX  +" " + players[i].curGridY);
						
						ran = null;
			}
					
				
		}
		
		public function onEnterFrame(e:Event):void
		{
			
			for (var i:uint; i < players.length;i++)
			{
				
				if ((players[i].prevColor != GridGame.COLOR_TILE || players[i].edgeCollided) && !players[i].dead)
				{
					players[i].setColor(0x000000);
					players[i].dead = true;
					
				}
			}
		}
		
	}
	
}