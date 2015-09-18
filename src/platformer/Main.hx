package platformer;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.scene.Director;
import flambe.System;
import flambe.util.Promise;

import platformer.core.SceneManager;
import platformer.pxlSq.Utils;
import platformer.screen.PreloadScreen;
import platformer.screen.SplashScreen;

class Main
{
	private static inline var PRELOAD_PACK: String = "preload";
	private static inline var MAIN_PACK: String = "main";
	
    private static function main ()
    {
        // Wind up all platform-specific stuff
        System.init();
		
		var gameDirector: Director = new Director();
		System.root.add(gameDirector);
		
		var sceneManager: SceneManager = new SceneManager(gameDirector);
		
		System.loadAssetPack(Manifest.fromAssets(PRELOAD_PACK)).get(function(preloadPack: AssetPack) {
			Utils.ConsoleLog("Preload pack loaded");
			
			var promise: Promise<AssetPack> = System.loadAssetPack(Manifest.fromAssets(MAIN_PACK));
			promise.get(function(mainPack: AssetPack) {
				Utils.ConsoleLog("Main pack loaded");
				
				sceneManager.InitScreens(mainPack, System.storage);
				
				#if flash
				SceneManager.ShowTitleScreen(true);
				#else
				SceneManager.ShowScreen(new SplashScreen(preloadPack, 2), true);
				#end
			});
			
			SceneManager.ShowScreen(new PreloadScreen(preloadPack, promise));
			
		});
    }
}
