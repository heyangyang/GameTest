package hy.rpg.starter
{
	import hy.game.starter.SStartNode;
	import hy.rpg.manager.SGameManager;
	import hy.rpg.map.SMapObject;

	public class SMapLoader extends SStartNode
	{
		public function SMapLoader()
		{
			super();
		}

		/**
		 * 启动器初始化
		 *
		 */
		override public function onStart() : void
		{
			SGameManager.getInstance().createCameraObject();
			var mapObject : SMapObject = SGameManager.getInstance().createMapObject();
			mapObject.load("wuxingwuzu", nextNode);
		}

		override public function get id() : String
		{
			return SGameNodeType.MAP_LOAD;
		}
	}
}