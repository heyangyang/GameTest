package hy.rpg.components
{
	import hy.game.components.SRenderComponent;
	import hy.game.resources.SResourceMagnger;
	import hy.rpg.enmu.SRenderLayerType;

	public class SShodowComponent extends SRenderComponent
	{

		public function SShodowComponent(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			m_render.bitmapData = SResourceMagnger.getInstance().getImageById("res_shadow_1");
			m_render.x = -m_render.bitmapData.width * .5;
			m_render.y = -20;
			m_render.layer = SRenderLayerType.SHODOW;
		}
	}
}