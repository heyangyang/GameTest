package hy.rpg.components
{
	import hy.game.components.SRenderComponent;
	import hy.game.manager.SLayerManager;
	import hy.game.render.SRender;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.enum.EnumRenderLayer;
	import hy.rpg.utils.UtilsHpBar;

	/**
	 * 血条组件
	 * @author wait
	 *
	 */
	public class ComponentHp extends SRenderComponent
	{
		private var mLastHp : int;
		private var mIsMouseOver : Boolean;
		private var mData : DataComponent;
		private var mIsUpdatable : Boolean;

		public function ComponentHp(type : * = null)
		{
			super(type);
		}

		override protected function onStart() : void
		{
			super.onStart();
			mData = m_owner.getComponentByType(DataComponent) as DataComponent;
			mTransform.addPositionChange(updatePosition);
			mTransform.addSizeChange(updatePosition);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			mRender.layer = EnumRenderLayer.HP;
			mLastHp = -1;
		}

		override public function notifyRemoved() : void
		{
			super.notifyRemoved();
			mData = null;
		}

		override public function update() : void
		{
			if (mIsMouseOver != mTransform.isMouseOver)
			{
				mIsMouseOver = mTransform.isMouseOver;
				updateRenderVisible();
			}
			if (mLastHp != mData.hp_cur)
			{
				mLastHp = mData.hp_cur;
				mRender.bitmapData = UtilsHpBar.getHp(mData.hp_cur / mData.hp_max * 100);
			}
			if (mIsUpdatable)
			{
				mIsUpdatable = false;
				updatePosition();
			}
		}

		protected function updatePosition() : void
		{
			mRender.x = mTransform.screenX - 30;
			mRender.y = mTransform.screenY - mTransform.height - mOffsetY - mTransform.z + mTransform.centerOffsetY;
		}

		/**
		 * 不添加到父类，直接添加到name层
		 * @param render
		 *
		 */
		protected override function addRender(render : SRender) : void
		{
			SLayerManager.getInstance().addRenderByType(SLayerManager.LAYER_HP, render);
		}

		protected override function removeRender(render : SRender) : void
		{
			SLayerManager.getInstance().removeRenderByType(SLayerManager.LAYER_HP, render);
		}

		override protected function updateRenderVisible() : void
		{
			if (mIsVisible || mIsMouseOver)
			{
				mIsUpdatable = true;
				addRender(mRender)
				return;
			}
			mIsUpdatable = false;
			removeRender(mRender);
		}
	}
}