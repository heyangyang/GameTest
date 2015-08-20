package hy.rpg.manager
{
	import flash.utils.Dictionary;

	import hy.game.avatar.SActionType;
	import hy.game.core.GameObject;
	import hy.game.core.SCameraObject;
	import hy.game.core.SUpdate;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.enum.EnumDirection;
	import hy.rpg.seek.SRoadSeeker;
	import hy.rpg.utils.UtilsCommon;

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
		private static var m_objectNumChildren : int;

		/**
		 * 可视范围内的对象数量
		 * @return
		 *
		 */
		public static function get objectNumChildren() : int
		{
			return m_objectNumChildren;
		}


		public static function getInstance() : ManagerGameObject
		{
			if (instance == null)
				instance = new ManagerGameObject();
			return instance;
		}

		/**
		 * 上一次场景的坐标X,Y
		 */
		private var m_lastSceneX : int = -99;
		private var m_lastSceneY : int = -99;
		/**
		 * 可视范围内的对象
		 */
		private var m_visaulObjects : Dictionary;
		/**
		 * 地图内的所有对象数据
		 */
		private var m_objectDatas : Vector.<DataComponent>;
		private var m_deleteObjects : Vector.<GameObject>;
		private var m_deleteCount : int;
		/**
		 * 是否有增加删除数据
		 */
		private var m_isDataChange : Boolean;
		private var currUpdateGame : GameObject;
		/**
		 * 是否还有没有创建完成的对象
		 */
		private var m_hasCreatedObject : Boolean;

		public function ManagerGameObject()
		{
			super();
			m_visaulObjects = new Dictionary();
			m_objectDatas = new Vector.<DataComponent>();
			m_deleteObjects = new Vector.<GameObject>();
			frameRate = 10;
			m_hasCreatedObject = false;
			init();
		}

		private function init() : void
		{
			//虚拟数据
			var heroTypes : Array = ["SHHeroAsura", "SHHeroExtreme", "SHHeroGhostValley", "SHHeroMoYingMan", "SHHeroMoYingWoman", "SHHeroXuanMing", "SHHeroHiddenFaery"];
			var heroWeapons : Array = ["sw_3_0", "sw_6_1", "sw_4_0", "sw_10_1", "sw_10_0", "sw_xuan", "sw_hidden"];
			var heroWings : Array = ["SHHeroWing_G", "", "SHHeroWing_G", "SHHeroMoYingWing", "SHHeroMoYingWingWoman", "SHHeroWing_G", "SHHeroWing_G"];
			var heroMounts : Array = ["SHMountTaoTie", "SHMountTaoWu", "SHMountTaoTie", "SHMountTaoWu", "SHMountTaoTie", "SHMountTaoWu", "SHMountTaoTie"];
			var data : DataComponent;
			var len : int = heroTypes.length - 1;
			var index : int;
			var sceneW : int = SCameraObject.getInstance().sceneW;
			var sceneH : int = SCameraObject.getInstance().sceneH;
			var gridX : int;
			var gridY : int;
			var seekRoad : SRoadSeeker = SRoadSeeker.getInstance();
			data = new DataComponent();
			data.transform.x = UtilsCommon.getPixelXByGrid(28);
			data.transform.y = UtilsCommon.getPixelYByGrid(22);
			data.avatarId = "SHHeroXuanMing";
			data.weaponId = "sw_6_1";
			data.wingId = "SHHeroWing_G";
			data.mountId = "SHMountTaoTie";
			data.name = "无法无天";
			data.isMe = true;
			data.action = SActionType.IDLE;
			data.transform.dir = EnumDirection.SOUTH;
			data.id = 999999;
			m_objectDatas.push(data);

			for (var i : int = 0; i < 500; )
			{
				gridX = UtilsCommon.getGridXByPixel(sceneW * Math.random());
				gridY = UtilsCommon.getGridYByPixel(sceneH * Math.random());
				if (seekRoad.isBlock(gridX, gridY))
				{
					continue;
				}
				data = new DataComponent();
				index = len * Math.random();
				data.name = heroTypes[index];
				data.avatarId = data.name;
				data.weaponId = heroWeapons[index];
				data.wingId = heroWings[index];
				data.mountId = heroMounts[index];
				data.mountId = "SHMountTaoTie";
				data.speed = 0.2;
				data.level = 100 * Math.random();
				data.hp_max = 200 * data.level;
				data.hp_cur = data.hp_max * Math.random();
				data.action = SActionType.IDLE;
				data.transform.dir = 1 + int(6 * Math.random());
				data.transform.x = UtilsCommon.getPixelXByGrid(gridX);
				data.transform.y = UtilsCommon.getPixelYByGrid(gridY);
				data.id = i++;
				m_objectDatas.push(data);
			}
		}


		override public function update() : void
		{
			checkDeleteList();
			createAndDisposeObject();
		}

		private function checkDeleteList() : void
		{
			if (m_deleteCount == 0)
				return;
			for each (currUpdateGame in m_deleteObjects)
			{
				m_objectNumChildren--;
				delete m_visaulObjects[currUpdateGame.id];
				currUpdateGame.destroy();
			}
			m_deleteCount = 0;
			m_deleteObjects.length = 0;
		}

		/**
		 * 如果还有需要创建的对象，或者对象数据列表改变了，或者移动了屏幕
		 * 则就需要更新数据，检测对象是否在屏幕范围内
		 * 然后添加删除对象操作
		 *
		 */
		private function createAndDisposeObject() : void
		{
			if (!m_hasCreatedObject && !m_isDataChange && SCameraObject.sceneX == m_lastSceneX && SCameraObject.sceneY == m_lastSceneY)
				return;
			m_lastSceneX = SCameraObject.sceneX;
			m_lastSceneY = SCameraObject.sceneY;
			m_objectNumChildren = 0;
			for each (currUpdateGame in m_visaulObjects)
			{
				if (SCameraObject.isInScreen(currUpdateGame.transform))
				{
					m_objectNumChildren++;
					continue;
				}
				delete m_visaulObjects[currUpdateGame.id];
				currUpdateGame.destroy();
			}

			for each (var data : DataComponent in m_objectDatas)
			{
				if (data.isMe)
				{
					if (m_visaulObjects[data.id] == null)
						m_visaulObjects[data.id] = ManagerGameCreate.getInstance().createMyselfHeroObject(data);
					continue;
				}
				if (!SCameraObject.isInScreen(data.transform))
					continue
				if (m_visaulObjects[data.id])
					continue;
				m_visaulObjects[data.id] = ManagerGameCreate.getInstance().createHeroObject(data);
				m_hasCreatedObject = true;
				return;
			}
			m_hasCreatedObject = false;
		}

		/**
		 * 销毁场景中得对象
		 * @param gameObject
		 * @return
		 *
		 */
		public function deleteGameObject(gameObject : GameObject) : void
		{
			if (m_visaulObjects[gameObject.id] == null)
				return;
			if (m_deleteObjects.indexOf(gameObject) == -1)
				m_deleteObjects.push(gameObject);
			m_deleteCount++;
		}

		public function get objectDatas() : Vector.<DataComponent>
		{
			return m_objectDatas;
		}

		public function get isDataChange() : Boolean
		{
			return m_isDataChange;
		}
	}
}