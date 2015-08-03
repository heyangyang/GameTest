package hy.rpg.components
{
	import hy.game.avatar.SActionType;
	import hy.game.avatar.SAvatar;
	import hy.game.components.SAvatarComponent;
	import hy.game.enum.EnumPriority;
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
			m_render.layer = EnumRenderLayer.WEAPON;
			setAvatarId(m_data.weaponId);
			registerd(EnumPriority.PRIORITY_7);
		}

		override public function update() : void
		{
			if (m_data.isRide && m_data.action != SActionType.ATTACK)
			{
				m_render.bitmapData = null;
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
				tmp_frame = m_avatar.gotoAnimation(SActionType.SIT, 0, m_dir, 0, 0);
			else
				tmp_frame = m_avatar.gotoAnimation(m_action, 0, m_dir, 0, 0);
		}

		override protected function onLoadAvatarComplete(avatar : SAvatar) : void
		{
			m_avatar = avatar;
		}
	}
}