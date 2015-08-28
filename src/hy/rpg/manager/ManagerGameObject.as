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
		private static var mObjectNumChildren : int;

		/**
		 * 可视范围内的对象数量
		 * @return
		 *
		 */
		public static function get objectNumChildren() : int
		{
			return mObjectNumChildren;
		}

		private static var instance : ManagerGameObject;
		
		public static function getInstance() : ManagerGameObject
		{
			if (instance == null)
				instance = new ManagerGameObject();
			return instance;
		}

		/**
		 * 上一次场景的坐标X,Y
		 */
		private var mLastSceneX : int = -99;
		private var mLastSceneY : int = -99;
		/**
		 * 可视范围内的对象
		 */
		private var mVisaulObjects : Dictionary;
		/**
		 * 地图内的所有对象数据
		 */
		private var mObjectDatas : Vector.<DataComponent>;
		private var mDeleteObjects : Vector.<GameObject>;
		private var mDeleteCount : int;
		/**
		 * 是否有增加删除数据
		 */
		private var mIsDataChange : Boolean;
		private var currUpdateGame : GameObject;
		/**
		 * 是否还有没有创建完成的对象
		 */
		private var mHasCreatedObject : Boolean;

		public function ManagerGameObject()
		{
			if (instance)
				error("instance != null");
			mVisaulObjects = new Dictionary();
			mObjectDatas = new Vector.<DataComponent>();
			mDeleteObjects = new Vector.<GameObject>();
			frameRate = 10;
			mHasCreatedObject = false;
			init();
		}

		private function init() : void
		{
			//虚拟数据
			var heroTypes : Array = ["SHHeroAsura", "SHHeroExtreme", "SHHeroGhostValley", "SHHeroMoYingMan", "SHHeroMoYingWoman", "SHHeroXuanMing", "SHHeroHiddenFaery"];
			var heroWeapons : Array = ["sw_3_0", "sw_6_1", "sw_4_0", "sw_10_1", "sw_10_0", "sw_xuan", "sw_hidden"];
			var heroWings : Array = ["SHHeroWing_G", "", "SHHeroWing_G", "SHHeroMoYingWing", "SHHeroMoYingWingWoman", "SHHeroWing_G", "SHHeroWing_G"];
			var heroMounts : Array = ["SHMountTaoTie", "SHMountTaoTie", "SHMountTaoTie", "SHMountTaoTie", "SHMountTaoTie", "SHMountTaoTie", "SHMountTaoTie"];
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
			mObjectDatas.push(data);

			for (var i : int = 0; i < 00; )
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
				data.speed = 0.2;
				data.level = 100 * Math.random();
				data.hp_max = 200 * data.level;
				data.hp_cur = data.hp_max * Math.random();
				data.action = SActionType.IDLE;
				data.transform.dir = 1 + int(6 * Math.random());
				data.transform.x = UtilsCommon.getPixelXByGrid(gridX);
				data.transform.y = UtilsCommon.getPixelYByGrid(gridY);
				data.id = i++;
				mObjectDatas.push(data);
			}
		}


		override public function update() : void
		{
			checkDeleteList();
			createAndDisposeObject();
		}

		private function checkDeleteList() : void
		{
			if (mDeleteCount == 0)
				return;
			for each (currUpdateGame in mDeleteObjects)
			{
				mObjectNumChildren--;
				delete mVisaulObjects[currUpdateGame.id];
				currUpdateGame.dispose();
			}
			mDeleteCount = 0;
			mDeleteObjects.length = 0;
		}

		/**
		 * 如果还有需要创建的对象，或者对象数据列表改变了，或者移动了屏幕
		 * 则就需要更新数据，检测对象是否在屏幕范围内
		 * 然后添加删除对象操作
		 *
		 */
		private function createAndDisposeObject() : void
		{
			if (!mHasCreatedObject && !mIsDataChange && SCameraObject.sceneX == mLastSceneX && SCameraObject.sceneY == mLastSceneY)
				return;
			mLastSceneX = SCameraObject.sceneX;
			mLastSceneY = SCameraObject.sceneY;
			mObjectNumChildren = 0;
			for each (currUpdateGame in mVisaulObjects)
			{
				if (SCameraObject.isInScreen(currUpdateGame.transform))
				{
					mObjectNumChildren++;
					continue;
				}
				delete mVisaulObjects[currUpdateGame.id];
				currUpdateGame.dispose();
			}

			for each (var data : DataComponent in mObjectDatas)
			{
				if (data.isMe)
				{
					if (mVisaulObjects[data.id] == null)
						mVisaulObjects[data.id] = ManagerGameCreate.getInstance().createMyselfHeroObject(data);
					continue;
				}
				if (!SCameraObject.isInScreen(data.transform))
					continue
				if (mVisaulObjects[data.id])
					continue;
				mVisaulObjects[data.id] = ManagerGameCreate.getInstance().createHeroObject(data);
				mHasCreatedObject = true;
				return;
			}
			mHasCreatedObject = false;
		}

		/**
		 * 销毁场景中得对象
		 * @param gameObject
		 * @return
		 *
		 */
		public function deleteGameObject(gameObject : GameObject) : void
		{
			if (mVisaulObjects[gameObject.id] == null)
				return;
			if (mDeleteObjects.indexOf(gameObject) == -1)
				mDeleteObjects.push(gameObject);
			mDeleteCount++;
		}

		public function get objectDatas() : Vector.<DataComponent>
		{
			return mObjectDatas;
		}

		public function get isDataChange() : Boolean
		{
			return mIsDataChange;
		}
	}
}