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
			mResource.priority = EnumLoadPriority.MOUNT;
		}

		override public function notifyRemoved() : void
		{
			super.notifyRemoved();
			if (mTransform)
				mTransform.isRide = false;
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
		override protected function changeAvatarAction() : void
		{
			mRender.layer = EnumDirection.isBackDirection(mTransform.dir) ? EnumRenderLayer.MOUNT_BACK : EnumRenderLayer.MOUNT;
			mAvatar.gotoAnimation(mTransform.action, mTransform.dir, 0, 0);
			mUpdateRectangle = true;
		}

		/**
		 * 加载完毕
		 *
		 */
		override protected function onLoadAvatarComplete() : void
		{
			mTransform.centerOffsetY = -mAvatar.height;
			mTransform.isRide = true;
			changeAvatarAction();
		}
	}
}