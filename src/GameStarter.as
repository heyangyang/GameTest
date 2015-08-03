package
{
	import hy.game.core.STime;
	import hy.game.manager.SReferenceManager;
	import hy.game.monitor.SMonitor;
	import hy.game.starter.SGameStartBase;
	import hy.rpg.starter.GameNodeEnmu;
	import hy.rpg.starter.StarterBaseConfig;
	import hy.rpg.starter.StarterEnterScene;
	import hy.rpg.starter.StarterMapLoader;
	import hy.rpg.starter.StarterShortcutKey;
	import hy.rpg.manager.ManagerGameObject;

	/**
	 * 启动器
	 * @author wait
	 *
	 */
	public class GameStarter extends SGameStartBase
	{
		public function GameStarter()
		{
			super();
		}

		override public function onStart() : void
		{
			addNodeByClass(StarterBaseConfig);
			addNodeByClass(StarterMapLoader);
			addNodeByClass(StarterEnterScene);
			addNodeByClass(StarterShortcutKey);
			onFirstStart();
		}

		/**
		 * 游戏第一次运行
		 *
		 */
		private function onFirstStart() : void
		{
			var monitor : SMonitor = SMonitor.getInstance();
			monitor.watchProperty(ManagerGameObject, "objectNumChildren", "objectNum", 0xff0000);
			monitor.watchProperty(SReferenceManager.getInstance(), "total_reference", "total_reference", 0x00ff00);
			monitor.watchProperty(SReferenceManager.getInstance(), "status", "status", 0x00ff00);
			monitor.watchProperty(STime, "deltaTime", "deltaTime", 0x00ff00);
			monitor.watchProperty(STime, "passedTime", "passedTime", 0x00ff00);

			addNodeByType(GameNodeEnmu.base_config);
			addNodeByType(GameNodeEnmu.map_load);
			addNodeByType(GameNodeEnmu.shortkey);
			addNodeByType(GameNodeEnmu.emter_scene);
			run();
		}
	}
}