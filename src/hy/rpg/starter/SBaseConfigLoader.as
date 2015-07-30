package hy.rpg.starter
{
	import flash.display.BitmapData;
	import flash.system.System;
	import flash.utils.ByteArray;

	import hy.game.cfg.Config;
	import hy.game.manager.SReferenceManager;
	import hy.game.manager.SVersionManager;
	import hy.game.resources.SPreLoad;
	import hy.game.resources.SResource;
	import hy.game.resources.SResourceMagnger;
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
		override public function onStart() : void
		{
			SReferenceManager.getInstance().createResource("version.dat", Config.VERSION).addNotifyCompleted(onVersionLoadCompleted).load();
		}

		private function onVersionLoadCompleted(res : SResource) : void
		{
			var bytes : ByteArray = res.data;
			bytes.uncompress();
			SVersionManager.getInstance().parseVersionData(bytes.readUTF());
			SReferenceManager.getInstance().createResource("config").addNotifyCompleted(onXmlLoadCompleted).load();
		}

		private function onXmlLoadCompleted(res : SResource) : void
		{
			var xml : XML = new XML(res.data);
			SPreLoad.getInstance().onConfigComplete(xml);
			SPreLoad.getInstance().preLoad("preload", onPreloadCompleted);
			System.disposeXML(xml);
		}

		private function onPreloadCompleted(preload : SPreLoad) : void
		{
			nextNode();
		}

		/**
		 * 启动器退出
		 *
		 */
		override public function onExit() : void
		{

		}

		override public function get id() : String
		{
			return SGameNodeType.BASE_CONFIG;
		}
	}
}