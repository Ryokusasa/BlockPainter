package 
{
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Mhtsu
	 */
	public class StObject 
	{
		
		
		public var rect:Rectangle;	//四角情報
		
		public var type:int;
		/* -1 : 無
		 *	0 : 通常(白)
		 *	1 : 一定時間で消える(透明度が上がっていく？)(最高三つプレイヤーが出せる)
		 *	2 : 触れたら死ぬ(赤)
		 *	3 : ゴール(黄色)
		 *  4 : プレイヤー制御中オブジェ（半透明）
		 */
		
		public var hF:uint = new uint(0);
		/* ヒットフラグ
		 * 0 :　無
		 * 1 : 左
		 * 2 : 右
		 * 3 : 上
		 * 4 : 下
		 */
		 
		//消滅時間
		public const countT:int = new int(120);	//二秒
		public var count:int = new int(120);
		
		public function StObject(TYPE:int = -1, X:int = 0, Y:int = 0, WIDTH:int = 0, HEIGHT:int = 0 ) 
		{
			type = TYPE;
			rect = new Rectangle(X, Y, WIDTH, HEIGHT);
		}
		
	}

}