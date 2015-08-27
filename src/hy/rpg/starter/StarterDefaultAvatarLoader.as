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
		private var mAvatarResource : SAvatarResource;
		private var mAvatar : SAvatar;

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
			SAvatarComponent.default_avatar = mAvatar = new SAvatar();
			mAvatarResource = new SAvatarResource(mAvatar);
			mAvatarResource.setAvatarId("SHHDefault");
			mAvatarResource.addNotifyCompleted(onLoadAvatarComplete);
			mAvatarResource.loadResource();
		}

		private function onLoadAvatarComplete() : void
		{
			mAvatar.animationsByParts.loaderAnimation(onLoadAllAnimation);
		}

		/**
		 * 所有动作加载完毕
		 *
		 */
		private function onLoadAllAnimation() : void
		{
			if (mAvatar)
				mAvatar = null;
			if (mAvatarResource)
			{
				mAvatarResource.dispose();
				mAvatarResource = null;
			}
			nextNode();
		}


		override public function get id() : String
		{
			return GameNodeEnmu.model_load;
		}
	}
}