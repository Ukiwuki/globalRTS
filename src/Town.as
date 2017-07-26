package 
{
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class Town extends Image 
	{
		public var isCapital : Boolean = false;
		public var faction : int = -1;
		public var lines : Vector.<TownLine> = new Vector.<TownLine>;
		public var townNumber : int;
		private static var _totalCount : int = 0;
		private var bg:Image;
		private var image:Image;
		
		public static function makeTown(isCapital : Boolean = false) : Town
		{
			var number : int = Math.random() * 4;
			var tex : Texture = Game.assets.getTexture("townIcon" + String(number));
			if (isCapital)
				tex = Game.assets.getTexture("capitalIcon");
			var town : Town = new Town(tex, isCapital);
			return town;
		}
		
		public function Town(tex : Texture, isCapital : Boolean = false) 
		{
			super(tex);
			this.isCapital = isCapital;
			this.pivotX = this.width/2;
			this.pivotY = this.height/2;
			this.townNumber = ++_totalCount;
		}
		
		public function addLine(theLine : TownLine) : void
		{
			lines.push(theLine);
		}
		
		public function getXml() : XML
		{
			var result : XML = <town x={this.x} y={this.y}></town>;
			if (isCapital)
				result = <town x={this.x} y={this.y} capital={this.isCapital}></town>;
			return result;
		}
		
		[Inline]
		public final function occupy(faction:int):void 
		{
			if (this.faction == faction)
				return;
			if (faction == 0)	
				this.color = 0xaf2b1e;
			if (faction == 1)
				this.color = 0x3558cc;
			this.faction = faction;
		}
		
		public function removeLine(line:TownLine):void 
		{
			for each (var item:TownLine in lines) 
			{
				if (item.equals(line))
					lines.removeAt(lines.indexOf(item));
			}
		}
	}

}