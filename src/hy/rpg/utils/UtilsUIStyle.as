package hy.rpg.utils
{
	import flash.text.TextFormat;

	/**
	 *
	 * text样式
	 *
	 */
	public final class UtilsUIStyle
	{
		public static var TEXT_COLOR : uint = 0xffffff;
		public static var TEXT_SIZE : int = 13;
		public static var TEXT_BOLD : Boolean = false;
		public static var TEXT_FONT : String = "SimSun";
		public static var TEXT_LEADING : int = 2;

		public static var STYLE_BORDER_COLOR : uint = 0xcccccc;
		public static var STYLE_BORDER_ALPHA : Number = 0.5;

		public static var defaultTextFormat : TextFormat = new TextFormat(UtilsUIStyle.TEXT_FONT, 12, 0xffffff, null, null, null, null, null, "left");
	}
}