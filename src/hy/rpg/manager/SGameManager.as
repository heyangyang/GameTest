package hy.rpg.manager
{
	import hy.game.cfg.Config;
	import hy.game.core.SCameraObject;
	import hy.game.enum.PriorityType;
	import hy.game.manager.SBaseManager;
	import hy.game.manager.SLayerManager;
	import hy.rpg.map.SMapObject;
	import hy.rpg.object.SRoleObject;

	/**
	 * 游戏管理器
	 * @author hyy
	 *
	 */
	public class SGameManager extends SBaseManager
	{
		private static var instance : SGameManager;

		public static function getInstance() : SGameManager
		{
			if (instance == null)
				instance = new SGameManager();
			return instance;
		}

		public function SGameManager()
		{
			if (instance)
				error("instance != null");
		}

		/**
		 * 初始化镜头
		 *
		 */
		public function createCameraObject() : void
		{
			var camera : SCameraObject = SCameraObject.getInstance();
			SLayerManager.getInstance().addObjectByType(SLayerManager.LAYER_MAP, camera);
			camera.registerd(PriorityType.PRIORITY_1);
		}

		/**
		 * 根据地图id创建地图
		 * @param id
		 *
		 */
		public function createMapObject(id : String) : void
		{
			var map : SMapObject = new SMapObject(Config.SMALL_MAP_SCALE);
			SLayerManager.getInstance().addObjectByType(SLayerManager.LAYER_MAP, map);
			map.registerd();
			map.load("scene/" + id + "/" + id + ".smc");
		}

		/**
		 *  创建玩家自己的角色
		 *
		 */
		public function createMyselfHeroObject(id : String) : void
		{
			var heroObject : SRoleObject = new SRoleObject();
			SLayerManager.getInstance().addObjectByType(SLayerManager.LAYER_GAME, heroObject);
			heroObject.registerd();
			SCameraObject.getInstance().setGameFocus(heroObject);
		}
	}
}