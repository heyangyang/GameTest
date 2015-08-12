package hy.rpg.components
{
	import hy.game.cfg.Config;
	import hy.game.components.SRenderComponent;
	import hy.game.resources.SResourceMagnger;
	import hy.rpg.enum.EnumRenderLayer;

	public class ComponentShodow extends SRenderComponent
	{

		public function ComponentShodow(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			m_render.bitmapData = SResourceMagnger.getInstance().getImageById("res_shadow_1", Config.supportDirectX);
			m_render.x = -m_render.bitmapData.width * .5;
			m_render.y = -20;
			m_render.layer = EnumRenderLayer.SHODOW;
		}
	}
}