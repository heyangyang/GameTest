package
{
	import hy.game.starter.SGameStartBase;
	import hy.rpg.starter.SBaseConfigLoader;
	
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
		
		override public function onStart():void
		{
			addNode(SBaseConfigLoader);
		}
	}
}