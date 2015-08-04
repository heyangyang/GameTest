package hy.rpg.pak
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import hy.game.core.SReference;
	import hy.game.manager.SReferenceManager;
	import hy.game.render.SRenderBitmap;
	import hy.game.render.SRenderBitmapData;
	import hy.game.resources.SResource;
	import hy.game.utils.SDebug;

	/**
	 * 一套序列帧动画解析器
	 * @author wait
	 *
	 */
	public class DecoderAnimation extends SReference
	{
		public static const DEFAULT : String = "1";
		public var id : String;
		private var decode_index : int;
		private var decode_count : int;
		/**
		 * 用来加载解析
		 */
		private var loader_dic : Dictionary;
		public var isSend : Boolean;
		/**
		 * 解析完后的动画
		 */
		protected var result_dic : Dictionary;
		private var _isCompleted : Boolean;
		private var notifyCompleteds : Array;
		private var errorCompleteds : Array;
		private var resource : SResource;

		public function DecoderAnimation(id : String)
		{
			this.id = id;
			super();
		}

		/**
		 * 开始加载资源
		 * @param ver
		 * @param priority
		 * @param isReload
		 *
		 */
		public function loadResource(ver : String, priority : int) : void
		{
			if (resource)
				return;
			resource = SReferenceManager.getInstance().createResource(id, ver);

			if (resource.isLoading)
				return;

			if (resource.isLoaded)
			{
				onResourceLoaded(resource);
				return;
			}

			resource.addNotifyCompleted(onResourceLoaded).addNotifyIOError(onResourceIOError).setPriority(priority).load();
		}

		/**
		 * 加载发生错误
		 * @param resource
		 *
		 */
		protected function onResourceIOError(resource : SResource) : void
		{
			SReferenceManager.getInstance().clearResource(resource.url);
			notifyError();
		}

		/**
		 * 加载完成，开始解析数据
		 * @param resource
		 *
		 */
		private function onResourceLoaded(resource : SResource) : void
		{
			decode(resource.data);
			SReferenceManager.getInstance().clearResource(id);
		}

		/**
		 * 解码
		 * 有多个方向的，也有只有一个方向
		 * @param bytes
		 *
		 */
		public function decode(bytes : ByteArray, isClear : Boolean = true) : void
		{
			//正在解析中
			if(loader_dic)
				return;
			bytes.position = 0
			var head : String = bytes.readUTF();
			var pak : DecoderPak;
			loader_dic = new Dictionary();
			decode_index = decode_count = 0;
			if (head == "zip")
			{
				var direction : int;
				var bytesAvailable : int;
				var newBytes : ByteArray = new ByteArray();
				var old_position : uint = bytes.position;
				while (bytes.bytesAvailable > 0)
				{
					direction = bytes.readByte();
					bytesAvailable = bytes.readUnsignedInt();
					bytes.position += bytesAvailable;
					decode_count++;
				}
				bytes.position = old_position;
				while (bytes.bytesAvailable > 0)
				{
					direction = bytes.readByte();
					bytesAvailable = bytes.readUnsignedInt();
					bytes.readBytes(newBytes, 0, bytesAvailable);
					createPakDecoder(newBytes, direction + "");
					newBytes.clear();
				}
			}
			else
			{
				decode_count++;
				createPakDecoder(bytes);
			}
			isClear && bytes.clear();
		}

		/**
		 * 解析一串动画数据
		 * @param bytes
		 * @param dir
		 * @return
		 *
		 */
		private function createPakDecoder(bytes : ByteArray, dir : String = DEFAULT) : DecoderPak
		{
			var pak : DecoderPak = new DecoderPak(id, bytes);
			pak.onComplete(onParseCompleted).onIOError(onReload);
			pak.decode();
			pak.loadImages();
			loader_dic[dir] = pak;
			return pak;
		}


		/**
		 * 加载完成
		 * 如果全部加载完成，解析图片，到结果列表
		 * @param decoder
		 *
		 */
		private function onParseCompleted(decoder : DecoderPak) : void
		{
			if (++decode_index < decode_count)
				return;
			result_dic = new Dictionary();
			var dir : String, i : int, len : int;
			var bmd : SRenderBitmapData;
			for (dir in loader_dic)
			{
				decoder = loader_dic[dir];
				len = decoder.length;
				for (i = 0; i < len; i++)
				{
					bmd = decoder.getResult(i);
				}
				result_dic[dir] = decoder;
			}
			notifyAll();
		}

		/**
		 * 获取需要发送给主线程的数据
		 * @return
		 *
		 */
		public function getSendMainThreadMessage() : Array
		{
			var dir : String, i : int;
			var message : Array = [id];
			var decoder : DecoderPak;
			var args : Array;
			var bmd : BitmapData;
			var len : int;
			for (dir in loader_dic)
			{
				decoder = loader_dic[dir];
				args = []
				len = decoder.length;
				for (i = 0; i < len; i++)
				{
					bmd = decoder.getShareResult(i);
					if (bmd == null)
					{
						warning(this, id + "decoder failed");
						continue;
					}
					args.push(bitmapDataToByteArray(bmd));
				}
				message.push([dir, args, decoder.width, decoder.height, decoder.offests]);
			}
			return message;
		}

		protected function bitmapDataToByteArray(bmd : BitmapData) : ByteArray
		{
			if (bmd == null)
				return null;
			var bytes : ByteArray = new ByteArray();
			bytes.writeInt(bmd.width);
			bytes.writeInt(bmd.height);
			bmd["copyPixelsToByteArray"](bmd.rect, bytes);
			bytes.position = 0;
			return bytes;
		}

		/**
		 * 把后台进程处理完的图片解析
		 * @param message
		 *
		 */
		public function parseBackThreadMessage(message : Array) : void
		{
			result_dic = new Dictionary();
			var len : int = message.length, args_len : int;
			var tmp_data : Array;
			var decoder : DecoderPak;
			var offests : Array;
			var args : Array;
			var bmd : SRenderBitmap;
			var j : int;
			//数组0是ID，所以跳过 i从1开始 
			for (var i : int = 1; i < len; i++)
			{
				tmp_data = message[i];
				decoder = new DecoderPak(id, null);
				result_dic[tmp_data[0]] = decoder;
				decoder.width = tmp_data[2];
				decoder.height = tmp_data[3];
				decoder.offests = parseOffests(tmp_data[4]);
				args = tmp_data[1];
				decoder.img_bytes = args;
				decoder.length = args.length;
				decoder.notifyAllComplete();
			}
		}

		/**
		 * 是否处理完毕
		 * @return
		 *
		 */
		public function get isCompleted() : Boolean
		{
			return _isCompleted;
		}

		private function parseOffests(data : Array) : Array
		{
			var offests : Array = [];
			var len : int = data.length;
			var point : Object;
			for (var i : int = 0; i < len; i++)
			{
				point = data[i];
				offests.push(new Point(point.x, point.y));
			}
			return offests;
		}

		private function onReload(decoder : DecoderPak) : void
		{
			if (++decode_index < decode_count)
				return;
			notifyAll();
			SDebug.error("解析图片出错" + id);
		}

		public function get width() : int
		{
			for each (var decoder : DecoderPak in result_dic)
			{
				return decoder.width;
			}
			return 0;
		}

		public function get height() : int
		{
			for each (var decoder : DecoderPak in result_dic)
			{
				return decoder.height;
			}
			return 0;
		}

		public function get length() : int
		{
			for each (var decoder : DecoderPak in result_dic)
			{
				return decoder.length;
			}
			return 0;
		}

		public function getOffest(index : uint = 0, dir : String = DEFAULT) : Point
		{
			if (result_dic == null)
				return null;
			if (result_dic[dir] == null)
			{
				var tmp_dir : String = dir;
				for (dir in result_dic)
					break;
			}
			return DecoderPak(result_dic[dir]).getOffest(index);
		}

		public function getResult(index : uint = 0, dir : String = DEFAULT) : SRenderBitmapData
		{
			if (result_dic == null)
				return null;
			if (result_dic[dir] == null)
			{
				var tmp_dir : String = dir;
				for (dir in result_dic)
					break;
			}
			return DecoderPak(result_dic[dir]).getResult(index);
		}

		override protected function destroy() : void
		{
			super.destroy();
			isSend = false;
			if (notifyCompleteds)
				notifyCompleteds.length = 0
			if (errorCompleteds)
				errorCompleteds.length = 0
			notifyCompleteds = null;
			errorCompleteds = null;
			clearResultPakDecoder();
			clearPakDecoder();
		}

		/**
		 * 添加通知处理
		 * @param fun
		 *
		 */
		public function addNotify(fun : Function) : void
		{
			if (notifyCompleteds == null)
				notifyCompleteds = [];
			if (notifyCompleteds.indexOf(fun) == -1)
				notifyCompleteds.push(fun);
		}

		/**
		 * 添加错误处理
		 * @param fun
		 *
		 */
		public function addErrorNotify(fun : Function) : void
		{
			if (errorCompleteds == null)
				errorCompleteds = [];
			if (errorCompleteds.indexOf(fun) == -1)
				errorCompleteds.push(fun);
		}

		/**
		 * 处理完成，通知处理
		 *
		 */
		public function notifyAll() : void
		{
			_isCompleted = true;
			for each (var fun : Function in notifyCompleteds)
			{
				fun && fun(this);
			}
			if (notifyCompleteds)
				notifyCompleteds.length = 0;
		}

		public function notifyError() : void
		{
			for each (var fun : Function in errorCompleteds)
			{
				fun && fun(this);
			}
			if (errorCompleteds)
				errorCompleteds.length = 0;
		}

		private function clearPakDecoder() : void
		{
			for each (var pak : DecoderPak in loader_dic)
			{
				pak.dispose();
			}
			loader_dic = null;
		}

		private function clearResultPakDecoder() : void
		{
			for each (var pak : DecoderPak in result_dic)
			{
				pak.dispose();
			}
			result_dic = null;
		}
	}
}