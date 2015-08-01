package hy.rpg.manager
{
	import hy.game.avatar.SActionType;
	import hy.game.cfg.Config;
	import hy.game.components.SAnimationComponent;
	import hy.game.components.SAvatarComponent;
	import hy.game.core.GameObject;
	import hy.game.core.SCameraObject;
	import hy.game.data.STransform;
	import hy.game.enum.EnumPriority;
	import hy.game.enum.EnumTags;
	import hy.game.manager.SBaseManager;
	import hy.game.manager.SLayerManager;
	import hy.game.state.StateComponent;
	import hy.rpg.components.ComponentHp;
	import hy.rpg.components.ComponentMouse;
	import hy.rpg.components.ComponentName;
	import hy.rpg.components.ComponentShodow;
	import hy.rpg.components.ComponentWeapon;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.enum.EnumDirection;
	import hy.rpg.map.MapObject;
	import hy.rpg.object.ObjectRole;
	import hy.rpg.state.StateStand;
	import hy.rpg.state.StateWalk;
	import hy.rpg.utils.UtilsCommon;

	/**
	 * 游戏管理器
	 * @author hyy
	 *
	 */
	public class ManagerGame extends SBaseManager
	{
		private static var instance : ManagerGame;

		public static function getInstance() : ManagerGame
		{
			if (instance == null)
				instance = new ManagerGame();
			return instance;
		}

		public function ManagerGame()
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
			camera.registerd(EnumPriority.PRIORITY_1);
		}

		/**
		 * 根据地图id创建地图
		 * @param id
		 *
		 */
		public function createMapObject() : MapObject
		{
			var map : MapObject = new MapObject(Config.SMALL_MAP_SCALE);
			SLayerManager.getInstance().addObjectByType(SLayerManager.LAYER_MAP, map);
			map.registerd();
			return map;
		}

		/**
		 *  创建玩家自己的角色
		 *
		 */
		public function createMyselfHeroObject(id : String) : ObjectRole
		{
			var heroObject : ObjectRole = new ObjectRole();
			heroObject.transform = new STransform();
			heroObject.transform.x = UtilsCommon.getPixelXByGrid(45);
			heroObject.transform.y = UtilsCommon.getPixelYByGrid(20);
			heroObject.transform.dir = EnumDirection.SOUTH;
			//数据组件
			var roleComponentData : DataComponent = new DataComponent();
			roleComponentData.name = "无法无天";
			roleComponentData.avatarId = id;
			roleComponentData.weaponId = "sw_1_0";
			roleComponentData.action = SActionType.IDLE;
			heroObject.addComponent(roleComponentData);
			//avatar组件
			heroObject.addComponent(new SAvatarComponent());
			heroObject.addComponent(new ComponentWeapon());
			//名字组件
			heroObject.addComponent(new ComponentName());
			//shodow
			heroObject.addComponent(new ComponentShodow());
			heroObject.addComponent(new ComponentHp());
			var stateComponent : StateComponent = new StateComponent();
			heroObject.addComponent(stateComponent);
			stateComponent.setStates([StateStand, StateWalk]);
			heroObject.addComponent(new ComponentMouse());
			addTargetEffect(heroObject, "expGuangHuan", 0);
			SLayerManager.getInstance().addObjectByType(SLayerManager.LAYER_GAME, heroObject);
			heroObject.registerd();
			//为镜头添加焦点对象
			SCameraObject.getInstance().setGameFocus(heroObject);
			heroObject.tag = EnumTags.PLAYER;
			return heroObject;
		}

		/**
		 *  创建玩家自己的角色
		 *
		 */
		public function createHeroObject(data : DataComponent) : ObjectRole
		{
			var heroObject : ObjectRole = new ObjectRole();
			heroObject.id = data.id;
			heroObject.transform = data.transform;
			heroObject.addComponent(data);
			//avatar组件
			heroObject.addComponent(new SAvatarComponent());
			heroObject.addComponent(new ComponentWeapon());
			//名字组件
			heroObject.addComponent(new ComponentName());
			//shodow
			heroObject.addComponent(new ComponentShodow());
			heroObject.addComponent(new ComponentHp());
			var stateComponent : StateComponent = new StateComponent();
			heroObject.addComponent(stateComponent);
			stateComponent.setStates([StateStand, StateWalk]);
			SLayerManager.getInstance().addObjectByType(SLayerManager.LAYER_GAME, heroObject);
			heroObject.registerd();
			heroObject.tag = EnumTags.PLAYER;
			return heroObject;
		}

		public function addTargetEffect(gameObject : GameObject, id : String, loops : int, offsetX : int = 0, offsetY : int = 0) : SAnimationComponent
		{
			var animaitonCom : SAnimationComponent = new SAnimationComponent(id);
			animaitonCom.setEffectId(id);
			animaitonCom.setLoops(loops);
			animaitonCom.setOffsetXY(offsetX, offsetY);
			gameObject.addComponent(animaitonCom);
			return animaitonCom;
		}
	}
}