package hy.rpg.starter
{
	import hy.game.cfg.Config;
	import hy.game.starter.SStartNode;
	import hy.rpg.manager.ManagerGameCreate;
	import hy.rpg.map.MapObject;

	/**
	 * 地图
	 * 启动器
	 * @author hyy
	 *
	 */
	public class StarterMapLoader extends SStartNode
	{
		public function StarterMapLoader()
		{
			super();
		}

		/**
		 * 启动器初始化
		 *
		 */
		override public function onStart() : void
		{
			ManagerGameCreate.getInstance().createCameraObject();
			var mapObject : MapObject = ManagerGameCreate.getInstance().createMapObject();
			mapObject.load("wuxingwuzu" + (Config.supportDirectX ? "_atf" : ""), nextNode);
		}

		override public function get id() : String
		{
			return GameNodeEnmu.map_load;
		}
	}
}