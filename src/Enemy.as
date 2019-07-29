package 
{
	/**
	 * ...
	 * @author Mhtsu
	 */
	public class Enemy 
	{
		//座標
		public var x:Number = new Number;
		public var y:Number = new Number;
		public var w:uint = new uint(20);
		public var h:uint = new uint(20);
		public var sx:Number = new Number(2);
		public var sy:Number = new Number(0);
		public var ground:Boolean = new Boolean(false );
		
		public var type:int = new int(0);
		/*
		 * 敵タイプ
		 * 0 : 壁に当たるまで方向転換しない系
		 * 1 : 未定
		 * */
		public var m:Boolean = new Boolean(false);	//動く方向	false=左
		
		public function Enemy(TYPE:int = 0, X:Number = 0, Y:Number = 0 ) 
		{
			type = type
			x = X;
			y = Y;
		}
		
	}

}