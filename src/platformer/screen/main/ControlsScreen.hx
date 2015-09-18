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

import platformer.core.SceneManager;
import platformer.name.AssetName;
import platformer.name.ScreenName;
import platformer.screen.GameScreen;
import platformer.main.PlatformMain;

/**
 * ...
 * @author Anthony Ganzon
 */
class ControlsScreen extends GameScreen
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
		
		var controlsImg: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_GAME_CONTROLS));
		controlsImg.centerAnchor();
		controlsImg.setXY(System.stage.width / 2, System.stage.height / 2);
		AddToEntity(controlsImg);
		
		var spaceToContinue: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_GAME_CONTINUE));
		spaceToContinue.centerAnchor();
		spaceToContinue.setXY(System.stage.width / 2, System.stage.height * 0.85);
		AddToEntity(spaceToContinue);
		
		var blinkScript: Script = new Script();
		blinkScript.run(new Repeat(new Sequence([
			new AnimateTo(spaceToContinue.alpha, 0.25, 0.5),
			new AnimateTo(spaceToContinue.alpha, 1, 0.5)
		])));
		AddToEntity(blinkScript);
		
		screenDisposer.add(System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (event.key == Key.Space) {
				SceneManager.UnwindToCurScene();
				PlatformMain.sharedInstance.isGameStart = true;
				
			}
		}));
		
		return screenEntity;
	}
	
	override public function GetScreenName():String {
		return ScreenName.SCREEN_CONTROLS;
	}	
}