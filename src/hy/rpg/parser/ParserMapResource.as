package hy.rpg.parser
{
	import flash.utils.ByteArray;

	import hy.game.cfg.Config;
	import hy.game.interfaces.display.IBitmapData;
	import hy.game.render.SDirectBitmapData;
	import hy.game.render.SRender;
	import hy.game.stage3D.texture.STexture;
	import hy.rpg.enum.EnumLoadPriority;

	/**
	 *
	 * 地图资源解析器
	 *
	 */
	public class ParserMapResource extends ParserPakResource
	{
		private var mRender : SRender;
		private var mTexture : SDirectBitmapData;

		public function ParserMapResource(id : String, version : String = null, priority : int = EnumLoadPriority.MAP)
		{
			super(id, version, priority);
		}

		override protected function parseLoaderData(bytes : ByteArray) : void
		{
			if (!Config.supportDirectX)
			{
				super.parseLoaderData(bytes);
				return;
			}
			if (mTexture)
				return;
			mTexture = STexture.fromAtfData(bytes, 1, false) as SDirectBitmapData;
			onParseCompleted(null);
		}

		private function get bitmapData() : IBitmapData
		{
			if (mTexture)
				return mTexture;
			return decoder ? decoder.getResult() : null;
		}

		public function get render() : SRender
		{
			if (bitmapData == null)
				return null;
			if (mRender)
				return mRender;
			mRender = new SRender();
			mRender.bitmapData = bitmapData;
			return mRender;
		}

		override protected function dispose() : void
		{
			super.dispose();
			if (mTexture)
			{
				mTexture.dispose();
				mTexture = null;
			}
			if (mRender)
			{
				mRender.dispose();
				mRender = null;
			}
		}
	}
}