package hy.rpg.manager
{
	import hy.game.components.SAnimationComponent;
	import hy.game.components.SAvatarComponent;
	import hy.game.components.SCollisionComponent;
	import hy.game.components.SRenderComponent;
	import hy.game.core.GameObject;
	import hy.game.core.SCameraObject;
	import hy.game.data.STransform;
	import hy.game.enum.EnumPriority;
	import hy.game.enum.EnumTags;
	import hy.game.manager.SBaseManager;
	import hy.game.manager.SLayerManager;
	import hy.game.state.StateComponent;
	import hy.rpg.components.ComponentAi;
	import hy.rpg.components.ComponentHp;
	import hy.rpg.components.ComponentMount;
	import hy.rpg.components.ComponentMouse;
	import hy.rpg.components.ComponentName;
	import hy.rpg.components.ComponentShodow;
	import hy.rpg.components.ComponentWeapon;
	import hy.rpg.components.ComponentWing;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.enum.EnumRenderLayer;
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
			camera.registerd(EnumPriority.PRIORITY_MAX);
		}

		/**
		 * 根据地图id创建地图
		 * @param id
		 *
		 */
		public function createMapObject() : MapObject
		{
			var map : MapObject = MapObject.getInstance();
			map.transform = new STransform();
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
				heroObject.addComponent(new SAvatarComponent(), EnumPriority.PRIORITY_9);
			if (data.weaponId)
				heroObject.addComponent(new ComponentWeapon(), EnumPriority.PRIORITY_7);
			if (data.wingId)
				heroObject.addComponent(new ComponentWing(), EnumPriority.PRIORITY_7);
			if (data.mountId)
				heroObject.addComponent(new ComponentMount(), EnumPriority.PRIORITY_8);
			//名字组件
			heroObject.addComponent(new ComponentName());
			heroObject.addComponent(new ComponentHp());
			//shodow
			heroObject.addComponent(new ComponentShodow());
			var stateComponent : StateComponent = new StateComponent();
			heroObject.addComponent(stateComponent, EnumPriority.PRIORITY_6);
			stateComponent.setStates([StateStand, StateWalk]);
			//鼠标组件
			heroObject.addComponent(new ComponentMouse());
			addTargetEffect(heroObject, "expGuangHuan", null, 0, EnumRenderLayer.SHODOW_ANIMATION);
			SLayerManager.getInstance().addObjectByType(SLayerManager.LAYER_ENTITY, heroObject);
			heroObject.registerd(EnumPriority.PRIORITY_MAX);
			//为镜头添加焦点对象
			SCameraObject.getInstance().setGameFocus(heroObject);
			heroObject.tag = EnumTags.PLAYER;
			return heroObject;
		}

		/**
		 *  创建其他玩家的角色
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
				heroObject.addComponent(new SAvatarComponent(), EnumPriority.PRIORITY_9);
			if (data.weaponId)
				heroObject.addComponent(new ComponentWeapon(), EnumPriority.PRIORITY_7);
			if (data.wingId)
				heroObject.addComponent(new ComponentWing(), EnumPriority.PRIORITY_7);
			if (data.mountId)
				heroObject.addComponent(new ComponentMount(), EnumPriority.PRIORITY_8);
			//名字组件
			var renderComponent : SRenderComponent = new ComponentName();
			//renderComponent.setVisible(false);
			heroObject.addComponent(renderComponent);
			renderComponent = new ComponentHp()
			renderComponent.setVisible(false);
			heroObject.addComponent(renderComponent);
			//shodow
			heroObject.addComponent(new ComponentShodow());
			heroObject.addComponent(new SCollisionComponent());
			heroObject.addComponent(new ComponentAi());
			var stateComponent : StateComponent = new StateComponent();
			heroObject.addComponent(stateComponent, EnumPriority.PRIORITY_6);
			stateComponent.setStates([StateStand, StateWalk]);
			SLayerManager.getInstance().addObjectByType(SLayerManager.LAYER_ENTITY, heroObject);
			heroObject.registerd();
			heroObject.tag = EnumTags.PLAYER;
			return heroObject;
		}

		public function addTargetEffect(gameObject : GameObject, id : String, typeId : String, loops : int, layer : int = 0, offsetX : int = 0, offsetY : int = 0) : SAnimationComponent
		{
			var animaitonCom : SAnimationComponent = new SAnimationComponent(typeId ? typeId : id);
			animaitonCom.setEffectId(id);
			animaitonCom.setLoops(loops);
			animaitonCom.setOffsetXY(offsetX, offsetY);
			animaitonCom.setPosition(0, 0);
			animaitonCom.setLayer(layer);
			gameObject.addComponent(animaitonCom);
			return animaitonCom;
		}

		public function createSceneEffect(id : String, typeId : String, x : int, y : int, loops : int, offsetX : int = 0, offsetY : int = 0) : SAnimationComponent
		{
			var animaitonCom : SAnimationComponent = new SAnimationComponent(typeId ? typeId : id);
			animaitonCom.setEffectId(id);
			animaitonCom.setLoops(loops);
			animaitonCom.setOffsetXY(offsetX, offsetY);
			animaitonCom.setPosition(x, y);
			animaitonCom.setLayer(1);
			MapObject.getInstance().addComponent(animaitonCom);
			return animaitonCom;
		}
	}
}