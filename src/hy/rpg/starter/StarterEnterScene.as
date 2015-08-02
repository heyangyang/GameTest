package hy.rpg.starter
{
	import hy.game.monitor.SMonitor;
	import hy.game.starter.SStartNode;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.manager.ManagerGame;
	import hy.rpg.manager.ManagerGameData;
	import hy.rpg.manager.ManagerGameObject;
	import hy.rpg.utils.UtilsCommon;

	/**
	 * 转换场景
	 * 启动器
	 * @author hyy
	 *
	 */
	public class StarterEnterScene extends SStartNode
	{
		public function StarterEnterScene()
		{
			super();
		}

		/**
		 * 启动器初始化
		 *
		 */
		override public function onStart() : void
		{
			var data : DataComponent = new DataComponent();
			data.transform.x = UtilsCommon.getPixelXByGrid(45);
			data.transform.y = UtilsCommon.getPixelYByGrid(20);
			data.avatarId = "SHHeroXuanMing";
			data.weaponId = "sw_6_1";
			data.wingId = "SHHeroWing_G";
			data.name = "无法无天";
			ManagerGame.getInstance().createMyselfHeroObject(data);
			ManagerGameData.getInstance();
			ManagerGameObject.getInstance().registerd();
			SMonitor.getInstance().registerd();
		}

		override public function get id() : String
		{
			return GameNodeEnmu.emter_scene;
		}
	}
}