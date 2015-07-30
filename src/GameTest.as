package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import hy.game.GameFrameStart;

	public class GameTest extends Sprite
	{
		public function GameTest()
		{
			stage ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(evt : Event = null) : void
		{
			new GameFrameStart(stage,new GameStarter());
		}
	}
}