package  
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;
	
	/**
	 * ...
	 * @author Dwiz
	 */
	public class PFPlayer 
	{
		//player type: 1=participant 2=spectator
		private var type:int;
		
		static public const PARTICIPANT:int = 1;
		static public const SPECTATOR:int = 2;
		static public const READY:String = "Ready";
		static public const NOT_READY:String = "NotReady";
		static public const TYPE_MYSELF:String = "Myself"; //for setting legal body in shooting handler
		static public const TYPE_OPPONENT:String = "Opponent";
		
		public var playerDesig:int;  //random number for deciding order --default num means not ready
		public var myTurn:Boolean = false;
		public var playerState:String; //ready or not ready
		public var userName:String;
		public var peerID:String;
		public var pen:Pen;
		public var playerDraw:int; //player 1,2,3 or 4
		public var xPos:Number;
		public var yPos:Number;
		public var playerType:String; // myself or opponent for controlling shooting
		public var penAngle:Number;
		
		public function PFPlayer(name:String) 
		{
			this.userName = new String(name);
			this.peerID = new String();
			this.playerState = new String();
		}
		
		public function createPlayerPen(m_world:b2World):void 
		{
			pen = new Pen(m_world);
			switch(playerDraw)
			{
				case 1:
					pen.createPen(100, 300, 50, 5);
					pen.setAngle(0);
					break;
				case 2:
					pen.createPen(400, 100, 50, 5);
					pen.setAngle(90);
					break;
				case 3:
					pen.createPen(700, 300, 50, 5);
					pen.setAngle(0);
					break;
				case 4:
					pen.createPen(400, 500, 50, 5);
					pen.setAngle(90);
					break;
			}
			
			pen.setAngDamping(1.2);
			pen.setLinearDamping(1.6);
		}
		
		public function createUserData():void 
		{
			pen.body.SetUserData(new PenBlue());
			pen.body.GetUserData().width = 110;
			pen.body.GetUserData().height = 20;
		}
		
		//used to decide 
		public function playerReady(self:Boolean):void
		{
			if (self) {
					this.playerType = new String(TYPE_MYSELF);
					this.playerDesig = Math.ceil(1000 * Math.random() + Math.random() * 100 - Math.random() * 10); //for deciding who plays what turn
			}
			else this.playerType = new String(TYPE_OPPONENT);
			
			playerState = PFPlayer.READY;
		}
		
		public function setPosition(x:Number,y:Number):void
		{
			pen.body.SetPosition(new b2Vec2(x / PFGame.m_physScale, y / PFGame.m_physScale));
		}
		
		public function setAngle(ang:Number):void 
		{
			pen.body.SetAngle(ang / 180 * Math.PI);
		}
		
		public function getPenPositionInfo():Object
		{
			//xPos = pen.body.GetPosition().x;
			xPos = pen.penPosX;
			yPos = pen.penPosY;
			//yPos = pen.body.GetPosition().y;
			penAngle = pen.body.GetAngle();
			var posObj:Object = new Object();
			posObj.xpos = xPos;
			posObj.ypos = yPos;
			posObj.angle = penAngle;
			return posObj;
		}
		
		public function setPenPosition(x:Number, y:Number, angle:Number):void
		{
			pen.body.SetPosition(new b2Vec2(x, y));
			pen.body.SetAngle(angle);
		}
	}

}