package hy.rpg.pak
{
	import flash.geom.Point;
	
	import hy.game.manager.SReferenceManager;
	import hy.game.render.SRenderBitmapData;
	import hy.game.resources.SResource;

	/**
	 * 用于3d动画解析
	 * @author Administrator
	 *
	 */
	public class SDirectAnimationDecoder extends SAnimationDecoder
	{
		private var textureAtlas : *;

		public function SDirectAnimationDecoder(id : String)
		{
			super(id);
		}

		/**
		 * 加载atf和xml结合
		 *
		 */
		public function startXtfLoad(ver : String, priority : int) : void
		{
			var resource : SResource = SReferenceManager.getInstance().createResource(id,ver);

			if (resource.isLoaded)
			{
				onXtfLoaded(resource);
				return;
			}

			resource.addNotifyCompleted(onXtfLoaded).addNotifyIOError(onResourceIOError).priority(priority).load();
		}

		protected function onXtfLoaded(resource : SResource) : void
		{
//			var bytes : ByteArray = resource.getBinary();
//			var name : String = bytes.readUTF();
//			var len : int = bytes.readUnsignedInt();
//			var atf_bytes : ByteArray = new ByteArray();
//			bytes.readBytes(atf_bytes, 0, len);
//			name = bytes.readUTF();
//			len = bytes.readUnsignedInt();
//			var xml_bytes : ByteArray = new ByteArray();
//			bytes.readBytes(xml_bytes, 0, len);
//			var xml : XML = new XML(xml_bytes);
//			var texture : Texture = Texture.fromData(atf_bytes);
//			textureAtlas = new STextureAtlas(texture, xml);
//			atf_bytes.clear();
//			xml_bytes.clear();
//			bytes.clear();
//			System.disposeXML(xml);
//			SReferenceManager.getInstance().clearResource(resource.url);
//			notifyAll();
		}

		public function getDirResult(action : String, index : uint = 0, dir : String = DEFAULT) : SRenderBitmapData
		{
			if (textureAtlas)
				return textureAtlas.getAnimationFrame(action, dir, index);
			else
				return getResult(index, dir);
		}

		public function getDirOffest(action : String, index : uint = 0, dir : String = DEFAULT) : Point
		{
			if (textureAtlas)
				return textureAtlas.getPoint(action, dir, index);
			else
				return getOffest(index, dir);
		}

		override protected function destroy() : void
		{
			super.destroy();
			if (textureAtlas)
			{
				textureAtlas.dispose();
				textureAtlas = null;
			}
		}
	}
}