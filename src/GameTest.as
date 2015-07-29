package
{
	import flash.display.Sprite;
	import flash.events.Event;

	import hy.game.SGame;
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
			new SGame(stage);
			SGameManager.getInstance().createCameraObject();
			SGameManager.getInstance().createMapObject("wuxingwuzu");
			var heroObject : SRoleObject = SGameManager.getInstance().createMyselfHeroObject("SHHeroAsura");
			heroObject.transform.x = stage.stageWidth * .5;
			heroObject.transform.y = stage.stageHeight * .5;
		}
	}
}