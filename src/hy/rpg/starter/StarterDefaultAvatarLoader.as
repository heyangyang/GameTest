package hy.rpg.starter
{
	import hy.game.avatar.SAvatar;
	import hy.game.avatar.SAvatarResource;
	import hy.game.components.SAvatarComponent;
	import hy.game.starter.SStartNode;

	/**
	 * 加载默认模型
	 * @author wait
	 *
	 */
	public class StarterDefaultAvatarLoader extends SStartNode
	{
		private var m_avatarResource : SAvatarResource;
		private var m_avatar : SAvatar;

		public function StarterDefaultAvatarLoader()
		{
			super();
		}

		/**
		 * 启动器初始化
		 *
		 */
		override public function onStart() : void
		{
			SAvatarComponent.default_avatar = m_avatar = new SAvatar();
			m_avatarResource = new SAvatarResource(m_avatar);
			m_avatarResource.setAvatarId("SHHDefault");
			m_avatarResource.addNotifyCompleted(onLoadAvatarComplete);
			m_avatarResource.loadResource();
		}

		private function onLoadAvatarComplete() : void
		{
			m_avatar.animationsByParts.loaderAnimation(onLoadAllAnimation);
		}

		/**
		 * 所有动作加载完毕
		 *
		 */
		private function onLoadAllAnimation() : void
		{
			if (m_avatar)
				m_avatar = null;
			if (m_avatarResource)
			{
				m_avatarResource.dispose();
				m_avatarResource = null;
			}
			nextNode();
		}


		override public function get id() : String
		{
			return GameNodeEnmu.model_load;
		}
	}
}