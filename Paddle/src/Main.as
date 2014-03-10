package  
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import Input;

	/**
	 * ...
	 * @author Dwiz
	 */
	[SWF(width="800",height="600",backgroundColor="0x000000" )]
	public class Main extends Sprite
	{
		public var game:Breakout;
		public var m_input:Input;
		public var left:Boolean;
		public var right:Boolean;
		public var curLevel:uint = 1;
		static public var m_sprite:Sprite;
		public var level_txt:TextField;
		public var instructions_text:TextField;
		static public var msg_text:TextField;
		private var ballsprite:Ball;
		public var brickSprite:BrickGfx;
		public var finalLevel:uint = 4;
		private var paddleSprite:PaddleGfx;
		private var bgSky:BG_Graphics;
		
		
		public function Main() 
		{
			//trace("main");
			m_sprite = new Sprite();
			addChild(m_sprite);
			
			m_input = new Input(m_sprite);
			
			init();
		}

		
		private function init():void 
		{
			//trace("init");
			showMsgText(curLevel);
			game = new Breakout(curLevel);
			setupGraphics();
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			
		}
		
		private function setupGraphics():void 
		{
			bgSky = new BG_Graphics();
			bgSky.x = 400;
			bgSky.y = 300;
			addChildAt(bgSky, 0);
			
			//ball
			ballsprite = new Ball();
			ballsprite.width = 2 * 10;
			ballsprite.height = 2 * 10;
			game.ball.SetUserData(ballsprite);
			addChild(game.ball.GetUserData());

			//boundary
			game.ceiling.SetUserData(new BoundaryGfx());
			game.ceiling.GetDefinition().userData.width = 800;
			game.ceiling.GetDefinition().userData.height = 20;
			addChild(game.ceiling.GetUserData());
			
			//bricks
			for (var i:uint = 0; i < game.bricks.length; ++i)
			{
				game.bricks[i].SetUserData(new BrickGfx());
				game.bricks[i].GetDefinition().userData.width = 40;
				game.bricks[i].GetDefinition().userData.height = 20;
				addChild(game.bricks[i].GetUserData());
			}
			
			//paddle
			paddleSprite = new PaddleGfx();
			paddleSprite.width = 170;
			paddleSprite.height = 30;
			game.paddle.SetUserData(paddleSprite);
			addChild(game.paddle.GetUserData());
		}
		
	
		private function update(e:Event):void 
		{
			//trace("main update");
			updateGraphics();
			game.Update();
			checkGameOver();
			Input.update();

		}
		
		private function updateGraphics():void 
		{
			//paddle
			paddleSprite.x = game.paddle.GetPosition().x * 30;
			paddleSprite.y = game.paddle.GetPosition().y * 30;
			
			//ball
			ballsprite.x = game.ball.GetPosition().x * 30;
			ballsprite.y = game.ball.GetPosition().y * 30;
			ballsprite.rotation = game.ball.GetAngle() * (180 / Math.PI);
			
			//boundary
			game.ceiling.GetUserData().x = game.ceiling.GetPosition().x * 30;
			game.ceiling.GetUserData().y = game.ceiling.GetPosition().y * 30; 
			
			//bricks
			for (var i:uint = 0; i < game.bricks.length; ++i)
			{
				game.bricks[i].GetUserData().x = game.bricks[i].GetPosition().x * 30;
				game.bricks[i].GetUserData().y = game.bricks[i].GetPosition().y * 30;
				game.bricks[i].GetUserData().rotation = game.bricks[i].GetAngle() * (180/Math.PI);
				
			}
			
			//removing hit bricks
			if(game.remSprite != null)	
			{
				//trace("brick parent " + game.remSprite.parent);
				this.removeChild(DisplayObject(game.remSprite));
				game.remSprite = null;
			}

		}
		
		private function checkGameOver():void 
		{
			if(game.ballLost)
			{
				msg_text.text = "Play Another Game? (y/n)";
				if (ballsprite.parent) //ballsprite.parent.removeChild(DisplayObject(ballsprite));
				this.removeChild(DisplayObject(ballsprite));
				
				game.destroyBall = true;
				
										
			if (Input.isKeyDown(89))
			{
				//instructions_text.text = "yes";
				//removeEventListener(Event.ENTER_FRAME, update);
				this.deInit();
				game.breakoutDeInit();
				this.init();
				
			}
			else if (Input.isKeyDown(78))
			{
				instructions_text.text = "Sad";
			}
			}
			
			if (game.bricks.length == 0)
			{
				if (curLevel != finalLevel)
				{
					curLevel++;
					if (ballsprite.parent) //ballsprite.parent.removeChild(DisplayObject(ballsprite));
					this.removeChild(DisplayObject(ballsprite));
					this.deInit();
					game.breakoutDeInit();
					this.init();
				}
				else {

					if (ballsprite.parent) //ballsprite.parent.removeChild(DisplayObject(ballsprite));
					this.removeChild(DisplayObject(ballsprite));
					game.destroyBall = true;
					this.deInit();
				}
				
			}
		}
		
		private function deInit():void 
		{
			trace("num children "+this.numChildren);
			for (var i:uint = 0; i < this.numChildren; i++)
			{

					if (this.getChildAt(i) is TextField) {
						this.removeChildAt(i);
						i--;
					}
					if (this.getChildAt(i) is BrickGfx) {
							//trace(this.getChildAt(i));
							this.removeChildAt(i);
							i--;
					}
					if (this.getChildAt(i) is PaddleGfx) {
						this.removeChildAt(i);
						i--;
					}

			}
			
		}
		
		private function showMsgText(curlevel:uint):void 
		{
			//Instructions Text
			instructions_text = new TextField();
			
			var instructions_text_format:TextFormat = new TextFormat("Arial", 16, 0xffffff, false, false, false);
			instructions_text_format.align = TextFormatAlign.RIGHT;
			
			instructions_text.defaultTextFormat = instructions_text_format;
			instructions_text.x = 300;
			instructions_text.y = 5;
			instructions_text.width = 495;
			instructions_text.height = 61;
			instructions_text.mouseEnabled = false;
			instructions_text.text = "Welcome to Breakout..\n'Left'/'Right' arrows to control paddle.";
			addChild(instructions_text);
			
			msg_text = new TextField();
			
			var msg_text_format:TextFormat = new TextFormat("Arial", 30, 0x00ccff,true, false, false);
			msg_text_format.align = TextFormatAlign.JUSTIFY;
			
			msg_text.defaultTextFormat = msg_text_format;
			msg_text.x = 400;
			msg_text.y = 50;
			msg_text.width = 495;
			msg_text.height = 61;
			msg_text.mouseEnabled = false;
			msg_text.text = "New Game!";
			addChild(msg_text);
			
			level_txt = new TextField();
			var levelTxt_format:TextFormat = new TextFormat("Arial", 20, 0xff0022,true, false, false);
			levelTxt_format.align = TextFormatAlign.LEFT;
			
			level_txt.defaultTextFormat = levelTxt_format;
			level_txt.x = 200;
			level_txt.y = 25;
			level_txt.width = 100;
			level_txt.height = 25;
			level_txt.mouseEnabled = false;
			level_txt.text = "Level: " + curlevel;
			addChild(level_txt);
		}
		

		
	}

}