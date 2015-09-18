package platformer.screen;

import flambe.asset.AssetPack;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.PatternSprite;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.System;
import flambe.util.Promise;

import platformer.name.AssetName;
import platformer.name.FontName;
import platformer.name.ScreenName;

/**
 * ...
 * @author Anthony Ganzon
 */
class PreloadScreen extends GameScreen
{
	private var promise: Promise<Dynamic>;
	private var loadingText: TextSprite;
	
	private static inline var PROGRESS_BAR_PADDING: Int = 50;
	
	public function new(preloadPack: AssetPack, promise: Promise<Dynamic>) {
		super(preloadPack, null);
		
		this.promise = promise;
	}
	
	override public function CreateScreen(): Entity {
		screenEntity = super.CreateScreen();
		screenBackground.color = 0x202020;
		HideTitleText();
		
		var loadingFont: Font = new Font(gameAsset, FontName.FONT_VANADINE_32);
		loadingText = new TextSprite(loadingFont, "LOADING | 0%");
		loadingText.centerAnchor();
		loadingText.setXY(System.stage.width / 2, System.stage.height * 0.45);
		AddToEntity(loadingText);
		
		var progressLeft: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.PROGRESS_LEFT));
		var progressRight: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.PROGRESS_RIGHT));
		
		var totalWidth: Float = System.stage.width - progressLeft.texture.width - progressRight.texture.width - 2 * PROGRESS_BAR_PADDING;
		var yOffset: Float = System.stage.height / 2 - progressLeft.texture.height / 2;
		
		progressLeft.setXY(PROGRESS_BAR_PADDING, yOffset);
		AddToEntity(progressLeft);
		
		var progressBg: PatternSprite = new PatternSprite(gameAsset.getTexture(AssetName.PROGRESS_BG), totalWidth);
		progressBg.setXY(progressLeft.x._ + progressLeft.texture.width, yOffset);
		AddToEntity(progressBg);
		
		var progressFill: PatternSprite = new PatternSprite(gameAsset.getTexture(AssetName.PROGRESS_FILL));
		progressFill.setXY(progressBg.x._, yOffset);
		
		promise.progressChanged.connect(function() {
			progressFill.width._ = promise.progress / promise.total * totalWidth;
			SetLoadingTextDirty();
		});
		AddToEntity(progressFill);
		
		progressRight.setXY(progressFill.x._ + totalWidth, yOffset);
		AddToEntity(progressRight);
		
		return screenEntity;
	}
	
	public function SetLoadingTextDirty(): Void {
		loadingText.text = "LOADING | " + Std.int(promise.progress / promise.total * 100) + "%";
		loadingText.centerAnchor();
		loadingText.setXY(System.stage.width / 2, System.stage.height * 0.45);
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_PRELOAD;
	}
}