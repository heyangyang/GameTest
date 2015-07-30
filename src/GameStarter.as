package
{
	import hy.game.starter.SGameStartBase;
	import hy.rpg.starter.SBaseConfigLoader;
	import hy.rpg.starter.SEnterGameScene;
	import hy.rpg.starter.SGameNodeType;
	import hy.rpg.starter.SMapLoader;

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
			addNode(SBaseConfigLoader);
			addNode(SMapLoader);
			addNode(SEnterGameScene);
			onFirstStart();
		}

		private function onFirstStart() : void
		{
			updateExcuteData([SGameNodeType.BASE_CONFIG, SGameNodeType.MAP_LOAD, SGameNodeType.ENTER_SCENE]);
			run();
		}
	}
}