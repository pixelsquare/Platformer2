package platformer.screen.main;

import flambe.asset.AssetPack;
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
import flambe.display.Texture;

import platformer.core.SceneManager;
import platformer.name.AssetName;
import platformer.name.ScreenName;
import platformer.screen.GameScreen;
import platformer.main.PlatformMain;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameOverScreen extends GameScreen
{
	public function new(assetPack: AssetPack, storage: StorageSystem) {		
		super(assetPack, storage);
	}
	
	override public function CreateScreen():Entity {
		screenEntity = super.CreateScreen();
		screenBackground.color = 0xFFFFFF;
		screenBackground.alpha.animate(0, 0.5, 0.5);
		HideTitleText();
		//HideBackground();
		
		var titleTexture: Texture = (PlatformMain.sharedInstance.didWin) ? gameAsset.getTexture(AssetName.ASSET_GAME_WIN) : gameAsset.getTexture(AssetName.ASSET_GAME_OVER);
		var title: ImageSprite = new ImageSprite(titleTexture);
		title.centerAnchor();
		title.setXY(System.stage.width / 2, System.stage.height * 0.3);
		AddToEntity(title);
		
		var spaceToMenu: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_GAME_MENU));
		spaceToMenu.centerAnchor();
		spaceToMenu.setXY(System.stage.width / 2, System.stage.height * 0.7);
		AddToEntity(spaceToMenu);
		
		var blinkScript: Script = new Script();
		blinkScript.run(new Repeat(new Sequence([
			new AnimateTo(spaceToMenu.alpha, 0.25, 0.5),
			new AnimateTo(spaceToMenu.alpha, 1, 0.5)
		])));
		AddToEntity(blinkScript);
		
		screenDisposer.add(System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (event.key == Key.Space) {
				SceneManager.UnwindToCurScene();
				SceneManager.ShowTitleScreen();
			}
		}));
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_GAME_OVER;
	}
}