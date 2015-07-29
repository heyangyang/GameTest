package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import hy.game.GameFrameStart;
	import hy.rpg.manager.SGameManager;
	import hy.rpg.object.SRoleObject;

	public class GameTest extends Sprite
	{
		public function GameTest()
		{
			stage ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(evt : Event = null) : void
		{
			new GameFrameStart(stage,new GameStarter());
			SGameManager.getInstance().createCameraObject();
			SGameManager.getInstance().createMapObject("wuxingwuzu");
			var heroObject : SRoleObject = SGameManager.getInstance().createMyselfHeroObject("SHHeroAsura");
		}
	}
}