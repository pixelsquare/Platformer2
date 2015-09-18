package platformer.core;

import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.math.FMath;
import flambe.scene.Director;
import flambe.scene.FadeTransition;
import flambe.subsystem.StorageSystem;
import flambe.System;

import platformer.screen.GameScreen;
import platformer.screen.main.ControlsScreen;
import platformer.screen.main.GameOverScreen;
import platformer.screen.main.MainScreen;
import platformer.screen.main.TitleScreen;

import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class SceneManager
{
	public var gameTitleScreen(default, null): TitleScreen;
	public var gameMainScreen(default, null): MainScreen;
	public var gameControlScreen(default, null): ControlsScreen;
	public var gameOverScreen(default, null): GameOverScreen;
	public var gameDirector(default, null): Director;
	
	private var gameScreenList: Array<GameScreen>;
	
	public static var sharedInstance(default, null): SceneManager;
	public static var curSceneEntity(default, null): Entity;
	
	private static inline var DURATION_SHORT: Float = 0.5;
	private static inline var DURATION_LONG: Int = 1;
	
	public static inline var TARGET_WIDTH: 	Int = 640;
	public static inline var TARGET_HEIGHT: Int = 800;
	
	public function new(director: Director) {
		sharedInstance = this;
		gameDirector = director;
	}
	
	public function InitScreens(assetPack: AssetPack, storage: StorageSystem): Void {
		AddGameScreen(gameTitleScreen = new TitleScreen(assetPack, storage));
		AddGameScreen(gameMainScreen = new MainScreen(assetPack, storage));
		AddGameScreen(gameControlScreen = new ControlsScreen(assetPack, storage));
		AddGameScreen(gameOverScreen = new GameOverScreen(assetPack, storage));
		
		System.stage.resize.connect(onResize);
	}
	
	private function AddGameScreen(screen: GameScreen) : Void {
		if (gameScreenList == null) {
			gameScreenList = new Array<GameScreen>();
		}
		
		gameScreenList.push(screen);
	}
	
	public function onResize(): Void {
		var targetWidth: Float = 800;
		var targetHeight: Float = 800;
		
		var scale: Float = FMath.min(System.stage.width / targetWidth, System.stage.height / targetHeight);
		if (scale > 1) scale = 1;
		
		gameDirector.topScene.get(Sprite)
		.setScale(scale)
		.setXY((System.stage.width - targetWidth * scale) / 2, (System.stage.height - targetHeight * scale) / 2);
	}
	
	public static function UnwindToCurScene(): Void {
		sharedInstance.gameDirector.unwindToScene(curSceneEntity);
	}
	
	public static function UnwindToScene(scene: Entity): Void {
		sharedInstance.gameDirector.unwindToScene(scene);
	}
	
	public static function ShowScreen(gameScreen: GameScreen, willAnimate: Bool = false): Void {
		Utils.ConsoleLog("SHOW SCREEN [" + gameScreen.GetScreenName() + "]");
		sharedInstance.gameDirector.unwindToScene(gameScreen.CreateScreen(),
			willAnimate ? new FadeTransition(DURATION_SHORT, Ease.linear) : null);
		curSceneEntity = gameScreen.screenEntity;
	}
	
	public static function ShowTitleScreen(willAnimate: Bool = false): Void {
		Utils.ConsoleLog("SHOWING [" + sharedInstance.gameTitleScreen.GetScreenName() + "]");
		sharedInstance.gameDirector.unwindToScene(sharedInstance.gameTitleScreen.CreateScreen(),
			willAnimate ? new FadeTransition(DURATION_SHORT, Ease.linear) : null);
		curSceneEntity = sharedInstance.gameTitleScreen.screenEntity;
	}
	
	public static function ShowMainScreen(willAnimate: Bool = false): Void {
		Utils.ConsoleLog("SHOWING [" + sharedInstance.gameMainScreen.GetScreenName() + "]");
		sharedInstance.gameDirector.unwindToScene(sharedInstance.gameMainScreen.CreateScreen(),
			willAnimate ? new FadeTransition(DURATION_SHORT, Ease.linear) : null);
		curSceneEntity = sharedInstance.gameMainScreen.screenEntity;
	}
	
	public static function ShowControlsScreen(willAnimate: Bool = false): Void {	
		Utils.ConsoleLog("SHOWING [" + sharedInstance.gameControlScreen.GetScreenName() + "]");
		UnwindToCurScene();
		sharedInstance.gameDirector.pushScene(sharedInstance.gameControlScreen.CreateScreen());
	}
	
	public static function ShowGameOverScreen(willAnimate: Bool = false) : Void {
		Utils.ConsoleLog("SHOWING [" + sharedInstance.gameOverScreen.GetScreenName() + "]");
		UnwindToCurScene();
		sharedInstance.gameDirector.pushScene(sharedInstance.gameOverScreen.CreateScreen());
	}
}