package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Mhtsu
	 * 
	 * 400x300 60fps
	 */
	public class Main extends Sprite 
	{
		
		//定数-------------------------
		/* 最大速度 */
		private const MAX_SPEED_X:Number = new Number(3.0);
		private const MAX_SPEED_Y:Number = new Number(12.0);
		
		private const JUMP_SPEED:int = new int(-6);	/* ジャンプ時加速度 */
		private const JUMP_TIME:int = new int(10);	/* 最大ジャンプ時間とカウンタ */
		
		//カメラサイズ(表示画面のこと)
		private const CAMERA_WIDTH:int = 400;
		private const CAMERA_HEIGHT:int = 300;
		private const CAMERA_INWIDTH:int = 400 * 0.6;
		private const CAMERA_INHEIGHT:int = 300 * 0.6;
		private const CAMERA_SPEED:uint = new uint(2);
		
		//障害物
		private const MIN_OBJ_W:uint = new uint(1);
		private const MIN_OBJ_H:uint = new uint(1);
		
		//変数---------------------------
		private var stages:Vector.<Stage> = new Vector.<Stage>(3, true);	//ステージ情報
		private var ebmd:BitmapData = new BitmapData(20, 20, true, 0x00FFFFFF);
		private var stageNumber:uint = new uint(2);	//ステージ番号 0が最初
		private var p1:Player = new Player(100, 3980);	//プレイヤー
		private var p1bmd:BitmapData = new BitmapData(p1.w, p1.h, true, 0x00FFFFFF);	//プレイヤー画像
		private var resistance:Number = new Number(0.8);	//摩擦抵抗
		private var game:int = new int(0);	//ゲームフラグ 1 = ゲーム画面
		private var frame:uint = new uint(0);
		private const RESTART_COUNT:uint = new uint(100);	//死んでからスタートに戻るまでの時間
		private var restartCount:uint = new uint(RESTART_COUNT);
		
		//カメラ位置
		private var cam:Point = new Point(0, 0);
		
		//画面Bitmap
		private var bmp:Bitmap = new Bitmap;
		private var bmd:BitmapData = new BitmapData(400, 300, true, 0xFFFFFF);
		
		//キー＆マウス
		private var keyCode:Vector.<Boolean> = new Vector.<Boolean>(256, true);
		private var mouseD:Boolean = new Boolean(false);
		private var mouse:Point = new Point();
		
		private var g:Number = new Number(0.5);	//重力
		
		//デバッグテキスト
		private var debugTxt:TextField = new TextField();
		
		//ポーズテキスト
		private var pauseTxt:TextField = new TextField();
		
		//ナビゲーション
		private var navi:TextField = new TextField();
		private var naviTf:TextFormat = new TextFormat();
		private const NAVI_POINT:Point = new  Point(100, 280);	//ナビの表示位置
		private var NAVI_COUNT:uint = new uint(60);	//表示時間
		private var naviCount:uint = new uint(0);	//カウンタ
		
		//FPS計測用変数
		private var fps:Number = new Number;
		private var start:int = new int;
		private var end:int = new int;
		
		//ゲームオーバーテキスト
		private var goText:TextField = new TextField;
		
		//メニューテキスト
		private var menuText1:TextField = new TextField();	/* プレイボタン */
		private var menuText2:TextField = new TextField();	/* 操作説明ボタン　*/
		
		//操作説明テキスト
		private var howTo:TextField = new TextField();
		
		[Embed(source = "../CTCZdMEUsAAZ0HM.png")] private static const imgc1:Class;
		private var img1:Bitmap = new imgc1;
		
		//ゲームクリアテキスト
		private var gcText:TextField = new TextField();
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			//初期化もろもろ
			//ビットマップ設定
			bmp.bitmapData = bmd;
			addChild(bmp);
			//プレイヤー画像生成
			var sp:Sprite = new Sprite();
			var gra:Graphics = sp.graphics;
			gra.lineStyle(1, 0);
			gra.beginFill(0xFFFFFF, 1);
			gra.drawCircle(10, 10, 9);
			gra.endFill();
			p1bmd.draw(sp);
			
			
			//デバッグテキスト編集
			debugTxt.height = 50;
			debugTxt.width = 200;
			debugTxt.alpha = 0.4;
			debugTxt.selectable = false;
			debugTxt.visible = false;
			addChild(debugTxt);
			
			//ナビゲーション編集
			navi.width = 200;
			navi.height = 30;
			navi.x = NAVI_POINT.x;
			navi.y = NAVI_POINT.y + navi.height;
			navi.background = true;
			navi.backgroundColor = 0x999999;
			navi.visible = false;
			navi.selectable = false;
			naviTf.align = TextFormatAlign.CENTER;
			naviTf.size = 15
			navi.defaultTextFormat = naviTf;
			navi.textColor = 0xFFFFFF;
			stage.addChild(navi);
			
			//ポーズテキスト
			pauseTxt.visible = false;
			pauseTxt.text = "Pause\nescキーでメニューへ";
			pauseTxt.textColor = 0xFFFFFF;
			pauseTxt.width = 400;
			pauseTxt.height = 300;
			pauseTxt.background = true;
			pauseTxt.backgroundColor = 0x000000;
			pauseTxt.alpha = 0.4;
			stage.addChild(pauseTxt);
			
			//敵画像生成(赤い三角形)
			sp = new Sprite;
			gra = sp.graphics;
			gra.lineStyle(1, 0, 1);
			gra.beginFill(0xDD0000, 1);
			gra.moveTo(0, 20);
			gra.lineTo(10, 0);
			gra.lineTo(20, 20);
			gra.lineTo(0, 20);
			gra.endFill();
			ebmd.draw(sp);
			
			//ゲームオーバーテキスト
			goText.width = 400;
			goText.height = 300;
			goText.visible = false;
			goText.text = "クリックでメニュー画面へ"
			goText.textColor = 0xFFFFFF;
			stage.addChild(goText);
			
			//メニュー
			menuText1.text = "プレイ！";
			menuText1.x = 100;
			menuText1.y = 120;
			menuText1.autoSize = "right"
			menuText1.selectable = false;
			menuText1.textColor = 0x999999;
			menuText1.visible = false;
			menuText1.addEventListener(MouseEvent.MOUSE_OVER, mText1_MouseOver);
			menuText1.addEventListener(MouseEvent.MOUSE_OUT, mText1_MouseOut);
			stage.addChild(menuText1);
			
			menuText2.text = "操作説明";
			menuText2.x = 100;
			menuText2.y = 150;
			menuText2.autoSize = "right";
			menuText2.textColor = 0x999999; 
			menuText2.addEventListener(MouseEvent.MOUSE_OVER, mText2_MouseOver);
			menuText2.addEventListener(MouseEvent.MOUSE_OUT, mText2_MouseOut);
			menuText2.selectable = false;
			menuText2.visible = false;
			stage.addChild(menuText2);
			
			//操作説明テキスト
			howTo.visible = false;
			howTo.selectable = false;
			howTo.text = "操作説明\n\nAWDキー : 移動\nマウス :　画面端に持っていくとカメラ移動\nマウスドラッグ : ブロック配置(三つまで)\nEnterキー : 残機確認\n\n赤いものに触れると死にます。黄色はゴールです。\n\nクリックでメニューへ";
			howTo.width = 400;
			howTo.height = 300;
			stage.addChild(howTo);
			
			img1.visible = false;
			stage.addChild(img1);
			
			gcText.width = 400;
			gcText.height = 300;
			gcText.visible = false;
			gcText.text = "クリックで次のステージへ!"
			gcText.textColor = 0x000000;
			stage.addChild(gcText);
			
			menuSet();
			
		}
		
		private function onEnterFrame(e:Event):void
		{
			frame++;
			if (game == 0){	//メニュー画面
				bmd.fillRect(bmd.rect, 0xFFFFFFFF);
				navigation();
			}else if (game == 1){	//ゲーム画面
				if(frame % 60 == 0){
					end = getTimer();
					fps = 60 / ((end - start)/1000);
				}
				
				
				
				control();
				enemyCtl();
				hit();
				camera();
				controlObj();
				draw();
				navigation();
				
				if (frame % 60 == 0){
					start = getTimer();
				}
				
				
				debugTxt.text = "p1.x=" + int(p1.x) + " p1.y=" + p1.y + " cam" + int(cam.x) + " " + int(cam.y)  + " \nfps=" + int(fps) + " sx=" + p1.sx;
			}else if (game == 2){	//ポーズ画面
				//ポーズ画面での操作はkeyDownで行っている
			}else if (game == 3){	//ゲームオーバー画面
				bmd.fillRect(bmd.rect, 0xFF000000);
				navigation();
				stageNumber = 0;
			}else if (game == 4){	//操作説明画面
				navigation();
			}else if (game == 5){	//ステージクリア!!
				bmd.fillRect(bmd.rect, 0xFFFFFFFF);
				navigation();
				gcText.visible = true;
				//img1.visible = true;
			}
		}
		
		//プレイヤー処理
		private function control():void
		{
			if (keyCode[65]){
				p1.left(MAX_SPEED_X);
			}
			if (keyCode[68]){
				p1.right(MAX_SPEED_X);
			}
			if (keyCode[87]){
				p1.jump(JUMP_SPEED, JUMP_TIME);
			}else{
				if (p1.ground){
					p1.jtc = 0;
				}
			}
			
			if (p1.type == -1){	//死亡中
				if (restartCount > 0){
					restartCount--;
				}else{
					restartCount = RESTART_COUNT;
					stageReset();
					if (p1.hp == 0){
						game = 3;	//ゲームオーバーへ
						p1.hp = p1.chp;	//残機リセット
						
						//各表示
						navigationSet("GAMEOVER", 120);
						goText.visible = true;
					}
				}
			}else{
				p1.update(MAX_SPEED_Y, JUMP_TIME, g, resistance);
			}
			
		}
		
		//当たり判定
		private function hit():void
		{
			var i:uint = new uint;
			
			p1.ground = false;
			
			//ステージ自体のあたり判定
			if (p1.x < stages[stageNumber].stageRect.x){	//左
				p1.x = stages[stageNumber].stageRect.x;
			}else if (p1.x + p1.w > stages[stageNumber].stageRect.x + stages[stageNumber].stageRect.width){	//右
				p1.x = stages[stageNumber].stageRect.x + stages[stageNumber].stageRect.width - p1.w;
			}
			if (p1.y < stages[stageNumber].stageRect.y){	//上
				p1.y = stages[stageNumber].stageRect.y;
			}else if (p1.y + p1.h > stages[stageNumber].stageRect.y + stages[stageNumber].stageRect.height){	//下
				p1.y = stages[stageNumber].stageRect.y + stages[stageNumber].stageRect.height - p1.h - 1;
				p1.ground = true;
			}
			
			for (i = 0; i < stages[stageNumber].eNum; i++){
				if (stages[stageNumber].enemys[i] != null){
					if (stages[stageNumber].enemys[i].x < stages[stageNumber].stageRect.x){	//左
						stages[stageNumber].enemys[i].x = stages[stageNumber].stageRect.x;
						stages[stageNumber].enemys[i].m = true;
					}else if (stages[stageNumber].enemys[i].x + stages[stageNumber].enemys[i].w > stages[stageNumber].stageRect.x + stages[stageNumber].stageRect.width){	//右
						stages[stageNumber].enemys[i].x = stages[stageNumber].stageRect.x + stages[stageNumber].stageRect.width - stages[stageNumber].enemys[i].w;
						stages[stageNumber].enemys[i].m = false;
					}
					if (stages[stageNumber].enemys[i].y < stages[stageNumber].stageRect.y){	//上
						stages[stageNumber].enemys[i].y = stages[stageNumber].stageRect.y;
					}else if (stages[stageNumber].enemys[i].y + stages[stageNumber].enemys[i].h > stages[stageNumber].stageRect.y + stages[stageNumber].stageRect.height){	//下
						stages[stageNumber].enemys[i].y = stages[stageNumber].stageRect.y + stages[stageNumber].stageRect.height - stages[stageNumber].enemys[i].h;
						stages[stageNumber].enemys[i].ground = true;
					}
				}
			}
			
			
			hitObj();
			if(p1.type >= 0){	//死んでないとき以外
				playerHit();
			}
			
		}
		
		private function draw():void
		{
			var i:int = new int;
			var j:uint = new uint;
			
			bmd.lock();
			
			//塗りつぶし初期化
			bmd.fillRect(new Rectangle(0, 0, CAMERA_WIDTH, CAMERA_HEIGHT), 0xFFFFFFFF );
			
			//ステージ描画
			bmd.fillRect(new Rectangle( -cam.x, -cam.y, stages[stageNumber].stageRect.width, stages[stageNumber].stageRect.height), 0xFF000000 );
			bmd.fillRect(new Rectangle( -cam.x + 1, -cam.y + 1, stages[stageNumber].stageRect.width - 2, stages[stageNumber].stageRect.height - 2), 0xFFFFFFFF );
			
			//プレイヤー描画
			if(p1.type >= 0){
				bmd.copyPixels(p1bmd, new Rectangle(0, 0, p1.w, p1.h), new Point(p1.x - cam.x, p1.y - cam.y + 1), null, null, true);
			}else if (p1.type == -1){	//死亡中なら
				bmp.alpha = 1 - restartCount / RESTART_COUNT;
			}
			
			
			//オブジェクト
			for (i = 0; i < stages[stageNumber].objNum; i++){
				if (stages[stageNumber].objs[i] != null){	//中身がない場合、
					if (stages[stageNumber].objs[i].type != -1){	//非常時以外を描画
						switch (stages[stageNumber].objs[i].type){
							case 0:	//ただの障害物
								bmd.fillRect(new Rectangle(stages[stageNumber].objs[i].rect.x - cam.x, stages[stageNumber].objs[i].rect.y - int(cam.y), stages[stageNumber].objs[i].rect.width, stages[stageNumber].objs[i].rect.height), 0xFF000000);
								bmd.fillRect(new Rectangle(stages[stageNumber].objs[i].rect.x - cam.x + 1, stages[stageNumber].objs[i].rect.y - int(cam.y) + 1, stages[stageNumber].objs[i].rect.width - 2, stages[stageNumber].objs[i].rect.height - 2), 0xFFFFFFFF);	//白ブロック
								break;
							case 1:	//プレイヤー障害物
								bmd.fillRect(new Rectangle(stages[stageNumber].objs[i].rect.x - cam.x, stages[stageNumber].objs[i].rect.y - cam.y, stages[stageNumber].objs[i].rect.width, stages[stageNumber].objs[i].rect.height), 0xFF000000);	
								bmd.fillRect(new Rectangle(stages[stageNumber].objs[i].rect.x - cam.x + 1, stages[stageNumber].objs[i].rect.y - cam.y + 1, stages[stageNumber].objs[i].rect.width - 2, stages[stageNumber].objs[i].rect.height - 2), 0xFFDDDDDD);	//灰色
								break;
							case 2:	//危険障害物
								bmd.fillRect(new Rectangle(stages[stageNumber].objs[i].rect.x - cam.x, stages[stageNumber].objs[i].rect.y - cam.y, stages[stageNumber].objs[i].rect.width, stages[stageNumber].objs[i].rect.height), 0xFFDD0000);	//赤
								break;
							case 3:
								bmd.fillRect(new Rectangle(stages[stageNumber].objs[i].rect.x - cam.x, stages[stageNumber].objs[i].rect.y - cam.y, stages[stageNumber].objs[i].rect.width, stages[stageNumber].objs[i].rect.height), 0xFFFFFF00);	//ゴール
								break;
							default:
								break;
						}
					}
				}
			}
			
			
			//敵描画
			for (i = 0; i < stages[stageNumber].eNum; i++){
				if (stages[stageNumber].enemys[i] != null){
					switch(stages[stageNumber].enemys[i].type){
						case 0:
							bmd.copyPixels(ebmd, ebmd.rect, new Point(stages[stageNumber].enemys[i].x - cam.x, stages[stageNumber].enemys[i].y - cam.y), null, null, true);
						default:
							break;
					}
				}
			}
			
			//プレイヤーオブジェクト描画
			var alpha:Number = new Number();
			for (i = 1; i <= p1.objNum; i++){
				j = (p1.objsPr + i) % p1.objNum;
				if (p1.objs[j].type != -1){	//非常時以外を描画
					switch (p1.objs[j].type){
						case 0:	//ただの障害物
							bmd.fillRect(new Rectangle(p1.objs[j].rect.x - cam.x, p1.objs[j].rect.y - cam.y, p1.objs[j].rect.width, p1.objs[j].rect.height), 0xFF000000);
							bmd.fillRect(new Rectangle(p1.objs[j].rect.x - cam.x + 1, p1.objs[j].rect.y - cam.y + 1, p1.objs[j].rect.width - 2, p1.objs[j].rect.height - 2), 0xFFFFFFFF);	//白ブロック
							break;
						case 1:	//プレイヤー障害物
							alpha = (p1.objs[j].count / p1.objs[j].countT);
							//bmd.fillRect(new Rectangle(p1.objs[j].rect.x - cam.x, p1.objs[j].rect.y - cam.y, p1.objs[j].rect.width, p1.objs[j].rect.height), 0x000000 + (((p1.objs[j].count / p1.objs[j].countT) * 256) << 24));	
							//bmd.fillRect(new Rectangle(p1.objs[j].rect.x - cam.x + 1, p1.objs[j].rect.y - cam.y + 1, p1.objs[j].rect.width - 2, p1.objs[j].rect.height - 2), 0x666666 + (((p1.objs[j].count / p1.objs[j].countT) * 256) << 24));	//灰色
							bmd.colorTransform(new Rectangle(p1.objs[j].rect.x - cam.x, p1.objs[j].rect.y - cam.y, p1.objs[j].rect.width, p1.objs[j].rect.height), new ColorTransform(1, 1, 1, 1, -200*alpha, -200*alpha, -200*alpha, 0 ));
							break;
						case 2:	//危険障害物
							bmd.fillRect(new Rectangle(p1.objs[j].rect.x - cam.x, p1.objs[j].rect.y - cam.y, p1.objs[j].rect.width, p1.objs[j].rect.height), 0xFFDD0000);	//赤
							break;
						case 3:
							break;
						case 4:	//設置中障害物
							bmd.colorTransform(new Rectangle(p1.objs[j].rect.x - cam.x, p1.objs[j].rect.y - cam.y, p1.objs[j].rect.width, p1.objs[j].rect.height),new ColorTransform(1,1,1,1,-100,-100,-100,0));
							//bmd.fillRect(new Rectangle(p1.objs[j].rect.x - cam.x + 1, p1.objs[j].rect.y - cam.y + 1, p1.objs[j].rect.width - 2, p1.objs[j].rect.height - 2), 0x55666666);	//灰色
							break;
						default:
							break;
					}
				}
			}
			bmd.unlock();
		}
		
		private function camera():void
		{
			
			//マウスによるカメラ操作
			if (!mouseD){	//設置中でないとき作動
				if (stage.mouseX < (CAMERA_WIDTH - CAMERA_INWIDTH) / 2){	//左
					cam.x -= CAMERA_SPEED;
				}else if (stage.mouseX > CAMERA_WIDTH - (CAMERA_WIDTH - CAMERA_INWIDTH) / 2){
					cam.x += CAMERA_SPEED;
				}
				
				if (stage.mouseY < (CAMERA_HEIGHT - CAMERA_INHEIGHT) / 2){	//上
					cam.y -= CAMERA_SPEED;
				}else if (stage.mouseY > CAMERA_HEIGHT - (CAMERA_HEIGHT - CAMERA_INHEIGHT) / 2){
					cam.y += CAMERA_SPEED;
				}
			}
			
			//プレイヤーのカメラ追従処理
			if (p1.x < cam.x + (CAMERA_WIDTH - CAMERA_INWIDTH) / 2){	//左
				cam.x = p1.x - (CAMERA_WIDTH - CAMERA_INWIDTH) / 2
			}else if (p1.x + p1.w > cam.x + CAMERA_WIDTH - (CAMERA_WIDTH - CAMERA_INWIDTH) / 2){	//右
				cam.x = p1.x + p1.w - CAMERA_WIDTH + (CAMERA_WIDTH - CAMERA_INWIDTH) / 2;
			}
			if (p1.y < cam.y + (CAMERA_HEIGHT - CAMERA_INHEIGHT) / 2){	//上
				cam.y = p1.y - (CAMERA_HEIGHT - CAMERA_INHEIGHT) / 2;
			}else if (p1.y + p1.h > cam.y + CAMERA_HEIGHT - (CAMERA_HEIGHT - CAMERA_INHEIGHT) / 2){	//下
				cam.y = p1.y + p1.h - CAMERA_HEIGHT + (CAMERA_HEIGHT - CAMERA_INHEIGHT) / 2;
			}
		}
		
		private function hitObj():void	//障害物との衝突処理
		{
			var p1Rect:Rectangle = new Rectangle(p1.x, p1.y, p1.w, p1.h);
			var p1RectU:Rectangle = new Rectangle(p1.x, p1.y, p1.w, 1);	//上部分
			var p1RectD:Rectangle = new Rectangle(p1.x, p1.y + p1.h - 1, p1.w, 1);	//下部分
			var p1RectL:Rectangle = new Rectangle(p1.x, p1.y, 1, p1.h);	//左部分
			var p1RectR:Rectangle = new Rectangle(p1.x + p1.w - 1, p1.y, 1, p1.h);	//右部分
			var eRectU:Rectangle = new Rectangle;
			var eRectD:Rectangle = new Rectangle;
			var eRectL:Rectangle = new Rectangle;
			var eRectR:Rectangle = new Rectangle;
			
			var i:int = new int;
			var j:int = new int;
			
			
			//プレイヤー障害物
			for (i = 0; i < p1.objNum; i++){
				if (p1.objs[i] != null){	//中身がない場合は無視
					if (p1.objs[i].type != -1){	//無以外
						if (p1.objs[i].type == 0 || p1.objs[i].type == 1){//通常障害物
							
							//上
							if (p1.objs[i].hF == 0 || p1.objs[i].hF == 3){	//連続性あたり判定(もともと上に当たっているならば上しかないという判定)
								if (hitBox(p1RectD, new Rectangle(p1.objs[i].rect.x, p1.objs[i].rect.y, p1.objs[i].rect.width, Math.abs(p1.sy)))){
									p1.objs[i].hF = 3;
									if(p1.sy > 0) p1.sy = 0;	//同じ方向の速さ維持
									p1.y = p1.objs[i].rect.y - p1.h;
									p1.ground = true;
									continue;
								}
							}
							
							//下
							if (p1.objs[i].hF == 0 || p1.objs[i].hF == 4){	//連続性あたり判定(もともと上に当たっているならば上しかないという判定)
								if (hitBox(p1RectU, new Rectangle(p1.objs[i].rect.x, p1.objs[i].rect.bottom - Math.abs(p1.sy), p1.objs[i].rect.width, Math.abs(p1.sy)))){
									p1.objs[i].hF = 4;
									if (p1.sy < 0) p1.sy = 0;
									p1.y = p1.objs[i].rect.bottom;
									p1.jtc = JUMP_TIME;	//ジャンプ処理止め
									continue;
								}
							}
							
							//左
							if (p1.objs[i].hF == 0 || p1.objs[i].hF == 1){	//連続性あたり判定(もともと上に当たっているならば上しかないという判定)
								if (hitBox(p1RectR, new Rectangle(p1.objs[i].rect.x, p1.objs[i].rect.y, Math.abs(p1.sx), p1.objs[i].rect.height))){
									p1.objs[i].hF = 1;
									if(p1.sx > 0)p1.sx = 0;
									p1.x = p1.objs[i].rect.x - p1.w;
									continue;
								}
							}
							
							//右
							if (p1.objs[i].hF == 0 || p1.objs[i].hF == 2){	//連続性あたり判定(もともと上に当たっているならば上しかないという判定)
								if (hitBox(p1RectL, new Rectangle(p1.objs[i].rect.right - Math.abs(p1.sx), p1.objs[i].rect.y, Math.abs(p1.sx), p1.objs[i].rect.height))){
									p1.objs[i].hF = 2;
									if (p1.sx < 0) p1.sx = 0;
									p1.x = p1.objs[i].rect.right;
									continue;
								}
							}
							
							
							p1.objs[i].hF = 0;
						}
					}
				}
			}
			
			//通常障害物
			for (i = 0; i < stages[stageNumber].objNum; i++){
				if (stages[stageNumber].objs[i] != null){	//中身がない場合は無視
					if (stages[stageNumber].objs[i].type != -1){	//無以外
						if (stages[stageNumber].objs[i].type == 0 || stages[stageNumber].objs[i].type == 1){//通常障害物
							
							//プレイヤーの衝突
							//上
							if (stages[stageNumber].objs[i].hF == 0 || stages[stageNumber].objs[i].hF == 3){	//連続性あたり判定(もともと上に当たっているならば上しかないという判定)
								if (hitBox(p1RectD, new Rectangle(stages[stageNumber].objs[i].rect.x + 1, stages[stageNumber].objs[i].rect.y, stages[stageNumber].objs[i].rect.width - 2, Math.abs(p1.sy)))){
									stages[stageNumber].objs[i].hF = 3;
									if(p1.sy > 0) p1.sy = 0;	//同じ方向の速さ維持
									p1.y = stages[stageNumber].objs[i].rect.y - p1.h;
									p1.ground = true;
								}
							}
							
							//下
							if (stages[stageNumber].objs[i].hF == 0 || stages[stageNumber].objs[i].hF == 4){	//連続性あたり判定(もともと上に当たっているならば上しかないという判定)
								if (hitBox(p1RectU, new Rectangle(stages[stageNumber].objs[i].rect.x + 1, stages[stageNumber].objs[i].rect.bottom - Math.abs(p1.sy), stages[stageNumber].objs[i].rect.width - 2, Math.abs(p1.sy)))){
									stages[stageNumber].objs[i].hF = 4;
									if (p1.sy < 0) p1.sy = 0;
									p1.y = stages[stageNumber].objs[i].rect.bottom;
									p1.jtc = JUMP_TIME;	//ジャンプ処理止め
								}
							}
							
							//左
							if (stages[stageNumber].objs[i].hF == 0 || stages[stageNumber].objs[i].hF == 1){	//連続性あたり判定(もともと上に当たっているならば上しかないという判定)
								if (hitBox(p1RectR, new Rectangle(stages[stageNumber].objs[i].rect.x, stages[stageNumber].objs[i].rect.y, Math.abs(p1.sx), stages[stageNumber].objs[i].rect.height))){
									stages[stageNumber].objs[i].hF = 1;
									if(p1.sx > 0)p1.sx = 0;
									p1.x = stages[stageNumber].objs[i].rect.x - p1.w;
								}
							}
							
							//右
							if (stages[stageNumber].objs[i].hF == 0 || stages[stageNumber].objs[i].hF == 2){	//連続性あたり判定(もともと上に当たっているならば上しかないという判定)
								if (hitBox(p1RectL, new Rectangle(stages[stageNumber].objs[i].rect.right - Math.abs(p1.sx), stages[stageNumber].objs[i].rect.y, Math.abs(p1.sx), stages[stageNumber].objs[i].rect.height))){
									stages[stageNumber].objs[i].hF = 2;
									if (p1.sx < 0) p1.sx = 0;
									p1.x = stages[stageNumber].objs[i].rect.right;
								}
							}
							
							stages[stageNumber].objs[i].hF = 0;
							
							//敵の衝突判定
							for (j = 0; j < stages[stageNumber].eNum; j++ ){
								if (stages[stageNumber].enemys[j] != null){
									eRectU = new Rectangle(stages[stageNumber].enemys[j].x, stages[stageNumber].enemys[j].y, stages[stageNumber].enemys[j].w, 1);
									eRectD = new Rectangle(stages[stageNumber].enemys[j].x, stages[stageNumber].enemys[j].y + stages[stageNumber].enemys[j].h - 1, stages[stageNumber].enemys[j].w, 1);
									eRectL = new Rectangle(stages[stageNumber].enemys[j].x, stages[stageNumber].enemys[j].y, 1, stages[stageNumber].enemys[j].h);
									eRectR = new Rectangle(stages[stageNumber].enemys[j].x + stages[stageNumber].enemys[j].w - 1, stages[stageNumber].enemys[j].y, 1, stages[stageNumber].enemys[j].h);
									//上
									if (hitBox(eRectD, new Rectangle(stages[stageNumber].objs[i].rect.x, stages[stageNumber].objs[i].rect.y, stages[stageNumber].objs[i].rect.width, Math.abs(stages[stageNumber].enemys[j].sy)))){
										if(stages[stageNumber].enemys[j].sy > 0) stages[stageNumber].enemys[j].sy = 0;	//同じ方向の速さ維持
										stages[stageNumber].enemys[j].y = stages[stageNumber].objs[i].rect.y - stages[stageNumber].enemys[j].h + 1;
										stages[stageNumber].enemys[j].ground = true;
										continue;
									}
									
									//下
									if (hitBox(eRectU, new Rectangle(stages[stageNumber].objs[i].rect.x, stages[stageNumber].objs[i].rect.bottom - Math.abs(p1.sy), stages[stageNumber].objs[i].rect.width, Math.abs(stages[stageNumber].enemys[j].sy)))){
										if (stages[stageNumber].enemys[j].sy < 0) stages[stageNumber].enemys[j].sy = 0;
										stages[stageNumber].enemys[j].y = stages[stageNumber].objs[i].rect.bottom;
										//p1.jtc = JUMP_TIME;	//ジャンプ処理止め
										continue;
									}
									
									//左
									if (hitBox(eRectR, new Rectangle(stages[stageNumber].objs[i].rect.x, stages[stageNumber].objs[i].rect.y, Math.abs(stages[stageNumber].enemys[j].sx), stages[stageNumber].objs[i].rect.height))){
										if (stages[stageNumber].enemys[j].sx > 0) stages[stageNumber].enemys[j].m = false;;
										stages[stageNumber].enemys[j].x = stages[stageNumber].objs[i].rect.x - stages[stageNumber].enemys[j].w;
										stages[stageNumber].enemys[j].m = false;
										continue;
									}
									
									//右
									if (hitBox(eRectL, new Rectangle(stages[stageNumber].objs[i].rect.right - Math.abs(stages[stageNumber].enemys[j].sx), stages[stageNumber].objs[i].rect.y, Math.abs(stages[stageNumber].enemys[j].sx), stages[stageNumber].objs[i].rect.height))){
										if (stages[stageNumber].enemys[j].sx < 0) stages[stageNumber].enemys[j].m = true;
										stages[stageNumber].enemys[j].x = stages[stageNumber].objs[i].rect.right;
										stages[stageNumber].enemys[j].m = true;
										continue;
									}
								}
							}
						}else if (stages[stageNumber].objs[i].type == 3){	//ゴール
							if (p1.type >= 0){
								if (hitBox(p1Rect, stages[stageNumber].objs[i].rect)){
									if (stageNumber < 1){
										navigationSet("ステージクリア！", 100);
										game = 5;
									}else if ( stageNumber == 2){	//チュートリアルステージ
										navigationSet("ステージクリア！", 100);
										game = 5;
									}else {
										game = 5;
										navigationSet("Thank you for playing!!")
										gcText.text = "プレイしてくれてありがとう！\n計画書の時点ではもっといろいろ盛ってたんだけど時間がなくて\nちょい難ゲームと化してました。\n\np.s.\nこれをクリアしたリア友にジュース一本おごります(4/6まで)\nクリックでメニューへ";
									}
								}
							}
						}
					}
				}
			}
			
			//通常障害物にて補正後赤障害物
			p1Rect = new Rectangle(p1.x, p1.y, p1.w, p1.h);
			for (i = 0; i < stages[stageNumber].objNum; i++){
				if (stages[stageNumber].objs[i] != null){
					if (stages[stageNumber].objs[i].type == 2){	//赤障害物
						if (p1.type >= 0){	//死んでないとき
							if (hitBox(p1Rect, stages[stageNumber].objs[i].rect)){
								//死亡処理
								p1.type = -1;
								p1.hp--;
								navigationSet("死亡", RESTART_COUNT);
							}
						}
					}
				}
			}
		}
		
		private function navigation():void	//ナビゲーションの動作処理
		{	
			if (navi.visible){	//動作中
				if (naviCount < NAVI_COUNT){	//上り動作
					navi.y -= (navi.y - NAVI_POINT.y) * 0.5;
					naviCount++;
				}else{
					navi.y += ((NAVI_POINT.y + navi.height) - navi.y) * 0.5;
					naviCount++;
					if ((NAVI_POINT.y + navi.height) - navi.y < 0.1){	//ほぼ近いなら	
						navi.y = (NAVI_POINT.y + navi.height);
						navi.visible = false;
					}
				}
			}
		}
		
		private function navigationSet(txt:String, time:int = 60):void
		{	//下にナビを出す
			navi.text = txt;
			navi.y = NAVI_POINT.y + navi.height;
			naviCount = 0;
			NAVI_COUNT = time;
			navi.visible = true;	//フラグ替わり
		}
		
		private function controlObj():void	//playerオブジェ処理
		{
			var i:uint = new int;
			if (mouseD){
				if(p1.type != -1){
					//マウスがどこにいても四角の描画をできるように
					if (stage.mouseX + cam.x > p1.objPos.x){	//左右
						p1.objs[p1.objsPr].rect.right = stage.mouseX + cam.x;
						p1.objs[p1.objsPr].rect.left = p1.objPos.x;
					}else{
						p1.objs[p1.objsPr].rect.left = stage.mouseX + cam.x;
						p1.objs[p1.objsPr].rect.right = p1.objPos.x;
					}
					if (stage.mouseY + cam.y < p1.objPos.y){	//上下
						p1.objs[p1.objsPr].rect.top = stage.mouseY + cam.y;
						p1.objs[p1.objsPr].rect.bottom = p1.objPos.y;
					}else{
						p1.objs[p1.objsPr].rect.bottom = stage.mouseY + cam.y;
						p1.objs[p1.objsPr].rect.top = p1.objPos.y;
					}
				}else{
					if (p1.objs[p1.objsPr].type == 4){
						p1.objs[p1.objsPr].type = -1;	//もう一回削除
						p1.objsPr = (p1.objsPr - 1 + p1.objNum) % p1.objNum;	//優先度を戻す
					}
				}
			}
			
			//消滅時間加算
			for (i = 0; i < p1.objNum; i++){
				if (p1.objs[i].type == 1){
					if(p1.objs[i].count != 0){	//カウント減算
						p1.objs[i].count--;
					}else{	//カウントなくなったら
						p1.objs[i].count = p1.objs[i].countT;	//カウントを戻す
						p1.objs[i].type = -1;	//消す
					}
				}
			}
			
		}
		
		private function enemyCtl():void
		{
			var i:uint = new uint;
			
			//敵の処理
			
			//移動処理
			for (i = 0; i < stages[stageNumber].eNum; i++){
				if (stages[stageNumber].enemys[i] != null ){
					if (stages[stageNumber].enemys[i].type == 0){
						if (stages[stageNumber].enemys[i].m){	//左
							stages[stageNumber].enemys[i].x += stages[stageNumber].enemys[i].sx;
						}else{									//右
							stages[stageNumber].enemys[i].x -= stages[stageNumber].enemys[i].sx;
						}
						
						//落下処理
						if (!stages[stageNumber].enemys[i].ground){
							stages[stageNumber].enemys[i].sy += g;
						}
						stages[stageNumber].enemys[i].y += stages[stageNumber].enemys[i].sy;
					}
					stages[stageNumber].enemys[i].ground = false;
				}
			}
		}
		
		private function playerHit():void
		{	
			//プレイヤーとの衝突処理(敵・アイテムなど)
			var  i:int = new int;
			var pRect:Rectangle = new Rectangle(p1.x, p1.y, p1.w, p1.h);
			var eRect:Rectangle = new Rectangle();
			
			for (i = 0; i < stages[stageNumber].eNum; i++){
				if (stages[stageNumber].enemys[i] != null ){
					if (stages[stageNumber].enemys[i].type == 0){
						eRect = new Rectangle(stages[stageNumber].enemys[i].x, stages[stageNumber].enemys[i].y, stages[stageNumber].enemys[i].w, stages[stageNumber].enemys[i].h);
						//通常的との衝突判定
						if (hitBox(pRect, eRect)){
							if (p1.type != -1){
								p1.hp--;
								p1.type = -1;
								navigationSet("死亡", RESTART_COUNT);
							}
						}
					}
				}
			}
		}
		
		private function stageReset():void
		{
			//ステージ作成
			if(stageNumber == 0){
				stages[0] = new Stage;
				{	//障害物・敵作成
					stages[0].objs[0] = new StObject(0, 0, 300, 200, 500);
					stages[0].objs[1] = new StObject(2, 200, 300, 100, 500);
					stages[0].objs[2] = new StObject(0, 300, 300, 100, 500);
					stages[0].objs[3] = new StObject(0, 400, 350, 100, 500);
					stages[0].objs[4] = new StObject(0, 500, 400, 100, 500);
					stages[0].objs[5] = new StObject(2, 600, 450, 200, 500);
					stages[0].objs[6] = new StObject(0, 900, 550, 100, 500);
					stages[0].objs[7] = new StObject(0, 1000, 600, 400, 500);
					stages[0].objs[8] = new StObject(0, 1400, 550, 50, 500);
					stages[0].objs[9] = new StObject(2, 1450, 600, 400, 500);
					stages[0].objs[10] = new StObject(0, 1620, 480, 80, 20);
					stages[0].objs[11] = new StObject(0, 1850, 550, 100, 500);
					stages[0].objs[12] = new StObject(2, 800, 550, 100, 1000);
					stages[0].objs[13] = new StObject(0, 1950, 550, 80, 10);
					stages[0].objs[14] = new StObject(0, 2150, 0, 100, 950);
					stages[0].objs[15] = new StObject(0, 2070, 650, 80, 10);
					stages[0].objs[16] = new StObject(0, 1950, 750, 80, 10);
					stages[0].objs[17] = new StObject(2, 2000, 850, 150, 50);
					stages[0].objs[18] = new StObject(0, 1950, 950, 80, 10);
					stages[0].objs[19] = new StObject(2, 1950, 1050, 1000, 500);
					stages[0].objs[20] = new StObject(3, 1950, 1000, 100, 100);
					stages[0].enemys[0] = new Enemy(0, 1100, 350);
					stages[0].enemys[1] = new Enemy(0, 1150, 350);
					stages[0].startPos = new Point(0, 280);
				}
			}else if (stageNumber == 1){
				stages[1] = new Stage;
				{	//障害物・敵作成
					stages[1].objs[0] = new StObject(0, 0, 3000, 1000, 900);
					stages[1].objs[1] = new StObject(0, 100, 3980, 20, 20);
					stages[1].objs[2] = new StObject(0, 800, 3980, 20, 20);
					stages[1].objs[3] = new StObject(0, 500, 3880, 20, 20);
					stages[1].objs[4] = new StObject(0, 1100, 3500, 100, 500);
					stages[1].objs[5] = new StObject(2, 1200, 3000, 100, 500);
					stages[1].objs[6] = new StObject(2, 1000, 3200, 50, 50);
					stages[1].objs[7] = new StObject(2, 1060, 3000, 50, 50);
					stages[1].objs[8] = new StObject(2, 700, 0, 300, 3500);
					stages[1].objs[9] = new StObject(2, 1000, 2700, 500, 100);
					stages[1].objs[10] = new StObject(0, 1190, 2990, 510, 20);
					stages[1].objs[11] = new StObject(0, 1300, 2850, 50, 140);
					stages[1].objs[12] = new StObject(0, 1700, 2980, 300, 20);
					stages[1].objs[13] = new StObject(0, 1500, 2700, 100, 200);
					stages[1].objs[14] = new StObject(2, 1800, 2700, 100, 200);
					stages[1].objs[15] = new StObject(2, 1800, 2950, 100, 400);
					stages[1].objs[16] = new StObject(0, 1600, 2700, 200, 100);
					stages[1].objs[17] = new StObject(2, 1900, 0, 1000, 2800);
					stages[1].objs[18] = new StObject(0, 2000, 2980, 20, 100);
					stages[1].objs[19] = new StObject(0, 2000, 3080, 500, 50);
					stages[1].objs[20] = new StObject(0, 2500, 2980, 20, 100);
					stages[1].objs[21] = new StObject(2, 2050, 2000, 400, 1030);
					stages[1].objs[22] = new StObject(2, 2520, 2980, 600, 100);
					stages[1].objs[23] = new StObject(2, 3120, 0, 600, 3080);
					stages[1].objs[24] = new StObject(2, 2900, 0, 10, 2600);
					stages[1].objs[25] = new StObject(2, 2900, 2500, 180, 20);
					stages[1].objs[26] = new StObject(2, 3110, 0, 10, 2450);
					stages[1].objs[27] = new StObject(2, 3000, 2350, 120, 20);
					stages[1].objs[28] = new StObject(0, 2950, 2700, 40, 40);
					stages[1].objs[29] = new StObject(2, 2900, 0, 10, 2250);
					stages[1].objs[30] = new StObject(2, 2900, 2250, 150, 20);
					stages[1].objs[31] = new StObject(2, 3110, 0, 10, 2000);
					stages[1].objs[32] = new StObject(2, 3000, 2000, 150, 20);
					stages[1].objs[32] = new StObject(3, 2900, 2000, 220, 100);
					stages[1].enemys[0] = new Enemy(0, 300, 3980);
					stages[1].enemys[1] = new Enemy(0, 350, 3980);
					stages[1].enemys[2] = new Enemy(0, 400, 3980);
					stages[1].enemys[3] = new Enemy(0, 1350, 2880);
					stages[1].enemys[4] = new Enemy(0, 2100, 3050);
					stages[1].enemys[5] = new Enemy(0, 2115, 3050);
					stages[1].enemys[6] = new Enemy(0, 2130, 3050);
					stages[1].enemys[7] = new Enemy(0, 2145, 3050);
					stages[1].enemys[8] = new Enemy(0, 2160, 3050);
					stages[1].enemys[9] = new Enemy(0, 2175, 3050);
					stages[1].enemys[10] = new Enemy(0, 2190, 3050);
					stages[1].enemys[11] = new Enemy(0, 2205, 3050);
					stages[1].enemys[12] = new Enemy(0, 2220, 3050);
					stages[1].enemys[13] = new Enemy(0, 2235, 3050);
					stages[1].enemys[14] = new Enemy(0, 2250, 3050);
					stages[1].startPos = new Point(0, 3980);
				}
			}else if (stageNumber == 2){
				stages[2] = new Stage;
				{
					//障害物・敵作成
					stages[2].objs[0] = new StObject(2, 100, 3800, 100, 100);
					stages[2].objs[1] = new StObject(0, 500, 3980, 20, 20);
					stages[2].objs[2] = new StObject(0, 800, 3980, 20, 20);
					stages[2].objs[3] = new StObject(2, 400, 3999, 50, 100);
					stages[2].objs[4] = new StObject(3, 1000, 3500, 50, 500);
					stages[2].enemys[0] = new Enemy(0, 600, 3980);
					stages[2].startPos = new Point(0, 3980);
				}
			}
			
			//プレイヤー戻す
			p1.type = 0;
			p1.x = stages[stageNumber].startPos.x;
			p1.sx = 0;
			p1.y = stages[stageNumber].startPos.y;
			p1.sy = 0;
			
			
			restartCount = RESTART_COUNT;
			bmp.alpha = 1;
			
			navigationSet("残機：" + p1.hp);
			game = 1;
		}
		
		private function keyUp(e:KeyboardEvent):void
		{
			keyCode[e.keyCode] = false;
		}
		
		private function keyDown(e:KeyboardEvent):void
		{
			keyCode[e.keyCode] = true;
			if (e.keyCode == 81){
				debugTxt.visible = !debugTxt.visible;
			}
			if (game == 1){	//ゲーム中
				if(p1.hp > 0){
					if (e.keyCode == 80){	//pキー
						game = 2;	//ポーズ画面へ推移
						pauseTxt.visible = true;
					}
					if (e.keyCode == 13){
						navigationSet("残機：" + p1.hp);
					}
					if (e.keyCode == 77){
						menuSet();
						game = 0;
					}
				}
			}else if (game == 2){	//ポーズ画面
				if (e.keyCode == 80){	//pキー
					game = 1;	//ゲーム画面へ推移
					pauseTxt.visible = false;
				}else if (e.keyCode == 27){	//escキー
					pauseTxt.visible = false;
					menuSet();
				}
			}else if (game == 0){	//隠しコマンド
				if (e.keyCode == 90){
					p1.hp = p1.chp;
					navigationSet("わーい\(^o^)/");
				}
			}
		}
		
		private function mouseUp(e:MouseEvent):void
		{
			mouseD = false;
			if (game == 1){
				if (p1.type != -1 && p1.objs[p1.objsPr].type == 4){
					if (hitBox(new Rectangle(p1.x, p1.y, p1.w, p1.h), p1.objs[p1.objsPr].rect)){	//設置場所にプレイヤーがいる場合
						//設置拒否処理
						p1.objs[p1.objsPr].type = -1;	//もう一回削除
						p1.objsPr = (p1.objsPr - 1 + p1.objNum) % p1.objNum;	//優先度を戻す
						navigationSet("プレイヤーとかぶっています");
						
					}else if (p1.objs[p1.objsPr].rect.width <= MIN_OBJ_W || p1.objs[p1.objsPr].rect.height <= MIN_OBJ_H) {
						p1.objs[p1.objsPr].type = -1;	//もう一回削除
						p1.objsPr = (p1.objsPr - 1 + p1.objNum) % p1.objNum;	//優先度を戻す
						navigationSet("ブロックが小さすぎます");
						
					}else{
						p1.objs[(p1.objsPr + 1) % p1.objNum].type = -1;	//四つつまで
						p1.objs[p1.objsPr].type = 1;	//オブジェ化
						p1.objs[p1.objsPr].count = p1.objs[p1.objsPr].countT;	//カウントを戻す
					}
				}
			}
		}
		
		private function mouseDown(e:MouseEvent):void
		{
			mouseD = true;
			if (game == 1){
				if (p1.type != -1){	//死亡してないとき
					p1.objsPr = (p1.objsPr + 1) % p1.objNum;	//優先度変更
					p1.objs[p1.objsPr].type = 4;	//設置中状態に
					//座標セット
					p1.objs[p1.objsPr].rect.x = stage.mouseX + cam.x;
					p1.objs[p1.objsPr].rect.y = stage.mouseY + cam.y;
					p1.objPos = new Point(stage.mouseX + cam.x, stage.mouseY + cam.y);
				}
			}else if (game == 0){	//メニュー画面
				if (menuText1.textColor == 0x000000){	//文字が濃いのは選択されているので
					menuText1.visible = false;
					menuText2.visible = false;
					game = 1;
					stageReset();
				}else if (menuText2.textColor == 0x000000){
					//操作説明へ
					menuText1.visible = false;
					menuText2.visible = false;
					howTo.visible = true;
					game = 4;
				}
			}else if (game == 3){	//ゲームオーバー
				goText.visible = false;
				menuSet();
			}else if (game == 4){	//操作説明画面
				howTo.visible = false;
				menuSet();
			}else if (game == 5){	//ステージクリアー
				gcText.text = "";
				gcText.visible = false;
				if (stageNumber < 1){
					stageNumber++;
					stageReset();
				}else{
					menuSet();
					stageNumber = 0;
				}
			}
		}
		
		private function hitBox(box1:Rectangle, box2:Rectangle):Boolean
		{
			if (box1.left > box2.right){	//左
			}else if (box1.right < box2.left){	//右
			}else if (box1.top > box2.bottom){
			}else if (box1.bottom < box2.top){
			}else {
				return true;
			}
			return false;
		}
		
		private function mText1_MouseOver(e:MouseEvent):void
		{
			menuText1.textColor = 0x000000;
		}
		
		private function mText1_MouseOut(e:MouseEvent):void
		{
			menuText1.textColor = 0x999999;
		}
		
		private function mText2_MouseOver(e:MouseEvent):void
		{
			menuText2.textColor = 0x000000;
		}
		
		private function mText2_MouseOut(e:MouseEvent):void
		{
			menuText2.textColor = 0x999999;
		}
		
		private function menuSet():void	//メニューセット
		{
			menuText1.visible = true;
			menuText2.visible = true;
			game = 0;
		}
		
	}
	
}