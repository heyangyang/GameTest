package hy.rpg.pak
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import hy.game.render.SRenderBitmapData;

	/**
	 * 资源包解码器
	 *
	 */
	public class DecoderPak
	{
		private static var pakDecoders : Dictionary = new Dictionary();
		private static var context : LoaderContext = new LoaderContext();

		public static function getPakDecoder(id : String) : DecoderPak
		{
			return pakDecoders[id];
		}

		public var id : String;
		/**
		 * 源数据
		 */
		private var bytes : ByteArray;
		/**
		 *  解析后的图片
		 */
		private var result_list : Array;
		/**
		 * 当前解析到第几张
		 */
		private var result_index : uint;
		public var offests : Array;
		public var rects : Array;
		public var length : int;

		public var type : int;
		public var quality : int;
		public var alphaQuality : int;
		public var alphaFilter : int;
		public var width : int;
		public var height : int;

		/**
		 * 图片数据
		 */
		public var loadDataList : Array;

		private var image_list : Array;
		private var _notifyCompleted : Function;
		private var _notifyIOError : Function;
		private var loader_list : Array;

		private var load_index : int;
		/**
		 * 是否加载完成
		 */
		private var isCompleted : Boolean;
		private var _isDisposed : Boolean;

		/**
		 * 后端线程传过来的图片数据
		 */
		public var img_bytes : Array;
		private var img_index : int;

		public function DecoderPak(id : String, data : ByteArray)
		{
			this.id = id;
			pakDecoders[id] = this;
			bytes = new ByteArray();
			if (data)
			{
				data.position = 0;
				data.readBytes(bytes, 0, data.length);
			}
		}

		public function decode() : void
		{
			rects = [];
			offests = [];
			image_list = [];
			loadDataList = [];

			type = bytes.readByte();
			width = bytes.readUnsignedShort();
			height = bytes.readUnsignedShort();
			quality = bytes.readByte();
			alphaQuality = bytes.readByte();
			alphaFilter = bytes.readByte();
			length = bytes.readUnsignedShort();

			for (var i : int = 0; i < length; i++)
			{
				offests.push(new Point(bytes.readShort(), bytes.readShort()));
				rects.push(new Point(bytes.readShort(), bytes.readShort()));
				type == 2 && pushData(bytes);
			}
			type == 1 && pushData(bytes);
			bytes.clear();
		}

		/**
		 * 记录图片字节流
		 * @param image_data
		 *
		 */
		private function pushData(image_data : ByteArray) : void
		{
			var len : int = image_data.readUnsignedInt();
			var data : ByteArray = new ByteArray();
			image_data.readBytes(data, 0, len);
			loadDataList.push(data);

			if (alphaQuality != 0 && quality != alphaQuality)
			{
				var alphaData : ByteArray = new ByteArray();
				len = image_data.readUnsignedInt();
				if (len)
				{
					image_data.readBytes(alphaData, 0, len);
					loadDataList.push(alphaData);
				}
			}
		}

		public function loadImages() : void
		{
			isCompleted = false;
			load_index = 0;
			loader_list = [];
			var loader : Loader;

			for each (var data : ByteArray in loadDataList)
			{
				loader = new Loader();
				loader_list.push(loader);
				context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				loader.loadBytes(data, context);
			}
		}

		private function loadCompleteHandler(e : Event) : void
		{
			var loader : Loader = (e.currentTarget as LoaderInfo).loader as Loader;
			var index : int = loader_list.indexOf(loader);
			addBitmapData(index, (loader.content as Bitmap).bitmapData);
		}

		private function addBitmapData(index : int, bmd : BitmapData) : void
		{
			if (_isDisposed)
				return;
			image_list[index] = bmd;
			load_index++;

			if (load_index >= loadDataList.length)
				loadAllComplete();
		}

		private function securityErrorHandler(e : SecurityErrorEvent) : void
		{
			notifyIOError();
		}

		private function ioErrorHandler(e : IOErrorEvent) : void
		{
			notifyIOError();
		}

		public function notifyIOError() : void
		{
			if (_isDisposed)
				return;
			clearLoaders();
			if (_notifyIOError != null)
				_notifyIOError(this);
		}

		/**
		 * 加载完成
		 *
		 */
		private function loadAllComplete() : void
		{
			result_list = [];
			result_index = 0;
			clearLoaders();
			notifyAllComplete();
		}

		public function notifyAllComplete() : void
		{
			if (_isDisposed)
				return;
			isCompleted = true;
			clearLoaders();
			if (_notifyCompleted != null)
				_notifyCompleted(this);
		}

		protected function byteArrayToBitmapData(bytes : ByteArray) : SRenderBitmapData
		{
			if (bytes && bytes.bytesAvailable)
			{
				bytes.position = 0;
				var width : int = bytes.readInt();
				var height : int = bytes.readInt();
				var bmd : SRenderBitmapData = new SRenderBitmapData(width, height, true, 0);
				bmd.setPixels(bmd.rect, bytes);
				bytes.clear();
				return bmd;
			}
			return null;
		}

		private static var bmdRect : Rectangle = new Rectangle();
		private static var zeroPoint : Point = new Point();

		public function getResult(index : uint = 0) : SRenderBitmapData
		{
			if (_isDisposed)
				return null;
			if (!isCompleted)
				return null;
			if (img_bytes && img_bytes[index])
			{
				setResult(index, byteArrayToBitmapData(img_bytes[index]));
				img_bytes[index] = null;
				if (++img_index >= length)
				{
					img_bytes.length = 0;
					img_bytes = null;
				}
			}
			if (!result_list)
				return null;
			if (index < 0 || index >= length)
				return null;
			var newBmd : SRenderBitmapData = result_list[index];
			if (newBmd)
				return newBmd;
			newBmd = getShareResult(index);
			if (newBmd)
				result_list[index] = newBmd;
			else
			{
				var rect : Point;
				var bmd : BitmapData;
				var alphaBmd : BitmapData;
				if (type == 1)
				{
					var dx : int = 0;
					for (var i : int = 0; i < index; i++)
					{
						rect = rects[i];
						dx += rect.x;
					}

					rect = rects[index];
					if (rect.x == 0)
						rect.x = 1;
					if (rect.y == 0)
						rect.y = 1;

					bmd = image_list[0];
					newBmd = new SRenderBitmapData(rect.x, rect.y, true, 0);
					bmdRect.x = dx;
					bmdRect.y = 0;
					bmdRect.width = rect.x;
					bmdRect.height = rect.y;
					newBmd.copyPixels(bmd, bmdRect, zeroPoint);

					if (quality == alphaQuality)
					{
						if (quality < 100)
						{
							bmdRect.x = dx;
							bmdRect.y = bmd.height * 0.5;
							bmdRect.width = rect.x;
							bmdRect.height = rect.y;
							newBmd.copyChannel(bmd, bmdRect, zeroPoint, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
						}
					}
					else
					{
						if (alphaQuality != 0)
							alphaBmd = image_list[1];
						if (alphaBmd)
							newBmd.copyChannel(alphaBmd, bmdRect, zeroPoint, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
					}
					doAlphaFilter(newBmd);

					result_list[index] = newBmd;
				}
				else if (type == 2)
				{
					rect = rects[index];
					if (rect.x == 0 || rect.y == 0)
						newBmd = new SRenderBitmapData(1, 1, true, 0);
					else
						newBmd = new SRenderBitmapData(rect.x, rect.y, true, 0);
					bmdRect.x = 0;
					bmdRect.y = 0;
					bmdRect.width = rect.x;
					bmdRect.height = rect.y;
					if (alphaQuality != 0 && quality != alphaQuality)
					{
						bmd = image_list[index * 2];
						alphaBmd = image_list[index * 2 + 1];
						newBmd.copyPixels(bmd, bmdRect, zeroPoint);
						newBmd.copyChannel(alphaBmd, bmdRect, zeroPoint, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
						bmd.dispose();
						alphaBmd.dispose();
					}
					else
					{
						bmd = image_list[index];
						newBmd.copyPixels(bmd, bmdRect, zeroPoint);
						bmdRect.x = 0;
						bmdRect.y = rect.y;
						bmdRect.width = rect.x;
						bmdRect.height = rect.y;
						newBmd.copyChannel(bmd, bmdRect, zeroPoint, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
						bmd.dispose();
					}

					doAlphaFilter(newBmd);
					result_list[index] = newBmd;
				}
			}
			result_index++;
			//完全解析完毕，清理临时数据
			result_index >= length && clearBmds();
			return newBmd;
		}

		public function onComplete(notifyCompleted : Function) : DecoderPak
		{
			if (_isDisposed)
				return this;
			_notifyCompleted = notifyCompleted;
			return this;
		}

		public function removeCompleteNotify(fun : Function) : DecoderPak
		{
			_notifyCompleted = null;
			return this;
		}

		public function onIOError(notifyIOError : Function) : DecoderPak
		{
			if (_isDisposed)
				return this;
			_notifyIOError = notifyIOError;
			return this;
		}

		public function removeIOErrorNotify(fun : Function) : DecoderPak
		{
			_notifyIOError = null;
			return this;
		}

		private function doAlphaFilter(bmd : BitmapData) : void
		{
			if (alphaFilter)
				bmd.threshold(bmd, bmd.rect, zeroPoint, "<", alphaFilter << 24, 0x00000000, 0xFF000000, true);
		}

		public function setResult(index : uint, bmd : SRenderBitmapData) : void
		{
			if (_isDisposed)
				return;
			if (!result_list)
			{
				result_list = [];
				result_index = 0;
			}
			if (!result_list[index])
			{
				if (!bmd)
					bmd = getShareResult(index);
				result_list[index] = bmd;
				result_index++;
			}
		}

		private function clearResult() : void
		{
			for each (var bmd : BitmapData in result_list)
			{
				bmd && bmd.dispose();
			}
			if (result_list)
				result_list.length = 0;
			result_list = null;
		}

		private function clearLoaders() : void
		{
			for each (var data : ByteArray in loadDataList)
			{
				data.clear();
			}
			if (loadDataList)
				loadDataList.length = 0;
			loadDataList = null;

			for each (var loader : Loader in loader_list)
			{
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadCompleteHandler);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			}
			if (loader_list)
				loader_list.length = 0;
			loader_list = null;
		}

		private function clearBmds() : void
		{
			for each (var bmd : BitmapData in image_list)
				bmd.dispose();
			if (image_list)
				image_list.length = 0;
			image_list = null;
		}

		public function dispose() : void
		{
			if (_isDisposed)
				return;
			_isDisposed = true;
			clearLoaders();
			clearBmds();
			clearResult();
			if (img_bytes)
			{
				for each (var bytes : ByteArray in img_bytes)
					bytes && bytes.clear();
				img_bytes.length = 0;
				img_bytes = null;
			}
			if (offests)
			{
				offests.length = 0;
				offests = null;
			}
			if (rects)
			{
				rects.length = 0;
				rects = null;
			}
			_notifyCompleted = null;
			_notifyIOError = null;
			loadDataList = null;
			pakDecoders[id] = null;
			delete pakDecoders[id];
		}

		public function getSize(index : uint = 0) : Point
		{
			if (_isDisposed)
				return null;
			return rects[index] as Point;
		}

		public function getOffest(index : uint = 0) : Point
		{
			if (_isDisposed)
				return null;
			return offests[index] as Point;
		}

		public function getShareResult(index : uint = 0) : SRenderBitmapData
		{
			if (_isDisposed)
				return null;
			return result_list[index] as SRenderBitmapData;
		}
	}
}