package hy.rpg.parser
{
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import hy.game.manager.SReferenceManager;
	import hy.game.render.SRenderBitmapData;
	import hy.rpg.enmu.SLoadPriorityType;
	import hy.rpg.pak.SAnimationDecoder;
	import hy.rpg.pak.SDirectAnimationDecoder;

	/**
	 *  pak资源解析器
	 *
	 */
	public class SPakResourceParser extends SResourceParser
	{
		/**
		 * 正在加载的
		 */
		protected static var load_list : Array = [];
		/**
		 * 需要加载的
		 */
		protected static var need_send_list : Array = [];
		/**
		 * 最大加载的数量
		 */
		protected static const COUNT : int = 2;
		/**
		 * 是否需要排序
		 */
		protected static var isSort : Boolean;

		/**
		 * 每次加载完成，实行下一个加载
		 *
		 */
		public static function sendLoadMessage() : void
		{
			if (load_list.length < COUNT && need_send_list.length > 0)
			{
				if (isSort)
				{
					need_send_list.sort(load_sort);
					isSort = false;
				}
				load_list.push(need_send_list.shift())
			}
		}

		protected static function load_sort(a : Array, b : Array) : int
		{
			if (a[2] < b[2])
				return 1;
			if (a[2] > [2])
				return -1;
			return 0;
		}

		public static function removeLoadMessage(id : String) : void
		{
			var len : int = load_list.length;
			for (var i : int = 0; i < len; i++)
			{
				if (load_list[i][0] == id)
				{
					load_list.splice(i, 1);
					break;
				}
			}
		}

		protected var _decoder : SDirectAnimationDecoder;

		public function SPakResourceParser(id : String, version : String = null, priority : int = SLoadPriorityType.MAP)
		{
			super(id, version, priority);
		}

		override protected function startParseLoader(bytes : ByteArray) : void
		{
			if (!bytes)
				return;
			decoder = SReferenceManager.getInstance().createDirectAnimationDeocder(id);
			_decoder.addNotify(onParseCompleted);
			_decoder.decode(bytes, false);
		}

		protected function set decoder(value : SDirectAnimationDecoder) : void
		{
			if (_decoder)
				_decoder.release();
			_decoder = value;
		}


		protected function loadThreadResource() : void
		{
			decoder = SReferenceManager.getInstance().createDirectAnimationDeocder(id);
			if (_decoder.isCompleted)
				parseComplete(_decoder);
			else
				_decoder.addNotify(parseComplete);
			if (!_decoder.isSend)
			{
				_decoder.isSend = true;

				if (load_list.length > COUNT)
				{
					need_send_list.push([id, version, priority]);
					isSort = true;
				}
				else
				{
					var send_arr : Array = [id, version, priority];
					load_list.push(send_arr);
				}
			}
		}

		/**
		 * 解析完成
		 * @param pak
		 *
		 */
		public function parseComplete(pak : SDirectAnimationDecoder) : void
		{
			onParseCompleted(null);
		}

		protected function onParseCompleted(decoder : SAnimationDecoder) : void
		{
			parseCompleted();
		}

		public function getLength() : int
		{
			if (_decoder)
				return _decoder.length;
			return 0;
		}

		public function get width() : int
		{
			if (_decoder)
				return _decoder.width;
			return 0;
		}

		public function get height() : int
		{
			if (_decoder)
				return _decoder.height;
			return 0;
		}

		/**
		 * 根据帧得到位图，帧指的是整个动画文件的帧序列号
		 * @param frame
		 * @return
		 *
		 */
		public function getBitmapDataByFrame(frame : int) : SRenderBitmapData
		{
			if (_decoder)
				return _decoder.getResult(frame - 1);
			return null;
		}

		public function getOffset(index : int, dir : String = null) : Point
		{
			if (_decoder)
				return _decoder.getOffest(index);
			return null;
		}

		override protected function destroy() : void
		{
			decoder = null;
			super.destroy();
		}
	}
}