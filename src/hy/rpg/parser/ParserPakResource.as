package hy.rpg.parser
{
	import flash.utils.ByteArray;
	
	import hy.game.manager.SReferenceManager;
	import hy.rpg.enum.EnumLoadPriority;
	import hy.rpg.pak.DecoderAnimation;
	import hy.rpg.pak.DecoderDirectAnimation;

	/**
	 *  pak资源解析器
	 *
	 */
	public class ParserPakResource extends ParserResource
	{
		private var mDecoder : DecoderDirectAnimation;

		public function ParserPakResource(id : String, version : String = null, priority : int = EnumLoadPriority.MIN)
		{
			super(id, version, priority);
		}

		/**
		 * 加载完成后解析数据
		 * @param bytes
		 *
		 */
		override protected function parseLoaderData(bytes : ByteArray) : void
		{
			decoder = SReferenceManager.getInstance().createDirectAnimationDeocder(id);
			mDecoder.addNotify(onParseCompleted);
			mDecoder.decode(bytes);
		}

		protected function set decoder(value : DecoderDirectAnimation) : void
		{
			mDecoder && mDecoder.release();
			mDecoder = value;
		}

		protected function get decoder() : DecoderDirectAnimation
		{
			return mDecoder;
		}

		/**
		 * 解析完成后
		 *
		 */
		protected function onParseCompleted(decoder : DecoderAnimation) : void
		{
			parseLoaderCompleted();
		}

		public function get width() : int
		{
			return mDecoder ? mDecoder.width : 0;
		}

		public function get height() : int
		{
			return mDecoder ? mDecoder.height : 0;
		}

		override protected function dispose() : void
		{
			decoder = null;
			super.dispose();
		}
	}
}