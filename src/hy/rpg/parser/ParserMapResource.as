package hy.rpg.parser
{
	import flash.display.BitmapData;
	
	import hy.game.cfg.Config;
	import hy.game.core.interfaces.IBitmap;
	import hy.game.manager.SReferenceManager;
	import hy.game.render.SRenderBitmap;
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
		private var _bitmap : SRenderBitmap;

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

		public function get bitmapData() : BitmapData
		{
			if (_decoder)
				return _decoder.getResult();
			return null;
		}

		public function get bitmap() : IBitmap
		{
			if (_bitmap)
				return _bitmap;
			if (Config.supportDirectX)
			{
				//_bitmap = new SDirectBitmap(SDirectBitmapData.fromDirectBitmapData(bitmapData));
				//SDirectBitmap(_bitmap).smoothing = TextureSmoothing.NONE;
			}
			else
				_bitmap = new SRenderBitmap(bitmapData);
			return _bitmap;
		}

		public function clearBitmap() : void
		{
			_bitmap && _bitmap.removeChild();
		}

		override protected function destroy() : void
		{
			super.destroy();
			clearBitmap();
			_bitmap = null;
		}
	}
}