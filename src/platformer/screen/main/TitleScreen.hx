package platformer.screen.main;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.ImageSprite;
import flambe.Entity;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.script.AnimateTo;
import flambe.script.Repeat;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.subsystem.StorageSystem;
import flambe.System;
import flambe.util.Promise;

import platformer.core.SceneManager;
import platformer.main.utils.GameConstants;
import platformer.name.AssetName;
import platformer.name.ScreenName;

import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class TitleScreen extends GameScreen
{		
	public static inline var STREAMING_ASSET_PACK: String = "streamingassets";
	
	public function new(assetPack: AssetPack, storage: StorageSystem) {		
		super(assetPack, storage);
	}
	
	override public function CreateScreen(): Entity {
		screenEntity = super.CreateScreen();
		HideTitleText();
		HideBackground();
		
		var background: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_BACKGROUND));
		background.centerAnchor();
		background.setXY(System.stage.width / 2, System.stage.height / 2);
		background.setScaleXY(
			(System.stage.width / background.getNaturalWidth()) / 2 + (GameConstants.GAME_WIDTH / background.getNaturalWidth()) / 2,
			(System.stage.height / background.getNaturalHeight()) / 2 + (GameConstants.GAME_HEIGHT / background.getNaturalHeight()) / 2
		);
		AddToEntity(background);
		
		var title: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_GAME_TITLE));
		title.centerAnchor();
		title.setXY(System.stage.width / 2, System.stage.height * 0.3);
		AddToEntity(title);
		
		var spaceToStart: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_GAME_START));
		spaceToStart.centerAnchor();
		spaceToStart.setXY(System.stage.width / 2, System.stage.height * 0.7);
		AddToEntity(spaceToStart);
		
		var blinkScript: Script = new Script();
		blinkScript.run(new Repeat(new Sequence([
			new AnimateTo(spaceToStart.alpha, 0.25, 0.5),
			new AnimateTo(spaceToStart.alpha, 1, 0.5)
		])));
		AddToEntity(blinkScript);
		
		screenDisposer.add(System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (event.key == Key.Space) {
				var promise: Promise<AssetPack> = System.loadAssetPack(Manifest.fromAssets(STREAMING_ASSET_PACK));
				promise.get(function(streamingAsset: AssetPack) {
					Utils.ConsoleLog("Streaming Asset loaded!");
					SceneManager.ShowMainScreen();
					MainScreen.sharedInstance.CreatePlatformMain(streamingAsset);
					//SceneManager.sharedInstance.gameMainScreen.CreatePlatformMain(streamingAsset);
				});

				SceneManager.ShowScreen(new PreloadScreen(gameAsset, promise));
			}
		}));
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_TITLE;
	}
}