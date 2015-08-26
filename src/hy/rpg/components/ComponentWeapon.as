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
			m_lazyAvatar.priority = EnumLoadPriority.WEAPON;
			mRender.layer = EnumRenderLayer.WEAPON;
			m_isUseFilters = false;
			m_useDefaultAvatar = false;
		}

		override protected function onStart() : void
		{
			super.onStart();
			setAvatarId(m_data.weaponId);
		}

		override public function update() : void
		{
			if (m_data.isRide && m_data.action != SActionType.ATTACK)
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
			if (m_data.isRide)
				tmp_frame = m_avatar.gotoAnimation(SActionType.SIT, m_dir, 0, 0);
			else
				tmp_frame = m_avatar.gotoAnimation(m_action, m_dir, 0, 0);
		}

		override protected function onLoadAvatarComplete() : void
		{
			m_dir = m_action = -1;
		}
	}
}