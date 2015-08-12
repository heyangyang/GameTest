package hy.rpg.parser
{
	import hy.game.cfg.Config;
	import hy.game.manager.SReferenceManager;
	import hy.game.render.SDirectBitmapData;
	import hy.game.render.SRender;
	import hy.game.render.SRenderBitmapData;
	import hy.rpg.enum.EnumLoadPriority;

	/**
	 *
	 * <p>
	 * SunnyGame的地图资源解析器
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
	public class ParserMapResource extends ParserPakResource
	{
		private var _render : SRender;

		public function ParserMapResource(id : String, version : String = null, priority : int = EnumLoadPriority.MAP)
		{
			super(id, version, priority);
		}

		override protected function loadThreadResource() : void
		{
			decoder = SReferenceManager.getInstance().createDirectAnimationDeocder(id);
			if (_decoder.isCompleted)
				parseComplete(_decoder);
			else
				_decoder.addNotify(parseComplete);
			if (!_decoder.isSend)
			{
				_decoder.isSend = true;
				var send_arr : Array = [id, version, priority];
					//SThreadEvent.dispatchEvent(SThreadEvent.LOAD_SEND, send_arr);
			}
		}

		private function get bitmapData() : SRenderBitmapData
		{
			if (_decoder)
				return _decoder.getResult();
			return null;
		}

		public function get render() : SRender
		{
			if (bitmapData == null)
				return null;
			if (_render)
				return _render;
			_render = new SRender();
			if (Config.supportDirectX)
				_render.bitmapData = SDirectBitmapData.fromDirectBitmapData(bitmapData);
			else
				_render.bitmapData = bitmapData;
			return _render;
		}

		override protected function destroy() : void
		{
			super.destroy();
			_render.dispose();
		}
	}
}