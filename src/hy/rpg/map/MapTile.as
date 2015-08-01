package hy.rpg.map
{
	import hy.game.manager.SReferenceManager;
	import hy.rpg.parser.ParserMapResource;
	import hy.rpg.parser.ParserResource;

	/**
	 *
	 * 地图块
	 *
	 */
	public class MapTile
	{
		protected var _id : String;
		protected var _resId : String;
		protected var _priority : int;
		protected var _version : String;
		protected var _parser : ParserMapResource;

		public function MapTile(id : String, resId : String, priority : int, version : String = null)
		{
			_id = id;
			_resId = resId;
			_priority = priority;
			_version = version;
			super();
		}

		public function load(onComplete : Function) : void
		{
			_parser && _parser.release();
			_parser = SReferenceManager.getInstance().createMapResourceParser(ParserMapResource, _id, _resId, _priority, _version);
			if (!_parser.isLoading)
			{
				_parser.onComplete(onComplete);
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

		public function clearBitmap() : void
		{
			_parser && _parser.clearBitmap();
		}

		public function get parser() : ParserMapResource
		{
			return _parser;
		}

		public function destroy() : void
		{
			if (_parser)
			{
				_parser.clearBitmap();
				_parser.release();
				_parser = null;
			}
		}
	}
}