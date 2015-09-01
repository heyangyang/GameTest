package hy.rpg.parser
{
	import flash.geom.Point;
	import flash.utils.ByteArray;

	import hy.game.animation.SAnimationDescription;
	import hy.game.cfg.Config;
	import hy.game.interfaces.display.IBitmapData;
	import hy.game.manager.SReferenceManager;


	/**
	 *  动画资源解析器
	 *
	 */
	public class ParserAnimationResource extends ParserPakResource
	{
		public function ParserAnimationResource(desc : SAnimationDescription, priority : int)
		{
			super(desc.url, desc.version, priority);
		}

		override public function load() : void
		{
			if (Config.supportDirectX)
			{
				parseLoaderData(null);
			}
			else
			{
				super.load();
			}
		}

		override protected function parseLoaderData(bytes : ByteArray) : void
		{
			if (!Config.supportDirectX)
			{
				super.parseLoaderData(bytes);
				return;
			}
			decoder = SReferenceManager.getInstance().createDirectAnimationDeocder(id);
			decoder.addNotify(onParseCompleted);
			decoder.startXtfLoad(version, priority);
		}

		public function getBitmapDataByDir(frame : int, dir : String) : IBitmapData
		{
			return decoder ? decoder.getDirResult(frame - 1, dir) : null;
		}

		public function getOffset(index : int, dir : String) : Point
		{
			return decoder ? decoder.getDirOffest(index, dir) : null;
		}
	}
}