package platformer.main.hero;

import flambe.Component;
import flambe.Disposer;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.System;

import nape.geom.Vec2;
import nape.phys.Body;

import platformer.main.hero.utils.HeroDirection;
import platformer.main.PlatformMain;
import platformer.main.tile.PlatformTile;
import platformer.main.utils.GameConstants;
import platformer.main.tile.utils.TileDataType;
import platformer.main.tile.utils.TileType;

import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformHeroControl extends Component
{
	public var heroDirection(default, null): HeroDirection;
	public var isHeroRunning(default, null): Bool;
	public var isHeroGrounded(default, null): Bool;
	
	private var platformHero: PlatformHero;
	private var platformMain: PlatformMain;
	private var heroBody: Body;
	private var tileGrid: Array<Array<PlatformTile>>;
	
	private var controlDisposer: Disposer;
	
	private static inline var JUMP_FORCE: Float = -20;
	
	public function new () { 
		this.heroDirection = HeroDirection.NONE;
		this.isHeroRunning = false;
		this.isHeroGrounded = false;
	}
	
	public function SetHeroDirection(direction: HeroDirection): Void {
		heroDirection = direction;
		SetHeroFacingDirty();
	}
	
	public function SetHeroFacingDirty(): Void {
		// We return back the call if there are no hero attached
		if (platformHero == null || heroDirection == HeroDirection.NONE)
			return;
		
		if (heroDirection == HeroDirection.LEFT) {
			platformHero.scaleX._ = -Math.abs(platformHero.scaleX._);
		}
		
		if (heroDirection == HeroDirection.RIGHT) {
			platformHero.scaleX._ = Math.abs(platformHero.scaleX._);
		}
	}
	
	override public function onAdded() {
		super.onAdded();
		
		platformHero = owner.get(PlatformHero);
		platformMain = platformHero.parent.get(PlatformMain);
		heroBody = platformHero.gameBody;
		
		controlDisposer = owner.get(Disposer);
		if (controlDisposer == null) {
			owner.add(controlDisposer = new Disposer());
		}
		
		var curTile: PlatformTile = null;
		controlDisposer.add(platformHero.onTileChanged.connect(function(tile: PlatformTile) {
			curTile = tile;
		}));
		
		controlDisposer.add(System.keyboard.down.connect(function(event: KeyboardEvent) {
			if (!PlatformMain.sharedInstance.isGameStart)
				return;
			
			if (event.key == Key.W || event.key == Key.Up) {
				if(curTile.tileDataType == TileDataType.DOOR && curTile.tileType == TileType.DOOR_OUT) {
					PlatformMain.sharedInstance.LoadNextRoom();
				}
			}
			
			if (event.key == Key.Space) {
				if (!isHeroGrounded)
					return;
				
				heroBody.applyImpulse(Vec2.weak(0, JUMP_FORCE));
			}
		}));
	}
	
	override public function onUpdate(dt:Float) {	
		super.onUpdate(dt);
		
		// Don't update when there is no hero
		if (platformHero == null || !PlatformMain.sharedInstance.isGameStart)
			return;
			
		isHeroRunning = false;
		isHeroGrounded = false;
		heroDirection = HeroDirection.NONE;
		tileGrid = platformMain.tileGrid;
			
		heroBody = platformHero.gameBody;
		heroBody.velocity.x = 0;
		
		if (System.keyboard.isDown(Key.D) || System.keyboard.isDown(Key.Right)) {		
			if (heroDirection == HeroDirection.LEFT) {
				heroBody.velocity.x = 0;
				isHeroRunning = false;
			}
			else {
				if (platformHero.x._ < GameConstants.GRID_ROWS * GameConstants.TILE_WIDTH - (GameConstants.TILE_WIDTH / 2)) {
					heroBody.velocity.x = 100;
					isHeroRunning = true;
				}
				else {
					heroBody.velocity.x = 0;
					isHeroRunning = false;
				}
			}
			heroDirection = HeroDirection.RIGHT;
			SetHeroFacingDirty();
		}
		
		if (System.keyboard.isDown(Key.A) || System.keyboard.isDown(Key.Left)) {
			if (heroDirection == HeroDirection.RIGHT) {
				heroBody.velocity.x = 0;
				isHeroRunning = false;
			}
			else {
				if (platformHero.x._ > (GameConstants.TILE_WIDTH / 2)) {
					heroBody.velocity.x = -100;
					isHeroRunning = true;
				}
				else {
					heroBody.velocity.x = 0;
					isHeroRunning = false;
				}
			}
			heroDirection = HeroDirection.LEFT;
			SetHeroFacingDirty();
		}
		
		var idx: Int = Math.floor(platformHero.x._ / GameConstants.TILE_WIDTH);
		var idy: Int = Math.floor((platformHero.y._ - 20) / GameConstants.TILE_HEIGHT);
		var postBottomTile: PlatformTile = tileGrid[idx][idy + 1];
		
		if (heroBody.velocity.y > -5 && heroBody.velocity.y < 5) {
			if(heroBody.arbiters.length > 0 && postBottomTile.gameBodyLayer != 0) {
				isHeroGrounded = true;
			}
		}
		
		idx = platformHero.idx;
		idy = platformHero.idy;
		var bottomTile: PlatformTile = tileGrid[idx][idy + 1];
		//if(!isHeroGrounded && bottomTile != null) {
			if (heroBody.velocity.y >= 0 && bottomTile.gameBodyLayer != 0) {
				platformHero.gameBody.shapes.at(0).filter.collisionMask = bottomTile.gameBodyLayer;
			}
		//}
		
		platformHero.SetAnimationDirty(isHeroRunning);
	}
}