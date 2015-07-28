package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import hy.game.SGame;
	import hy.rpg.manager.SGameManager;

	public class GameTest extends Sprite
	{
		public function GameTest()
		{
			stage ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(evt : Event = null) : void
		{
			new SGame(stage);
			SGameManager.getInstance().createMapObject("wuxingwuzu");
		}
	}
}