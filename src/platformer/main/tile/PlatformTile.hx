package platformer.main.tile;

import flambe.animation.AnimatedFloat;
import flambe.display.ImageSprite;
import flambe.display.Texture;

import platformer.main.element.GameBody;
import platformer.main.element.GameElement;
import platformer.main.tile.utils.TileDataType;
import platformer.main.tile.utils.TileType;
import platformer.main.utils.IGrid;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformTile extends GameBody implements IGrid
{
	public var idx(default, null): Int;
	public var idy(default, null): Int;
	
	public var width(default, null): AnimatedFloat;
	public var height(default, null): AnimatedFloat;

	public var tileType(default, null): TileType;
	public var tileDataType(default, null): TileDataType;
	
	private var tileTexture: Texture;
	private var tileImage: ImageSprite;
	
	public function new() {
		this.width = new AnimatedFloat(0.0);
		this.height = new AnimatedFloat(0.0);
		this.tileType = TileType.NONE;
		this.tileDataType = TileDataType.NONE;
		this.tileTexture = null;
		
		super();
	}
	
	public function SetSize(width: Float, height: Float): Void {
		this.width._ = width;
		this.height._ = height;
	}
	
	public function SetTileTexture(texture: Texture): Void {
		this.tileTexture = texture;
	}
	
	public function SetTileDataType(dataType: TileDataType): Void {
		this.tileDataType = dataType;
	}
	
	public function SetTileType(tileType: TileType): Void {
		this.tileType = tileType;
	}
	
	public function Reset(): Void {
		this.tileTexture = null;
		this.tileType = TileType.NONE;
		this.tileDataType = TileDataType.NONE;
		//this.gameBodyLayer = 0;
	}
	
	override public function Init(): Void {
		super.Init();
		
		if (tileTexture == null)
			return;
		
		tileImage = new ImageSprite(tileTexture);
		tileImage.centerAnchor();
	}
	
	override public function Draw(): Void {
		super.Draw();
		
		if (tileTexture == null || tileImage == null)
			return;
			
		AddToEntity(tileImage);
	}
	
	override public function SetVisibility(visible:Bool): GameElement {
		tileImage.visible = visible;
		return super.SetVisibility(visible);
	}
	
	override public function GetNaturalWidth(): Float {
		return (tileImage != null) ? tileImage.getNaturalWidth() : width._;
	}
	
	override public function GetNaturalHeight(): Float {
		return (tileImage != null) ? tileImage.getNaturalHeight() : height._;
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		if (tileImage != null) {
			tileImage.setAlpha(alpha._);
			tileImage.setXY(x._, y._);
			tileImage.setScale(scale._);
			tileImage.setScaleXY(scaleX._, scaleY._);
			tileImage.setRotation(rotation._);
		}
	}
	
	/* INTERFACE platformer.main.utils.IGrid */
	
	public function SetGridID(idx:Int, idy:Int, updatePosition:Bool = false): Void {
		this.idx = idx;
		this.idy = idy;
	}
	
	public function GridIDToString(): String {
		return "Grid [" + this.idx + "," + this.idy + "]";
	}
}