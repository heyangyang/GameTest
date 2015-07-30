package hy.rpg.starter
{
	import hy.game.starter.SStartNode;
	import hy.rpg.manager.SGameManager;

	public class SEnterGameScene extends SStartNode
	{
		public function SEnterGameScene()
		{
			super();
		}

		/**
		 * 启动器初始化
		 *
		 */
		override public function onStart() : void
		{
			SGameManager.getInstance().createMyselfHeroObject("SHHeroAsura");
		}

		override public function get id() : String
		{
			return SGameNodeType.ENTER_SCENE;
		}
	}
}