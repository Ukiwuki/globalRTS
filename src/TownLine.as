package 
{
	import utils.Line;

	public class TownLine extends Line
	{
		public var startTown : Town;
		public var endTown : Town;
//		private var line : Line;
		public function TownLine(startTown:Town, endTown : Town) 
		{
			this.startTown = startTown;
			this.endTown = endTown;
			this.color = 0x444444;
			this.thickness = 2;
			this.x = startTown.x// + startTown.width / 2;
			this.y = startTown.y// + startTown.height / 2;
			this.lineTo(endTown.x, endTown.y)
		}
		
		[Inline]
		public final function equals(townLine:TownLine):Boolean
		{
			if (this.startTown == townLine.startTown && this.endTown == townLine.endTown)
				return true;
			if (this.startTown == townLine.endTown && this.endTown == townLine.startTown)
				return true;
			return false;
		}
		
	}

}