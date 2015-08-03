package hy.rpg.manager
{
	import hy.game.cfg.Config;
	import hy.game.components.SAnimationComponent;
	import hy.game.components.SAvatarComponent;
	import hy.game.core.GameObject;
	import hy.game.core.SCameraObject;
	import hy.game.enum.EnumPriority;
	import hy.game.enum.EnumTags;
	import hy.game.manager.SBaseManager;
	import hy.game.manager.SLayerManager;
	import hy.game.state.StateComponent;
	import hy.rpg.components.ComponentHp;
	import hy.rpg.components.ComponentMount;
	import hy.rpg.components.ComponentMouse;
	import hy.rpg.components.ComponentName;
	import hy.rpg.components.ComponentShodow;
	import hy.rpg.components.ComponentWeapon;
	import hy.rpg.components.ComponentWing;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.map.MapObject;
	import hy.rpg.object.ObjectRole;
	import hy.rpg.state.StateStand;
	import hy.rpg.state.StateWalk;

	/**
	 * 游戏管理器
	 * @author hyy
	 *
	 */
	public class ManagerGameCreate extends SBaseManager
	{
		private static var instance : ManagerGameCreate;

		public static function getInstance() : ManagerGameCreate
		{
			if (instance == null)
				instance = new ManagerGameCreate();
			return instance;
		}

		public function ManagerGameCreate()
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
		public function createMyselfHeroObject(data : DataComponent) : ObjectRole
		{
			var heroObject : ObjectRole = new ObjectRole();
			heroObject.id = data.id;
			heroObject.transform = data.transform;
			heroObject.addComponent(data);
			//avatar组件
			if (data.avatarId)
				heroObject.addComponent(new SAvatarComponent());
			if (data.weaponId)
				heroObject.addComponent(new ComponentWeapon());
			if (data.wingId)
				heroObject.addComponent(new ComponentWing());
			if (data.mountId)
				heroObject.addComponent(new ComponentMount());
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
			if (data.avatarId)
				heroObject.addComponent(new SAvatarComponent());
			if (data.weaponId)
				heroObject.addComponent(new ComponentWeapon());
			if (data.wingId)
				heroObject.addComponent(new ComponentWing());
			if (data.mountId)
				heroObject.addComponent(new ComponentMount());
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