package hy.rpg.utils
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import hy.game.cfg.Config;
	import hy.game.core.interfaces.IBitmapData;
	import hy.game.render.SRenderBitmapData;


	/**
	 *
	 * 角色血条
	 *
	 */
	public class SHpBarUtils
	{
		public static var res_hp : Class;
		public static var res_hpBg : Class;
		
		private static var hp : BitmapData;
		private static var hpBg : BitmapData;
		private static var dic : Dictionary = new Dictionary();

		public static function getHp(hp_value : int) : IBitmapData
		{
			var bmd : IBitmapData = dic[hp_value];
			if (bmd)
				return bmd;
			if (hp == null)
			{
				hp = new res_hp();
				hpBg = new res_hpBg();
			}

			var rect : Rectangle = new Rectangle();
			rect.height = hpBg.height;
			rect.width = hpBg.width * hp_value / 100;
			var tmp_bmd : SRenderBitmapData = new SRenderBitmapData(hpBg.width, hpBg.height, false, 0);
			tmp_bmd.draw(hpBg);
			tmp_bmd.copyPixels(hp, rect, new Point(), null, null, true);
			bmd = tmp_bmd;
			if (Config.supportDirectX)
			{
//				bmd = SDirectBitmapData.fromDirectBitmapData(tmp_bmd);
//				tmp_bmd.dispose();
			}
			dic[hp_value] = bmd;
			return bmd;
		}


	}
}