package hy.rpg.starter
{
	import hy.game.manager.SKeyboardManager;
	import hy.game.monitor.SMonitor;
	import hy.game.starter.SStartNode;
	import hy.game.utils.SKeycode;

	/**
	 * 快捷键
	 * 启动器
	 * @author hyy
	 *
	 */
	public class StarterShortcutKey extends SStartNode
	{

		public function StarterShortcutKey()
		{
			super();
		}

		/**
		 * 启动器初始化
		 *
		 */
		override public function onStart() : void
		{
			var keyboardMgr : SKeyboardManager = SKeyboardManager.getInstance();
			keyboardMgr.addKeyDownHandler(startMonitorHandler, SKeycode.Keyb0, SKeycode.Control);
			nextNode();
		}

		private function startMonitorHandler() : void
		{
			if (SMonitor.getInstance().isRegisterd)
				SMonitor.getInstance().unRegisterd();
			else
				SMonitor.getInstance().registerd();
		}


		override public function get id() : String
		{
			return GameNodeEnmu.shortkey;
		}
	}
}