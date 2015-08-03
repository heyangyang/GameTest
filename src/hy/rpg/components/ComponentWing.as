package hy.rpg.components
{
	import hy.game.avatar.SActionType;
	import hy.game.avatar.SAvatar;
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
			m_lazyAvatar.priority = EnumLoadPriority.WING;
			setAvatarId(m_data.wingId);
			registerd();
		}

		/**
		 * 转换动作的一些操作
		 *
		 */
		override protected function changeAnimation() : void
		{
			tmp_frame = m_avatar.gotoDirection(m_dir);
			m_render.layer = EnumDirection.isBackDirection(m_dir) ? EnumRenderLayer.WING_BACK : EnumRenderLayer.WING;
		}

		override protected function onLoadAvatarComplete(avatar : SAvatar) : void
		{
			m_avatar = avatar;
			if (!m_avatar)
				return;
			tmp_frame = m_avatar.gotoAnimation(SActionType.IDLE, 0, m_transform.dir, 0, 0);
		}
	}
}