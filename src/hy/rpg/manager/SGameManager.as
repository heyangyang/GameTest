package hy.rpg.manager
{
	import hy.game.cfg.Config;
	import hy.game.components.SAvatarComponent;
	import hy.game.core.SCameraObject;
	import hy.game.enum.PriorityType;
	import hy.game.manager.SBaseManager;
	import hy.game.manager.SLayerManager;
	import hy.rpg.components.SHpComponent;
	import hy.rpg.components.SNameComponent;
	import hy.rpg.components.SRoleComponentData;
	import hy.rpg.components.SShodowComponent;
	import hy.rpg.map.SMapObject;
	import hy.rpg.object.SRoleObject;
	import hy.rpg.utils.SCommonUtil;

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
		public function createMapObject() : SMapObject
		{
			var map : SMapObject = new SMapObject(Config.SMALL_MAP_SCALE);
			SLayerManager.getInstance().addObjectByType(SLayerManager.LAYER_MAP, map);
			map.registerd();
			return map;
		}

		/**
		 *  创建玩家自己的角色
		 *
		 */
		public function createMyselfHeroObject(id : String) : SRoleObject
		{
			var heroObject : SRoleObject = new SRoleObject();

			heroObject.transform.x = SCommonUtil.getPixelXByGrid(45);
			heroObject.transform.y = SCommonUtil.getPixelYByGrid(20);

			//数据组件
			var roleComponentData : SRoleComponentData = new SRoleComponentData();
			roleComponentData.name = "无法无天";
			heroObject.addComponent(roleComponentData);
			//avatar组件
			var avatarComponet : SAvatarComponent = new SAvatarComponent();
			avatarComponet.setAvatarId(id);
			heroObject.addComponent(avatarComponet);
			//名字组件
			var nameComponent : SNameComponent = new SNameComponent();
			heroObject.addComponent(nameComponent);
			//shodow
			var shodowComponent : SShodowComponent = new SShodowComponent();
			heroObject.addComponent(shodowComponent);
			heroObject.addComponent(new SHpComponent());
			//为镜头添加焦点对象
			SLayerManager.getInstance().addObjectByType(SLayerManager.LAYER_GAME, heroObject);
			heroObject.registerd();
			SCameraObject.getInstance().setGameFocus(heroObject);
			return heroObject;
		}
	}
}