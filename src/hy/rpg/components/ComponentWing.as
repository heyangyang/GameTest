package hy.rpg.components
{
	import hy.game.avatar.SActionType;
	import hy.game.components.SAvatarComponent;
	import hy.rpg.enum.EnumDirection;
	import hy.rpg.enum.EnumLoadPriority;
	import hy.rpg.enum.EnumRenderLayer;

	public class ComponentWing extends SAvatarComponent
	{
		public function ComponentWing(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			mResource.priority = EnumLoadPriority.WING;
			mIsUseFilters = false;
			mUseDefaultAvatar = false;
		}

		override protected function onStart() : void
		{
			super.onStart();
			setAvatarId(mData.wingId);
		}

		/**
		 * 转换动作的一些操作
		 *
		 */
		override protected function changeAnimation() : void
		{
			tmp_frame = mAvatar.gotoDirection(mDir);
			mRender.layer = EnumDirection.isBackDirection(mDir) ? EnumRenderLayer.WING_BACK : EnumRenderLayer.WING;
		}

		override protected function onLoadAvatarComplete() : void
		{
			mDir = mAction = -1;
			tmp_frame = mAvatar.gotoAnimation(SActionType.IDLE, mTransform.dir, 0, 0);
		}
	}
}