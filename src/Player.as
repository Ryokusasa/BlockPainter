package 
{
	import adobe.utils.CustomActions;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Mhtsu
	 */
	public class Player 
	{
		/* 絶対座標 
		 * カメラから見た相対座標は別の処理 */
		public var x:Number = new Number(0);
		public var y:Number = new Number(0);
		public var w:int = new int(20);
		public var h:int = new int(20);
		
		/* 速度およびベクトル */
		public var sx:Number = new Number(0);
		public var sy:Number = new Number(0);
		public var vx:Number = new Number(1);
		public var vy:Number = new Number(1);
		/* 最大速度 */
		//public const msx:Number = new Number(6);
		//public const msy:Number = new Number(10);
		/* ジャンプ時加速度 */
		//public const j:int = new int(-6);
		/* 最大ジャンプ時間とカウンタ */
		//public const jt:int = new int(10);
		public var jtc:int = new int(0);
		
		/* 地面着地フラグ */
		public var ground:Boolean = new Boolean(false);
		
		private var jf:Boolean = new Boolean(false);
		private var mf:Boolean = new Boolean(false);	//移動フラグ
		
		public const objNum:uint = new uint(4);	//表示四つ	//
		
		public var objs:Vector.<StObject> = new Vector.<StObject>(objNum, true);	//プレイヤーオブジェ	消失時も含めて
		public var objsPr:uint = new uint(0);	//オブジェ優先番号 (この要素番号から捜索する)
		public var objPos:Point = new Point;	//設置位置
		
		public var hp:uint = new uint(5);
		public const chp:uint = new uint(5);
		public var type:int = new int(0);
		/* プレイヤーの状態
		 * 0 = 通常
		 * -1 = 死亡中
		 * 
		*/
		
		
		public function Player(fx:int = 0, fy:int = 0) 
		{
			var i:int = new int();
			
			/* 初期設定 */
			x = fx;
			y = fy;
			hp = chp;
			
			/* オブジェクト初期化 */
			for (i = 0; i < objNum; i++){
				objs[i] = new StObject();
			}
			
		}
		
		//右移動処理
		public function right(MAX_SPEED_X:Number):void
		{
			sx += vx;
			if (sx > MAX_SPEED_X){
				sx = MAX_SPEED_X;
			}
			mf = true;
		}
		
		//左移動処理
		public function left(MAX_SPEED_X:Number):void
		{
			sx -= vx;
			if (sx < -MAX_SPEED_X){
				sx = -MAX_SPEED_X;
			}
			mf = true;
		}
		
		//ジャンプ処理
		public function jump(JUMP_SPEED:int, JUMP_TIME:int):void
		{
			if(jtc < JUMP_TIME){
				if (ground == true){
					sy = JUMP_SPEED;
				}else{
					if (jtc < JUMP_TIME){
						sy = JUMP_SPEED;
					}
				}
				//ジャンプフラグ
				jf = true;
			}else{
				jf = false;
			}
		}
		
		public function update(MAX_SPEED_Y:Number, JUMP_TIME:int, g:Number, resistance:Number):void
		{
			x += sx;
			y += sy;
			//重力加算
			if (!ground){
				sy += g;
				if (sy > MAX_SPEED_Y){
					sy = MAX_SPEED_Y
				}
				
				if (jf == true){
					jtc++;
				}else{
					jtc = JUMP_TIME;
				}
			}else{
				if (!mf){
					sx *= resistance;
					if (sx < 0.1 && sx > -0.1) sx = 0;
				}
				
			}
			jf = false;
			mf = false;
		}
		
	}

}