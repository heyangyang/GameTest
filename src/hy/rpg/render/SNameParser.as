package hy.rpg.render
{
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import hy.game.cfg.Config;
	import hy.game.core.SReference;
	import hy.game.core.interfaces.IBitmapData;
	import hy.game.render.SDirectBitmapData;
	import hy.game.render.SRenderBitmapData;
	import hy.rpg.utils.UtilsFilter;
	import hy.rpg.utils.UtilsUIStyle;

	public class SNameParser extends SReference
	{
		private static var textField : TextField;

		private var m_bitmapData : IBitmapData;
		protected var nameTextColor : uint;
		protected var nameTextFontSize : int;
		protected var name : String;

		public function SNameParser(name : String, nameTextFontSize : int = 13, nameTextColor : uint = 0xffffff)
		{
			super();
			this.name = name;
			this.nameTextColor = nameTextColor;
			this.nameTextFontSize = nameTextFontSize;
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
			textField.defaultTextFormat = new TextFormat(UtilsUIStyle.TEXT_FONT, nameTextFontSize, nameTextColor, null, null, null, null, null, "center");
			textField.htmlText = name;

			textField.width = 256;
			textField.height = 32;

			m_bitmapData = new SRenderBitmapData(textField.width, textField.height, true, 0);
			SRenderBitmapData(m_bitmapData).draw(textField);
			if (Config.supportDirectX)
			{
				var tmp : SRenderBitmapData = m_bitmapData as SRenderBitmapData;
				m_bitmapData = SDirectBitmapData.fromDirectBitmapData(tmp);
				tmp.dispose();
			}
		}

		public function get bitmapData() : IBitmapData
		{
			return m_bitmapData;
		}

		public function get width() : int
		{
			if (!m_bitmapData)
				return 0;
			return m_bitmapData.width;
		}

		public function get height() : int
		{
			if (!m_bitmapData)
				return 0;
			return m_bitmapData.height;
		}

		override protected function destroy() : void
		{
			super.destroy();
			m_bitmapData && m_bitmapData.dispose();
			m_bitmapData = null;
		}
	}
}