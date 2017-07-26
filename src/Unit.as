package 
{
	import flash.geom.Point;
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class Unit extends Image
	{
		private var currentTown : Town;
		private var targetTown : Town;
		private var speed : Number = 0.005;
		public var faction : int = 0;
		public var stopped : Boolean = false;
		
		public static function makeRandomUnit(town : Town, faction : int=0) : Unit
		{
			
			var number : int = Math.random() * 16;
			number = Math.random() * 16;
			// special units KGB and DB
			if (faction == 1 && number == 15)
				number = 16;
				
			var tex : Texture = Game.assets.getTexture("unit" + number);
			var unit : Unit = new Unit(tex, town);
			town.occupy(faction);
			unit.color = 0xaf2b1e;
			if (faction == 1)
				unit.color = 0x3558cc;
			unit.faction = faction;
			return unit;
		}
		public function Unit(texture : Texture, town : Town) 
		{
			super(texture);
			
			currentTown = town;
			var number : int = Math.random() * 16;
			this.x = town.x - this.width/2;
			this.y = town.y - this.height/2;
			chooseDestination(currentTown);
		}
		private var targetPoint : Point;
		private var startPoint : Point;
		private var distance : Number = 0;
		private var prevTown : Town;
		
		[Inline]
		private final function chooseDestination(startTown : Town):void 
		{
			prevTown = currentTown;
			currentTown = startTown;
			currentTown.occupy(faction);
			if (currentTown.lines.length == 0)
			{
				stopped = true;
				return;
			}
			while (true)
			{
				var line : TownLine = currentTown.lines[int(Math.random() * currentTown.lines.length)];
				targetTown = line.endTown;
				if (targetTown != prevTown)
					break;
				if (currentTown.lines.length == 1)
					break;
			}
			distance = 0;
			targetPoint = new Point(targetTown.x-this.width/2, targetTown.y - this.height/2);
			startPoint = new Point(currentTown.x-this.width/2, currentTown.y - this.height/2);
			var moveVector : Point = new Point(targetPoint.x - startPoint.x, targetPoint.y - startPoint.y);
			// normalize move speed
			speed = 2*(0.005 * 100)/ moveVector.length;
		}
		
		private var result : Point;
		[Inline]
		public final function move():void 
		{
			if (stopped)
				return;
			result = Point.interpolate(targetPoint, startPoint, distance);
			this.x = result.x;
			this.y = result.y;
			distance+= speed;
			if (distance >= 1)
			{
				chooseDestination(targetTown);
			}
		}
		
	}

}