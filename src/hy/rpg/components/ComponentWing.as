package hy.rpg.components
{
	import hy.game.avatar.SActionType;
	import hy.game.avatar.SAvatar;
	import hy.game.components.SAvatarComponent;
	import hy.game.core.STime;
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
			m_render.layer = EnumRenderLayer.WING;
			setAvatarId(m_data.weaponId);
		}

		override public function update() : void
		{
			if (m_lazyAvatar.isChange)
			{
				m_lazyAvatar.addNotifyCompleted(onLoadAvatarComplete);
				m_lazyAvatar.loadResource();
			}
			if (!m_avatar)
				return;
			if (m_dir != m_transform.dir)
			{
				m_dir = m_transform.dir;
				m_avatar.gotoDirection(m_dir);
			}
			else
				tmp_frame = m_avatar.gotoNextFrame(STime.deltaTime);
			if (!tmp_frame || tmp_frame == m_frame || !tmp_frame.frameData)
				return;
			m_frame = tmp_frame;
			if (needReversal != m_frame.needReversal)
			{
				needReversal = m_frame.needReversal;
				m_render.scaleX = needReversal ? -1 : 1;
			}
			m_frame.needReversal && m_frame.reverseData();
			m_render.bitmapData = m_frame.frameData;
			m_render.x = m_frame.x;
			m_render.y = m_frame.y;
		}

		override protected function onLoadAvatarComplete(avatar : SAvatar) : void
		{
			m_avatar = avatar;
			tmp_frame = m_avatar.gotoAnimation(SActionType.IDLE, 0, m_transform.dir, 0, 0);
		}
	}
}