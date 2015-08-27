package hy.ui.core
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;

	public class SProgressBar extends SSprite
	{
		private var mSkin : Sprite;
		private var mBar : Sprite;
		private var txt_progress : TextField;
		private var mMask : Shape;

		public function SProgressBar(skin : Sprite)
		{
			super();
			mSkin = skin;
		}

		override protected function init() : void
		{
			mouseChildren = mouseEnabled = false;
			addChild(mSkin);
			mBar = mSkin["bar"];
			txt_progress = txt_progress["txt_bar"];
			mMask = new Shape();
			mMask.graphics.beginFill(0);
			mMask.graphics.drawRect(0, 0, mBar.width, mBar.height);
			mMask.graphics.endFill();
			mMask.x = mBar.x;
			mMask.y = mBar.y;
			addChild(mMask);
			mBar.mask = mMask;
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
			mMask.width = value / 100 * mBar.width;
		}
	}
}