package hy.rpg.map
{
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import hy.game.cfg.Config;
	import hy.game.core.GameDispatcher;
	import hy.game.core.GameObject;
	import hy.game.core.SCameraObject;
	import hy.game.data.SRectangle;
	import hy.game.manager.SReferenceManager;
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
		private static var instance : MapObject;

		public static function getInstance() : MapObject
		{
			if (!instance)
				instance = new MapObject(Config.SMALL_MAP_SCALE);
			return instance;
		}
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
		 * 小地图
		 */
		protected var m_smallPreviewerMapParser : ParserImageResource;
		/**
		 * 保存加载过的地图块位图
		 */
		protected var m_tiles : Dictionary;

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
		 * 缓冲范围
		 */
		protected var m_bufferRect : SRectangle;

		/**
		 * 缓冲区域大小
		 */
		private var m_bufferNum : int = 1;

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
		private var m_isLoaded : Boolean;
		private var m_maxMultiDistance : int;
		private var m_index : int;

		public function MapObject(min_scale : Number)
		{
			m_scale = min_scale;
			m_camera = SCameraObject.getInstance();
			m_tiles = new Dictionary();
			m_bufferRect = new SRectangle();
			super();
		}

		override public function registerd(priority : int = 0) : void
		{
			super.registerd(priority);
			GameDispatcher.addEventListener(GameDispatcher.RESIZE, onResizeHandler);
		}

		override public function unRegisterd() : void
		{
			super.unRegisterd();
			GameDispatcher.removeEventListener(GameDispatcher.RESIZE, onResizeHandler);
		}

		private function onResizeHandler() : void
		{
			resizeScreen(Config.screenWidth, Config.screenHeight);
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
			m_isLoaded = false;
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
			m_mapWidth = m_config.@right;
			m_mapHeight = m_config.@bottom;

			m_tileWidth = Config.TILE_WIDTH;
			m_tileHeight = Config.TILE_HEIGHT;

			m_camera.setSceneSize(int(m_mapWidth / m_tileWidth) * m_tileWidth, int(m_mapHeight / m_tileHeight) * m_tileHeight);

			m_mapCols = Math.floor(m_mapWidth / m_tileWidth) - 1;
			m_mapRows = Math.floor(m_mapHeight / m_tileHeight) - 1;


			resizeScreen(Config.screenWidth, Config.screenHeight);

			loadPreviewMap(m_config.bm.@url, m_config.bm.@version);
		}

		/**
		 * 设置屏幕大小
		 * @param w
		 * @param h
		 *
		 */
		public function resizeScreen(w : int, h : int) : void
		{
			//设置镜头的基本信息
			m_camera.setScreenSize(w, h);
			m_camera.updateRectangle(200, 200);

			m_viewWidth = w;
			m_viewHeight = h;

			m_bufferCols = Math.ceil(m_viewWidth / m_tileWidth) + m_bufferNum;
			m_bufferRows = Math.ceil(m_viewHeight / m_tileHeight) + m_bufferNum;

			//计算出缓冲区的区块
			m_bufferRect.width = m_bufferCols;
			m_bufferRect.height = m_bufferRows;

			resetMapBuffer();
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
			m_isLoaded = true;
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

		private function resetMapBuffer() : void
		{
			m_lastStartTileCol = -1;
			m_lastStartTileRow = -1;
			m_lastViewX = -1;
			m_lastViewY = -1;
		}

		override public function update() : void
		{
			super.update();
			updateCamera(SCameraObject.sceneX, SCameraObject.sceneY);
		}

		/**
		 * 更新transform的一些信息
		 *
		 */
		override protected function updateTransform() : void
		{
			if (transform.x != SCameraObject.sceneX || transform.y != SCameraObject.sceneY)
			{
				m_render.x = transform.x = -SCameraObject.sceneX;
				m_render.y = transform.y = -SCameraObject.sceneY;
			}
		}

		public function updateCamera(viewX : int, viewY : int) : void
		{
			if (!m_isLoaded)
				return;
			//小于0表示镜头还没有初始化
			if (viewX < 0 || viewY < 0)
				return;
			//如果相等，表示镜头没有移动，则不需要更新
			if (viewX == m_lastViewX && viewY == m_lastViewY)
				return;

			m_lastViewX = viewX;
			m_lastViewY = viewY;

			//计算出缓冲区开始的索引

			m_bufferRect.x = Math.floor(viewX / m_tileWidth) - m_bufferNum;
			m_bufferRect.y = Math.floor(viewY / m_tileHeight) - m_bufferNum;
			//矫正起始坐
			if (m_bufferRect.x < 0)
				m_bufferRect.x = 0;
			if (m_bufferRect.y < 0)
				m_bufferRect.y = 0;
			if (m_bufferRect.x + m_bufferCols > m_mapCols)
				m_bufferRect.x = m_mapCols - m_bufferCols;
			if (m_bufferRect.y + m_bufferRows > m_mapRows)
				m_bufferRect.y = m_mapRows - m_bufferRows;

			//若果缓冲区域和上一次不一样
			if (m_bufferRect.x != m_lastStartTileCol || m_bufferRect.y != m_lastStartTileRow)
			{
				//如果不是正常移动则刷新页面
				if (Math.abs(m_bufferRect.x - m_lastStartTileCol) > 1 || Math.abs(m_bufferRect.y - m_lastStartTileRow) > 1)
				{
					m_lastStartTileRow = m_lastStartTileCol = -1;
				}
				refreshBuffer();
				m_lastStartTileCol = m_bufferRect.x;
				m_lastStartTileRow = m_bufferRect.y;
			}
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
				clearAllTiles();
			}

			var colmnsCount : int;
			var titleX : int, titleY : int;
			//将缓冲区对应的地图区块读入缓冲区中
			for (var rowCount : int = -m_bufferNum; rowCount <= m_bufferRows + m_bufferNum; rowCount++)
			{
				titleY = m_bufferRect.y + rowCount;
				for (colmnsCount = -m_bufferNum; colmnsCount <= m_bufferCols + m_bufferNum; colmnsCount++)
				{
					titleX = m_bufferRect.x + colmnsCount;
					if (m_bufferRect.containsByPoint(titleX, titleY))
					{
						copyTileBitmapData(titleX, titleY);
						continue;
					}
					clearTile(titleX, titleY);
				}
			}
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
			var tileId : String = encoderTileId(tileX, tileY);
			var tile : ParserMapResource = m_tiles[tileId];
			if (tile)
				return;
			var data : Object = m_fileVersions[tileId];
			if (!data)
			{
				error(this, "m_fileVersions is null : " + tileId);
				return;
			}
			return;
			tile = SReferenceManager.getInstance().createMapResourceParser(ParserMapResource, m_mapId + tileId, data.url, EnumLoadPriority.MAP - m_index++, data.version);
			tile.onComplete(onTileResourceParserComplete);
			tile.load();
			m_tiles[tileId] = tile;
		}

		protected function onTileResourceParserComplete(res : ParserMapResource) : void
		{
			var tileId : String = res.id.split("/").pop().split(".").shift();
			decoderTileId(tileId);
			if (!m_bufferRect.containsByPoint(m_loadTilePos.x, m_loadTilePos.y))
			{
				clearTile(m_loadTilePos.x, m_loadTilePos.y);
				return;
			}
			if (!res.render)
			{
				warning(this, "地图块数据为空！");
				return;
			}
			res.render.x = m_loadTilePos.x * m_tileWidth;
			res.render.y = m_loadTilePos.y * m_tileHeight;
			addRender(res.render);
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
			return UtilsCommon.xyToInt(tileX + m_bufferNum, tileY + m_bufferNum).toString(36);
		}

		/**
		 * 解锁一个字符串成坐标
		 * @param tileId
		 * @return
		 *
		 */
		protected function decoderTileId(tileId : String) : Point
		{
			m_loadTilePos.x = UtilsCommon.getXFromInt(parseInt(tileId, 36)) - m_bufferNum;
			m_loadTilePos.y = UtilsCommon.getYFromInt(parseInt(tileId, 36)) - m_bufferNum;
			return m_loadTilePos;
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
				return;
			var tileId : String = encoderTileId(tileX, tileY);
			removeTitle(m_tiles[tileId]);
			delete m_tiles[tileId];
		}

		private function removeTitle(tile : ParserMapResource) : void
		{
			if (!tile)
				return;
			removeRender(tile.render);
			tile.release();
		}

		private function clearAllTiles() : void
		{
			for (var tileId : String in m_tiles)
			{
				removeTitle(m_tiles[tileId]);
				delete m_tiles[tileId];
			}
		}

		public function clear() : void
		{
			clearAllTiles();
			resetMapBuffer();
			m_config = null;
			m_fileVersions = null;
		}

		override public function destroy() : void
		{
			if (m_isDisposed)
				return;

			clear();

			m_onConfigComplete = null;
			m_onProgress = null;

			super.destroy();
		}
	}
}