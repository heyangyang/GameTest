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
			m_isUseFilters = false;
			m_useDefaultAvatar = false;
		}

		override protected function onStart() : void
		{
			super.onStart();
			setAvatarId(m_data.wingId);
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
			m_dir = m_action = -1;
			tmp_frame = m_avatar.gotoAnimation(SActionType.IDLE, m_transform.dir, 0, 0);
		}
	}
}