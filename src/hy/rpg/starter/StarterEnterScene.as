package hy.rpg.starter
{
	import hy.game.starter.SStartNode;
	import hy.rpg.manager.ManagerGame;

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
		}

		override public function get id() : String
		{
			return GameNodeEnmu.emter_scene;
		}
	}
}