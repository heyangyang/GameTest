package hy.rpg.pak
{
	import flash.geom.Point;
	import flash.system.System;
	import flash.utils.ByteArray;

	import hy.game.interfaces.display.IBitmapData;
	import hy.game.manager.SReferenceManager;
	import hy.game.resources.SResource;
	import hy.game.stage3D.texture.STexture;
	import hy.game.stage3D.texture.STextureAtlas;

	/**
	 * 用于3d动画解析
	 * @author Administrator
	 *
	 */
	public class DecoderDirectAnimation extends DecoderAnimation
	{
		private var mTextureAtlas : STextureAtlas;

		public function DecoderDirectAnimation(id : String)
		{
			super(id);
		}

		/**
		 * 加载atf和xml结合
		 *
		 */
		public function startXtfLoad(ver : String, priority : int) : void
		{
			var resource : SResource = SReferenceManager.getInstance().createResource(id, ver);

			if (resource.isLoaded)
			{
				onXtfLoaded(resource);
				return;
			}

			resource.addNotifyCompleted(onXtfLoaded).addNotifyIOError(onResourceIOError).setPriority(priority).load();
		}

		protected function onXtfLoaded(resource : SResource) : void
		{
			var bytes : ByteArray = resource.getBinary();
			var name : String = bytes.readUTF();
			var len : int = bytes.readUnsignedInt();
			var atf_bytes : ByteArray = new ByteArray();
			bytes.readBytes(atf_bytes, 0, len);
			name = bytes.readUTF();
			len = bytes.readUnsignedInt();
			var xml_bytes : ByteArray = new ByteArray();
			bytes.readBytes(xml_bytes, 0, len);
			var xml : XML = new XML(xml_bytes);
			var texture : STexture = STexture.fromData(atf_bytes);
			mTextureAtlas = new STextureAtlas(texture, xml);
			atf_bytes.clear();
			xml_bytes.clear();
			bytes.clear();
			System.disposeXML(xml);
			SReferenceManager.getInstance().clearResource(resource.url);
			notifyAll();
		}

		public function getDirResult(index : uint = 0, dir : String = DEFAULT) : IBitmapData
		{
			if (mTextureAtlas)
				return mTextureAtlas.getAnimationFrame(dir, index);
			else
				return getResult(index, dir);
		}

		public function getDirOffest(index : uint = 0, dir : String = DEFAULT) : Point
		{
			if (mTextureAtlas)
				return mTextureAtlas.getPoint(dir, index);
			else
				return getOffest(index, dir);
		}

		override protected function dispose() : void
		{
			super.dispose();
			if (mTextureAtlas)
			{
				mTextureAtlas.dispose();
				mTextureAtlas = null;
			}
		}
	}
}