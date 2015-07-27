package hy.rpg.manager
{
	import hy.game.manager.SBaseManager;

	/**
	 * 游戏管理器
	 * @author hyy
	 *
	 */
	public class SGameManager extends SBaseManager
	{
		private static var instance : SGameManager;

		public static function getInstance() : void
		{
			if (instance == null)
				instance = new SGameManager();
			return;
		}

		public function SGameManager()
		{
			if (instance)
				error("instance != null");
		}

		public function createMapObject() : void
		{

		}
	}
}