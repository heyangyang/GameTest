package hy.rpg.parser
{
	import hy.game.core.interfaces.IBitmapData;
	import hy.rpg.enum.EnumLoadPriority;


	/**
	 *
	 * 图标资源解析器
	 *
	 */
	public class ParserImageResource extends ParserPakResource
	{
		public function ParserImageResource(id : String, version : String = null, priority : int = EnumLoadPriority.ICON)
		{
			super(id, version, priority);
		}

		public function get bitmapData() : IBitmapData
		{
			return decoder ? decoder.getResult() : null;
		}
	}
}