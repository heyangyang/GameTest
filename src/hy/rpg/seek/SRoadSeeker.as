package hy.rpg.seek
{
	import flash.geom.Point;

	import hy.rpg.utils.UtilsCommon;

	/**
	 * 一个路径搜索器
	 *
	 */
	public class SRoadSeeker
	{
		private static var instance : SRoadSeeker;

		public static function getInstance() : SRoadSeeker
		{
			if (instance == null)
				instance = new SRoadSeeker();
			return instance;
		}

		private var _originalBlocks : Array;
		/**
		 * 所有遮罩区域
		 */
		private var _masks : Array;
		/**
		 * 所有安全区域
		 */
		private var _safes : Array;
		private var m_astar : SAStar;

		public function SRoadSeeker()
		{
			_masks = [];
			_safes = [];
			m_astar = SAStar.getInstance();
		}

		public function isBlock(gridX : int, gridY : int) : Boolean
		{
			return m_astar.isBlock(gridX, gridY);
		}

		public function isJumpableBlock(gridX : int, gridY : int) : Boolean
		{
			return m_astar.isJumpableBlock(gridX, gridY);
		}

		public function findByAvaliabePoint(startIndexX : int, startIndexY : int, endIndexX : int, endIndexY : int) : Array
		{
			return m_astar.findByAvaliabePoint(startIndexX, startIndexY, endIndexX, endIndexY);
		}

		public function find(startGridX : int, startGridY : int, endGridX : int, endGridY : int) : Array
		{
			return m_astar.find(startGridX, startGridY, endGridX, endGridY);
		}

		public function setBlockBorder(rowsTop : int, rowsBottom : int, columsTop : int, columsBottom : int) : void
		{
			m_astar.setBlockBorder(rowsTop, rowsBottom, columsTop, columsBottom);

			var async : Boolean = true;
//			if (async && SShellVariables.isMultiThread)
//			{
//				var threadMessage : SThreadMessage = SObjectPool.getObject(SThreadMessage);
//				if (!threadMessage)
//					threadMessage = new SThreadMessage();
//				threadMessage.type = SThreadMessageType.THREAD_MESSAGE_SET_BLOCK_BORDER;
//				threadMessage.id = 1;
//				threadMessage.setArgs(rowsTop, rowsBottom, columsTop, columsBottom);
//				SThreadEvent.dispatchEvent(SThreadEvent.EVENT_MAIN_THREAD_SEND, threadMessage);
//			}
		}

		public function init(mapBlocks : Array) : void
		{
			_originalBlocks = mapBlocks;
			if (_originalBlocks)
			{
				initBlockAreas(_originalBlocks);
				var blocks : Array = cloneBlocks(_originalBlocks);
				m_astar.init(blocks);

//				var async : Boolean = true;
//				if (async && SShellVariables.isMultiThread)
//				{
//					var threadMessage : SThreadMessage = SObjectPool.getObject(SThreadMessage);
//					if (!threadMessage)
//						threadMessage = new SThreadMessage();
//					threadMessage.type = SThreadMessageType.THREAD_MESSAGE_INIT_ASTAR;
//					threadMessage.id = 1;
//					threadMessage.setArgs(blocks);
//					SThreadEvent.dispatchEvent(SThreadEvent.EVENT_MAIN_THREAD_SEND, threadMessage);
//				}
			}
		}

		/**
		 * 根据地图配置文件初始化阻挡以及遮罩区域
		 *
		 */
		private function initBlockAreas(mapBlocks : Array) : void
		{
			_masks.length = 0;
			_safes.length = 0;

			if (mapBlocks)
			{
				var block : int;
				for (var i : int = 0; i < mapBlocks.length; i++)
				{
					for (var j : int = 0; j < mapBlocks[0].length; j++)
					{
						block = mapBlocks[i][j];
						if (block == SRoadPointType.MASKABLE_VALUE || block == SRoadPointType.SAFE_MASKABLE_VALUE)
							_masks.push(UtilsCommon.xyToInt(i, j));
						if (block == SRoadPointType.SAFE_VALUE || block == SRoadPointType.SAFE_MASKABLE_VALUE)
							_safes.push(UtilsCommon.xyToInt(i, j));
					}
				}
			}
		}

		public function isMaskPoint(gridX : int, gridY : int) : Boolean
		{
			if (_masks)
			{
				var value : int = UtilsCommon.xyToInt(gridX, gridY);
				return (_masks.indexOf(value) >= 0);
			}
			return false;
		}

		public function isSafePoint(gridX : int, gridY : int) : Boolean
		{
			if (_safes)
			{
				var value : int = UtilsCommon.xyToInt(gridX, gridY);
				return (_safes.indexOf(value) >= 0);
			}
			return false;
		}

		public function getAroundsNoneBlock(gridX : int, gridY : int) : Array
		{
			return m_astar.getAroundsNoneBlock(gridX, gridY);
		}

		public function addUnwalkBlock(gridX : int, gridY : int) : void
		{
			if (gridX >= 0 && gridX < m_astar.mapBlockColums && gridY >= 0 && gridY < m_astar.mapBlockRows)
			{
				m_astar.mapBlocks[gridX][gridY] = SRoadPointType.UNWALKABLE_VALUE;

//				var async : Boolean = true;
//				if (async && SShellVariables.isMultiThread)
//				{
//					var threadMessage : SThreadMessage = SObjectPool.getObject(SThreadMessage);
//					if (!threadMessage)
//						threadMessage = new SThreadMessage();
//					threadMessage.type = SThreadMessageType.THREAD_MESSAGE_ADD_UNWALK_BLOCK;
//					threadMessage.id = 1;
//					threadMessage.setArgs(gridX, gridY);
//					SThreadEvent.dispatchEvent(SThreadEvent.EVENT_MAIN_THREAD_SEND, threadMessage);
//				}
			}
		}

		public function resetBlocks() : void
		{
			if (_originalBlocks)
			{
				var blocks : Array = cloneBlocks(_originalBlocks);
				m_astar.init(blocks);

//				var async : Boolean = true;
//				if (async && SShellVariables.isMultiThread)
//				{
//					var threadMessage : SThreadMessage = SObjectPool.getObject(SThreadMessage);
//					if (!threadMessage)
//						threadMessage = new SThreadMessage();
//					threadMessage.type = SThreadMessageType.THREAD_MESSAGE_RESET_BLOCKS;
//					threadMessage.id = 1;
//					threadMessage.setArgs(blocks);
//					SThreadEvent.dispatchEvent(SThreadEvent.EVENT_MAIN_THREAD_SEND, threadMessage);
//				}
			}
		}

		private function cloneBlocks(blocks : Array) : Array
		{
			var cloneBlocks : Array = [];
			var colums : int = blocks ? blocks.length : 0;
			var rows : int = blocks ? blocks[0].length : 0;
			for (var i : int = 0; i < colums; i++)
			{
				var columArr : Array = [];
				for (var j : int = 0; j < rows; j++)
				{
					columArr.push(blocks[i][j]);
				}
				cloneBlocks.push(columArr);
			}
			return cloneBlocks;
		}

		/**
		 *
		 * @param x
		 * @param y
		 * @param angle
		 * @param distance
		 * @param acrossJumpable 跨越可跳跃区
		 * @return
		 *
		 */
		public function getForwardPosition(x : int, y : int, angle : int, distance : int, acrossJumpable : Boolean = false) : Point
		{
			var dx : Number = UtilsCommon.cosd(angle) * distance;
			var dy : Number = UtilsCommon.sind(angle) * distance;
			//强制矫正部分，不能让玩家跳出镜头之外
			while ((dx + x) <= 0 || (dy + y) <= 0 || (dx + x) >= (m_astar.mapBlockColums - 1) || (dy + y) >= (m_astar.mapBlockRows - 1))
			{
				if (distance == 0)
					break;
				distance--;
				dx = UtilsCommon.cosd(angle) * distance;
				dy = UtilsCommon.sind(angle) * distance;
			}
			var point : Point = new Point(Math.round(dx + x), Math.round(dy + y));
			var distanceGrid : int = 0;
			var maxGrid : int = 0;

			if (acrossJumpable)
			{
				maxGrid = Math.round(UtilsCommon.getDistance(x, y, point.x, point.y));
				distanceGrid = maxGrid;
				while (distanceGrid > 0 && point.x >= 0 && point.x < (m_astar.mapBlockColums - 1) && point.y >= 0 && point.y < (m_astar.mapBlockRows - 1)) //走路方向的前N格是可跳跃区域
				{
					dx = UtilsCommon.cosd(angle) * distanceGrid;
					dy = UtilsCommon.sind(angle) * distanceGrid;
					point.x = Math.round(dx + x);
					point.y = Math.round(dy + y);
					if (!isBlock(point.x, point.y))
					{
						dx = UtilsCommon.cosd(angle) * distanceGrid;
						dy = UtilsCommon.sind(angle) * distanceGrid;
						point.x = Math.round(dx + x);
						point.y = Math.round(dy + y);
						break;
					}
					distanceGrid--;
				}
				if (distanceGrid < distance) //前方有疑似可跳跃格子
				{
					distanceGrid++;
					var crossGrid : int = 0;
					maxGrid = 100; //distance; //可跨越最大距离
					while (maxGrid > 0 && point.x >= 0 && point.x < m_astar.mapBlockColums && point.y >= 0 && point.y < m_astar.mapBlockRows) //走路方向的前N格是可跳跃区域
					{
						dx = UtilsCommon.cosd(angle) * (distanceGrid + crossGrid);
						dy = UtilsCommon.sind(angle) * (distanceGrid + crossGrid);
						point.x = Math.round(dx + x);
						point.y = Math.round(dy + y);
						if (!isJumpableBlock(point.x, point.y)) //已跨过
						{
							break;
						}
						crossGrid++;
						maxGrid--;
					}
					if (isBlock(point.x, point.y)) //无法跳跃跨过
					{
						distanceGrid--;
						dx = UtilsCommon.cosd(angle) * distanceGrid;
						dy = UtilsCommon.sind(angle) * distanceGrid;
						point.x = Math.round(dx + x);
						point.y = Math.round(dy + y);
					}
				}
			}
			else
			{
				distanceGrid = 0;
				maxGrid = Math.round(UtilsCommon.getDistance(x, y, point.x, point.y));
				while (maxGrid > 0 && point.x >= 0 && point.x < m_astar.mapBlockColums && point.y >= 0 && point.y < m_astar.mapBlockRows) //走路方向的前N格是可通行区域
				{
					distanceGrid++;
					dx = UtilsCommon.cosd(angle) * distanceGrid;
					dy = UtilsCommon.sind(angle) * distanceGrid;
					point.x = Math.round(dx + x);
					point.y = Math.round(dy + y);
					if (isBlock(point.x, point.y))
					{
						distanceGrid--;
						dx = UtilsCommon.cosd(angle) * distanceGrid;
						dy = UtilsCommon.sind(angle) * distanceGrid;
						point.x = Math.round(dx + x);
						point.y = Math.round(dy + y);
						break;
					}
					maxGrid--;
				}
			}
			return point;
		}
	}
}