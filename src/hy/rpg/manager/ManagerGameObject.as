package hy.rpg.manager
{
	import flash.utils.Dictionary;

	import hy.game.core.GameObject;
	import hy.game.core.SCameraObject;
	import hy.game.core.SUpdate;
	import hy.rpg.components.data.DataComponent;

	/**
	 * 游戏对象管理
	 * 移除可视范围外的对象
	 * 创建可视范围内的对象
	 * 镜头不移动的时候不会做任何操作
	 * @author wait
	 *
	 */
	public class ManagerGameObject extends SUpdate
	{
		private static var instance : ManagerGameObject;

		public static function getInstance() : ManagerGameObject
		{
			if (instance == null)
				instance = new ManagerGameObject();
			return instance;
		}

		private var lastSceneX : int;
		private var lastSceneY : int;
		private var game_list : Dictionary;
		private var updateGame : GameObject;
		private var dataMagr : ManagerGameData;
		/**
		 * 是否还有没有创建完成的对象
		 */
		private var hasCreatedObject : Boolean;
		public static var hero_count : int;

		public function ManagerGameObject()
		{
			super();
			game_list = new Dictionary();
			dataMagr = ManagerGameData.getInstance();
			frameRate = 10;
			hasCreatedObject = false;
		}

		override public function update() : void
		{
			if (!hasCreatedObject && !dataMagr.isChange && SCameraObject.sceneX == lastSceneX && SCameraObject.sceneY == lastSceneY)
				return;
			lastSceneX = SCameraObject.sceneX;
			lastSceneY = SCameraObject.sceneY;
			hero_count = 0;
			for each (updateGame in game_list)
			{
				if (SCameraObject.isInScreen(updateGame.transform))
				{
					hero_count++;
					continue;
				}
				delete game_list[updateGame.id];
				updateGame.destroy();
			}

			for each (var data : DataComponent in dataMagr.heros)
			{
				if (!SCameraObject.isInScreen(data.transform))
					continue
				if (game_list[data.id])
					continue;
				game_list[data.id] = ManagerGameCreate.getInstance().createHeroObject(data);
				hasCreatedObject = true;
				return;
			}
			hasCreatedObject = false;
		}
	}
}