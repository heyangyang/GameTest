package hy.ui.core.view.base
{
	import flash.display.Sprite;

	import hy.ui.core.SSprite;

	public class LoadingView extends SSprite
	{
		private var m_skin : Sprite;

		public function LoadingView()
		{

		}

		override protected function init() : void
		{
			m_skin = new(getClass(""));
		}
	}
}