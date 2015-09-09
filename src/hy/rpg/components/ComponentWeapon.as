package hy.rpg.components
{
	import hy.game.avatar.SActionType;
	import hy.game.components.SAvatarComponent;
	import hy.rpg.enum.EnumLoadPriority;
	import hy.rpg.enum.EnumRenderLayer;

	/**
	 * 武器
	 * @author hyy
	 *
	 */
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
		}

		override protected function onStart() : void
		{
			super.onStart();
			setAvatarId(mData.weaponId);
		}

		override public function update() : void
		{
			if (mTransform.isRide && mTransform.action != SActionType.ATTACK)
			{
				mRender.data = null;
				return;
			}
			super.update();
		}

		/**
		 * 转换动作的一些操作
		 *
		 */
		override protected function changeAvatarAction() : void
		{
			if (mTransform.isRide)
				return;
			mAvatar.gotoAnimation(mTransform.action, mTransform.dir, 0, 0);
			mUpdateRectangle = true;
		}

		/**
		 * 加载完毕
		 *
		 */
		override protected function onLoadAvatarComplete() : void
		{
			changeAvatarAction();
		}
	}
}