package hy.rpg.map
{
	import hy.game.manager.SReferenceManager;
	import hy.rpg.parser.SMapResourceParser;

	/**
	 *
	 * <p>
	 * SunnyGame的一个地图块
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
	public class SMapTile
	{
		protected var _isDisposed : Boolean;
		protected var _id : String;
		protected var _tileId : String;
		protected var _resId : String;
		protected var _priority : int;
		protected var _version : String;
		protected var _parser : SMapResourceParser;

		public function SMapTile(parserClass : Class, id : String, tileId : String, resId : String, priority : int, version : String = null)
		{
			_isDisposed = false;
			_id = id;
			_tileId = tileId;
			_resId = resId;
			_priority = priority;
			_version = version;
			_parser = SReferenceManager.getInstance().createMapResourceParser(parserClass, _id, resId, priority, version);
			super();
		}

		public function load() : void
		{
			if (_parser && !_parser.isLoaded && !_parser.isLoading)
			{
				_parser.load();
			}
		}

		public function get isLoaded() : Boolean
		{
			if (_parser)
				return _parser.isLoaded;
			return false;
		}

		public function get isLoading() : Boolean
		{
			if (_parser)
				return _parser.isLoading;
			return false;
		}

		public function onComplete(fun : Function) : SSunnyResourceParser
		{
			if (_parser)
				return _parser.onComplete(fun);
			return null;
		}

		public function removeOnComplete(fun : Function) : SSunnyResourceParser
		{
			if (_parser)
				return _parser.removeOnComplete(fun);
			return null;
		}

		public function clearBitmap() : void
		{
			_parser && _parser.clearBitmap();
		}

		public function get parser() : SMapResourceParser
		{
			return _parser;
		}

		public function destroy() : void
		{
			if (_isDisposed)
				return;
			if (_parser)
			{
				_parser.clearBitmap();
				_parser.release();
				_parser = null;
			}
			_isDisposed = true;
		}

		public function get isDisposed() : Boolean
		{
			return _isDisposed;
		}

		public function get resId() : String
		{
			return _resId;
		}

		public function get priority() : int
		{
			return _priority;
		}

		public function get version() : String
		{
			return _version;
		}
	}
}