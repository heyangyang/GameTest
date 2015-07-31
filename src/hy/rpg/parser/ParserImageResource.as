package hy.rpg.parser
{
	import hy.game.core.interfaces.IBitmapData;
	

	/**
	 *
	 * <p>
	 * SunnyGame的图标资源解析器
	 * </p>
	 * <p><strong><font color="#0000ff">Copyright © 2012 Sunny3D. All rights reserved.</font></strong><br>
	 * <font color="#0000ff">www.sunny3d.com</font></p>
	 * @langversion 3.0
	 * @playerversion Flash 11.2
	 * @playerversion AIR 3.2
	 * @productversion Flex 4.5
	 * @author <strong><font color="#0000ff">刘黎明</font></strong><br>
	 * <font color="#0000ff">www.liuliming.org</font>
	 *
	 */
	public class ParserImageResource extends ParserPakResource
	{
		public function ParserImageResource(id : String, version : String = null, priority : int = int.MAX_VALUE)
		{
			super(id, version, priority);
		}

		public function get bitmapData() : IBitmapData
		{
			if (_decoder)
				return _decoder.getResult();
			return null;
		}
	}
}