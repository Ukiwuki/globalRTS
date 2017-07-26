package 
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DProfile;
	import starling.textures.Texture;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.setTimeout;
	import flash.events.Event;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import starling.textures.TextureOptions;
	import starling.utils.AssetManager;
	import utils.ProgressBar;



    // If you set this class as your 'default application', it will run without a preloader.
    // To use a preloader, see 'Demo_Web_Preloader.as'.

    // This project requires the sources of the "demo" project. Add them either by
    // referencing the "demo/src" directory as a "source path", or by copying the files.
    // The "media" folder of this project has to be added to its "source paths" as well,
    // to make sure the icon and startup images are added to the compiled mobile app.
    
    [SWF(width="1024", height="640", frameRate="60", backgroundColor="#0")]
    public class Demo_Web extends Sprite
    {
        private var _starling:Starling;
        private var _progressBar:ProgressBar;

        public function Demo_Web()
        {
            if (stage) start();
            else addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
        }

        private function onAddedToStage(event:Object):void
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			
            removeEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
            start();
        }
		
		public function resizeStage(e:starling.events.Event):void 
		{
			trace("Demo_Web.resizeStage");
			var viewPortRectangle:Rectangle = new Rectangle();
			viewPortRectangle.width = Starling.current.nativeStage.stageWidth;
			viewPortRectangle.height = Starling.current.nativeStage.stageHeight;
			Starling.current.viewPort = viewPortRectangle;
			Starling.current.stage.stageWidth = Starling.current.nativeStage.stageWidth;
			Starling.current.stage.stageHeight = Starling.current.nativeStage.stageHeight;	
			Starling.current.setRequiresRedraw();
		}

        private function start():void
        {
            _starling = new Starling(Game, stage, null, null, "auto", Context3DProfile.STANDARD_EXTENDED);
            //_starling = new Starling(Game, stage, null, null, "auto", Context3DProfile.BASELINE_EXTENDED);
            _starling.skipUnchangedFrames = true;
            //_starling.enableErrorChecking = Capabilities.isDebugger;
			
			
            _starling.addEventListener(starling.events.Event.ROOT_CREATED, function():void
            {
                loadAssets(startGame);
            });

            _starling.start();
            initElements();
			_starling.showStats = true;
			_starling.stage.addEventListener(ResizeEvent.RESIZE, resizeStage);
        }

        private function loadAssets(onComplete:Function):void
        {
            var assets:AssetManager = new AssetManager();
            assets.enqueue(EmbeddedMap);
			assets.useMipMaps = true; // mipmaps for all other textures
            assets.enqueue(EmbeddedAssets);
/*			
			// no mipmas for europe map
			assets.enqueueWithName("assets/towns.xml", "towns");

			assets.enqueueWithName("assets/tile1.jpg", "tile1", new TextureOptions(1, false));
			assets.enqueueWithName("assets/tile2.jpg", "tile2", new TextureOptions(1, false));
			
			assets.useMipMaps = true; // mipmaps for all other textures
			
			assets.enqueueWithName("assets/icons.png", "icons");
			assets.enqueueWithName("assets/icons.xml", "iconsXml");
			assets.enqueueWithName("assets/nuke.png", "nuke");
			assets.enqueueWithName("assets/nuke.xml", "nukeXml");
			assets.enqueueWithName("assets/units.png", "units");
			assets.enqueueWithName("assets/units.xml", 'unitsXml');
            assets.verbose = Capabilities.isDebugger;
*/			
            assets.loadQueue(function(ratio:Number):void
            {
                _progressBar.ratio = ratio;
                if (ratio == 1)
                {
                    // now would be a good time for a clean-up
                    System.pauseForGCIfCollectionImminent(0);
                    System.gc();

                    onComplete(assets);
                }
            });
        }

        private function startGame(assets:AssetManager):void
        {
            var game:Game = _starling.root as Game;
            game.start(assets);
            setTimeout(removeElements, 150); // delay to make 100% sure there's no flickering.
			
        }

        private function initElements():void
        {
            // While the assets are loaded, we will display a progress bar.
            _progressBar = new ProgressBar(500, 40);
            _progressBar.x = (Starling.current.stage.stageWidth - _progressBar.width) / 2;
            _progressBar.y =  Starling.current.stage.stageHeight * 0.5;
            addChild(_progressBar);
        }

        private function removeElements():void
        {
            if (_progressBar)
            {
                removeChild(_progressBar);
                _progressBar = null;
            }
        }
    }
}