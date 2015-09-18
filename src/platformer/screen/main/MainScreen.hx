package platformer.screen.main;

import flambe.asset.AssetPack;
import flambe.display.ImageSprite;
import flambe.Entity;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.subsystem.StorageSystem;
import flambe.System;

import platformer.core.SceneManager;
import platformer.main.PlatformMain;
import platformer.main.utils.GameConstants;
import platformer.name.AssetName;
import platformer.name.ScreenName;
import platformer.screen.GameScreen;

/**
 * ...
 * @author Anthony Ganzon
 */
class MainScreen extends GameScreen
{	
	public var platformMain(default, null): PlatformMain;
	
	public static var sharedInstance: MainScreen;
	
	public function new(assetPack: AssetPack, storage: StorageSystem) {		
		super(assetPack, storage);
		sharedInstance = this;
	}
	
	override public function CreateScreen(): Entity {
		screenEntity = super.CreateScreen();
		HideTitleText();

		var background: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_BACKGROUND));
		background.centerAnchor();
		background.setXY(System.stage.width / 2, System.stage.height / 2);
		background.setScaleXY(
			(System.stage.width / background.getNaturalWidth()) / 2 + (GameConstants.GAME_WIDTH / background.getNaturalWidth()) / 2,
			(System.stage.height / background.getNaturalHeight()) / 2 + (GameConstants.GAME_HEIGHT / background.getNaturalHeight()) / 2
		);
		AddToEntity(background);
		
		#if debug
		screenDisposer.add(System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (event.key == Key.P) {
				SceneManager.ShowControlsScreen();
			}
			
			if (event.key == Key.G) {
				SceneManager.ShowGameOverScreen();
			}
		}));
		#end
		
		return screenEntity;
	}
	
	public function CreatePlatformMain(streamingAsset: AssetPack): Void {
		platformMain = new PlatformMain(this, streamingAsset);
		AddToEntity(platformMain);
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_MAIN;
	}
}