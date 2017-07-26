package 
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.ui.Keyboard;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MeshBatch;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.AssetManager;
	import utils.Line;


    public class Game extends Sprite
    {
        private static var sAssets:AssetManager;
		public static var _instance : Game;
		private var towns : Vector.<Town> = new Vector.<Town>;
		private var capitals : Vector.<Town> = new Vector.<Town>;
		private var townLines : Vector.<TownLine>;
		private var units : Vector.<Unit> = new Vector.<Unit>;
		
		private var mapContainer : Sprite = new Sprite;
		private var tile1:Image;
		private var tile2:Image;
		private var townsLayer : MeshBatch = new MeshBatch;
		private var linesLayer : MeshBatch = new MeshBatch;
		private var unitsLayer : MeshBatch = new MeshBatch;
        public function Game()
        {
            // nothing to do here -- Startup will call "start" immediately.
			_instance = this;
        }
        
        public function start(assets:AssetManager):void
        {
            sAssets = assets;
			Starling.current.showStats = true;
            addEventListener(Event.TRIGGERED, onButtonTriggered);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			
			// add map
			tile1 = new Image(assets.getTexture("tile1"));
			tile1.blendMode = BlendMode.NONE;
			tile2 = new Image(assets.getTexture("tile2"));
			tile2.blendMode = BlendMode.NONE;
			addChild(mapContainer);
			mapContainer.addChild(tile1);
			mapContainer.addChild(tile2);
			tile2.x = tile1.width;
			mapContainer.addChild(linesLayer);
			mapContainer.addChild(townsLayer);
			mapContainer.addChild(unitsLayer);
			
			unitsLayer.touchable = false;
			linesLayer.touchable = false;
			townsLayer.touchable = false;
			
			// map drag
			this.addEventListener(TouchEvent.TOUCH, onTouch);
			// map zooming
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_WHEEL, nativeStage_mouseWheel);
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_UP, nativeStage_mouseUp);

			
			loadTownsData();
			//spawnUnits();
			
			// center map
			mapContainer.x = Starling.current.stage.stageWidth/2 - mapContainer.width/4;
			mapContainer.y = Starling.current.stage.stageHeight / 2 - mapContainer.height / 4;
			this.scale = 0.25;
			Starling.current.juggler.repeatCall(gameLoop, 1 / 20.0);
			Starling.current.juggler.repeatCall(townsUodateLoop, 1 / 3.0);
			trace("Game.start", "townsCount:", towns.length);
			trace("Game.start", Starling.current.stage.stageWidth, Starling.current.stage.stageHeight);
			trace("Game.start", Starling.current.nativeStage.stageWidth, Starling.current.nativeStage.stageHeight);
        }
		
		[Inline]
		private function townsUodateLoop():void 
		{
			townsLayer.clear();
			var len : int = towns.length
			for (var i:int = 0; i < len; i++) 
				townsLayer.addMesh(towns[i]);
		}
		
		[Inline]
		private final function gameLoop() : void
		{
			unitsLayer.clear();
			var len : int = units.length;
			var unit : Unit;
			for (var i:int = 0; i < len; i++) 
			{
				unit = units[i];
				unit.move();
				unitsLayer.addMesh(unit);
			}
		}
		private function spawnUnits():void 
		{
			if (units.length != 0)
				return;
			//blue faction
			for (var i:int = 0; i < 2000; i++) 
			{
				// choose capital
				var index : int = Math.random() * capitals.length/2;
				var capital : Town = capitals[index];
				// spawn unit
				var unit : Unit = Unit.makeRandomUnit(capital, 1);
				unitsLayer.addMesh(unit);
				units.push(unit);
			}
			// red faction
			for (i = 0; i < 2000; i++) 
			{
				// choose capital
				index = Math.random() * capitals.length/2 + capitals.length/2;
				capital = capitals[index];
				// spawn unit
				unit = Unit.makeRandomUnit(capital, 0);
				unitsLayer.addMesh(unit);
				units.push(unit);
			}
		}
		
		private function nuke (pt : Point) : void
		{
			var mc : MovieClip = new MovieClip(assets.getTextures("nuke"), 25);
			Starling.juggler.add(mc);
			mc.addEventListener(Event.COMPLETE, mc_complete);
			mapContainer.addChild(mc);
			mc.scale = 2;
			mc.x = pt.x - mc.width/2;
			mc.y = pt.y - mc.height/2;
			shake();
			// del affected towns
			var townsToDelete : Vector.<Town> = getTowns(pt, 125)
			var linesToDelete : Vector.<Line> = new Vector.<Line>;
			for each (var town:Town in townsToDelete) 
			{
				towns.removeAt(towns.indexOf(town));
				// del affected lines
				for each (var line:TownLine in townLines) 
				{
					if (line.startTown == town || line.endTown == town)
					{
						linesToDelete.push(line);
					}
				}
				
			}
			for each (line in linesToDelete) 
			{
				var index : int = townLines.indexOf(line);
				if (index !=-1)
					townLines.removeAt(index);
				line.startTown.removeLine(line);
				line.endTown.removeLine(line);
			}
			
			linesLayer.clear();
			for each (line in townLines) 
				linesLayer.addMesh(line);
			townsLayer.clear();
			for each (town in towns) 
				townsLayer.addMesh(town);
			
			
			// del affected units
			var unitsToDelete : Vector.<Unit> = getUnits(pt, 135);
			for each (var unit:Unit in unitsToDelete) 
			{
					removeUnit(unit);
			}
			
			function mc_complete(e:Event) : void
			{
				mc.removeFromParent();
			}
		}
		
		public function removeUnit(theUnit : Unit) : void
		{
			units.removeAt(units.indexOf(theUnit));
		}
		
		private function nativeStage_mouseUp(e:MouseEvent):void 
		{
			var pt : Point = mapContainer.globalToLocal(new Point(e.stageX, e.stageY));
			if (e.shiftKey)
			{
				nuke(pt);
			}
			return;
			// town building features
			if (e.ctrlKey)
			{
				var town : Town = Town.makeTown();
				if (e.altKey)
					town = Town.makeTown(true);
				town.x = Math.round(pt.x);
				town.y = Math.round(pt.y);
				townsLayer.addMesh(town);
				towns.push(town);
			}
			if (e.shiftKey)
			{
				// get towns in radius
				var someTowns : Vector.<Town> = getTowns(pt, 50);
				// delete them
				townsLayer.clear();
				for each (var item:Town in someTowns) 
					towns.removeAt(towns.indexOf(item));
				for each (item in towns) 
					townsLayer.addMesh(item);
				
			}
			
		}
		private function shake(duration:Number=0.1, intensity:Number = 62):void
		{
			// tween the screen to a random pos
			this.x = Math.random() * intensity/4  - intensity / 8;
			this.y = Math.random() * intensity/2  + intensity / 2;
			var caller : Game = this;
			var shakeTween : Tween;
			shakeTween = new Tween(this, duration, Transitions.EASE_OUT);
			shakeTween.repeatCount = 3;
			var count : int = 1;
			shakeTween.onRepeat = onRepeat;
			shakeTween.moveTo(0, 0);
			Starling.juggler.add(shakeTween);
			
			function onRepeat() : void
			{
				count++;
				caller.x = Math.random() * intensity/8 + intensity / 8;
				caller.y = Math.random() * intensity/2  + intensity / 2;
				caller.y /= count;
				caller.x /= count;
			}
		}
		
		private function getUnits(pt:Point, radius:Number):Vector.<Unit>
		{
			var result : Vector.<Unit> = new Vector.<Unit>;
			var tempPoint : Point = new Point;
			for each (var item:Unit in units) 
			{
				tempPoint.x = item.x; tempPoint.y = item.y;
				var distance : int = Point.distance(pt, tempPoint);
				if (distance < radius)
					result.push(item);
			}
			return result;
		}
		
		private function getTowns(pt : Point, radius:int = 150) : Vector.<Town>
		{
			var result : Vector.<Town> = new Vector.<Town>;
			var tempPoint : Point = new Point;
			for each (var item:Town in towns) 
			{
				tempPoint.x = item.x; tempPoint.y = item.y;
				var distance : int = Point.distance(pt, tempPoint);
				if (distance < radius)
					result.push(item);
			}
			return result;
		}
		
		private function makeTowns():void 
		{
			for (var i:int = 0; i < 2000; i++) 
			{
				var town : Town = Town.makeTown();
				town.x = int(Math.random() * mapContainer.width);
				town.y = int(Math.random() * mapContainer.height);
				town.touchable = false;
				townsLayer.addMesh(town);
				towns.push(town);
			}
		}
		
		private function saveTownsData() : void
		{
			var file : FileReference = new FileReference();
			var townsXml : XML = <towns></towns>;
			for each (var item:Town in towns) 
			{
				var town : XML = item.getXml();
				townsXml.appendChild(town);
			}
			file.save(townsXml, "towns.xml");
		}
		
		private function loadTownsData() : void
		{
			var townsXml : XML = assets.getXml("towns");
			var xmlList : XMLList = townsXml.town;
			for each (var item:XML in xmlList) 
			{
				var town : Town = Town.makeTown();
				if (item.@capital == "true")
					town = Town.makeTown(true);
				town.x = item.@x;
				town.y = item.@y;
				townsLayer.addMesh(town);
				towns.push(town);
				if (town.isCapital)
					capitals.push(town);
			}
			makeTownLines();
		}
		
		private function makeTownLines():void 
		{
			var item:Town;
			townLines = new Vector.<TownLine>;
			var tempPoint : Point = new Point;
			for (var i:int = 0; i < towns.length; i++) 
			{
				item = towns[i];
				tempPoint.x = item.x;
				tempPoint.y = item.y;
				var toConnect : Vector.<Town> = getTowns(tempPoint, 85);
				//var toConnect : Vector.<Town> = getTowns(tempPoint, 125);
				for each (var someTown:Town in toConnect) 
				{
					if (someTown == item)
						continue;
					var townLine : TownLine = new TownLine(item, someTown);
					var valid : Boolean = true;
					var len : int = townLines.length;
					var line : TownLine;
					for (var j:int = 0; j < len; j++) 
					{
						line = townLines[j];
						if (line.equals(townLine))
						{
							valid = false;
							break;
						}
					}
					if (!valid)
						continue;
					linesLayer.addMesh(townLine);
					townLines.push(townLine);
					item.addLine(townLine);
					var reversedLine : TownLine = new TownLine(someTown, item);
					someTown.addLine(reversedLine);
				}
			}
		}
		
		private function nativeStage_mouseWheel(e:MouseEvent):void 
		{
			var factor : Number = 0.1;
			if (e.delta < 0)
				factor =-factor;
			if (factor < 0 && this.scale <= 0.15)
				return;
			if (factor > 0 && this.scale >= 1.8)
				return;
			var pt : Point = mapContainer.globalToLocal(new Point(e.stageX, e.stageY));
			this.scale+= factor;
			// limit zoom
			if (this.scale > 1.8)
				this.scale = 1.8;
			if (this.scale < 0.2)
				this.scale = 0.2;
			// scale to a mouse location
			var pt2 : Point = mapContainer.globalToLocal(new Point(e.stageX, e.stageY));
			mapContainer.x += pt2.x - pt.x;
			mapContainer.y += pt2.y - pt.y;
			
		}
		
		private function onTouch(event:TouchEvent):void
		{
			var target:DisplayObject = event.target as DisplayObject;
			var touch:Touch = event.getTouch(target, TouchPhase.MOVED);

			if (target && touch)
			{
				var movement:Point = touch.getMovement(this);
				mapContainer.x += movement.x;
				mapContainer.y += movement.y;
			}
		}			
		
        private function onKey(event:KeyboardEvent):void
        {
            if (event.keyCode == Keyboard.SPACE)
				spawnUnits();
                //Starling.current.showStats = !Starling.current.showStats;
            //if (event.keyCode == Keyboard.F5)
				//saveTownsData();
        }
        
        private function onButtonTriggered(event:Event):void
        {
            var button:Button = event.target as Button;
        }
        
        public static function get assets():AssetManager { return sAssets; }
    }
}