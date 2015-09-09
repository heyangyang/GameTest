package hy.rpg.components
{
	import hy.game.components.SRenderComponent;
	import hy.game.manager.SLayerManager;
	import hy.rpg.components.data.DataComponent;
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
			mData = mOwner.getComponentByType(DataComponent) as DataComponent;
			mTransform.addPositionChange(updatePosition);
			mTransform.addSizeChange(updatePosition);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			mLayerType = SLayerManager.LAYER_HP;
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
				mRender.data = UtilsHpBar.getHp(mData.hp_cur / mData.hp_max * 100);
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
			mRender.depth = mTransform.screenY;
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