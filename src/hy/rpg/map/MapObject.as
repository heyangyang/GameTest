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
	import hy.rpg.enum.EnumLoadPriority;
	import hy.rpg.parser.ParserImageResource;
	import hy.rpg.parser.ParserMapResource;
	import hy.rpg.seek.SRoadSeeker;
	import hy.rpg.utils.UtilsCommon;

	/**
	 * 地图
	 *
	 */
	public class MapObject extends GameObject
	{
		/**
		 * 地图宽高
		 */
		protected var m_mapWidth : int;
		protected var m_mapHeight : int;

		/**
		 * 地图总列数/行数
		 */
		protected var m_mapCols : int;
		protected var m_mapRows : int;

		/**
		 * 每个格子的宽高
		 */
		protected var m_tileWidth : int;
		protected var m_tileHeight : int;

		/**
		 * 缓冲区列数/行数
		 */
		protected var m_bufferCols : int;
		protected var m_bufferRows : int;
		/**
		 * 可视区域宽高度
		 */
		protected var m_viewWidth : int;
		protected var m_viewHeight : int;

		/**
		 * 未加载时的地图黑块
		 */
		private var m_blackBitmapData : BitmapData;

		/**
		 * 容器
		 */
		protected var m_container : IContainer;

		/**
		 * 用于坐标记录
		 */
		private var m_loadTilePos : Point = new Point();
		/**
		 * 地图配置文件
		 */
		protected var m_config : XML;

		/**
		 * 地址版本信息
		 */
		private var m_fileVersions : Dictionary;

		/**
		 *  小地图
		 */
		protected var m_smallMapBitmapData : BitmapData;
		protected var m_smallMapParser : ParserMapResource;
		protected var m_mosaicMatrix : Matrix = new Matrix();

		/**
		 * 小地图
		 */
		protected var m_smallPreviewerMapParser : ParserImageResource;
		/**
		 * 保存加载过的地图块位图
		 */
		protected var m_tiles : Dictionary;
		/**
		 * 保存未加载马赛克
		 */
		private var m_blackTitles : Dictionary;

		/**
		 * 上一帧的缓冲区起始X索引
		 */
		private var m_lastStartTileCol : int;

		/**
		 * 上一帧的缓冲区起始Y索引
		 */
		private var m_lastStartTileRow : int;

		/**
		 * 上一帧的屏幕偏移X值
		 */
		private var m_lastViewX : Number;

		/**
		 * 上一帧的屏幕偏移Y值
		 */
		private var m_lastViewY : Number;

		/**
		 * 当前帧的缓冲区起始X索引
		 */
		protected var m_startTileCol : int;

		/**
		 * 当前帧的缓冲区起始Y索引
		 */
		protected var m_startTileRow : int;

		/**
		 * 缓冲区域大小
		 */
		private var m_pretreatmentNum : int = 1;

		/**
		 * 摄像头
		 */
		private var m_camera : SCameraObject;
		/**
		 * 小地图缩放
		 */
		private var m_scale : Number;

		/**
		 * 地图id
		 */
		private var m_mapId : String;
		/**
		 * 配置文件加载完毕
		 */
		private var m_onConfigComplete : Function;
		/**
		 * 进度条
		 */
		private var m_onProgress : Function;
		private var m_maxMultiDistance : int;

		public function MapObject(min_scale : Number)
		{
			m_scale = min_scale;

			if (Config.supportDirectX)
			{
//				_container = new SDirectContainer();
			}
			else
			{
				m_container = new SRenderContainer();
				SRenderContainer(m_container).mouseChildren = false;
			}
			m_camera = SCameraObject.getInstance();
			m_tiles = new Dictionary();
			m_blackTitles = new Dictionary();
			super();
		}

		override public function registerd(priority : int = 0) : void
		{
			super.registerd(priority);
			addContainer(m_container);
			removeRender(m_render);
		}

		override public function unRegisterd() : void
		{
			super.unRegisterd();
			removeContainer(m_container);
		}

		/**
		 * 初始化地图
		 * @param id
		 * @param onComplete
		 * @param inited
		 *
		 */
		public function load(mapId : String, onComplete : Function = null, onProgress : Function = null) : void
		{
			if (m_mapId == mapId)
				return;
			clear();
			m_mapId = mapId;
			m_onConfigComplete = onComplete;
			m_onProgress = onProgress;
			SReferenceManager.getInstance().createResource(m_mapId).addNotifyCompleted(onConfigComplete).addNotifyProgress(onProgress).load();
		}

		/**
		 * 加载配置完成
		 * @param res
		 *
		 */
		private function onConfigComplete(res : SResource) : void
		{
			var bytes : ByteArray = res.getBinary();
			m_config = new XML(bytes.readUTFBytes(bytes.bytesAvailable));
			bytes.clear();
			parseMapData();
			if (!m_config.grid.@url)
			{
				warning("not find map block: " + m_mapId);
				return;
			}
			SReferenceManager.getInstance().createResource(m_config.grid.@url, m_config.grid.@version).addNotifyCompleted(onBlockComplete).addNotifyProgress(m_onProgress).load();
		}

		/**
		 * 初始化地图
		 *
		 */
		protected function parseMapData() : void
		{
			m_fileVersions = new Dictionary();
			for each (var tileXML : XML in m_config.tile)
			{
				m_fileVersions[String(tileXML.@id)] = {url: String(tileXML.@url), version: String(tileXML.@version)};
			}

			Config.BIG_MAP_SCALE = m_config.bm.@scale;

			m_maxMultiDistance = int(m_config.@multiDistance);
			if (m_maxMultiDistance < 1)
				m_maxMultiDistance = 1;

			// 从XML文件中获取地图基本信息
			m_mapWidth = m_config.@width;
			m_mapHeight = m_config.@height;

			//设置镜头的基本信息
			m_camera.setScreenSize(Config.screenWidth, Config.screenHeight);
			m_camera.setSceneSize(m_mapWidth, m_mapHeight);
			m_camera.updateRectangle(200, 200);

			m_tileWidth = Config.TILE_WIDTH;
			m_tileHeight = Config.TILE_HEIGHT;
			m_blackBitmapData = new BitmapData(m_tileWidth, m_tileHeight, false, 0);

			setViewSize(Config.screenWidth, Config.screenHeight);

			m_mapCols = Math.ceil(m_mapWidth / m_tileWidth);
			m_mapRows = Math.ceil(m_mapHeight / m_tileHeight);

			loadSmallMap(m_config.sm.@url, String(m_config.sm.@version));
			loadPreviewMap(m_config.bm.@url, m_config.bm.@version);
		}

		/**
		 * 加载阻挡块完毕
		 * @param res
		 *
		 */
		private function onBlockComplete(res : SResource) : void
		{
			var bytes : ByteArray = res.getBinary();
			var mapBlocks : Array = bytes.readObject() as Array;
			bytes.clear();
			if (!mapBlocks || mapBlocks.length == 0 || mapBlocks[0].length == 0)
			{
				error(this, "地图数据出现mapBlocks=" + mapBlocks ? mapBlocks.toString() : 'null');
			}
			updateBlocks(mapBlocks);
			m_onConfigComplete != null && m_onConfigComplete();
			m_onConfigComplete = null;
			m_onProgress = null;
		}

		private function updateBlocks(mapBlocks : Array = null) : void
		{
			if (!mapBlocks)
				return;
			if (m_maxMultiDistance > 1)
			{
				var multiBlocks : Array = [];
				var blockColumsLen : int = mapBlocks.length;
				var multiColumsLen : int = blockColumsLen * m_maxMultiDistance;
				var blockRowsLen : int = mapBlocks[0].length;
				var data : Array;
				var j : int;
				for (var i : int = 0; i < multiColumsLen; i++)
				{
					data = [];
					multiBlocks.push(data);
					for (j = 0; j < blockRowsLen; j++)
					{
						data.push(mapBlocks[i % blockColumsLen][j]);
					}
				}
				mapBlocks = multiBlocks;
			}
			SRoadSeeker.getInstance().init(mapBlocks);
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
			m_smallMapParser = new ParserMapResource(url, version);
			m_smallMapParser.onComplete(onSmallMapParserComplete);
			m_smallMapParser.load();
		}

		/**
		 * 预览小地图
		 * @param url
		 *
		 */
		private function loadPreviewMap(url : String, version : String) : void
		{
			if (!url)
				return;
			m_smallPreviewerMapParser && m_smallPreviewerMapParser.release();
			m_smallPreviewerMapParser = SReferenceManager.getInstance().createImageParser(url, version, EnumLoadPriority.MAP);
			m_smallPreviewerMapParser.load();
		}

		private function onSmallMapParserComplete(res : ParserMapResource) : void
		{
			m_smallMapBitmapData = res.bitmapData;
			resetMapBuffer();
		}

		/**
		 * 屏幕大小 改变
		 * @param w
		 * @param h
		 *
		 */
		public function setViewSize(viewWidth : int, viewHeight : int) : void
		{
			m_viewWidth = viewWidth;
			m_viewHeight = viewHeight;

			m_bufferCols = Math.ceil(m_viewWidth / m_tileWidth) + m_pretreatmentNum;
			m_bufferRows = Math.ceil(m_viewHeight / m_tileHeight) + m_pretreatmentNum;

			resetMapBuffer();
		}

		private function resetMapBuffer() : void
		{
			m_lastStartTileCol = -1;
			m_lastStartTileRow = -1;
			m_lastViewX = -1;
			m_lastViewY = -1;
		}

		protected function onTileResourceParserComplete(res : ParserMapResource) : void
		{
			var tileId : String = res.id.split("/").pop().split(".").shift();
			var loadTilePos : Point = decoderTileId(tileId);
			var blackBmd : IBitmap = m_blackTitles[tileId];
			blackBmd && blackBmd.removeChild();
			if (res.bitmap)
			{
				addChildTile(res.bitmap, loadTilePos.x, loadTilePos.y);
				return;
			}
			warning(this, "地图块数据为空！");
		}

		/**
		 * 释放指定x,y索引处的地图区块位图
		 * @param tileX
		 * @param tileY
		 *
		 */
		protected function clearTile(tileX : int, tileY : int) : void
		{
			if (tileX < 0 || tileY < 0 || tileX > m_mapCols || tileY > m_mapRows)
			{
				warning(this, "地图删除区域不在范围内！", tileX, tileY);
				return;
			}
			var tileId : String = encoderTileId(tileX, tileY);
			var tile : ParserMapResource = m_tiles[tileId];
			if (!tile)
				return;
			delete m_tiles[tileId];
			tile.release();
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
			return UtilsCommon.xyToInt(tileX + m_pretreatmentNum, tileY + m_pretreatmentNum).toString(36);
		}

		/**
		 * 解锁一个字符串成坐标
		 * @param tileId
		 * @return
		 *
		 */
		protected function decoderTileId(tileId : String) : Point
		{
			m_loadTilePos.x = UtilsCommon.getXFromInt(parseInt(tileId, 36)) - m_pretreatmentNum;
			m_loadTilePos.y = UtilsCommon.getYFromInt(parseInt(tileId, 36)) - m_pretreatmentNum;
			return m_loadTilePos;
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
			var startX : int = m_startTileCol - m_pretreatmentNum;
			var endX : int = m_startTileCol + m_bufferCols + m_pretreatmentNum;
			var startY : int = m_startTileRow - m_pretreatmentNum;
			var endY : int = m_startTileRow + m_bufferRows + m_pretreatmentNum;

			if (startX >= -m_pretreatmentNum && endX >= -m_pretreatmentNum && tileX >= startX && tileX <= endX && startY >= -m_pretreatmentNum && endY >= -m_pretreatmentNum && tileY >= startY && tileY <= endY)
			{
				var tileId : String = encoderTileId(tileX, tileY);
				var tile : ParserMapResource = m_tiles[tileId];
				if (!tile)
				{
					var data : Object = m_fileVersions[tileId];
					if (data)
					{
						tile = SReferenceManager.getInstance().createMapResourceParser(ParserMapResource, m_mapId + tileId, data.url, EnumLoadPriority.MAP, data.version);
						tile.onComplete(onTileResourceParserComplete);
						tile.load();
						m_tiles[tileId] = tile;
					}
					else
					{
						warning(this, "m_fileVersions is null : " + tileId);
						return;
					}

					var blackBmd : IBitmap = m_blackTitles[tileId];
					if (blackBmd == null)
					{
						createMosaicTile(tileX, tileY);
						if (Config.supportDirectX)
						{
							//blackBmd = new SDirectBitmap(SDirectBitmapData.fromDirectBitmapData(_blackBitmapData));
							//blackBmd.blendMode = BlendMode.NONE;
						}
						else
							blackBmd = new SRenderBitmap(m_blackBitmapData.clone());
						m_blackTitles[tileId] = blackBmd;
					}
					!tile.isLoaded && addChildTile(blackBmd, tileX, tileY);
					return;
				}
				if (tile.isLoaded)
				{
					onTileResourceParserComplete(tile);
					return;
				}

				if (tile.isLoading)
					return;
			}
			warning(this, "地图创建区域不在范围内！");
		}

		/**
		 * 为块添加马赛克效果，支持循环
		 * @param tileX
		 * @param tileY
		 *
		 */
		private function createMosaicTile(tileX : int, tileY : int) : void
		{
			if (!m_smallMapBitmapData)
				return;
			var tx : Number = (tileX * m_tileWidth) * m_scale;
			var ty : Number = (tileY * m_tileHeight) * m_scale;
			var scale : Number = m_scale * 100;
			m_mosaicMatrix.identity();
			m_mosaicMatrix.translate(-tx, -ty);
			m_mosaicMatrix.scale(scale, scale);
			m_blackBitmapData.draw(m_smallMapBitmapData, m_mosaicMatrix);
		}

		/**
		 * 把地图块放入到容器
		 * @param bitmap
		 * @param tileX
		 * @param tileY
		 *
		 */
		private function addChildTile(bitmap : IBitmap, tileX : int, tileY : int) : void
		{
			if (!bitmap)
				return;
			bitmap.x = tileX * m_tileWidth;
			bitmap.y = tileY * m_tileHeight;
			m_container.addGameChild(bitmap);
		}

		/**
		 * 刷新缓冲区
		 *
		 */
		protected function refreshBuffer() : void
		{
			//如果是滚动刷新缓冲区
			if (m_lastStartTileCol == -1 && m_lastStartTileRow == -1) //填充全部
			{
				clearAllBuffer();
			}

			var tileNeedFefresh : Boolean = false;
			var totalTileNum : int = 0;
			var colmnsCount : int;
			//将缓冲区对应的地图区块读入缓冲区中
			for (var rowCount : int = 0; rowCount < m_bufferRows; rowCount++)
			{
				for (colmnsCount = 0; colmnsCount < m_bufferCols; colmnsCount++)
				{
					tileNeedFefresh = checkIsNeedFefreshBuffer(rowCount, colmnsCount);
					if (tileNeedFefresh)
					{
						copyTileBitmapData(colmnsCount + m_startTileCol, rowCount + m_startTileRow);
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
			if ((m_lastStartTileCol == -1 && m_lastStartTileRow == -1))
			{
				return true;
			}
			//如果是滚动刷新缓冲区
			if (m_startTileCol - m_lastStartTileCol > 0)
			{
				if (colmnsCount + (m_startTileCol - m_lastStartTileCol) >= m_bufferCols)
				{
					return true;
				}
			}
			else if (m_startTileCol - m_lastStartTileCol < 0)
			{
				if (colmnsCount < m_lastStartTileCol - m_startTileCol)
				{
					return true;
				}
			}

			if (m_startTileRow - m_lastStartTileRow > 0)
			{
				if (rowCount + (m_startTileRow - m_lastStartTileRow) >= m_bufferRows)
				{
					return true;
				}
			}
			else if (m_startTileRow - m_lastStartTileRow < 0)
			{
				if (rowCount < m_lastStartTileRow - m_startTileRow)
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
			if (rowCount == 0 && m_startTileRow > 0)
			{
				clearTile(colmnsCount + m_startTileCol, rowCount + m_startTileRow - m_pretreatmentNum);
				if (m_startTileCol > 0 && colmnsCount == 0)
				{
					clearTile(colmnsCount + m_startTileCol - m_pretreatmentNum, rowCount + m_startTileRow - m_pretreatmentNum);
				}
				if (m_startTileCol < m_mapCols - m_bufferCols && colmnsCount == m_bufferCols - m_pretreatmentNum)
				{
					clearTile(colmnsCount + m_startTileCol + m_pretreatmentNum, rowCount + m_startTileRow - m_pretreatmentNum);
				}
			}
			//清除缓冲区下方一排
			if (rowCount == m_bufferRows - m_pretreatmentNum && m_startTileRow < m_mapRows - m_bufferRows)
			{
				clearTile(colmnsCount + m_startTileCol, rowCount + m_startTileRow + m_pretreatmentNum);
				if (m_startTileCol > 0 && colmnsCount == 0)
				{
					clearTile(colmnsCount + m_startTileCol - m_pretreatmentNum, rowCount + m_startTileRow + m_pretreatmentNum);
				}
				if (m_startTileCol < m_mapCols - m_bufferCols && colmnsCount == m_bufferCols - m_pretreatmentNum)
				{
					clearTile(colmnsCount + m_startTileCol + m_pretreatmentNum, rowCount + m_startTileRow - m_pretreatmentNum);
				}
			}
			//清除缓冲区左方一排
			if (colmnsCount == 0 && m_startTileCol > 0)
			{
				clearTile(colmnsCount + m_startTileCol - m_pretreatmentNum, rowCount + m_startTileRow);
			}
			//清除缓冲区右方一排
			if (colmnsCount == m_bufferCols - m_pretreatmentNum && m_startTileCol < m_mapCols - m_bufferCols)
			{
				clearTile(colmnsCount + m_startTileCol + m_pretreatmentNum, rowCount + m_startTileRow);
			}
		}


		private function clearAllTiles() : void
		{
			var tile : ParserMapResource;
			for (var tileId : String in m_tiles.dic)
			{
				tile = m_tiles[tileId];
				if (tile)
				{
					tile.release();
					delete m_tiles[tileId];
				}
			}

			var bit : IBitmap;
			for (var key : String in m_blackTitles)
			{
				bit = m_blackTitles[key];
				bit.dispose();
				delete m_blackTitles[key];
			}
		}

		private function clearAllBuffer() : void
		{
			if (!m_container)
				return;
			for (var i : int = m_container.numChildren - 1; i >= 0; i--)
			{
				m_container.removeGameChildAt(i);
			}
		}


		override public function update() : void
		{
			updateCamera(SCameraObject.sceneX, SCameraObject.sceneY);
		}

		public function updateCamera(viewX : int, viewY : int) : void
		{
			var isRefreshScreen : Boolean = true; //是否需要刷新屏幕
			if (!m_smallMapBitmapData)
				return;
			if (viewX == m_lastViewX && viewY == m_lastViewY)
			{
				isRefreshScreen = false;
				return;
			}

			m_lastViewX = viewX;
			m_lastViewY = viewY;

			if (isRefreshScreen)
			{
				// 计算出缓冲区开始的区块索引
				m_startTileCol = int(viewX / m_tileWidth);
				m_startTileRow = int(viewY / m_tileHeight);

				var isRefreshBuffer : Boolean = true; //是否需要刷新缓存
				if (m_startTileCol == m_lastStartTileCol && m_startTileRow == m_lastStartTileRow)
					isRefreshBuffer = false;

				m_container.x = -viewX;
				m_container.y = -viewY;
				// 加载地图区块到缓冲区中
				if (isRefreshBuffer)
				{
					refreshBuffer();
				}

				m_lastStartTileCol = m_startTileCol;
				m_lastStartTileRow = m_startTileRow;
			}
		}

		public function clear() : void
		{
			clearAllBuffer();
			clearAllTiles();

			m_smallMapParser = null;

			if (m_smallPreviewerMapParser)
			{
				m_smallPreviewerMapParser.release();
				m_smallPreviewerMapParser = null;
			}

			if (m_smallMapBitmapData)
			{
				m_smallMapBitmapData.dispose();
				m_smallMapBitmapData = null;
			}

			resetMapBuffer();
			m_config = null;
			m_fileVersions = null;
		}

		override public function destroy() : void
		{
			if (m_isDisposed)
				return;

			clear();
			m_container = null;

			m_onConfigComplete = null;
			m_onProgress = null;

			if (m_blackBitmapData)
			{
				m_blackBitmapData.dispose();
				m_blackBitmapData = null;
			}

			super.destroy();
		}
	}
}