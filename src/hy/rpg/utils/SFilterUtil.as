package hy.rpg.utils
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.filters.GradientGlowFilter;
	import flash.geom.Rectangle;

	/**
	 *
	 * 一个滤镜工具
	 *
	 */
	public class SFilterUtil
	{
		/**
		 * 白光滤镜
		 */
		private static const _whiteFilter : GlowFilter = new GlowFilter(0x999999, 1, 2, 2, 128);

		public static var whiteFilters : Array = [_whiteFilter];

		/**
		 * 深绿光滤镜
		 */
		private static const _darkGreenFilter : GlowFilter = new GlowFilter(0x0d2421, 1, 2, 2, 128);

		public static var darkGreenFilters : Array = [_darkGreenFilter];

		/**
		 * 黄色内发光滤镜
		 */
		private static const _yellowInnerFilter : GlowFilter = new GlowFilter(0xffff00, 1, 8, 8, 2, 3, true);

		public static var yellowInnerFilters : Array = [_yellowInnerFilter];

		/**
		 * 黑色光滤镜
		 */
		private static const _blackFilter : GlowFilter = new GlowFilter(0x000000, 1, 2, 2, 6, 1);

		public static var blackFilters : Array = [_blackFilter];

		private static const _redFilter : ColorMatrixFilter = new ColorMatrixFilter([0.25, 0.25, 0.25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]);

		public static var redFilters : Array = [_redFilter];
		/**
		 * 灰度
		 */
		private static const _greyFilter : ColorMatrixFilter = new ColorMatrixFilter([0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0, 0, 0, 1, 0]); //变成黑白图片，灰度图

		public static var greyFilters : Array = [_greyFilter];

		/**
		 * 高亮
		 */
		private static const _highlightFilter : ColorMatrixFilter = new ColorMatrixFilter([1.5, 0, 0, 0, 0, 0, 1.5, 0, 0, 0, 0, 0, 1.5, 0, 0, 0, 0, 0, 1.2, 0]); //高亮

		public static var highlightFilters : Array = [_highlightFilter];

		/**
		 * 变暗
		 */
		private static const _darkFilter : ColorMatrixFilter = new ColorMatrixFilter([1, 0, 0, 0, -50, 0, 1, 0, 0, -40, 0, 0, 1, 0, -50, 0, 0, 0, 1, 0]); //变暗图片

		public static var darkFilters : Array = [_darkFilter];

		/**
		 * 发光
		 * @param obj
		 * @param color
		 * @param strength
		 *
		 */
		public static function getLightFilter(color : uint, strength : Number = 1) : Array
		{
			var glow : GlowFilter = new GlowFilter(color, 1, 5, 5, strength, 3);
			return [glow];
		}

		/**
		 * 描边
		 * @param obj
		 * @param color
		 *
		 */
		public static function getStrokeFilter(color : uint, thickness : int = 2) : Array
		{
			var glow : GlowFilter = new GlowFilter(color, 1, thickness, thickness, 128, 1);
			return [glow];
		}

		/**
		 * 内发光滤镜
		 * @param color
		 * @return
		 */
		public static function getInsideGlowFilter(color : uint) : Array
		{
			var insideGlow : GlowFilter = new GlowFilter(color, 1, 7, 7, 1.8, BitmapFilterQuality.HIGH, true);
			return [insideGlow];
		}

		public static function getBlurFilter(blurX : Number = 4.0, blurY : Number = 4.0, quality : int = 3) : BlurFilter
		{
			return new BlurFilter(blurX, blurY, quality);
		}

		public static function getDropShadowFilter(distance : int = 4, angle : int = 45, color : uint = 0xff0000, alpha : Number = 1, blurX : int = 5, blurY : int = 5, srength : int = 1, quality : int = 1, inner : Boolean = true) : DropShadowFilter
		{
			return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, srength, quality, inner)
		}

		public static function getGlowFilter(color : uint = 0xffffff, alpha : Number = 1.0, blurX : Number = 6.0, blurY : Number = 6.0, strength : Number = 2, quality : int = 1, inner : Boolean = false, knockout : Boolean = false) : GlowFilter
		{
			return new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
		}

	}
}
