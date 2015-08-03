package hy.rpg.components
{
	import hy.game.avatar.SAvatar;
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
			m_lazyAvatar.priority = EnumLoadPriority.MOUNT;
			setAvatarId(m_data.mountId);
			m_useCenterOffsetY = false;
			registerd();
		}


		/**
		 * 转换动作的一些操作
		 *
		 */
		override protected function changeAnimation() : void
		{
			m_render.layer = EnumDirection.isBackDirection(m_dir) ? EnumRenderLayer.MOUNT_BACK : EnumRenderLayer.MOUNT;
			tmp_frame = m_avatar.gotoAnimation(m_action, 0, m_dir, 0, 0);
		}
		
		override protected function onLoadAvatarComplete(avatar : SAvatar) : void
		{
			m_avatar = avatar;
			if (!m_avatar)
				return;
			m_transform.centerOffsetY = -m_avatar.height;
			m_data.isRide = true;
		}

		override public function destroy() : void
		{
			if (m_data)
				m_data.isRide = false;
			super.destroy();
		}
	}
}