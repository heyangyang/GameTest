package hy.rpg.utils
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import hy.game.cfg.Config;
	import hy.game.interfaces.display.IBitmapData;
	import hy.game.render.SDirectBitmapData;
	import hy.game.render.SRenderBitmapData;
	import hy.game.resources.SResourceMagnger;


	/**
	 *
	 * 角色血条
	 *
	 */
	public class UtilsHpBar
	{
		private static var hp : SRenderBitmapData;
		private static var hpBg : SRenderBitmapData;
		private static var point : Point;
		private static var dic : Dictionary = new Dictionary();

		public static function getHp(hp_value : int) : IBitmapData
		{
			var bmd : IBitmapData = dic[hp_value];
			if (bmd)
				return bmd;
			if (hp == null)
			{
				hp = SResourceMagnger.getInstance().getImageById("res_hp") as SRenderBitmapData;
				hpBg = SResourceMagnger.getInstance().getImageById("res_hpBg") as SRenderBitmapData;
				point = new Point();
				point.x = (64 - hpBg.width) * .5;
				point.y = (8 - hpBg.height) * .5;
			}

			var rect : Rectangle = new Rectangle();
			rect.height = hpBg.height;
			rect.width = hpBg.width * hp_value / 100;
			var tmp_bmd : SRenderBitmapData = new SRenderBitmapData(64, 8, true, 0);
			tmp_bmd.copyPixels(hpBg, hpBg.rect, point);
			tmp_bmd.copyPixels(hp, rect, point, null, null, true);
			bmd = tmp_bmd;
			if (Config.supportDirectX)
			{
				bmd = SDirectBitmapData.fromDirectBitmapData(tmp_bmd);
				tmp_bmd.dispose();
			}
			dic[hp_value] = bmd;
			return bmd;
		}


	}
}