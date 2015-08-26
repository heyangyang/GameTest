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
			m_lazyAvatar.priority = EnumLoadPriority.MOUNT;
			m_useCenterOffsetY = false;
			m_isUseFilters = false;
			m_useDefaultAvatar = false;
		}

		override public function notifyRemoved() : void
		{
			super.notifyRemoved();
			if (m_data)
				m_data.isRide = false;
		}

		override protected function onStart() : void
		{
			super.onStart();
			setAvatarId(m_data.mountId);
		}

		/**
		 * 转换动作的一些操作
		 *
		 */
		override protected function changeAnimation() : void
		{
			mRender.layer = EnumDirection.isBackDirection(m_dir) ? EnumRenderLayer.MOUNT_BACK : EnumRenderLayer.MOUNT;
			tmp_frame = m_avatar.gotoAnimation(m_action, m_dir, 0, 0);
		}

		override protected function onLoadAvatarComplete() : void
		{
			m_dir = m_action = -1;
			mTransform.centerOffsetY = -m_avatar.height;
			m_data.isRide = true;
		}
	}
}