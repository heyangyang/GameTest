package hy.ui.core.view.base
{
	import flash.display.Sprite;

	import hy.ui.core.SSprite;

	public class LoadingView extends SSprite
	{
		private var mSkin : Sprite;

		public function LoadingView()
		{

		}

		override protected function init() : void
		{
			mSkin = new(getClass(""));
		}
	}
}