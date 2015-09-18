package platformer.screen;

import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.Sprite;
import flambe.display.TextSprite;
import flambe.display.Texture;
import flambe.input.PointerEvent;

import platformer.main.element.GameElement;
import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameButton extends GameElement
{
	private var buttonNormalTexture: Texture;
	private var buttonHoverTexture: Texture;
	private var buttonDownTexture: Texture;
	
	private var buttonImage: ImageSprite;
	
	private var buttonTextFont: Font;
	private var buttonTextSprite: TextSprite;
	private var buttonText: String;
	
	private var buttonSprite: Sprite;
	private var buttonShowText: Bool;
	
	private var buttonFunc: Void->Void;
	
	public function new(buttonFont: Font, buttonText: String, textures: Array<Dynamic>, ?fn:Void->Void, showText: Bool = true) {
		super();
		this.buttonTextFont = buttonFont;
		this.buttonText = buttonText;
		this.buttonNormalTexture = textures[0];
		this.buttonHoverTexture = textures[1];
		this.buttonDownTexture = textures[2];
		this.buttonFunc = fn;
		this.buttonShowText = showText;
	}
	
	override public function Init(): Void {
		super.Init();
		
		elementEntity.add(buttonSprite = new Sprite());
			
		buttonImage = new ImageSprite(buttonNormalTexture);
		buttonImage.centerAnchor();
		
		if(buttonShowText) {
			buttonTextSprite = new TextSprite(buttonTextFont, buttonText);
			buttonTextSprite.centerAnchor();
		}		
	}
	
	override public function Draw(): Void {
		AddToEntity(buttonImage);
		AddToEntity(buttonTextSprite);	
	}
	
	public function ButtonInteractive(): Void {
		elementDisposer.add(
			buttonSprite.pointerIn.connect(function(event: PointerEvent) {
				if(buttonHoverTexture != null) {
					buttonImage.texture = buttonHoverTexture;
				}
			})
		);
		
		elementDisposer.add(
			buttonSprite.pointerOut.connect(function(event: PointerEvent) {
				if(buttonNormalTexture != null) {	
					buttonImage.texture = buttonNormalTexture;
				}
			})
		);
		
		elementDisposer.add(
			buttonSprite.pointerDown.connect(function(event: PointerEvent) {
				if(buttonDownTexture != null) {	
					buttonImage.texture = buttonDownTexture;
				}
			})
		);
		
		elementDisposer.add(
			buttonSprite.pointerUp.connect(function(event: PointerEvent) {
				buttonImage.texture = (buttonHoverTexture != null) ? buttonHoverTexture : buttonNormalTexture;
				
				Utils.ConsoleLog("[BUTTON] " + buttonText);
				if (buttonFunc != null) {
					buttonFunc();
				}
			})
		);
	}
	
	override public function GetNaturalWidth():Float {
		return buttonImage.getNaturalWidth();
	}
	
	override public function GetNaturalHeight():Float {
		return buttonImage.getNaturalHeight();
	}
	
	override public function onStart() {
		super.onStart();
		
		ButtonInteractive();
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		if (buttonSprite != null) {
			buttonSprite.setAlpha(this.alpha._);
			buttonSprite.setXY(this.x._, this.y._);
			buttonSprite.setScaleXY(this.scaleX._, this.scaleY._);
		}
	}
}