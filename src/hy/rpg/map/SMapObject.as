package hy.rpg.map
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	import hy.game.cfg.Config;
	import hy.game.core.GameObject;
	import hy.game.core.SCamera;
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
		private var m_camera : SCamera;
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
			m_camera = SCamera.getInstance();
			_tiles = new Dictionary();
			_blackTitles = new Dictionary();
			super();
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

			setViewSize(Config.screenWidth, Config.screenHeight);

			_tileWidth = Config.TILE_WIDTH;
			_tileHeight = Config.TILE_HEIGHT;

			_mapTotalX = Math.ceil(_mapWidth / _tileWidth);
			_mapTotalY = Math.ceil(_mapHeight / _tileHeight);

			_mapName = _config.@name;
			loadSmallMap(_config.sm.@url, String(_config.sm.@version));
			loadPreviewMap(_config.bm.@url);
		}

		protected function initMapData() : void
		{
			_blackBitmapData = new BitmapData(_tileWidth, _tileHeight, _transparent, 0);
			updateBufferSize();
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
			refreshBuffer();
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
			var loadTilePos : Point = decoderTileId(res.id);
			var blackBmd : IBitmap = _blackTitles[res.id];
			blackBmd && blackBmd.removeChild();
			var bd : IBitmap = res.bitmap;
			if (bd)
			{
				drawTile(bd, loadTilePos.x, loadTilePos.y);
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
						var tileUrl : String = data.url;
						var version : String = data.version;
						tile = new SMapTile(SMapResourceParser, _mapName + tileId, resId, tileUrl, SLoadPriorityType.MAP, version);
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
			var created : Boolean = createMapTile(tileX, tileY);

			if (created)
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
		 * 设置焦点
		 * @param tx
		 * @param ty
		 *
		 */
		public function focus(viewX : Number, viewY : Number) : void
		{
			var isRefreshScreen : Boolean = true; //是否需要刷新屏幕
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

		/**
		 * 刷新缓冲区
		 *
		 */
		protected function refreshBuffer() : void
		{
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
			if (endRow > _mapTotalY)
				endRow = _mapTotalY;

			startColmns = -_pretreatmentNum + _startTileX;
			if (startColmns < 0)
				startColmns = 0;
			endColmns = _bufferCols + _pretreatmentNum + _startTileX;
			if (endColmns > _mapTotalX)
				endColmns = _mapTotalX;

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
				if (endRow > _mapTotalY)
					endRow = _mapTotalY;

				startColmns = -_pretreatmentNum + _startTileX;
				if (startColmns < 0)
					startColmns = 0;
				endColmns = _bufferCols + _pretreatmentNum + _startTileX;
				if (endColmns > _mapTotalX)
					endColmns = _mapTotalX;

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
					else if (startRow > _mapTotalY)
						startRow = _mapTotalY;

					endRow = _bufferRows + _pretreatmentNum + _startTileY;
					if (endRow > _mapTotalY)
						endRow = _mapTotalY;

					startColmns = -_pretreatmentNum + _startTileX;
					if (startColmns < 0)
						startColmns = 0;
					endColmns = _bufferCols + _pretreatmentNum + _startTileX;
					if (endColmns > _mapTotalX)
						endColmns = _mapTotalX;

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
					else if (endRow > _mapTotalY)
						endRow = _mapTotalY;

					startColmns = -_pretreatmentNum + _startTileX;
					if (startColmns < 0)
						startColmns = 0;
					endColmns = _bufferCols + _pretreatmentNum + _startTileX;
					if (endColmns > _mapTotalX)
						endColmns = _mapTotalX;

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
					if (endRow > _mapTotalY)
						endRow = _mapTotalY;

					startColmns = (_bufferCols - tileXDelta) + _pretreatmentNum + _startTileX;

					if (startColmns < _startTileX - _pretreatmentNum)
						startColmns = _startTileX - _pretreatmentNum;
					else if (startColmns > _startTileX + _bufferCols + _pretreatmentNum)
						startColmns = _startTileX + _bufferCols + _pretreatmentNum;
					if (startColmns < 0)
						startColmns = 0;
					else if (startColmns > _mapTotalX)
						startColmns = _mapTotalX;

					endColmns = _bufferCols + _pretreatmentNum + _startTileX;
					if (endColmns > _mapTotalX)
						endColmns = _mapTotalX;

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
					if (endRow > _mapTotalY)
						endRow = _mapTotalY;

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
					else if (endColmns > _mapTotalX)
						endColmns = _mapTotalX;

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
				endColmns = _mapTotalX;

				for (rowCount = startRow; rowCount < endRow; rowCount++)
				{
					for (colmnsCount = startColmns; colmnsCount < endColmns; colmnsCount++)
					{
						clearTile(colmnsCount, rowCount);
					}
				}

				//下方
				startRow = _bufferRows + _pretreatmentNum + _startTileY;
				endRow = _mapTotalY;

				startColmns = 0;
				endColmns = _mapTotalX;

				for (rowCount = startRow; rowCount < endRow; rowCount++)
				{
					for (colmnsCount = startColmns; colmnsCount < endColmns; colmnsCount++)
					{
						clearTile(colmnsCount, rowCount);
					}
				}

				//左方
				startRow = 0;
				endRow = _mapTotalY;

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
				endRow = _mapTotalY;

				startColmns = _bufferCols + _pretreatmentNum + _startTileX;
				endColmns = _mapTotalX;

				for (rowCount = startRow; rowCount < endRow; rowCount++)
				{
					for (colmnsCount = startColmns; colmnsCount < endColmns; colmnsCount++)
					{
						clearTile(colmnsCount, rowCount);
					}
				}
				return;
			}
			//清除局部

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


		override public function update() : void
		{
			updateCamera();
		}

		public function updateCamera() : void
		{
			//focus(SSceneRenderManagaer.getInstance().viewX, SSceneRenderManagaer.getInstance().viewY);
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
				clearBuffer();
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