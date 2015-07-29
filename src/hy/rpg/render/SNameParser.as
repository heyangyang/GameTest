package hy.rpg.render
{
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import hy.game.core.SReference;
	import hy.game.core.interfaces.IBitmapData;
	import hy.game.render.SRenderBitmapData;
	import hy.rpg.utils.SFilterUtil;
	import hy.rpg.utils.SUIStyle;

	public class SNameParser extends SReference
	{
		private static var textField : TextField;
		private static var matrix : Matrix;

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

			textField.filters = SFilterUtil.blackFilters;
			textField.defaultTextFormat = new TextFormat(SUIStyle.TEXT_FONT, nameTextFontSize, nameTextColor, null, null, null, null, null, "center");
			textField.htmlText = name;

			textField.width = 200;
			textField.height = textField.textHeight + 4;

			if (!matrix)
				matrix = new Matrix();
			matrix.identity();
			m_bitmapData = new SRenderBitmapData(textField.textWidth + 4, textField.height, true, 0);
			matrix.tx += -(textField.width - textField.textWidth - 4) * 0.5;
			matrix.ty = 0;
			SRenderBitmapData(m_bitmapData).draw(textField, matrix);
//			if (SShellVariables.supportDirectX)
//			{
//				var tmp : SRenderBitmapData = bmd as SRenderBitmapData;
//				bmd = SDirectBitmapData.fromDirectBitmapData(tmp);
//				tmp.dispose();
//			}
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