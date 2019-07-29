package 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Mhtsu
	 */
	public class Stage 
	{
		public var stageRect:Rectangle = new Rectangle(0, 0, 8000, 4000);	//ステージサイズ		基本8000x4000
		public var objs:Vector.<StObject> = new Vector.<StObject>(1000, true);	//オブジェクト情報
		public var objNum:uint = new uint(500);	//最大オブジェクト数
		public var enemys:Vector.<Enemy> = new Vector.<Enemy>(1000, true)	//敵配列　とりあえず千体
		public var eNum:uint = new uint(1000);	//最大敵数
		public var startPos:Point = new Point();
		
		public function Stage(WIDTH:Number = 8000 , HEIGHT:Number = 4000)
		{
			stageRect.width = WIDTH;
			stageRect.height = HEIGHT;
		}
		
	}

}