package hy.rpg.manager
{
	import hy.game.core.SCameraObject;
	import hy.game.manager.SBaseManager;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.seek.SRoadSeeker;
	import hy.rpg.utils.UtilsCommon;

	/**
	 * 游戏中所有对象数据的管理
	 * @author wait
	 *
	 */
	public class ManagerGameData extends SBaseManager
	{
		private static var instance : ManagerGameData;

		public static function getInstance() : ManagerGameData
		{
			if (instance == null)
			{
				instance = new ManagerGameData();
				instance.init();
			}
			return instance;
		}

		private var m_heros : Vector.<DataComponent>;
		private var m_isChange : Boolean;

		public function ManagerGameData()
		{
			super();
		}

		private function init() : void
		{
			m_heros = new Vector.<DataComponent>();
			var heroTypes : Array = ["SHHeroAsura", "SHHeroExtreme", "SHHeroGhostValley", "SHHeroMoYingMan", "SHHeroMoYingWoman", "SHHeroXuanMing", "SHHeroHiddenFaery"];
			var heroWeapons : Array = ["sw_3_0", "sw_6_1", "sw_4_0", "sw_10_1", "sw_10_0", "sw_xuan", "sw_hidden"];
			var heroWings : Array = ["SHHeroWing_D", "", "SHHeroWing_E", "SHHeroMoYingWing", "SHHeroMoYingWingWoman", "SHHeroWing_F", "SHHeroWing_G"];
			var data : DataComponent;
			var len : int = heroTypes.length - 1;
			var index : int;
			var sceneW : int = SCameraObject.getInstance().sceneW;
			var sceneH : int = SCameraObject.getInstance().sceneH;
			var gridX : int;
			var gridY : int;
			var seekRoad : SRoadSeeker = SRoadSeeker.getInstance();
			for (var i : int = 0; i < 400; )
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
				data.speed = 0.2;
				data.level = 100 * Math.random();
				data.hp_max = 200 * data.level;
				data.hp_cur = data.hp_max * Math.random();
				data.transform.dir = 7 * Math.random();
				data.transform.x = UtilsCommon.getPixelXByGrid(gridX);
				data.transform.y = UtilsCommon.getPixelYByGrid(gridY);
				data.id = i++;
				m_heros.push(data);
			}

		}

		public function get heros() : Vector.<DataComponent>
		{
			return m_heros;
		}

		public function get isChange() : Boolean
		{
			return m_isChange;
		}


	}
}