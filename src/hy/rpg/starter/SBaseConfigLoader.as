package hy.rpg.starter
{
	import hy.game.starter.SStartNode;
	
	/**
	 * 加载基础配置 
	 * @author wait
	 * 
	 */
	public class SBaseConfigLoader extends SStartNode
	{
		public function SBaseConfigLoader()
		{
			super();
		}
		
		/**
		 * 启动器初始化 
		 * 
		 */
		override public function onStart():void
		{
			
		}
		
		
		/**
		 * 启动器退出 
		 * 
		 */
		override public function onExit():void
		{
			
		}
		
		override public function get id():String
		{
			return SGameNodeType.BASE_CONFIG;
		}
	}
}