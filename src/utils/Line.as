/**
 * Class Line
 * @author Leandro Barreto 2012
 * @version 1.0
 **/
 
package utils
{
	import starling.display.Quad;
 
	public class Line extends Quad
	{
		private var _thickness:Number = 1;
		private var _color:uint = 0x000000;
 
		public function Line()
		{
			super(1, _thickness, _color);
		}
 
		public function lineTo(toX:int, toY:int):void
		{
			var toX2:int = toX-this.x;
			var toY2:int = toY-this.y;
			this.rotation = 0;
			this.width = Math.round(Math.sqrt((toX2*toX2)+(toY2*toY2)));
			this.rotation = Math.atan2(toY2, toX2);
		}
		
		public function set thickness(t:Number):void
		{
			var currentRotation:Number = this.rotation;
			this.rotation = 0;
			this.height = _thickness = t;
			this.rotation = currentRotation;
		}
 
		public function get thickness():Number
		{
			return _thickness;
		}
	}
}