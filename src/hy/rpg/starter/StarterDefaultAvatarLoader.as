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
			m_avatarResource = new SAvatarResource();
			m_avatarResource.setAvatarId("SHHDefault");
			m_avatarResource.addNotifyCompleted(onLoadAvatarComplete);
			m_avatarResource.loadResource();
		}

		private function onLoadAvatarComplete(avatar : SAvatar) : void
		{
			SAvatarComponent.defaultAvatar = avatar;
			avatar.animationsByParts.loaderAnimation(nextNode);
		}


		override public function get id() : String
		{
			return GameNodeEnmu.model_load;
		}
	}
}