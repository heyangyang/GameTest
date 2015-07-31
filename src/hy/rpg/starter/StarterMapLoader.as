package hy.rpg.starter
{
	import hy.game.starter.SStartNode;
	import hy.rpg.manager.ManagerGame;
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
			ManagerGame.getInstance().createCameraObject();
			var mapObject : MapObject = ManagerGame.getInstance().createMapObject();
			mapObject.load("wuxingwuzu", nextNode);
		}

		override public function get id() : String
		{
			return GameNodeEnmu.map_load;
		}
	}
}