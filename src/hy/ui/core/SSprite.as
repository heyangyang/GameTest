package hy.ui.core
{
	import flash.display.Sprite;

	import hy.game.resources.SResourceMagnger;

	public class SSprite extends Sprite
	{
		public function SSprite()
		{
			super();
			init();
		}

		protected function init() : void
		{

		}

		public function getClass(name : String) : Class
		{
			return SResourceMagnger.getInstance().getClass(name);
		}
	}
}