package platformer.main;

import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.asset.File;
import flambe.Component;
import flambe.debug.FpsDisplay;
import flambe.display.FillSprite;
import flambe.display.Font;
import flambe.display.SubTexture;
import flambe.display.TextSprite;
import flambe.display.Texture;
import flambe.Disposer;
import flambe.Entity;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.script.AnimateTo;
import flambe.script.CallFunction;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.sound.Playback;
import flambe.System;
import flambe.math.FMath;
import haxe.Json;

import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.shape.Polygon;
import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.BodyType;
import nape.space.Space;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionType;
import nape.phys.Material;
import nape.shape.Circle;

import platformer.core.DataManager;
import platformer.core.SceneManager;
import platformer.main.format.RoomFormat;
import platformer.main.hero.PlatformHero;
import platformer.main.hero.PlatformHeroControl;
import platformer.main.hero.utils.HeroDirection;
import platformer.main.tile.PlatformTile;
import platformer.main.tile.utils.TileDataType;
import platformer.main.tile.utils.TileType;
import platformer.main.utils.GameConstants;
import platformer.name.AssetName;
import platformer.name.FontName;

import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformMain extends Component
{
	public var dataManager(default, null): DataManager;
	public var streamingAsset(default, null): AssetPack;
	
	public var curRoomIndx(default, null): Int;
	public var tileList(default, null): Map<TileType, Texture>;
	public var tileGrid(default, null): Array<Array<PlatformTile>>;
	
	public var tilesEntity(default, null): Entity;
	public var heroEntity(default, null): Entity;
	
	public var didWin(default, null): Bool;
	public var isGameStart: Bool;
	public var isGameOver(default, null): Bool;
	
	public var gameSpace(default, null): Space;
	
	public var heroBodyCbType(default, null): CbType;
	public var doorBodyCbType(default, null): CbType;
	public var blockBodyCbType(default, null): CbType;
	public var obstacleBodyCbType(default, null): CbType;
	
	public var allTiles: Array<PlatformTile>;
	
	private var platformHero: PlatformHero;
	private var platformHeroControl: PlatformHeroControl;
	
	private var gameAsset: AssetPack;
	private var roomDataJson: RoomFormat;
	
	private var bgm: Playback;
	private var bgmToggle: Bool;
	private var audioText: TextSprite;
	
	private var fpsEntity: Entity;
	private var platformDisposer: Disposer;
	private var heroSignalDisposer: Disposer;
	
	//#if flash
	//private var debug: nape.util.ShapeDebug;
	//#end
	
	public static var sharedInstance: PlatformMain;
	
	private static inline var BGM_PATH: String = "audio/bgm/";
	private static inline var BGM_NAME: String = "Synthony";
	private static inline var BGM_VOLUME: Float = 0.5;
	
	private static inline var ROOM_DATA_PATH: String = "roomdata/RoomData_";
	private static inline var ROOM_DATA_EXT: String = ".json";
	
	private static inline var ROOM_MAX: Int = 5;
	private static inline var GAME_GRAVITY: Float = 1000;
	
	public function new(dataManager: DataManager, streamingAsset: AssetPack) {
		this.dataManager = dataManager;
		this.streamingAsset = streamingAsset;
		
		this.curRoomIndx = 1;
		this.tileList = new Map<TileType, Texture>();
		this.tileGrid = new Array<Array<PlatformTile>>();
		
		this.tilesEntity = new Entity();
		this.heroEntity = new Entity();
		
		this.didWin = false;
		this.isGameStart = false;
		this.isGameOver = false;
		
		this.allTiles = new Array<PlatformTile>();
		
		this.gameAsset = dataManager.gameAsset;
		this.gameSpace = new Space(Vec2.weak(0, GAME_GRAVITY));
		
		this.heroBodyCbType = new CbType();
		this.doorBodyCbType = new CbType();
		this.blockBodyCbType = new CbType();
		this.obstacleBodyCbType = new CbType();
		
		this.bgmToggle = true;
		this.heroSignalDisposer = new Disposer();
		
		//#if flash
		//debug = new nape.util.ShapeDebug(System.stage.width, System.stage.height);
		//flash.Lib.current.stage.addChild(debug.display);
		//#end
		
		sharedInstance = this;
		
		InitTileTypes();
		LoadRoomData(curRoomIndx);
	}
	
	public function InitTileTypes(): Void {
		tileList = new Map<TileType, Texture>();
		
		var tileTexture: Texture = gameAsset.getTexture(AssetName.ASSET_TILES);
		var tiles: Array<SubTexture> = tileTexture.split(
			Std.int(tileTexture.width / GameConstants.TILE_WIDTH), 
			Std.int(tileTexture.height / GameConstants.TILE_HEIGHT)
		);
		
		for (i in 0...tiles.length) {
			var tileType: TileType = Type.allEnums(TileType)[i + 1];
			tileList.set(tileType, tiles[i]);
		}
		
		tileList.set(TileType.SPIKE_UP, gameAsset.getTexture(AssetName.ASSET_SPIKE_UP));
		tileList.set(TileType.SPIKE_DOWN, gameAsset.getTexture(AssetName.ASSET_SPIKE_DOWN));
		tileList.set(TileType.DOOR_IN, gameAsset.getTexture(AssetName.ASSET_DOOR_CLOSE));
		tileList.set(TileType.DOOR_OUT, gameAsset.getTexture(AssetName.ASSET_DOOR_OPEN));
	}
	
	public function LoadRoomData(roomIndx: Int = 1): Void {
		if (roomIndx == 0 || roomIndx > ROOM_MAX)
			return;
		
		Utils.ConsoleLog("Reading room data " + roomIndx);
		
		var roomFile: File = streamingAsset.getFile(ROOM_DATA_PATH + Std.string(roomIndx) + ROOM_DATA_EXT);
		roomDataJson = Json.parse(roomFile.toString());
		curRoomIndx = roomIndx;
	}
	
	public function LoadRoom(roomIndx: Int = 1): Void {
		if (allTiles.length > 0)
			return;
			
		Utils.ConsoleLog("Loading Room " + roomIndx);
			
		ResetRoomTiles();
		LoadRoomData(roomIndx);
		CreateRoomBackground();
		CreateRoomBlocks();
		CreateRoomObstacles();
		CreateRoomDoors();
		SetBlockLayers();
		DrawAllTiles();
		
		CreatePlatformHero();
		ShowAudioIndicator();
		ShowScreenCurtain();
		ShowFPS();
	}
	
	public function LoadNextRoom(): Void {
		var curIndx: Int = curRoomIndx;
		curIndx++;
		
		if (curIndx > ROOM_MAX) {
			Utils.ConsoleLog("WIN!");
			OnGameEnd(true);
			return;
		}
		
		ClearStage();
		CreateRoomTiles();
		LoadRoom(curIndx);
	}
	
	public function LoadPrevRoom(): Void {
		var curIndx: Int = curRoomIndx;
		curIndx--;
		
		if (curIndx <= 0)
			return;
			
		ClearStage();
		CreateRoomTiles();
		LoadRoom(curIndx);
	}
	
	public function CreatePlatformHero(): Void {
		var doorIn: PlatformTile = GetTileOfType(TileType.DOOR_IN);
		if (doorIn == null) {
			Utils.ConsoleLog("Door in not specified!");
			return;
		}
		
		heroEntity = new Entity();
		platformHero = new PlatformHero(gameAsset);
		platformHero.SetParent(owner);
		platformHero.SetXY(doorIn.x._, doorIn.y._);
		platformHero.SetSize(GameConstants.TILE_WIDTH, GameConstants.TILE_HEIGHT);
		
		platformHero.InitBody(BodyType.DYNAMIC, gameSpace, [Vec2.weak( -17.5, -17.5), Vec2.weak(17.5, -17.5), Vec2.weak(17.5, 17.5), Vec2.weak( -17.5, 17.5)]);
		platformHero.gameBody.shapes.add(new Circle(18));
		platformHero.gameBody.setShapeMaterials(new Material(0.1, 0.0, 0.0, 0.05, 0.0001));
		platformHero.gameBody.cbTypes.add(heroBodyCbType);

		heroEntity.add(platformHero);
		
		platformHeroControl = new PlatformHeroControl();
		heroEntity.add(platformHeroControl);
		
		owner.addChild(heroEntity);
		
		// Set hero's initial direction
		platformHeroControl.SetHeroDirection((roomDataJson.Hero_Direction == 1) ? HeroDirection.RIGHT : HeroDirection.LEFT);
		
		heroSignalDisposer.add(platformHero.onTileChanged.connect(function(tile: PlatformTile) {
			if (isGameOver)
				return;
			
			if (tile.tileDataType == TileDataType.DOOR && tile.tileType == TileType.DOOR_OUT) {
				Utils.ConsoleLog("EXIT!");
			}
			
			if (tile.idy >= (GameConstants.GRID_COLS - 1)) {
				Utils.ConsoleLog("LOSE! Out of bounds!");				
				PlayHeroDeathAnim();
			}
		}));
	}
	
	public function CreateRoomTiles(): Void {
		tileGrid = new Array<Array<PlatformTile>>();
		
		for (ii in 0...GameConstants.GRID_ROWS) {
			var tileArray: Array<PlatformTile> = new Array<PlatformTile>();
			for (jj in 0...GameConstants.GRID_COLS) {
				var tile: PlatformTile = new PlatformTile();
				tile.SetGridID(ii, jj);
				tile.SetSize(GameConstants.TILE_WIDTH, GameConstants.TILE_HEIGHT);
				
				tile.SetXY(
					ii * tile.GetNaturalWidth() + (GameConstants.TILE_WIDTH / 2),
					jj * tile.GetNaturalHeight() + (GameConstants.TILE_HEIGHT / 2)
				);
				
				tile.InitBody(BodyType.STATIC, gameSpace, [Vec2.weak(-20, -20), Vec2.weak(20, -20), Vec2.weak(20, 20), Vec2.weak(-20, 20)]);
				tile.gameBodyShape.filter.collisionMask = 0;

				tileArray.push(tile);
			}
			tileGrid.push(tileArray);
		}
	}
	
	public function CreateRoomBackground(): Void {
		if (tileGrid == null)
			return;
			
		var backgroundData: Array<Array<Int>> = roomDataJson.Background_Data;
		
		for (ii in 0...backgroundData.length) {
			for (jj in 0...backgroundData[ii].length) {
				var bgVal: Int = backgroundData[jj][ii];
				
				if (bgVal == 0)
					continue;
					
				var bgTileType: TileType = GetTileType(bgVal);
				var bgTexture: Texture = tileList.get(bgTileType);
				var bgTile: PlatformTile = new PlatformTile();
				bgTile.SetGridID(ii, jj);
				bgTile.SetSize(GameConstants.TILE_WIDTH, GameConstants.TILE_HEIGHT);
				bgTile.SetXY(tileGrid[ii][jj].x._, tileGrid[ii][jj].y._);
				bgTile.SetTileTexture(bgTexture);
				bgTile.SetTileDataType(TileDataType.BLOCK);
				bgTile.SetTileType(bgTileType);
				allTiles.push(bgTile);
			}
		}
	}
	
	public function CreateRoomBlocks(): Void {
		if (tileGrid == null)
			return;
		
		var roomData: Array<Array<Int>> = roomDataJson.Block_Data;
		
		for (ii in 0...roomData.length) {
			for (jj in 0...roomData[ii].length) {
				var roomDataVal: Int = roomData[jj][ii];
				
				if (roomDataVal == 0)
					continue;
				
				var blockTileType: TileType = GetTileType(roomDataVal);
				var blockTexture: Texture = tileList.get(blockTileType);
				var blockTile: PlatformTile = tileGrid[ii][jj];
				blockTile.SetTileTexture(blockTexture);
				blockTile.SetTileType(blockTileType);
				blockTile.SetTileDataType(TileDataType.BLOCK);
				
				blockTile.gameBody.cbTypes.add(blockBodyCbType);
				blockTile.gameBodyShape.filter.collisionMask = -1;
				
				allTiles.push(blockTile);
			}
		}
	}
	
	public function CreateRoomObstacles(): Void {
		if (tileGrid == null)
			return;
			
		var obstaclesData: Array<Array<Int>> = roomDataJson.Obstacle_Data;
		
		for (ii in 0...obstaclesData.length) {
			for (jj in 0...obstaclesData[ii].length) {
				var obstacleDataVal: Int = obstaclesData[jj][ii];
				
				if (obstacleDataVal == 0)
					continue;
					
				var obstacleTileType: TileType = GetObstacleTileType(obstacleDataVal);
				var obstacleTexture: Texture = GetObstacleTexture(obstacleDataVal);
				var obstacleTile: PlatformTile = tileGrid[ii][jj];
				obstacleTile.SetTileTexture(obstacleTexture);
				obstacleTile.SetTileType(obstacleTileType);
				obstacleTile.SetTileDataType(TileDataType.OBSTACLE);
				
				if (curRoomIndx == 4) {
					Utils.ConsoleLog(ii + " " + jj + " " + obstacleDataVal);
				}
				
				obstacleTile.InitBody(BodyType.STATIC, gameSpace, GetObstacleShape(obstacleDataVal));
				obstacleTile.gameBody.cbTypes.add(obstacleBodyCbType);
				
				obstacleTile.gameBodyShape.sensorEnabled = true;
				allTiles.push(obstacleTile);
			}
		}
	}
	
	public function CreateRoomDoors(): Void {
		if (tileGrid == null)
			return;
			
		var doorsData: Array<Array<Int>> = roomDataJson.Door_Data;
		
		for (ii in 0...doorsData.length) {
			for (jj in 0...doorsData[ii].length) {
				var doorDataVal: Int = doorsData[jj][ii];
				
				if (doorDataVal == 0)
					continue;
					
				var doorTileType: TileType = GetDoorTileType(doorDataVal);
				var doorTexture: Texture = GetDoorTexture(doorDataVal);
				var doorTile: PlatformTile = tileGrid[ii][jj];
				doorTile.SetTileTexture(doorTexture);
				doorTile.SetTileType(doorTileType);
				doorTile.SetTileDataType(TileDataType.DOOR);
				
				doorTile.gameBody.cbTypes.add(doorBodyCbType);
				
				allTiles.push(doorTile);
			}
		}
	}
	
	public function SetBlockLayers(): Void {
		if (tileGrid == null)
			return;
			
		var layerData: Array<Array<Int>> = roomDataJson.Layer_Data;
		
		for (ii in 0...layerData.length) {
			for (jj in 0...layerData[ii].length) {
				var layerVal: Int = layerData[jj][ii];
				var blockTile: PlatformTile = tileGrid[ii][jj];
				if (blockTile != null) {
					blockTile.gameBodyShape.filter.collisionGroup = layerVal;
				}
			}
		}
		
	}
	
	public function DrawAllTiles(): Void {
		tilesEntity = new Entity();
		
		for (tile in allTiles) {
			tilesEntity.addChild(new Entity().add(tile));
		}
		
		owner.addChild(tilesEntity);
	}
	
	// Cleaning of room stage
	public function ClearStage(): Void {
		Utils.ConsoleLog("Cleaning room tiles [Count: " + allTiles.length + "]");
		
		roomDataJson = null;
		allTiles = new Array<PlatformTile>();
		
		owner.removeChild(tilesEntity);
		tilesEntity.dispose();
		
		owner.removeChild(heroEntity);
		heroEntity.dispose();
		
		platformHero.dispose();
		platformHeroControl.dispose();
		heroSignalDisposer.dispose();
		
		//#if flash
		//debug.clear();
		//#end
	}
	
	// Resetting all information stored in tile grid
	public function ResetRoomTiles(): Void {
		Utils.ConsoleLog("Resetting tile grid");
		for (ii in 0...tileGrid.length) {
			for (jj in 0...tileGrid[ii].length) {
				tileGrid[ii][jj].Reset();
			}
		}
	}
	
	public function GetTileOfType(tileType: TileType): PlatformTile {
		var result: PlatformTile = null;
		
		for (tile in allTiles) {
			if (tile.tileType != tileType)
				continue;
			
			result = tile;
		}
		
		return result;
	}
	
	public function GetTileType(indx: Int): TileType {
		return Type.allEnums(TileType)[indx];
	}
	
	public function GetDoorTexture(indx: Int): Texture {
		var result: Texture = null;
		
		if (indx == 1) {
			result = gameAsset.getTexture(AssetName.ASSET_DOOR_CLOSE);
		}
		else if (indx == 2) {
			result = gameAsset.getTexture(AssetName.ASSET_DOOR_OPEN);
		}
		
		return result;
	}
	
	public function GetDoorTileType(indx: Int): TileType {
		var doorType: TileType = TileType.NONE;
		
		if (indx == 1) {
			doorType = TileType.DOOR_IN;
		}
		else if (indx == 2) {
			doorType = TileType.DOOR_OUT;
		}
		
		return doorType;
	}
	
	public function GetObstacleTexture(indx: Int): Texture {
		var result: Texture = null;
		
		if (indx == 1) {
			result = gameAsset.getTexture(AssetName.ASSET_SPIKE_UP);
		}
		else if (indx == 2) {
			result = gameAsset.getTexture(AssetName.ASSET_SPIKE_DOWN);
		}
		
		return result;
	}
	
	public function GetObstacleTileType(indx: Int): TileType {
		var obstacleType: TileType = TileType.NONE;
		
		if (indx == 1) {
			obstacleType = TileType.SPIKE_UP;
		}
		else if (indx == 2) {
			obstacleType == TileType.SPIKE_DOWN;
		}
		
		return obstacleType;
	}
	
	// Creates a triangle-shaped polygon to fit spike's shape
	public function GetObstacleShape(indx: Int): Array<Vec2> {
		var result = [];
		if (indx == 1) {
			result = [Vec2.weak( -1, -20), Vec2.weak(1, -20), Vec2.weak(15, 20), Vec2.weak( -15, 20)];
		}
		else if (indx == 2) {
			result = [Vec2.weak( -15, -20), Vec2.weak(15, -20), Vec2.weak(1, 20), Vec2.weak( -1, 20)];
		}
		
		return result;
	}
	
	public function PlayHeroDeathAnim(): Void {
		isGameOver = true;
		platformHero.DestroyBody();
		platformHero.SetDeathPose();
		platformHeroControl.dispose();
		
		var heroAnim: Script = new Script();
		heroAnim.run(new Sequence([
			new AnimateTo(platformHero.y, platformHero.y._ - 30, 0.5, Ease.sineOut),
			new AnimateTo(platformHero.y, System.stage.height + platformHero.GetNaturalHeight(), 0.5, Ease.sineIn),
			new CallFunction(function() {
				OnGameEnd(false);
				owner.removeChild(new Entity().add(heroAnim));
				heroAnim.dispose();
			})
		]));
		owner.addChild(new Entity().add(heroAnim));
	}
	
	public function OnGameEnd(win: Bool): Void {
		didWin = win;
		bgm.dispose();
		SceneManager.ShowGameOverScreen();
	}
	
	public function ShowScreenCurtain(): Void {		
		var screenCurtain: FillSprite = new FillSprite(0x000000, System.stage.width, System.stage.height);
		owner.addChild(new Entity().add(screenCurtain));
		
		isGameStart = false;
		audioText.alpha._ = 0;
		
		var curtainScript: Script = new Script();
		curtainScript.run(new Sequence([
			new AnimateTo(screenCurtain.alpha, 0, 0.5),
			new CallFunction(function() {
				owner.removeChild(new Entity().add(screenCurtain));
				screenCurtain.dispose();
				owner.removeChild(new Entity().add(curtainScript));
				audioText.alpha._ = 1;
				
				if (curRoomIndx == 1) {
					SceneManager.ShowControlsScreen();
				}
				else {
					isGameStart = true;
				}
			})	
		]));
		owner.addChild(new Entity().add(curtainScript));
	}
	
	public function ShowFPS(): Void {
		if (fpsEntity != null) {
			owner.removeChild(fpsEntity);
		}
		
		fpsEntity = new Entity()
			.add(new TextSprite(new Font(gameAsset, FontName.FONT_ARIAL_20))
			.setXY(2, System.stage.height * 0.975))
			.add(new FpsDisplay());
		owner.addChild(fpsEntity);
	}
	
	public function CreateBGM(): Void {
		bgm = gameAsset.getSound(BGM_PATH + BGM_NAME).loop(BGM_VOLUME);
		bgm.paused = bgmToggle;
		platformDisposer.add(bgm);
	}
	
	public function ShowAudioIndicator(): Void {
		if (audioText != null) {
			owner.removeChild(new Entity().add(audioText));
		}
		
		audioText = new TextSprite(new Font(gameAsset, FontName.FONT_ARIAL_18), (!bgmToggle) ? "[M]usic: On" : "[M]usic: Off");
		audioText.setXY(System.stage.width * 0.9, System.stage.height * 0.975);
		owner.addChild(new Entity().add(audioText));
	}
	
	override public function onAdded() {
		super.onAdded();
		
		platformDisposer = owner.get(Disposer);
		if (platformDisposer == null) {
			owner.add(platformDisposer = new Disposer());
		}
		
		CreateRoomTiles();
		LoadRoom(curRoomIndx);
		CreateBGM();
		
		gameSpace.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, heroBodyCbType, obstacleBodyCbType, function(cb: InteractionCallback) {
			Utils.ConsoleLog("LOSE! Hit to obstacle!");				
			PlayHeroDeathAnim();
		}));
	}
	
	override public function onStart() {
		super.onStart();
		
		
		platformDisposer.add(System.keyboard.down.connect(function(event: KeyboardEvent) {
			if (event.key == Key.M) {
				bgmToggle = !bgmToggle;
				bgm.paused = bgmToggle;
				audioText.text = (!bgmToggle) ? "[M]usic: On" : "[M]usic: Off";
			}
			
			//#if debug
			if (event.key == Key.Number1) {
				LoadRoom(1);
			}
			if (event.key == Key.Number2) {
				LoadRoom(2);
			}
			if (event.key == Key.Number3) {
				LoadRoom(3);
			}
			if (event.key == Key.Number4) {
				LoadRoom(4);
			}
			if (event.key == Key.Number5) {
				LoadRoom(5);
			}
			if (event.key == Key.F1) {
				LoadPrevRoom();
			}
			if (event.key == Key.F2) {
				LoadNextRoom();
			}
			//if (event.key == Key.F3) {
				//ResetRoomTiles();
				//ClearStage();
			//}
			//#end
		}));
		
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		gameSpace.step(dt);
		
		//#if flash
		//if(!isGameOver) {
			//debug.clear();
			//debug.draw(gameSpace);
			//debug.flush();
		//}
		//#end
	}
}