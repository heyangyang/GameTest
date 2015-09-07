package hy.rpg.render
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import hy.game.cfg.Config;
	import hy.game.core.SReference;
	import hy.game.interfaces.display.IBitmapData;
	import hy.game.render.SDirectBitmapData;
	import hy.game.render.SRenderBitmapData;
	import hy.rpg.utils.UtilsFilter;
	import hy.rpg.utils.UtilsUIStyle;

	public class SNameParser extends SReference
	{
		private static var textField : TextField;

		private var mBitmapData : IBitmapData;
		protected var mNameTextColor : uint;
		protected var mNameTextFontSize : int;
		protected var mName : String;

		public function SNameParser(name : String, nameTextFontSize : int = 13, nameTextColor : uint = 0xffffff)
		{
			super();
			this.mName = name;
			this.mNameTextColor = nameTextColor;
			this.mNameTextFontSize = nameTextFontSize;
			init();
		}

		private function init() : void
		{
			if (textField == null)
			{
				textField = new TextField();
				textField.wordWrap = true;
				textField.multiline = true;
			}

			textField.filters = UtilsFilter.blackFilters;
			textField.defaultTextFormat = new TextFormat(UtilsUIStyle.TEXT_FONT, mNameTextFontSize, mNameTextColor, null, null, null, null, null, "center");
			textField.htmlText = mName;

			textField.width = 256;
			textField.height = 32;

			mBitmapData = new SRenderBitmapData(textField.width, textField.height, true, 0);
			SRenderBitmapData(mBitmapData).draw(textField);
			if (Config.supportDirectX)
			{
				var tmp : SRenderBitmapData = mBitmapData as SRenderBitmapData;
				mBitmapData = SDirectBitmapData.fromDirectBitmapData(tmp);
				tmp.dispose();
			}
		}

		public function get bitmapData() : IBitmapData
		{
			return mBitmapData;
		}

		public function get width() : int
		{
			if (!mBitmapData)
				return 0;
			return mBitmapData.width;
		}

		public function get height() : int
		{
			if (!mBitmapData)
				return 0;
			return mBitmapData.height;
		}

		override protected function dispose() : void
		{
			super.dispose();
			mBitmapData && mBitmapData.dispose();
			mBitmapData = null;
		}
	}
}