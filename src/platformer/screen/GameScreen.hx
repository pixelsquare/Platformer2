package platformer.screen;

import flambe.asset.AssetPack;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.Font;
import flambe.display.TextSprite;
import flambe.Disposer;
import flambe.Entity;
import flambe.scene.Scene;
import flambe.subsystem.StorageSystem;
import flambe.System;

import platformer.core.DataManager;
import platformer.name.FontName;
import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameScreen extends DataManager
{	
	public var screenEntity(default, null): Entity;
	
	private var screenScene: Scene;
	private var screenDisposer: Disposer;
	
	private var screenBackground: FillSprite;
	private var screenTitleText: TextSprite;
	
	private static inline var DEFAULT_BG_COLOR: Int = 0x202020;
	
	public function new(assetPack: AssetPack, storage: StorageSystem) {		
		super(assetPack, storage);
	}
	
	public function CreateScreen(): Entity {
		screenEntity = new Entity()
			.add(screenScene = new Scene(false))
			.add(screenDisposer = new Disposer());
			
		screenBackground = new FillSprite(DEFAULT_BG_COLOR, System.stage.width, System.stage.height);
		AddToEntity(screenBackground);
		
		var screenTitleFont: Font = new Font(gameAsset, FontName.FONT_VANADINE_32);
		screenTitleText = new TextSprite(screenTitleFont, GetScreenName());
		screenTitleText.centerAnchor();
		screenTitleText.setXY(
			System.stage.width / 2,
			System.stage.height / 2
		);
		AddToEntity(screenTitleText);
		
		return screenEntity;
	}
	
	public function ShowScreen(): Void { }
	
	public function HideScreen(): Void { }
	
	public function GetScreenName(): String {
		return "";
	}
	
	private function HideBackground(): Void {
		screenBackground.visible = false;
	}
	
	private function HideTitleText(): Void {
		screenTitleText.visible = false;
	}
	
	public function AddToEntity(component: Component, append: Bool = true): Void {
		if (component == null) {
			Utils.ConsoleLog("Cannot add nulled components. [" + component.name + "]");
			return;
		}
		
		screenEntity.addChild(new Entity().add(component), append);
	}
	
	public function RemoveEntity(component: Component): Void {
		if (component == null) {
			Utils.ConsoleLog("Cannot remove nulled components. [" + component.name + "]");
			return;
		}
		
		screenEntity.removeChild(new Entity().add(component));
	}
	
	public function RemoveAndDispose(component: Component): Void {
		RemoveEntity(component);
		component.dispose();
	}
}