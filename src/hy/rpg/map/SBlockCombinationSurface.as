package hy.rpg.map
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import hy.game.cfg.Config;
	import hy.game.core.GameObject;
	import hy.game.core.interfaces.IBitmap;
	import hy.game.core.interfaces.IContainer;
	import hy.game.manager.SReferenceManager;
	import hy.game.render.SRenderBitmap;
	import hy.game.render.SRenderContainer;
	import hy.game.utils.SDebug;
	import hy.rpg.enmu.SLoadPriorityType;
	import hy.rpg.parser.SImageResourceParser;
	import hy.rpg.parser.SMapResourceParser;
	import hy.rpg.utils.SCommonUtil;

	/**
	 * 地图
	 *
	 */
	public class SBlockCombinationSurface extends GameObject
	{
		protected var _id : String;
		/**
		 * 地图宽度
		 */
		protected var _mapWidth : int;

		public function get mapWidth() : int
		{
			return _mapWidth;
		}

		/**
		 * 地图宽度
		 */
		protected var _mapHeight : int;

		public function get mapHeight() : int
		{
			return _mapHeight;
		}

		/**
		 * 地图总列数
		 */
		protected var _mapCols : int;
		/**
		 * 地图总行数
		 */
		protected var _mapRows : int;

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
		 * 可视区域相对于整张地图的X偏移值
		 */
		protected var _viewX : int = 0;
		/**
		 * 可视区域相对于整张地图的Y偏移值
		 */
		protected var _viewY : int = 0;

		/**
		 * 可视区域相对于缓冲区的矩形
		 */
		private var _viewRect : Rectangle;
		private var _offsetPoint : Point;

		/**
		 * 可视区域相对于整张地图的矩形
		 */
		private var _screenRect : Rectangle;
		/**
		 * 地图名称
		 */
		protected var _mapName : String;

		/**
		 * 地图配置文件
		 */
		protected var _config : XML;
		private var _fileVersions : Dictionary;

		protected var _leftBorder : int = 0;
		protected var _topBorder : int = 0;
		protected var _rightBorder : int = 0;
		protected var _bottomBorder : int = 0;

		protected var _leftCols : int;
		protected var _rightCols : int;
		protected var _topRows : int;
		protected var _bottomRows : int;

		private var _inited : Function;

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

		protected var _updatable : Boolean;

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
		protected var _isDisposed : Boolean;

		protected var _smallMapResourceId : String;
		protected var _smallMapVersion : String;

		/**
		 * 有一块区块用于新进来的区块过度
		 */
		private var _pretreatmentNum : int = 1;
		private var _pretreatmentWidth : int;
		private var _pretreatmentHeight : int;

		public function SBlockCombinationSurface(id : String)
		{
			_id = id;
			super();
			_viewRect = new Rectangle();
			_offsetPoint = new Point();
			_screenRect = new Rectangle();

			if (Config.supportDirectX)
			{
				//_container = new SDirectContainer();
			}
			else
			{
				_container = new SRenderContainer();
				SRenderContainer(_container).mouseChildren = false;
			}
			_isDisposed = false;
			_tiles = new  Dictionary();
			_blackTitles = new Dictionary();
		}


		public function clear() : void
		{
			clearBuffer();
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

			_smallMapResourceId = null;
			_smallMapVersion = null;

			_updatable = false;
			_transparent = false;
			_lastStartTileX = -1;
			_lastStartTileY = -1;
			_lastViewX = -1;
			_lastViewY = -1;
			_config = null;
			_fileVersions = null;
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
				var version : String = String(tileXML.@version);
				_fileVersions[String(tileXML.@id)] = {url: String(tileXML.@url), version: version};
			}

			// 从XML文件中获取地图基本信息
			_mapWidth = _config.@width;
			_mapHeight = _config.@height;

			_tileWidth = Config.TILE_WIDTH;
			_tileHeight = Config.TILE_HEIGHT;

			_pretreatmentWidth = _pretreatmentNum * _tileWidth;
			_pretreatmentHeight = _pretreatmentNum * _tileHeight;

			_mapCols = Math.ceil(_mapWidth / _tileWidth);
			_mapRows = Math.ceil(_mapHeight / _tileHeight);

			_mapName = _config.@name;
			_smallMapResourceId = _config.sm.@url;
			_smallMapVersion = String(_config.sm.@version);
		}

		public function run() : void
		{
			_updatable = true;
		}

		protected function initMapData() : void
		{
			_blackBitmapData = new BitmapData(_tileWidth, _tileHeight, _transparent, 0);
			updateBufferSize();
		}

		/**
		 * 执行该函数之前必须先调用 initMap
		 * @param inited
		 */
		public function loadSmallMap(inited : Function = null) : void
		{
			_inited = inited;
			if (_smallMapResourceId)
			{
				_smallMapParser = new SMapResourceParser(_smallMapResourceId, _smallMapVersion);
				_smallMapParser.onComplete(onSmallMapParserComplete);
				_smallMapParser.load();
			}
			
			//预先  
			_smallPreviewerMapParser = SReferenceManager.getInstance().createImageParser(_config.bm.@url, SLoadPriorityType.MAP);
			_smallPreviewerMapParser.load();
		}

		private function onSmallMapParserComplete(res : SMapResourceParser) : void
		{
			_smallMapBitmapData = res.bitmapData;
			if (_inited != null)
			{
				_inited();
				_inited = null;
			}
			_lastStartTileX = -1;
			_lastStartTileY = -1;
			_lastViewX = -1;
			_lastViewY = -1;
			refreshBuffer();
		}

		/**
		 * 屏幕大小 改变
		 * @param w
		 * @param h
		 *
		 */
		public function resize(w : int, h : int) : void
		{
			setViewSize(w, h);
		}

		/**
		 * 设置地图可滚动的边界区域
		 * @param left
		 * @param top
		 * @param right
		 * @param bottom
		 *
		 */
		protected function setScrollBorder(left : int, top : int, right : int, bottom : int) : void
		{
			left = left < 0 ? 0 : left;
			right = right == 0 ? _mapWidth : right;
			right = right > _mapWidth ? _mapWidth : right;
			top = top < 0 ? 0 : top;
			bottom = bottom == 0 ? _mapHeight : bottom;
			bottom = bottom > _mapHeight ? _mapHeight : bottom;

			_leftBorder = left;
			_topBorder = top;
			_rightBorder = right;
			_bottomBorder = bottom;

			_leftCols = Math.ceil(_leftBorder / _tileWidth);
			_topRows = Math.ceil(_topBorder / _tileHeight);
			_rightCols = Math.ceil(_rightBorder / _tileWidth);
			_bottomRows = Math.ceil(_bottomBorder / _tileHeight);
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

			_viewRect.x = 0;
			_viewRect.y = 0;
			_viewRect.width = _viewWidth;
			_viewRect.height = _viewHeight;
			_screenRect.x = 0;
			_screenRect.y = 0;
			_screenRect.width = _viewWidth;
			_screenRect.height = _viewHeight;
			updateBufferSize();
			if (_updatable)
				updateCamera();
		}

		private function updateBufferSize() : void
		{
			_bufferCols = Math.ceil(_viewWidth / _tileWidth);
			_bufferRows = Math.ceil(_viewHeight / _tileHeight);

			if (_bufferCols > 0 && _bufferRows > 0)
			{
				clearBuffer();

				_lastStartTileX = -1;
				_lastStartTileY = -1;
				_lastViewX = -1;
				_lastViewY = -1;
			}
		}

		protected function onTileResourceParserComplete(res : SMapResourceParser) : void
		{
			var tileId : String = res.id;
			var loadTilePos : Point = getLoadTilePos(tileId);
			var blackBmd : IBitmap = _blackTitles[loadTilePos.x + "," + loadTilePos.y];
			blackBmd && blackBmd.removeChild();
			var bd : IBitmap = res.bitmap;
			if (bd)
			{
				parserCompleteDrawTile(bd, loadTilePos.x, loadTilePos.y);
			}
			else
			{
					SDebug.warning(this, "地图块数据为空！");
			}
		}

		protected var _loadTilePos : Point = new Point();

		protected function getLoadTilePos(tileId : String) : Point
		{
			var loadTileX : int = SCommonUtil.getXFromInt(parseInt(tileId, 36)) - 1;
			var loadTileY : int = SCommonUtil.getYFromInt(parseInt(tileId, 36)) - 1;
			_loadTilePos.x = loadTileX;
			_loadTilePos.y = loadTileY;
			return _loadTilePos;
		}

		/**
		 * 释放指定x,y索引处的地图区块位图
		 * @param tileX
		 * @param tileY
		 *
		 */
		protected function clearTile(tileX : int, tileY : int) : void
		{
			if (tileX < 0 || tileY < 0)
				return;
			if (tileX >= 0 && tileX <= _mapCols && tileY >= 0 && tileY <= _mapRows)
			{
				var tileId : String = getTileId(tileX, tileY);
				var tile : SMapTile = _tiles.getValue(tileId);
				if (tile)
				{
					_tiles.deleteValue(tileId);
					tile.removeOnComplete(onTileResourceParserComplete);
					tile.destroy();
				}
			}
			else
			{
					SDebug.warning(this, "地图删除区域不在范围内！");
			}
		}

		private function getTileId(tileX : int, tileY : int) : String
		{
			var resId : String = getTileResId(tileX, tileY);
			return _mapName + _id + resId;
		}

		protected function getTileResId(tileX : int, tileY : int) : String
		{
			var resTx : int = tileX - int(tileX / _rightCols) * _rightCols;
			var resTy : int = tileY - int(tileY / _bottomRows) * _bottomRows;
			var resId : String = SCommonUtil.xyToInt(resTx + 1, resTy + 1).toString(36);
			return resId;
		}

		protected function createMapTile(tileX : int, tileY : int) : Boolean
		{
			var startX : int = _startTileX - _pretreatmentNum;
			var endX : int = _startTileX + _bufferCols + _pretreatmentNum;
			var startY : int = _startTileY - _pretreatmentNum;
			var endY : int = _startTileY + _bufferRows + _pretreatmentNum;

			if (startX >= -_pretreatmentNum && endX >= -_pretreatmentNum && tileX >= startX && tileX <= endX && startY >= -_pretreatmentNum && endY >= -_pretreatmentNum && tileY >= startY && tileY <= endY)
			{
				var tileId : String = getTileId(tileX, tileY);
				var tile : SMapTile = _tiles.getValue(tileId);
				if (!tile)
				{
					var resId : String = getTileResId(tileX, tileY);
					var data : Object = _fileVersions[resId];
					if (data)
					{
						var tileUrl : String = data.url;
						var version : String = data.version;
						tile = new SMapTile(SMapResourceParser, tileId, resId, tileUrl, SLoadPriorityType.MAP, version);
						_tiles.setValue(tileId, tile);
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
			var created : Boolean = createMapTile(tileX, tileY);

			if (created)
			{
				drawTileBitmapData(tileX, tileY);
			}
		}

		protected function drawTileBitmapData(tileX : int, tileY : int) : void
		{
			var tileId : String = getTileId(tileX, tileY);
			var tile : SMapTile = _tiles.getValue(tileId);
			if (!tile || !tile.isLoaded)
			{
				var blackBmd : IBitmap = _blackTitles[tileX + "," + tileY];
				if (blackBmd == null)
				{
					if (_smallMapBitmapData)
						createMosaicTile(tileX, tileY);
					if (Config.supportDirectX)
					{
						//blackBmd = new SDirectBitmap(SDirectBitmapData.fromDirectBitmapData(_blackBitmapData));
						//blackBmd.blendMode = BlendMode.NONE;
					}
					else
						blackBmd = new SRenderBitmap(_blackBitmapData.clone());
					_blackTitles[tileX + "," + tileY] = blackBmd;
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
				var tileId : String = getTileId(tileX, tileY);
				var tile : SMapTile = _tiles.getValue(tileId);
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
			if (_smallMapBitmapData)
			{
				_blackBitmapData.fillRect(_blackBitmapData.rect, 0);
				var resTx : int = tileX - int(tileX / _rightCols) * _rightCols;
				var resTy : int = tileY - int(tileY / _bottomRows) * _bottomRows;
				var tx : Number = (resTx * _tileWidth) * Config.SMALL_MAP_SCALE;
				var ty : Number = (resTy * _tileHeight) * Config.SMALL_MAP_SCALE;
				var scale : Number = Config.SMALL_MAP_SCALE * 100;
				_mosaicMatrix.identity();
				_mosaicMatrix.translate(-tx, -ty);
				_mosaicMatrix.scale(scale, scale);
				_blackBitmapData.draw(_smallMapBitmapData, _mosaicMatrix);
			}
		}

		protected function parserCompleteDrawTile(bitmap : IBitmap, tileX : int, tileY : int) : void
		{
			if (bitmap)
			{
				drawTile(bitmap, tileX, tileY);
			}
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
		 * 设置焦点
		 * @param tx
		 * @param ty
		 *
		 */
		public function focus(viewX : Number, viewY : Number) : void
		{
			_viewX = viewX;
			_viewY = viewY;

			if (!_updatable)
				return;

			var isRefreshScreen : Boolean = true;
			if (viewX == _lastViewX && viewY == _lastViewY)
			{
				isRefreshScreen = false;
			}

			_lastViewX = viewX;
			_lastViewY = viewY;

			if (isRefreshScreen)
			{
				// 计算出缓冲区开始的区块索引
				_startTileX = int(viewX / _tileWidth);
				_startTileY = int(viewY / _tileHeight);

				_screenRect.x = viewX;
				_screenRect.y = viewY;

				var isRefreshBuffer : Boolean = true;
				_offsetPoint.x = viewX % _tileWidth; //剩余值
				_offsetPoint.y = viewY % _tileHeight;

				// 如果缓冲区的区块索引与上一帧相同，则本帧无需刷新缓冲区
				var tileXDelta : int = _startTileX - _lastStartTileX;
				if (tileXDelta < 0)
					tileXDelta = -tileXDelta;
				var tileYDelta : int = _startTileY - _lastStartTileY;
				if (tileYDelta < 0)
					tileYDelta = -tileYDelta;
				if (tileXDelta == 0 && tileYDelta == 0)
				{
					isRefreshBuffer = false;
				}
				else if (tileXDelta > _bufferCols * 0.5 || tileYDelta > _bufferRows * 0.5) //移动超过半屏当做是切换镜头
				{
					_lastStartTileX = -1;
					_lastStartTileY = -1;
				}

				_viewRect.x = _offsetPoint.x + _pretreatmentWidth;
				_viewRect.y = _offsetPoint.y + _pretreatmentHeight;
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

		/**
		 * 刷新缓冲区
		 *
		 */
		protected function refreshBuffer() : void
		{
			if (!_updatable)
				return;

			//如果是滚动刷新缓冲区
			if (_lastStartTileX == -1 && _lastStartTileY == -1) //填充全部
			{
				clearBuffer();
			}

			//将缓冲区对应的地图区块读入缓冲区中 
			clearPeripheral();
			fillInternal();
		}

		private function fillReject(centerX : Number, centerY : Number, x : int, y : int) : Boolean
		{
			var colmnsCount : int = centerX + x;
			var rowCount : int = centerY + y;

			var startRow : int;
			var endRow : int;
			var startColmns : int;
			var endColmns : int;

			startRow = -_pretreatmentNum + _startTileY;
			if (startRow < 0)
				startRow = 0;
			endRow = _bufferRows + _pretreatmentNum + _startTileY;
			if (endRow > _mapRows)
				endRow = _mapRows;

			startColmns = -_pretreatmentNum + _startTileX;
			if (startColmns < 0)
				startColmns = 0;
			endColmns = _bufferCols + _pretreatmentNum + _startTileX;
			if (endColmns > _mapCols)
				endColmns = _mapCols;

			if (colmnsCount >= startColmns && colmnsCount < endColmns && rowCount >= startRow && rowCount < endRow)
				return false;
			return true;
		}

		private function fillProcess(centerX : Number, centerY : Number, x : int, y : int) : void
		{
			var colmnsCount : int = centerX + x;
			var rowCount : int = centerY + y;
			copyTileBitmapData(colmnsCount, rowCount);
		}

		/**
		 * 填充内部
		 * @param colmnsCount
		 * @param rowCount
		 *
		 */
		private function fillInternal() : void
		{
			var startRow : int;
			var endRow : int;
			var startColmns : int;
			var endColmns : int;
			var rowCount : int;
			var colmnsCount : int;
			if (_lastStartTileX == -1 && _lastStartTileY == -1) //填充全部
			{
				startRow = -_pretreatmentNum + _startTileY;
				if (startRow < 0)
					startRow = 0;
				endRow = _bufferRows + _pretreatmentNum + _startTileY;
				if (endRow > _mapRows)
					endRow = _mapRows;

				startColmns = -_pretreatmentNum + _startTileX;
				if (startColmns < 0)
					startColmns = 0;
				endColmns = _bufferCols + _pretreatmentNum + _startTileX;
				if (endColmns > _mapCols)
					endColmns = _mapCols;

				var gridColumns : int = endColmns - startColmns;
				if (gridColumns < 0)
					gridColumns = 0;
				var gridRows : int = endRow - startRow;
				if (gridRows < 0)
					gridRows = 0;
				var r : int = gridColumns > gridRows ? gridColumns : gridRows;
				var halfR : Number = r / 2;
				var centerX : Number = startColmns + gridColumns / 2;
				var centerY : Number = startRow + gridRows / 2;

			//	SArrayUtil.getRectangularSpiralArray(centerX, centerY, halfR, fillReject, fillProcess);
			}
			else //填充局部
			{
				var tileXDelta : int = _startTileX - _lastStartTileX;
				var tileYDelta : int = _startTileY - _lastStartTileY;

				if (tileYDelta > 0) //下边新增
				{
					startRow = (_bufferRows - tileYDelta) + _pretreatmentNum + _startTileY;

					if (startRow < _startTileY - _pretreatmentNum)
						startRow = _startTileY - _pretreatmentNum;
					else if (startRow > _startTileY + _bufferRows + _pretreatmentNum)
						startRow = _startTileY + _bufferRows + _pretreatmentNum;
					if (startRow < 0)
						startRow = 0;
					else if (startRow > _mapRows)
						startRow = _mapRows;

					endRow = _bufferRows + _pretreatmentNum + _startTileY;
					if (endRow > _mapRows)
						endRow = _mapRows;

					startColmns = -_pretreatmentNum + _startTileX;
					if (startColmns < 0)
						startColmns = 0;
					endColmns = _bufferCols + _pretreatmentNum + _startTileX;
					if (endColmns > _mapCols)
						endColmns = _mapCols;

					for (rowCount = startRow; rowCount < endRow; rowCount++) //从上到下 
					{
						for (colmnsCount = endColmns - 1; colmnsCount >= startColmns; colmnsCount--) //顺时针则从右到左 
						{
							copyTileBitmapData(colmnsCount, rowCount);
						}
					}
				}
				else if (tileYDelta < 0) //上边新增
				{
					tileYDelta = -tileYDelta;

					startRow = -_pretreatmentNum + _startTileY;
					if (startRow < 0)
						startRow = 0;
					endRow = tileYDelta - _pretreatmentNum + _startTileY;

					if (endRow < _startTileY - _pretreatmentNum)
						endRow = _startTileY - _pretreatmentNum;
					else if (endRow > _startTileY + _bufferRows + _pretreatmentNum)
						endRow = _startTileY + _bufferRows + _pretreatmentNum;
					if (endRow < 0)
						endRow = 0;
					else if (endRow > _mapRows)
						endRow = _mapRows;

					startColmns = -_pretreatmentNum + _startTileX;
					if (startColmns < 0)
						startColmns = 0;
					endColmns = _bufferCols + _pretreatmentNum + _startTileX;
					if (endColmns > _mapCols)
						endColmns = _mapCols;

					for (rowCount = endRow - 1; rowCount >= startRow; rowCount--) //从下到上
					{
						for (colmnsCount = startColmns; colmnsCount < endColmns; colmnsCount++) //顺时针则从左到右
						{
							copyTileBitmapData(colmnsCount, rowCount);
						}
					}
				}

				if (tileXDelta > 0) //右边新增
				{
					startRow = -_pretreatmentNum + _startTileY;
					if (startRow < 0)
						startRow = 0;
					endRow = _bufferRows + _pretreatmentNum + _startTileY;
					if (endRow > _mapRows)
						endRow = _mapRows;

					startColmns = (_bufferCols - tileXDelta) + _pretreatmentNum + _startTileX;

					if (startColmns < _startTileX - _pretreatmentNum)
						startColmns = _startTileX - _pretreatmentNum;
					else if (startColmns > _startTileX + _bufferCols + _pretreatmentNum)
						startColmns = _startTileX + _bufferCols + _pretreatmentNum;
					if (startColmns < 0)
						startColmns = 0;
					else if (startColmns > _mapCols)
						startColmns = _mapCols;

					endColmns = _bufferCols + _pretreatmentNum + _startTileX;
					if (endColmns > _mapCols)
						endColmns = _mapCols;

					for (rowCount = startRow; rowCount < endRow; rowCount++) //顺时针则从上到下
					{
						for (colmnsCount = startColmns; colmnsCount < endColmns; colmnsCount++) //从左到右
						{
							copyTileBitmapData(colmnsCount, rowCount);
						}
					}
				}
				else if (tileXDelta < 0) //左边新增
				{
					tileXDelta = -tileXDelta;

					startRow = -_pretreatmentNum + _startTileY;
					if (startRow < 0)
						startRow = 0;
					endRow = _bufferRows + _pretreatmentNum + _startTileY;
					if (endRow > _mapRows)
						endRow = _mapRows;

					startColmns = -_pretreatmentNum + _startTileX;
					if (startColmns < 0)
						startColmns = 0;
					endColmns = tileXDelta - _pretreatmentNum + _startTileX;

					if (endColmns < _startTileX - _pretreatmentNum)
						endColmns = _startTileX - _pretreatmentNum;
					else if (endColmns > _startTileX + _bufferCols + _pretreatmentNum)
						endColmns = _startTileX + _bufferCols + _pretreatmentNum;
					if (endColmns < 0)
						endColmns = 0;
					else if (endColmns > _mapCols)
						endColmns = _mapCols;

					for (rowCount = endRow - 1; rowCount >= startRow; rowCount--) //顺时针则从下到上
					{
						for (colmnsCount = endColmns - 1; colmnsCount >= startColmns; colmnsCount--) //从右到左
						{
							copyTileBitmapData(colmnsCount, rowCount);
						}
					}
				}
			}
		}

		/**
		 * 清除不在缓冲区中的地图区块位图（外围）
		 * @param rowCount
		 * @param colmnsCount
		 *
		 */
		private function clearPeripheral() : void
		{
			var startRow : int;
			var endRow : int;
			var startColmns : int;
			var endColmns : int;
			var rowCount : int;
			var colmnsCount : int;
			if (_lastStartTileX == -1 && _lastStartTileY == -1) //清除全部
			{
				//上方
				startRow = 0;
				endRow = _startTileY - _pretreatmentNum;

				startColmns = 0;
				endColmns = _mapCols;

				for (rowCount = startRow; rowCount < endRow; rowCount++)
				{
					for (colmnsCount = startColmns; colmnsCount < endColmns; colmnsCount++)
					{
						clearTile(colmnsCount, rowCount);
					}
				}

				//下方
				startRow = _bufferRows + _pretreatmentNum + _startTileY;
				endRow = _mapRows;

				startColmns = 0;
				endColmns = _mapCols;

				for (rowCount = startRow; rowCount < endRow; rowCount++)
				{
					for (colmnsCount = startColmns; colmnsCount < endColmns; colmnsCount++)
					{
						clearTile(colmnsCount, rowCount);
					}
				}

				//左方
				startRow = 0;
				endRow = _mapRows;

				startColmns = 0;
				endColmns = _startTileX - _pretreatmentNum;

				for (rowCount = startRow; rowCount < endRow; rowCount++)
				{
					for (colmnsCount = startColmns; colmnsCount < endColmns; colmnsCount++)
					{
						clearTile(colmnsCount, rowCount);
					}
				}

				//右方
				startRow = 0;
				endRow = _mapRows;

				startColmns = _bufferCols + _pretreatmentNum + _startTileX;
				endColmns = _mapCols;

				for (rowCount = startRow; rowCount < endRow; rowCount++)
				{
					for (colmnsCount = startColmns; colmnsCount < endColmns; colmnsCount++)
					{
						clearTile(colmnsCount, rowCount);
					}
				}
			}
			else //清除局部
			{
				var tileXDelta : int = _startTileX - _lastStartTileX;
				var tileYDelta : int = _startTileY - _lastStartTileY;

				if (tileYDelta < 0) //清除缓冲区下方几排
				{
					startRow = _bufferRows + _pretreatmentNum + _startTileY;
					endRow = _bufferRows + _pretreatmentNum + _startTileY - tileYDelta;

					if (tileXDelta < 0) //右方
					{
						startColmns = _startTileX - _pretreatmentNum;
						endColmns = _bufferCols + _startTileX + _pretreatmentNum - tileXDelta;
					}
					else //左方
					{
						startColmns = _startTileX - _pretreatmentNum - tileXDelta;
						endColmns = _bufferCols + _startTileX + _pretreatmentNum;
					}

					for (rowCount = startRow; rowCount < endRow; rowCount++)
					{
						for (colmnsCount = startColmns; colmnsCount < endColmns; colmnsCount++)
						{
							clearTile(colmnsCount, rowCount);
						}
					}
				}
				else if (tileYDelta > 0) //清除缓冲区上方几排
				{
					startRow = _startTileY - _pretreatmentNum - tileYDelta;
					endRow = _startTileY - _pretreatmentNum;

					if (tileXDelta < 0) //右方
					{
						startColmns = _startTileX - _pretreatmentNum;
						endColmns = _bufferCols + _startTileX + _pretreatmentNum - tileXDelta;
					}
					else //左方
					{
						startColmns = _startTileX - _pretreatmentNum - tileXDelta;
						endColmns = _bufferCols + _startTileX + _pretreatmentNum;
					}

					for (rowCount = startRow; rowCount < endRow; rowCount++)
					{
						for (colmnsCount = startColmns; colmnsCount < endColmns; colmnsCount++)
						{
							clearTile(colmnsCount, rowCount);
						}
					}
				}

				if (tileXDelta < 0) //清除缓冲区右方几排
				{
					if (tileYDelta < 0) //下方
					{
						startRow = _startTileY - _pretreatmentNum;
						endRow = _bufferRows + _startTileY + _pretreatmentNum - tileYDelta;
					}
					else //上方
					{
						startRow = _startTileY - _pretreatmentNum - tileYDelta;
						endRow = _bufferRows + _startTileY + _pretreatmentNum;
					}

					startColmns = _bufferCols + _pretreatmentNum + _startTileX;
					endColmns = _bufferCols + _pretreatmentNum + _startTileX - tileXDelta;

					for (rowCount = startRow; rowCount < endRow; rowCount++)
					{
						for (colmnsCount = startColmns; colmnsCount < endColmns; colmnsCount++)
						{
							clearTile(colmnsCount, rowCount);
						}
					}
				}
				else if (tileXDelta > 0) //清除缓冲区左方几排
				{
					if (tileYDelta < 0) //下方
					{
						startRow = _startTileY - _pretreatmentNum;
						endRow = _bufferRows + _startTileY + _pretreatmentNum - tileYDelta;
					}
					else //上方
					{
						startRow = _startTileY - _pretreatmentNum - tileYDelta;
						endRow = _bufferRows + _startTileY + _pretreatmentNum;
					}

					startColmns = _startTileX - _pretreatmentNum - tileXDelta;
					endColmns = _startTileX - _pretreatmentNum;

					for (rowCount = startRow; rowCount < endRow; rowCount++)
					{
						for (colmnsCount = startColmns; colmnsCount < endColmns; colmnsCount++)
						{
							clearTile(colmnsCount, rowCount);
						}
					}
				}
			}
		}

		private function clearAllTiles() : void
		{
			for (var tileId : String in _tiles.dic)
			{
				var tile : SMapTile = _tiles.getValue(tileId);
				if (tile)
				{
					tile.removeOnComplete(onTileResourceParserComplete);
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

		private function clearBuffer() : void
		{
			for (var i : int = _container.numChildren - 1; i >= 0; i--)
			{
				_container.removeGameChildAt(i);
			}
		}

		public function setUpdatable(value : Boolean) : void
		{
			_updatable = value;
		}

		public function get smallMapBitmapData() : BitmapData
		{
			return _smallMapBitmapData;
		}

		public function get tiles() : Dictionary
		{
			return _tiles;
		}

		public function get tileParsersLen() : int
		{
			if (_tiles)
				return _tiles.length;
			return 0;
		}

		public function update(elapsedTime : int = 0) : void
		{
			if (!_updatable)
				return;
			updateCamera();
		}

		public function updateCamera() : void
		{
			//focus(SSceneRenderManagaer.getInstance().viewX, SSceneRenderManagaer.getInstance().viewY);
		}

		public function get isDisposed() : Boolean
		{
			return _isDisposed;
		}

		public function destroy() : void
		{
			if (_isDisposed)
				return;

			clear();
			if (_container)
			{
				clearBuffer();
				_container = null;
			}

			if (_blackBitmapData)
			{
				_blackBitmapData.dispose();
				_blackBitmapData = null;
			}

			_viewRect = null;
			_offsetPoint = null;

			_isDisposed = true;
		}

		public function get leftBorder() : int
		{
			return _leftBorder;
		}

		public function get topBorder() : int
		{
			return _topBorder;
		}

		public function get rightBorder() : int
		{
			return _rightBorder;
		}

		public function get bottomBorder() : int
		{
			return _bottomBorder;
		}

		/**
		 * 区块高度
		 */
		public function get tileHeight() : int
		{
			return _tileHeight;
		}

		/**
		 * 区块宽度
		 */
		public function get tileWidth() : int
		{
			return _tileWidth;
		}

		public function get bufferBitmap() : IContainer
		{
			return _container;
		}

		public function get mapName() : String
		{
			return _mapName;
		}

		public function get viewWidth() : int
		{
			return _viewWidth;
		}

		public function get viewHeight() : int
		{
			return _viewHeight;
		}

		public function get viewX() : int
		{
			return _viewX;
		}

		public function get viewY() : int
		{
			return _viewY;
		}

		public function get mapCols() : int
		{
			return _mapCols;
		}

		public function get mapRows() : int
		{
			return _mapRows;
		}

		public function get validMapWidth() : int
		{
			return _rightBorder - _leftBorder;
		}

		public function get validMapHeight() : int
		{
			return _bottomBorder - _topBorder;
		}

		public function get config() : XML
		{
			return _config;
		}
	}
}