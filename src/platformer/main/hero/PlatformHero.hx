package platformer.main.hero;

import flambe.animation.AnimatedFloat;
import flambe.asset.AssetPack;
import flambe.display.Sprite;
import flambe.swf.Library;
import flambe.swf.MoviePlayer;
import flambe.util.Signal1;

import platformer.main.element.GameBody;
import platformer.main.tile.PlatformTile;
import platformer.main.utils.GameConstants;
import platformer.main.utils.IGrid;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformHero extends GameBody implements IGrid
{
	public var idx(default, null): Int;
	public var idy(default, null): Int;
	
	public var width(default, null): AnimatedFloat;
	public var height(default, null): AnimatedFloat;
	
	public var onTileChanged(default, null): Signal1<PlatformTile>;
	
	private var heroSprite: Sprite;
	private var heroLibrary: Library;
	private var heroMoviePlayer: MoviePlayer;
	
	private var curTile: PlatformTile;
	private var prevTile: PlatformTile;
	
	private var gameAsset: AssetPack;
	
	private static inline var HERO_ANIM_IDLE: String = "hero_idle";
	private static inline var HERO_ANIM_RUN: String = "hero_dash";
	private static inline var HERO_ANIM_PATH: String = "platformerassets/heroanim";
	
	public function new(gameAsset: AssetPack) {
		this.gameAsset = gameAsset;
		this.width = new AnimatedFloat(0.0);
		this.height = new AnimatedFloat(0.0);
		this.onTileChanged = new Signal1<PlatformTile>();
		super();
	}
	
	public function UpdateGridPosition(): Void {
		var tileIdx: Int = Math.floor(heroSprite.x._ / GameConstants.TILE_WIDTH);
		var tileIdy: Int = Math.floor(heroSprite.y._ / GameConstants.TILE_HEIGHT);
		SetGridID(tileIdx, tileIdy);
		SetTileChangedDirty();
	}
	
	public function SetTileChangedDirty(): Void {
		var baseRow: Int = Math.floor(x._ / GameConstants.TILE_WIDTH);
		var baseCol: Int = Math.floor(y._ / GameConstants.TILE_HEIGHT);
		
		var platformMain: PlatformMain = parent.get(PlatformMain);
		if (platformMain == null)
			return;
			
		var tileGrid: Array<Array<PlatformTile>> = platformMain.tileGrid;
		if (tileGrid == null)
			return;
		
		curTile = tileGrid[baseRow][baseCol];
		if (curTile != prevTile) {
			onTileChanged.emit(tileGrid[baseRow][baseCol]);
			prevTile = tileGrid[baseRow][baseCol];
		}
	}
	
	public function SetSize(width: Float, height: Float): Void {
		this.width._ = width;
		this.height._ = height;
	}
	
	public function SetAnimationDirty(isRunning: Bool): Void {
		if(heroMoviePlayer.looping) {
			heroMoviePlayer.loop(isRunning ? HERO_ANIM_RUN : HERO_ANIM_IDLE, false);
		}
	}
	
	public function DestroyBody(): Void {
		gameBody = null;
	}
	
	public function SetDeathPose(): Void {
		if(heroMoviePlayer.looping) {
			heroMoviePlayer.loop(HERO_ANIM_IDLE, false);
		}
	}
	
	override public function Init(): Void {
		super.Init();
		
		heroLibrary = new Library(gameAsset, HERO_ANIM_PATH);
		heroMoviePlayer = new MoviePlayer(heroLibrary);
		heroMoviePlayer.loop(HERO_ANIM_IDLE);
		
		heroSprite = new Sprite();
		heroSprite.centerAnchor();
	}
	
	override public function Draw(): Void {
		super.Draw();
		
		elementEntity.add(heroMoviePlayer);
		elementEntity.add(heroSprite);
	}
	
	override public function GetNaturalWidth():Float {
		return (heroSprite != null && heroSprite.getNaturalWidth() > 0) ? heroSprite.getNaturalWidth() : width._;
	}
	
	override public function GetNaturalHeight():Float {
		return (heroSprite != null && heroSprite.getNaturalHeight() > 0) ? heroSprite.getNaturalHeight() : height._;
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		if (heroSprite != null) {
			heroSprite.setAlpha(alpha._);
			heroSprite.setXY(x._, y._);
			heroSprite.setScale(scale._);
			heroSprite.setScaleXY(scaleX._, scaleY._);
			
			UpdateGridPosition();
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