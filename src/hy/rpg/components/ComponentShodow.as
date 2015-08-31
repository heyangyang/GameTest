package hy.rpg.components
{
	import hy.game.cfg.Config;
	import hy.game.components.SRenderComponent;
	import hy.game.manager.SLayerManager;
	import hy.game.render.SRender;
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
			mRender.bitmapData = SResourceMagnger.getInstance().getImageById("res_shadow_1", Config.supportDirectX);
			mRender.x = -mRender.bitmapData.width * .5;
			mRender.y = -20;
			mRender.layer = EnumRenderLayer.SHODOW;
		}
		
		/**
		 * 不添加到父类，直接添加到name层
		 * @param render
		 *
		 */
		protected override function addRender(render : SRender) : void
		{
			SLayerManager.getInstance().push(SLayerManager.LAYER_ENTITY, render);
		}
		
		protected override function removeRender(render : SRender) : void
		{
			SLayerManager.getInstance().push(SLayerManager.LAYER_ENTITY, render);
		}
	}
}