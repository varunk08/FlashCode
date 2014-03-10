package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	/**
	 * ...
	 * @author DWiz
	 */
	
	[SWF (width='600', height='480', backgroundColor='0x000000')]
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			addSomeStuff();
		}
		
		private function onKeyPressed(e:KeyboardEvent):void 
		{
			graphics.clear();
			addSomeStuff();
		}
		
		private function addSomeStuff():void 
		{
			var x1:int = 600 * Math.random();
			var y1:int = 0;
			var x2:int = 600 * Math.random();
			var y2:int = 480;
			var x3:int = 0;
			var y3:int = 480 * Math.random();
			//var y3:int = 200;
			var x4:int = 600;
			var y4:int = 480 * Math.random();
			//var y4:int = 200;
			
			
			
			graphics.lineStyle(2, 0x555555);
			graphics.moveTo(x3, y3);
			graphics.lineTo(x4, y4);
			
			var s:Number = (x1 * (y3 - y2) + x2 * (y3 - y1) + x3 * (y2 - y1)) / ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1));
			var t:Number = (x1 * (y4 - y3) + x3 * (y1 - y4) + x4 * (y3 - y1)) / ((y2 - y1) * (x4 - x3) - (x2 - x1) * (y4 - y3));
	
			var xi:Number = x1 + t * (x2 - x1);
			var yi:Number = y1 + t * (y2 - y1);
			
			trace("xi = " + xi + "\nyi = " + yi +"\ns = " + s + "\nt = " + t);
			
			graphics.drawCircle(xi, yi, 5);
			graphics.lineStyle(1, 0x00ff00);
			graphics.moveTo(x2,y2);
			graphics.lineTo(xi, yi);
			var arr:Array = getIntersectionPoint(x1, y1, x2, y2, x3, y3, x4, y4);
			trace(arr[0] + " " + arr[1]);
			var angle:Number = findAngleBetween(x1, y1, x2, y2, x3, y3, x4, y4);
			
			
			
			var ang1:Number = Math.atan2(y2 - arr[1],x2 -  arr[0]) * 180 / Math.PI;
			
			trace("Angle bet ray-mirror: "+angle );
			
			var normal:Array = getNormal(xi, yi, x4, y4);
			//var incidentAngle:Number = findAngleBetween(arr[0], arr[1], normal[0], normal[1], arr[0], arr[1], x4, y4);
			var incidentAngle:Number = normal[2] - ang1;
			trace("Incidence wrt normal: " + incidentAngle);
			
				var tx:Number = arr[0] + 300 * Math.cos((incidentAngle+normal[2]) * Math.PI / 180);
				var ty:Number = arr[1] + 300 * Math.sin((incidentAngle+normal[2]) * Math.PI / 180);
		
			//checking
			var refAng:Number = Math.abs(normal[2] - Math.atan2(ty - arr[1], tx - arr[0]) * 180/Math.PI);
			trace("Reflected angle: " + refAng);
			
			graphics.lineStyle(1,0x0000ff);
			graphics.moveTo(arr[0], arr[1]);
			graphics.lineTo(tx, ty);
			trace("Ray angle wrt hor: " + ang1);
		}
		
		public function getNormal(intersectX:Number, intersectY:Number,endX:Number,endY:Number):Array
		{
			var xi:Number = intersectX;
			var yi:Number = intersectY;
			var x4:Number = endX;
			var y4:Number = endY;
			
			var dx:Number = x4 - xi;
			var dy:Number = y4 - yi;
			
			//line 2 - reflector angle
			var lineAngleRad:Number = Math.atan2(dy, dx);
			trace("mirror angle: " + lineAngleRad * 180/Math.PI);
			var nx:Number = xi + 100 * Math.cos(lineAngleRad + Math.PI/2);
			var ny:Number = yi + 100 * Math.sin(lineAngleRad + Math.PI / 2);
			graphics.lineStyle(1, 0xff0000,0.5);
			graphics.moveTo(xi, yi);
			graphics.lineTo(nx, ny);
			
			return new Array(nx, ny, (lineAngleRad + Math.PI / 2) * 180 / Math.PI );
			
		}
		
		public function findAngleBetween(x1:int, y1:int, x2:int, y2:int, x3:int, y3:int, x4:int, y4:int):Number
		{
			
			//dot product
			var dx1:Number = x2 - x1;
			var dy1:Number = y2 - y1;
			var dx2:Number = x4 - x3;
			var dy2:Number = y4 - y3;
			var d:Number = dx1 * dx2 + dy1 * dy2; //dot prod.. 
			var LenSq:Number = (dx1*dx1+dy1*dy1) * (dx2*dx2+dy2*dy2); //|A|*|B|
			var angle:Number  = Math.acos(d / Math.sqrt(LenSq)) *180/Math.PI;
			//trace("Angle: " + angle);
			if (angle < 0) angle += 360;
			return angle;
			
			
		}
		
		
		
		public function getIntersectionPoint(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, x4:Number, y4:Number):Array
		{
			//var s:Number = (x1 * (y3 - y2) + x2 * (y3 - y1) + x3 * (y2 - y1)) / ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1));
			var t:Number = (x1 * (y4 - y3) + x3 * (y1 - y4) + x4 * (y3 - y1)) / ((y2 - y1) * (x4 - x3) - (x2 - x1) * (y4 - y3));
			
			var xi:Number = x1 + t * (x2 - x1);
			var yi:Number = y1 + t * (y2 - y1);
			
			return new Array(xi, yi);
		}
		
	}
	
}