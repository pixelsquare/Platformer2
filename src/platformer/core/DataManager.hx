package platformer.core;

import flambe.asset.AssetPack;
import flambe.subsystem.StorageSystem;

/**
 * ...
 * @author Anthony Ganzon
 */
class DataManager
{
	public var gameAsset(default, null): AssetPack;
	public var gameStorage(default, null): StorageSystem;
	
	public function new(assetPack: AssetPack, storage: StorageSystem) {		
		this.gameAsset = assetPack;
		this.gameStorage = storage;
	}
}