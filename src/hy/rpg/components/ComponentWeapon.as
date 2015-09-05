package hy.rpg.components
{
	import hy.game.avatar.SActionType;
	import hy.game.components.SAvatarComponent;
	import hy.rpg.enum.EnumLoadPriority;
	import hy.rpg.enum.EnumRenderLayer;

	public class ComponentWeapon extends SAvatarComponent
	{
		public function ComponentWeapon(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			mResource.priority = EnumLoadPriority.WEAPON;
			mRender.layer = EnumRenderLayer.WEAPON;
//			mIsUseFilters = false;
			mUseDefaultAvatar = false;
		}

		override protected function onStart() : void
		{
			super.onStart();
			setAvatarId(mData.weaponId);
		}

		override public function update() : void
		{
			if (mData.isRide && mData.action != SActionType.ATTACK)
			{
				mRender.bitmapData = null;
				return;
			}
			super.update();
		}

		/**
		 * 转换动作的一些操作
		 *
		 */
		override protected function changeAnimation() : void
		{
			if (mData.isRide)
				tmp_frame = mAvatar.gotoAnimation(SActionType.SIT, mDir, 0, 0);
			else
				tmp_frame = mAvatar.gotoAnimation(mAction, mDir, 0, 0);
		}

		override protected function onLoadAvatarComplete() : void
		{
			mDir = mAction = -1;
		}
	}
}