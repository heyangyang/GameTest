package hy.rpg.components
{
	import hy.game.components.SAvatarComponent;
	import hy.rpg.enum.EnumDirection;
	import hy.rpg.enum.EnumLoadPriority;
	import hy.rpg.enum.EnumRenderLayer;

	/**
	 * 坐骑组件
	 * @author hyy
	 *
	 */
	public class ComponentMount extends SAvatarComponent
	{
		public function ComponentMount(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			mLazyAvatar.priority = EnumLoadPriority.MOUNT;
			mUseCenterOffsetY = false;
			mIsUseFilters = false;
			mUseDefaultAvatar = false;
		}

		override public function notifyRemoved() : void
		{
			super.notifyRemoved();
			if (mData)
				mData.isRide = false;
		}

		override protected function onStart() : void
		{
			super.onStart();
			setAvatarId(mData.mountId);
		}

		/**
		 * 转换动作的一些操作
		 *
		 */
		override protected function changeAnimation() : void
		{
			mRender.layer = EnumDirection.isBackDirection(mDir) ? EnumRenderLayer.MOUNT_BACK : EnumRenderLayer.MOUNT;
			tmp_frame = mAvatar.gotoAnimation(mAction, mDir, 0, 0);
		}

		override protected function onLoadAvatarComplete() : void
		{
			mDir = mAction = -1;
			mTransform.centerOffsetY = -mAvatar.height;
			mData.isRide = true;
		}
	}
}