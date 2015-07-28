package hy.rpg.map
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import hy.game.cfg.Config;
	import hy.game.core.GameObject;
	import hy.game.core.SCameraObject;
	import hy.game.core.interfaces.IBitmap;
	import hy.game.core.interfaces.IContainer;
	import hy.game.manager.SReferenceManager;
	import hy.game.render.SRenderBitmap;
	import hy.game.render.SRenderContainer;
	import hy.game.resources.SResource;
	import hy.game.utils.SDebug;
	import hy.rpg.enmu.SLoadPriorityType;
	import hy.rpg.parser.SImageResourceParser;
	import hy.rpg.parser.SMapResourceParser;
	import hy.rpg.seek.SRoadSeeker;
	import hy.rpg.utils.SCommonUtil;

	/**
	 * 地图
	 *
	 */
	public class SMapObject extends GameObject
	{
		/**
		 * 地图宽度
		 */
		protected var _mapWidth : int;

		/**
		 * 地图宽度
		 */
		protected var _mapHeight : int;

		/**
		 * 地图总列数
		 */
		protected var _mapTotalX : int;
		/**
		 * 地图总行数
		 */
		protected var _mapTotalY : int;

		protected var _tileWidth : int;
		protected var _tileHeight : int;

		/**
		 * 缓冲区列数
		 */
		protected var _bufferCols : int;
		/**
		 * 缓冲区行数
		 */
		protected var _bufferRows : int;
		/**
		 * 可视区域宽度
		 */
		protected var _viewWidth : int;
		/**
		 * 可视区域高度
		 */
		protected var _viewHeight : int;

		/**
		 * 未加载时的地图黑块
		 */
		private var _blackBitmapData : BitmapData;

		/**
		 * 地图缓冲区
		 */
		protected var _container : IContainer;

		/**
		 * 地图名称
		 */
		protected var _mapName : String;

		/**
		 * 用于坐标记录
		 */
		private var _loadTilePos : Point = new Point();
		/**
		 * 地图配置文件
		 */
		protected var _config : XML;
		private var _fileVersions : Dictionary;

		//小地图，马塞克
		protected var _smallMapBitmapData : BitmapData;
		protected var _smallMapParser : SMapResourceParser;
		protected var _mosaicMatrix : Matrix = new Matrix();

		/**
		 * 小地图
		 */
		protected var _smallPreviewerMapParser : SImageResourceParser;
		/**
		 * 保存加载过的地图块位图
		 */
		protected var _tiles : Dictionary;
		private var _blackTitles : Dictionary;

		/**
		 * 上一帧的缓冲区起始X索引
		 */
		private var _lastStartTileX : int;

		/**
		 * 上一帧的缓冲区起始Y索引
		 */
		private var _lastStartTileY : int;

		/**
		 * 上一帧的屏幕偏移X值
		 */
		private var _lastViewX : Number;

		/**
		 * 上一帧的屏幕偏移Y值
		 */
		private var _lastViewY : Number;

		/**
		 * 当前帧的缓冲区起始X索引
		 */
		protected var _startTileX : int;

		/**
		 * 当前帧的缓冲区起始Y索引
		 */
		protected var _startTileY : int;

		protected var _transparent : Boolean;

		/**
		 * 缓冲区域大小
		 */
		private var _pretreatmentNum : int = 1;

		/**
		 * 摄像头
		 */
		private var m_camera : SCameraObject;
		/**
		 * 小地图缩放
		 */
		private var m_scale : Number;

		public function SMapObject(min_scale : Number)
		{
			m_scale = min_scale;

			if (Config.supportDirectX)
			{
				//_container = new SDirectContainer();
			}
			else
			{
				_container = new SRenderContainer();
				SRenderContainer(_container).mouseChildren = false;
			}
			m_camera = SCameraObject.getInstance();
			_tiles = new Dictionary();
			_blackTitles = new Dictionary();
			super();
		}

		override public function registerd(priority : int = 0) : void
		{
			super.registerd(priority);
			addContainer(_container);
			removeRender(m_render);
		}
		private var _mapId : String;
		private var _onConfigComplete : Function;
		private var _onProgress : Function;
		private var _mapBlocks : Array;
		private var _maxMultiDistance : int;

		/**
		 * 初始化地图
		 * @param id
		 * @param onComplete
		 * @param inited
		 *
		 */
		public function load(mapId : String, onComplete : Function = null, onProgress : Function = null) : void
		{
			clear();
			_mapId = mapId;
			_onConfigComplete = onComplete;
			_onProgress = onProgress;
			SReferenceManager.getInstance().createResource(_mapId).addNotifyCompleted(onConfigComplete).addNotifyProgress(onProgress).load();
		}

		private function onConfigComplete(res : SResource) : void
		{
			var bytes : ByteArray = res.getBinary();
			bytes.position = 0;
			setConfig(XML(bytes.readUTFBytes(bytes.bytesAvailable)));
			if (_config.grid.@url)
			{
				SReferenceManager.getInstance().createResource(_config.grid.@url, _config.grid.@version).addNotifyCompleted(onBlockComplete).addNotifyProgress(_onProgress).addNotifyIOError(onBlockError).load();
			}
			else
			{
				updateBlocks();
				if (_onConfigComplete != null)
					_onConfigComplete();
				_onConfigComplete = null;
			}
		}

		private function onBlockComplete(res : SResource) : void
		{
			var bytes : ByteArray = res.getBinary();
			bytes.position = 0;
			var mapBlocks : Array = bytes.readObject() as Array;
			if (!mapBlocks || mapBlocks.length == 0 || mapBlocks[0].length == 0)
			{
				SDebug.error(this, "地图数据出现mapBlocks=" + mapBlocks ? mapBlocks.toString() : 'null');
			}
			updateBlocks(mapBlocks);

			if (_onConfigComplete != null)
				_onConfigComplete();
			_onProgress = null;
			_onConfigComplete = null;
		}

		private function onBlockError(res : SResource) : void
		{
			updateBlocks();
			if (_onConfigComplete != null)
				_onConfigComplete();
			_onConfigComplete = null;
		}

		public function updateBlocks(mapBlocks : Array = null) : void
		{
			if (mapBlocks)
			{
				_mapBlocks = mapBlocks;
				if (_maxMultiDistance > 1)
				{
					var multiBlocks : Array = [];
					var blockColumsLen : int = _mapBlocks.length;
					var multiColumsLen : int = blockColumsLen * _maxMultiDistance;
					var blockRowsLen : int = _mapBlocks[0].length;
					for (var i : int = 0; i < multiColumsLen; i++)
					{
						var data : Array = [];
						multiBlocks.push(data);
						for (var j : int = 0; j < blockRowsLen; j++)
						{
							data.push(_mapBlocks[i % blockColumsLen][j]);
						}
					}
					_mapBlocks = multiBlocks;
				}
				SRoadSeeker.getInstance().init(_mapBlocks);
			}
		}

		public function setConfig(xml : XML) : void
		{
			_config = xml;
			parseMapData();
		}

		/**
		 * 初始化地图
		 *
		 */
		protected function parseMapData() : void
		{
			_fileVersions = new Dictionary();
			for each (var tileXML : XML in _config.tile)
			{
				_fileVersions[String(tileXML.@id)] = {url: String(tileXML.@url), version: String(tileXML.@version)};
			}

			// 从XML文件中获取地图基本信息
			_mapWidth = _config.@width;
			_mapHeight = _config.@height;

			//设置镜头的基本信息
			m_camera.setScreenSize(Config.screenWidth, Config.screenHeight);
			m_camera.setSceneSize(_mapWidth, _mapHeight);
			m_camera.updateRectangle(200, 200);

			_tileWidth = Config.TILE_WIDTH;
			_tileHeight = Config.TILE_HEIGHT;
			_blackBitmapData = new BitmapData(_tileWidth, _tileHeight, _transparent, 0);

			setViewSize(Config.screenWidth, Config.screenHeight);

			_mapTotalX = Math.ceil(_mapWidth / _tileWidth);
			_mapTotalY = Math.ceil(_mapHeight / _tileHeight);

			_mapName = _config.@name;
			loadSmallMap(_config.sm.@url, String(_config.sm.@version));
			loadPreviewMap(_config.bm.@url);
		}

		/**
		 * 加载马赛克小地图
		 * @param url
		 *
		 */
		private function loadSmallMap(url : String, version : String) : void
		{
			if (!url)
				return;
			_smallMapParser = new SMapResourceParser(url, version);
			_smallMapParser.onComplete(onSmallMapParserComplete);
			_smallMapParser.load();
		}

		/**
		 * 预览小地图
		 * @param url
		 *
		 */
		private function loadPreviewMap(url : String) : void
		{
			if (!url)
				return;
			_smallPreviewerMapParser = SReferenceManager.getInstance().createImageParser(url, SLoadPriorityType.MAP);
			_smallPreviewerMapParser.load();
		}

		private function onSmallMapParserComplete(res : SMapResourceParser) : void
		{
			_smallMapBitmapData = res.bitmapData;
			_lastStartTileX = -1;
			_lastStartTileY = -1;
			_lastViewX = -1;
			_lastViewY = -1;
		}

		/**
		 * 屏幕大小 改变
		 * @param w
		 * @param h
		 *
		 */
		public function setViewSize(viewWidth : int, viewHeight : int) : void
		{
			_viewWidth = viewWidth;
			_viewHeight = viewHeight;

			updateBufferSize();
			updateCamera(m_camera.sceneX, m_camera.sceneY);
		}

		private function updateBufferSize() : void
		{
			_bufferCols = Math.ceil(_viewWidth / _tileWidth);
			_bufferRows = Math.ceil(_viewHeight / _tileHeight);

			if (_bufferCols > 0 && _bufferRows > 0)
			{
				clearAllBuffer();

				_lastStartTileX = -1;
				_lastStartTileY = -1;
				_lastViewX = -1;
				_lastViewY = -1;
			}
		}

		protected function onTileResourceParserComplete(res : SMapResourceParser) : void
		{
			var tileId : String = res.id.split("/").pop().split(".").shift();
			var loadTilePos : Point = decoderTileId(tileId);
			var blackBmd : IBitmap = _blackTitles[tileId];
			blackBmd && blackBmd.removeChild();
			if (res.bitmap)
			{
				drawTile(res.bitmap, loadTilePos.x, loadTilePos.y);
				return;
			}
			SDebug.warning(this, "地图块数据为空！");
		}

		/**
		 * 释放指定x,y索引处的地图区块位图
		 * @param tileX
		 * @param tileY
		 *
		 */
		protected function clearTile(tileX : int, tileY : int) : void
		{
			if (tileX < 0 || tileY < 0 || tileX > _mapTotalX || tileY > _mapTotalY)
			{
				SDebug.warning(this, "地图删除区域不在范围内！");
				return;
			}
			var tileId : String = encoderTileId(tileX, tileY);
			var tile : SMapTile = _tiles[tileId];
			if (!tile)
				return;
			delete _tiles[tileId];
			tile.destroy();
		}

		/**
		 * 把坐标加密成一串字符串
		 * @param tileX
		 * @param tileY
		 * @return
		 *
		 */
		protected function encoderTileId(tileX : int, tileY : int) : String
		{
			return SCommonUtil.xyToInt(tileX + 1, tileY + 1).toString(36);
		}

		/**
		 * 解锁一个字符串成坐标
		 * @param tileId
		 * @return
		 *
		 */
		protected function decoderTileId(tileId : String) : Point
		{
			_loadTilePos.x = SCommonUtil.getXFromInt(parseInt(tileId, 36)) - 1;
			_loadTilePos.y = SCommonUtil.getYFromInt(parseInt(tileId, 36)) - 1;
			return _loadTilePos;
		}

		protected function createMapTile(tileX : int, tileY : int) : Boolean
		{
			var startX : int = _startTileX - _pretreatmentNum;
			var endX : int = _startTileX + _bufferCols + _pretreatmentNum;
			var startY : int = _startTileY - _pretreatmentNum;
			var endY : int = _startTileY + _bufferRows + _pretreatmentNum;

			if (startX >= -_pretreatmentNum && endX >= -_pretreatmentNum && tileX >= startX && tileX <= endX && startY >= -_pretreatmentNum && endY >= -_pretreatmentNum && tileY >= startY && tileY <= endY)
			{
				var tileId : String = encoderTileId(tileX, tileY);
				var tile : SMapTile = _tiles[tileId];
				if (!tile)
				{
					var resId : String = encoderTileId(tileX, tileY);
					var data : Object = _fileVersions[resId];
					if (data)
					{
						tile = new SMapTile(SMapResourceParser, _mapName + tileId, data.url, SLoadPriorityType.MAP, data.version);
						_tiles[tileId] = tile;
					}
				}
				else if (tile.isLoaded)
				{
					onTileResourceParserComplete(tile.parser);
				}
				else if (tile.isLoading)
				{

				}
				else
				{
					SDebug.warning(this, "null tile");
				}
				return true;
			}
			else
			{
				SDebug.warning(this, "地图创建区域不在范围内！");
			}
			return false;
		}

		/**
		 * 获取指定x,y索引处的地图区块位图
		 * @param tileX
		 * @param tileY
		 * @return
		 *
		 */
		protected function copyTileBitmapData(tileX : int, tileY : int) : void
		{
			if (createMapTile(tileX, tileY))
			{
				drawTileBitmapData(tileX, tileY);
			}
		}

		protected function drawTileBitmapData(tileX : int, tileY : int) : void
		{
			var tileId : String = encoderTileId(tileX, tileY);
			var tile : SMapTile = _tiles[tileId];
			if (!tile || !tile.isLoaded)
			{
				var blackBmd : IBitmap = _blackTitles[tileId];
				if (blackBmd == null)
				{
					createMosaicTile(tileX, tileY);
					if (Config.supportDirectX)
					{
						//blackBmd = new SDirectBitmap(SDirectBitmapData.fromDirectBitmapData(_blackBitmapData));
						//blackBmd.blendMode = BlendMode.NONE;
					}
					else
						blackBmd = new SRenderBitmap(_blackBitmapData.clone());
					_blackTitles[tileId] = blackBmd;
				}
				drawTile(blackBmd, tileX, tileY);
				createTileResourceParser(tileX, tileY);
			}
			else if (tile.isLoaded)
			{
				onTileResourceParserComplete(tile.parser);
			}
		}

		private function createTileResourceParser(tileX : int, tileY : int) : void
		{
			var startX : int = _startTileX - _pretreatmentNum;
			var endX : int = _startTileX + _bufferCols + _pretreatmentNum;
			var startY : int = _startTileY - _pretreatmentNum;
			var endY : int = _startTileY + _bufferRows + _pretreatmentNum;

			if (startX >= -_pretreatmentNum && endX >= -_pretreatmentNum && tileX >= startX && tileX <= endX && startY >= -_pretreatmentNum && endY >= -_pretreatmentNum && tileY >= startY && tileY <= endY)
			{
				var tileId : String = encoderTileId(tileX, tileY);
				var tile : SMapTile = _tiles[tileId];
				if (tile)
				{
					tile.onComplete(onTileResourceParserComplete);
					tile.load();
				}
			}
			else
			{
				SDebug.warning(this, "地图加载区域不在范围内！");
			}
		}

		/**
		 * 为块添加马赛克效果，支持循环
		 * @param tileX
		 * @param tileY
		 *
		 */
		private function createMosaicTile(tileX : int, tileY : int) : void
		{
			if (!_smallMapBitmapData)
				return;
			var tx : Number = (tileX * _tileWidth) * m_scale;
			var ty : Number = (tileY * _tileHeight) * m_scale;
			var scale : Number = m_scale * 100;
			_mosaicMatrix.identity();
			_mosaicMatrix.translate(-tx, -ty);
			_mosaicMatrix.scale(scale, scale);
			_blackBitmapData.draw(_smallMapBitmapData, _mosaicMatrix);
		}

		private function drawTile(bitmap : IBitmap, tileX : int, tileY : int) : void
		{
			if (bitmap)
			{
				bitmap.x = tileX * _tileWidth;
				bitmap.y = tileY * _tileHeight;
				_container.addGameChild(bitmap);
			}
		}

		/**
		 * 刷新缓冲区
		 *
		 */
		protected function refreshBuffer() : void
		{
			//如果是滚动刷新缓冲区
			if (_lastStartTileX == -1 && _lastStartTileY == -1) //填充全部
			{
				clearAllBuffer();
			}

			var tileNeedFefresh : Boolean = false;
			var totalTileNum : int = 0;
			var colmnsCount : int;
			//将缓冲区对应的地图区块读入缓冲区中
			for (var rowCount : int = 0; rowCount < _bufferRows; rowCount++)
			{
				for (colmnsCount = 0; colmnsCount < _bufferCols; colmnsCount++)
				{
					tileNeedFefresh = checkIsNeedFefreshBuffer(rowCount, colmnsCount);
					if (tileNeedFefresh)
					{
						copyTileBitmapData(colmnsCount + _startTileX, rowCount + _startTileY);
						continue;
					}
					clearBuffer(colmnsCount, rowCount);
				}
			}
		}

		/**
		 *检测是否需要刷新缓冲区域
		 * @return
		 *
		 */
		public function checkIsNeedFefreshBuffer(rowCount : int, colmnsCount : int) : Boolean
		{
			//如果是第一次构建缓冲区
			if ((_lastStartTileX == -1 && _lastStartTileY == -1))
			{
				return true;
			}
			//如果是滚动刷新缓冲区
			if (_startTileX - _lastStartTileX > 0)
			{
				if (colmnsCount + (_startTileX - _lastStartTileX) >= _bufferCols)
				{
					return true;
				}
			}
			else if (_startTileX - _lastStartTileX < 0)
			{
				if (colmnsCount < _lastStartTileX - _startTileX)
				{
					return true;
				}
			}

			if (_startTileY - _lastStartTileY > 0)
			{
				if (rowCount + (_startTileY - _lastStartTileY) >= _bufferRows)
				{
					return true;
				}
			}
			else if (_startTileY - _lastStartTileY < 0)
			{
				if (rowCount < _lastStartTileY - _startTileY)
				{
					return true;
				}
			}
			return false;
		}

		private function clearBuffer(rowCount : int, colmnsCount : int) : void
		{
			//清除不在缓冲区中的地图区块位图
			//清除缓冲区上方一排
			if (rowCount == 0 && _startTileY > 0)
			{
				clearTile(colmnsCount + _startTileX, rowCount + _startTileY - _pretreatmentNum);
				if (_startTileX > 0 && colmnsCount == 0)
				{
					clearTile(colmnsCount + _startTileX - _pretreatmentNum, rowCount + _startTileY - _pretreatmentNum);
				}
				if (_startTileX < _mapTotalX - _bufferCols && colmnsCount == _bufferCols - _pretreatmentNum)
				{
					clearTile(colmnsCount + _startTileX + _pretreatmentNum, rowCount + _startTileY - _pretreatmentNum);
				}
			}
			//清除缓冲区下方一排
			if (rowCount == _bufferRows - _pretreatmentNum && _startTileY < _mapTotalY - _bufferRows)
			{
				clearTile(colmnsCount + _startTileX, rowCount + _startTileY + _pretreatmentNum);
				if (_startTileX > 0 && colmnsCount == 0)
				{
					clearTile(colmnsCount + _startTileX - _pretreatmentNum, rowCount + _startTileY + _pretreatmentNum);
				}
				if (_startTileX < _mapTotalX - _bufferCols && colmnsCount == _bufferCols - _pretreatmentNum)
				{
					clearTile(colmnsCount + _startTileX + _pretreatmentNum, rowCount + _startTileY - _pretreatmentNum);
				}
			}
			//清除缓冲区左方一排
			if (colmnsCount == 0 && _startTileX > 0)
			{
				clearTile(colmnsCount + _startTileX - _pretreatmentNum, rowCount + _startTileY);
			}
			//清除缓冲区右方一排
			if (colmnsCount == _bufferCols - _pretreatmentNum && _startTileX < _mapTotalX - _bufferCols)
			{
				clearTile(colmnsCount + _startTileX + _pretreatmentNum, rowCount + _startTileY);
			}
		}


		private function clearAllTiles() : void
		{
			for (var tileId : String in _tiles.dic)
			{
				var tile : SMapTile = _tiles.getValue(tileId);
				if (tile)
				{
					tile.destroy();
					_tiles.deleteValue(tileId);
				}
			}

			for each (var bit : IBitmap in _blackTitles)
			{
				bit.dispose();
			}
			_blackTitles = new Dictionary();
		}

		private function clearAllBuffer() : void
		{
			for (var i : int = _container.numChildren - 1; i >= 0; i--)
			{
				_container.removeGameChildAt(i);
			}
		}


		override public function update() : void
		{
			updateCamera(m_camera.sceneX, m_camera.sceneY);
		}

		public function updateCamera(viewX : int, viewY : int) : void
		{
			var isRefreshScreen : Boolean = true; //是否需要刷新屏幕
			if (!_smallMapBitmapData)
				return;
			if (viewX == _lastViewX && viewY == _lastViewY)
			{
				isRefreshScreen = false;
				return;
			}

			_lastViewX = viewX;
			_lastViewY = viewY;

			if (isRefreshScreen)
			{
				// 计算出缓冲区开始的区块索引
				_startTileX = int(viewX / _tileWidth);
				_startTileY = int(viewY / _tileHeight);

				var isRefreshBuffer : Boolean = true; //是否需要刷新缓存
				if (_startTileX == _lastStartTileX && _startTileY == _lastStartTileY)
					isRefreshBuffer = false;

				_container.x = -viewX;
				_container.y = -viewY;
				// 加载地图区块到缓冲区中
				if (isRefreshBuffer)
				{
					refreshBuffer();
				}

				_lastStartTileX = _startTileX;
				_lastStartTileY = _startTileY;
			}
		}

		public function clear() : void
		{
			clearAllBuffer();
			clearAllTiles();

			if (_smallMapParser)
			{
				_smallMapParser.release();
				_smallMapParser = null;
			}

			if (_smallPreviewerMapParser)
			{
				_smallPreviewerMapParser.release();
				_smallPreviewerMapParser = null;
			}

			if (_smallMapBitmapData)
			{
				_smallMapBitmapData.dispose();
				_smallMapBitmapData = null;
			}

			_transparent = false;
			_lastStartTileX = -1;
			_lastStartTileY = -1;
			_lastViewX = -1;
			_lastViewY = -1;
			_config = null;
			_fileVersions = null;
		}

		override public function destroy() : void
		{
			if (m_isDisposed)
				return;

			clear();
			if (_container)
			{
				clearAllBuffer();
				_container = null;
			}

			if (_blackBitmapData)
			{
				_blackBitmapData.dispose();
				_blackBitmapData = null;
			}

			super.destroy();
		}
	}
}