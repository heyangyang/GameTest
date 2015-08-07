package hy.ui.core
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;

	public class SProgressBar extends SSprite
	{
		private var m_skin : Sprite;
		private var m_bar : Sprite;
		private var txt_progress : TextField;
		private var m_mask : Shape;

		public function SProgressBar(skin : Sprite)
		{
			super();
			m_skin = skin;
		}

		override protected function init() : void
		{
			mouseChildren = mouseEnabled = false;
			addChild(m_skin);
			m_bar = m_skin["bar"];
			txt_progress = txt_progress["txt_bar"];
			m_mask = new Shape();
			m_mask.graphics.beginFill(0);
			m_mask.graphics.drawRect(0, 0, m_bar.width, m_bar.height);
			m_mask.graphics.endFill();
			m_mask.x = m_bar.x;
			m_mask.y = m_bar.y;
			addChild(m_mask);
			m_bar.mask = m_mask;
		}

		/**
		 * 进度
		 * @param value 必须是大于0,100=100%
		 *
		 */
		public function setProgress(value : int) : void
		{
			value = Math.max(0, value);
			txt_progress.text = Math.floor(value / 100) + "%";
			value = Math.min(100, value);
			m_mask.width = value / 100 * m_bar.width;
		}
	}
}