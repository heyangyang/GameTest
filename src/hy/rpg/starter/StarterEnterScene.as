package hy.rpg.starter
{
	import hy.game.starter.SStartNode;
	import hy.rpg.manager.ManagerGame;
	import hy.rpg.manager.ManagerObjectData;
	import hy.rpg.update.GameObjectManager;

	/**
	 * 转换场景
	 * 启动器
	 * @author hyy
	 *
	 */
	public class StarterEnterScene extends SStartNode
	{
		public function StarterEnterScene()
		{
			super();
		}

		/**
		 * 启动器初始化
		 *
		 */
		override public function onStart() : void
		{
			ManagerGame.getInstance().createMyselfHeroObject("SHHeroAsura");
			ManagerObjectData.getInstance();
			GameObjectManager.getInstance().registerd();
		}

		override public function get id() : String
		{
			return GameNodeEnmu.emter_scene;
		}
	}
}