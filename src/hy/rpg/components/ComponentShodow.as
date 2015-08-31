package hy.rpg.components
{
	import hy.game.cfg.Config;
	import hy.game.components.SRenderComponent;
	import hy.game.manager.SLayerManager;
	import hy.game.render.SRender;
	import hy.game.resources.SResourceMagnger;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.enum.EnumRenderLayer;

	public class ComponentShodow extends SRenderComponent
	{
		private var mData : DataComponent;

		public function ComponentShodow(type : * = null)
		{
			super(type);
		}

		/**
		 * 继承的子类，必须调用该类方法
		 *
		 */
		override protected function onStart() : void
		{
			super.onStart();
			mData = mOwner.getComponentByType(DataComponent) as DataComponent;
			mTransform.addPositionChange(updatePosition);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			mRender.bitmapData = SResourceMagnger.getInstance().getImageById("res_shadow_1", Config.supportDirectX);
			mRender.layer = EnumRenderLayer.SHODOW;
		}

		protected function updatePosition() : void
		{
			mRender.x = mTransform.screenX - (mRender.bitmapData.width >> 1);
			mRender.y = mTransform.screenY - 20;
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