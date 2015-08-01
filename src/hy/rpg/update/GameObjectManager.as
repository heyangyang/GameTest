package hy.rpg.update
{
	import flash.utils.Dictionary;

	import hy.game.core.GameObject;
	import hy.game.core.SCameraObject;
	import hy.game.core.SUpdate;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.manager.ManagerGame;
	import hy.rpg.manager.ManagerObjectData;

	public class GameObjectManager extends SUpdate
	{
		private static var instance : GameObjectManager;

		public static function getInstance() : GameObjectManager
		{
			if (instance == null)
				instance = new GameObjectManager();
			return instance;
		}

		private var lastSceneX : int;
		private var lastSceneY : int;
		private var game_list : Dictionary;
		private var updateGame : GameObject;
		private var dataMagr : ManagerObjectData;
		private var hasCreatedObject : Boolean;

		public function GameObjectManager()
		{
			super();
			game_list = new Dictionary();
			dataMagr = ManagerObjectData.getInstance();
			frameRate = 10;
			hasCreatedObject = false;
		}

		override public function update() : void
		{
			if (!hasCreatedObject && SCameraObject.sceneX == lastSceneX && SCameraObject.sceneY == lastSceneY)
				return;
			lastSceneX = SCameraObject.sceneX;
			lastSceneY = SCameraObject.sceneY;
			for each (updateGame in game_list)
			{
				if (SCameraObject.isInScreen(updateGame.transform))
					continue
				delete game_list[updateGame.id];
				updateGame.destroy();
			}

			for each (var data : DataComponent in dataMagr.heros)
			{
				if (!SCameraObject.isInScreen(data.transform))
					continue
				if (game_list[data.id])
					continue;
				game_list[data.id] = ManagerGame.getInstance().createHeroObject(data);
				hasCreatedObject = true;
				return;
			}
			hasCreatedObject = false;
		}
	}
}