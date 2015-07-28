package hy.rpg.seek
{
	import flash.geom.Rectangle;
	
	import hy.rpg.utils.SCommonUtil;

	/**
	 * A星寻路算法
	 *
	 */
	public class SAStar
	{
		/**
		 * 横向或竖向移动一格的路径评分
		 */
		private const COST_STRAIGHT : int = 10;

		/**
		 * 斜向移动一格的路径评分
		 */
		private const COST_DIAGONAL : int = 14;

		/**
		 * 节点ID
		 */
		private const NODE_ID : int = 0;

		/**
		 * 在开启列表中ID
		 */
		private const NODE_OPEN : int = 1;

		/**
		 * 在关闭列表中ID
		 */
		private const NODE_CLOSED : int = 2;

		/**
		 * 最大寻路步数，超时则返回
		 */
		private var _maxTry : int;

		/**
		 * 开放列表，存放节点ID
		 */
		private var _openList : Vector.<int>;

		/**
		 * 开放列表长度
		 */
		private var _openCount : int;

		/**
		 * 节点加入开放列表时分配的唯一ID，从0开始
		 */
		private var _openId : int;

		/**
		 * 节点x坐标列表
		 */
		private var _xList : Vector.<int>;
		/**
		 * 节点y坐标列表
		 */
		private var _yList : Vector.<int>;

		/**
		 * 节点路径评分列表，F值
		 */
		private var _pathScoreList : Vector.<int>;

		/**
		 * 从起点移动到节点的移动耗费列表，G值
		 */
		private var _movementCostList : Vector.<int>;

		/**
		 * 节点的父节点ID列表
		 */
		private var _parentList : Vector.<int>;

		/**
		 * 节点(数组)地图,根据节点坐标记录节点开启关闭状态和ID
		 */
		private var _nodeMap : Array = [];

		private var _mapBlocks : Array;
		private var _mapBlockRowTop : int = 0;
		private var _mapBlockColumTop : int = 0;
		private var _mapBlockRows : int;
		private var _mapBlockColums : int;

		private static var _instance : SAStar;

		public function get mapBlockColums() : int
		{
			return _mapBlockColums;
		}

		public function get mapBlockRows() : int
		{
			return _mapBlockRows;
		}

		public function get mapBlocks() : Array
		{
			return _mapBlocks;
		}

		public static function getInstance() : SAStar
		{
			if (_instance == null)
				_instance = new SAStar();
			return _instance;
		}

		public function SAStar()
		{
			_openList = new Vector.<int>();
			_xList = new Vector.<int>();
			_yList = new Vector.<int>();
			_pathScoreList = new Vector.<int>();
			_movementCostList = new Vector.<int>();
			_parentList = new Vector.<int>();
			_nodeMap = [];
		}

		public function init(mapBlocks : Array, maxTry : int = 10000) : void
		{
			_mapBlocks = mapBlocks;
			_maxTry = maxTry;

			_mapBlockRowTop = 0;
			_mapBlockColumTop = 0;
			_mapBlockColums = _mapBlocks.length;
			_mapBlockRows = _mapBlocks[0].length;
		}

		/**
		 * 设置A星寻路节点的宽高数
		 * @param rows
		 * @param colums
		 */
		public function setBlockBorder(rowsTop : int, rowsBottom : int, columsTop : int, columsBottom : int) : void
		{
			_mapBlockRowTop = rowsTop;
			_mapBlockColumTop = columsTop;
			_mapBlockRows = rowsBottom;
			_mapBlockColums = columsBottom;
		}

		/**
		 * 获取数据的范围
		 * @return
		 */
		public function getBlockBorder() : Rectangle
		{
			var rect : Rectangle = new Rectangle();
			rect.left = _mapBlockRowTop;
			rect.top = _mapBlockColumTop;
			rect.right = _mapBlockRows;
			rect.bottom = _mapBlockColums;
			return rect;
		}

		public function get maxTry() : int
		{
			return _maxTry;
		}

		public function set maxTry(value : int) : void
		{
			_maxTry = value;
		}

		/**
		 * 开始寻路 ,如果两点有无效的点则先将两点转化为附近的有效点再进行寻路
		 * @param startIndexX
		 * @param startIndexY
		 * @param endIndexX
		 * @param endIndexY
		 * @return
		 *
		 */
		public function findByAvaliabePoint(startIndexX : int, startIndexY : int, endIndexX : int, endIndexY : int) : Array
		{
			var avaliableStart : Array = getAvailablePoint(startIndexX, startIndexY, endIndexX, endIndexY);
			var avaliableEnd : Array = getAvailablePoint(endIndexX, endIndexY, startIndexX, startIndexY);
			var paths : Array = find(avaliableStart[0], avaliableStart[1], avaliableEnd[0], avaliableEnd[1]);
			return paths;
		}

		/**
		 * 开始寻路
		 * @param startX		起点X坐标
		 * @param startY		起点Y坐标
		 * @param endX		终点X坐标
		 * @param endY		终点Y坐标
		 * @return 				找到的路径(二维数组 : [startX, startY], ... , [endX, endY])
		 */
		public function find(startX : int, startY : int, endX : int, endY : int) : Array
		{
			if (!_mapBlocks)
				return null;
			if (isBlock(endX, endY))
				return null;

			clear();
			_openCount = 0;
			_openId = -1;

			//添加起始点到开启列表
			openNode(startX, startY, 0, 0, 0);

			var currTry : int = 0;
			var currId : int;
			var currNodeX : int;
			var currNodeY : int;
			var aroundNodes : Array;

			var checkingId : int;

			var cost : int;
			var score : int;
			while (_openCount > 0)
			{
				//超时返回
				if (++currTry > _maxTry)
				{
					return null;
				}
				//每次取出开放列表最前面的ID
				currId = _openList[0];
				//将编码为此ID的元素列入关闭列表
				closeNode(currId);
				currNodeX = _xList[currId];
				currNodeY = _yList[currId];

				//如果终点被放入关闭列表寻路结束，返回路径
				if (currNodeX == endX && currNodeY == endY)
				{
					return getPath(startX, startY, currId);
				}
				//获取周围节点，排除不可通过和已在关闭列表中的
				aroundNodes = getArounds(currNodeX, currNodeY);

				//对于周围的每一个节点
				for each (var note : Array in aroundNodes)
				{
					//计算F和G值 cost 为G,score 为f
					cost = _movementCostList[currId] + ((note[0] == currNodeX || note[1] == currNodeY) ? COST_STRAIGHT : COST_DIAGONAL);
					score = cost + (Math.abs(endX - note[0]) + Math.abs(endY - note[1])) * COST_STRAIGHT;
					if (isOpen(note[0], note[1])) //如果节点已在播放列表中
					{
						checkingId = _nodeMap[note[1]][note[0]][NODE_ID];
						//如果新的G值比节点原来的G值小,修改F,G值，换父节点
						if (cost < _movementCostList[checkingId])
						{
							//G值
							_movementCostList[checkingId] = cost;
							//F值
							_pathScoreList[checkingId] = score;
							_parentList[checkingId] = currId;
							aheadNode(getIndex(checkingId));
						}
					}
					else //如果节点不在开放列表中
					{
						//将节点放入开放列表
						openNode(note[0], note[1], score, cost, currId);
					}
				}
			}
			return null;
		}

		/**
		 * 是否为障碍
		 * @param checkX
		 * @param checkY
		 * @return
		 *
		 */
		public function isBlock(checkX : int, checkY : int) : Boolean
		{
			if (!_mapBlocks)
				return true;
			if (checkX < _mapBlockColumTop || checkX >= _mapBlockColums || checkY < _mapBlockRowTop || checkY >= _mapBlockRows)
			{
				return true;
			}
			var type : int = _mapBlocks[checkX][checkY];
			return (type == SRoadPointType.UNWALKABLE_VALUE || type == SRoadPointType.JUMP_VALUE);
		}

		public function isJumpableBlock(checkX : int, checkY : int) : Boolean
		{
			if (!_mapBlocks)
				return false;
			if (checkX < _mapBlockColumTop || checkX >= _mapBlockColums || checkY < _mapBlockRowTop || checkY >= _mapBlockRows)
			{
				return true;
			}
			var type : int = _mapBlocks[checkX][checkY];
			return (type == SRoadPointType.JUMP_VALUE);
		}

		/**
		 * 将节点加入开放列表
		 * @param x 节点在地图中的x坐标
		 * @param y 节点在地图中的y坐标
		 * @param score 节点的路径评分
		 * @param cost 起始点到节点的移动成本
		 * @param fatherId 父节点
		 *
		 */
		private function openNode(x : int, y : int, score : int, cost : int, fatherId : int) : void
		{
			_openCount++; //初始为0
			_openId++; //初始为-1

			if (_nodeMap[y] == null)
			{
				_nodeMap[y] = [];
			}
			_nodeMap[y][x] = [];
			_nodeMap[y][x][NODE_OPEN] = true;
			//保存某节点的 在开启列表中索引的位置
			_nodeMap[y][x][NODE_ID] = _openId;

			_xList.push(x);
			_yList.push(y);
			//评分
			_pathScoreList.push(score);
			_movementCostList.push(cost);
			_parentList.push(fatherId);
			//id从0开始，count从-1开始
			_openList.push(_openId);
			aheadNode(_openCount);
		}

		/**
		 * 将节点加入关闭列表
		 * @param id
		 *
		 */
		private function closeNode(id : int) : void
		{
			_openCount--;
			var noteX : int = _xList[id];
			var noteY : int = _yList[id];
			_nodeMap[noteY][noteX][NODE_OPEN] = false;
			_nodeMap[noteY][noteX][NODE_CLOSED] = true;

			if (_openCount <= 0)
			{
				_openCount = 0;
				_openList = new Vector.<int>();
				return;
			}
			_openList[0] = _openList.pop();
			backNode();
		}

		/**
		 * 将(新加入开放别表或修改了路径评分的)节点向前移动
		 * @param index 添加到开启列表的计数索引
		 *
		 */
		private function aheadNode(index : int) : void
		{
			var father : int;
			var change : int;
			while (index > 1)
			{
				//父节点的位置
				father = Math.floor(index / 2);
				//如果该节点的F值小于父节点的F值则和父节点交换
				if (getScore(index) < getScore(father))
				{
					change = _openList[index - 1];
					_openList[index - 1] = _openList[father - 1];
					_openList[father - 1] = change;
					index = father;
				}
				else
					break;
			}
		}

		/**
		 * 将(取出开启列表中路径评分最低的节点后从队尾移到最前的)节点向后移动
		 *
		 */
		private function backNode() : void
		{
			//尾部的节点被移到最前面
			var checkIndex : int = 1;
			var index : int;
			var change : int;

			while (true)
			{
				index = checkIndex;
				//如果有子节点
				if (2 * index <= _openCount)
				{
					//如果子节点的F值更小
					if (getScore(checkIndex) > getScore(2 * index))
					{
						//记节点的新位置为子节点位置
						checkIndex = 2 * index;
					}
					//如果有两个子节点
					if (2 * index + 1 <= _openCount)
					{
						//如果第二个子节点F值更小
						if (getScore(checkIndex) > getScore(2 * index + 1))
						{
							//更新节点新位置为第二个子节点位置
							checkIndex = 2 * index + 1;
						}
					}
				}
				//如果节点位置没有更新结束排序
				if (index == checkIndex)
				{
					break;
				}
				//反之和新位置交换，继续和新位置的子节点比较F值
				else
				{
					change = _openList[index - 1];
					_openList[index - 1] = _openList[checkIndex - 1];
					_openList[checkIndex - 1] = change;
				}
			}
		}

		/**
		 * 判断某节点是否在开放列表
		 * @param x
		 * @param y
		 * @return
		 *
		 */
		private function isOpen(x : int, y : int) : Boolean
		{
			if (_nodeMap[y] == null)
				return false;
			if (_nodeMap[y][x] == null)
				return false;
			return _nodeMap[y][x][NODE_OPEN];
		}

		/**
		 * 判断某节点是否在关闭列表中
		 * @param x
		 * @param y
		 * @return
		 *
		 */
		private function isClose(x : int, y : int) : Boolean
		{
			if (_nodeMap[y] == null)
				return false;
			if (_nodeMap[y][x] == null)
				return false;
			return _nodeMap[y][x][NODE_CLOSED];
		}

		/**
		 * 获取某节点的周围节点，排除不能通过和已在关闭列表中的
		 * @param x
		 * @param y
		 * @return
		 *
		 */
		public function getArounds(x : int, y : int) : Array
		{
			var arr : Array = [];
			var checkX : int;
			var checkY : int;
			var canDiagonal : Boolean;

			//右
			checkX = x + 1;
			checkY = y;
			var canRight : Boolean = (isBlock(checkX, checkY) == false);
			if (canRight && !isClose(checkX, checkY))
				arr.push([checkX, checkY]);
			//下
			checkX = x;
			checkY = y + 1;
			var canDown : Boolean = (isBlock(checkX, checkY) == false);
			if (canDown && !isClose(checkX, checkY))
				arr.push([checkX, checkY]);
			//左
			checkX = x - 1;
			checkY = y;
			var canLeft : Boolean = (isBlock(checkX, checkY) == false);
			if (canLeft && !isClose(checkX, checkY))
				arr.push([checkX, checkY]);
			//上
			checkX = x;
			checkY = y - 1;
			var canUp : Boolean = (isBlock(checkX, checkY) == false);
			if (canUp && !isClose(checkX, checkY))
				arr.push([checkX, checkY]);

			//右下
			checkX = x + 1;
			checkY = y + 1;
			canDiagonal = (isBlock(checkX, checkY) == false);
			if (canDiagonal && canRight && canDown && !isClose(checkX, checkY))
				arr.push([checkX, checkY]);
			//左下
			checkX = x - 1;
			checkY = y + 1;
			canDiagonal = (isBlock(checkX, checkY) == false);
			if (canDiagonal && canLeft && canDown && !isClose(checkX, checkY))
				arr.push([checkX, checkY]);
			//左上
			checkX = x - 1;
			checkY = y - 1;
			canDiagonal = (isBlock(checkX, checkY) == false);
			if (canDiagonal && canLeft && canUp && !isClose(checkX, checkY))
				arr.push([checkX, checkY]);
			//右上
			checkX = x + 1;
			checkY = y - 1;
			canDiagonal = (isBlock(checkX, checkY) == false);
			if (canDiagonal && canRight && canUp && !isClose(checkX, checkY))
				arr.push([checkX, checkY]);

			return arr;
		}

		/**
		 * 获取周围所有可行走点的坐标
		 * @param x
		 * @param y
		 * @return
		 *
		 */
		public function getAroundsNoneBlock(x : int, y : int) : Array
		{
			var arr : Array = [];
			var checkX : int;
			var checkY : int;
			var canDiagonal : Boolean;

			//右
			checkX = x + 1;
			checkY = y;
			var canRight : Boolean = (isBlock(checkX, checkY) == false);
			if (canRight)
				arr.push([checkX, checkY]);
			//下
			checkX = x;
			checkY = y + 1;
			var canDown : Boolean = (isBlock(checkX, checkY) == false);
			if (canDown)
				arr.push([checkX, checkY]);
			//左
			checkX = x - 1;
			checkY = y;
			var canLeft : Boolean = (isBlock(checkX, checkY) == false);
			if (canLeft)
				arr.push([checkX, checkY]);
			//上
			checkX = x;
			checkY = y - 1;
			var canUp : Boolean = (isBlock(checkX, checkY) == false);
			if (canUp)
				arr.push([checkX, checkY]);

			//右下
			checkX = x + 1;
			checkY = y + 1;
			canDiagonal = (isBlock(checkX, checkY) == false);
			if (canDiagonal)
				arr.push([checkX, checkY]);
			//左下
			checkX = x - 1;
			checkY = y + 1;
			canDiagonal = (isBlock(checkX, checkY) == false);
			if (canDiagonal)
				arr.push([checkX, checkY]);
			//左上
			checkX = x - 1;
			checkY = y - 1;
			canDiagonal = (isBlock(checkX, checkY) == false);
			if (canDiagonal)
				arr.push([checkX, checkY]);
			//右上
			checkX = x + 1;
			checkY = y - 1;
			canDiagonal = (isBlock(checkX, checkY) == false);
			if (canDiagonal)
				arr.push([checkX, checkY]);

			return arr;
		}

		/**
		 * 取周围八向所有数据
		 * @param x
		 * @param y
		 * @return
		 *
		 */
		public function getAllArounds(x : int, y : int) : Array
		{
			var arr : Array = [];
			arr.push([x + 1, y]);
			arr.push([x + 1, y + 1]);
			arr.push([x + 1, y - 1]);
			arr.push([x - 1, y]);
			arr.push([x - 1, y + 1]);
			arr.push([x - 1, y - 1]);
			arr.push([x, y - 1]);
			arr.push([x, y + 1]);
			return arr;
		}

		/**
		 * 找到从 ［startIndexX ， startIndexY］ 到 ［endIndexX ， endIndexY］ 可用于寻路的最短的点
		 * @param startIndexX
		 * @param startIndexY
		 * @param endIndexX
		 * @param endIndexY
		 * @param closed
		 * @return
		 *
		 */
		private function getAvailablePoint(startIndexX : int, startIndexY : int, endIndexX : int, endIndexY : int, closed : Array = null) : Array
		{
			if (closed == null)
				closed = [];

			var avaliable : Array = null;
			if (isBlock(startIndexX, startIndexY))
			{
				closed.push(startIndexX + "_" + startIndexY);
				var arounds : Array = getAroundsNoneBlock(startIndexX, startIndexY);
				for each (var arr : Array in arounds)
				{
					if (!isBlock(arr[0], arr[1]))
					{
						avaliable = [arr[0], arr[1]];
						break;
					}
				}

				if (avaliable == null && arounds.length > 0)
				{
					for each (var toCheck : Array in arounds)
					{
						if (closed.indexOf(toCheck[0] + "_" + toCheck[1]) == -1)
						{
							var start2endDst : int = SCommonUtil.getDistance(startIndexX, startIndexY, endIndexX, endIndexY);
							var preDst : int = SCommonUtil.getDistance(toCheck[0], toCheck[1], endIndexX, endIndexY);
							if (preDst < start2endDst)
								break;
						}
					}
					avaliable = getAvailablePoint(toCheck[0], toCheck[1], endIndexX, endIndexY, closed);
				}
				else if (avaliable == null && arounds.length == 0)
				{
					var allArounds : Array = getAllArounds(startIndexX, startIndexY);
					start2endDst = SCommonUtil.getDistance(startIndexX, startIndexY, endIndexX, endIndexY);
					for each (toCheck in allArounds)
					{
						if (closed.indexOf(toCheck[0] + "_" + toCheck[1]) == -1)
						{
							preDst = SCommonUtil.getDistance(toCheck[0], toCheck[1], endIndexX, endIndexY);
							if (preDst < start2endDst)
								break;
						}
					}
					avaliable = getAvailablePoint(toCheck[0], toCheck[1], endIndexX, endIndexY, closed);
				}
			}
			closed = null;
			return avaliable == null ? [startIndexX, startIndexY] : avaliable;
		}

		/**
		 * 获取路径
		 * @param startX 起始点X坐标
		 * @param startY 起始点Y坐标
		 * @param id 终点ID
		 * @return 路径坐标(Point)数组
		 *
		 */
		private function getPath(startX : int, startY : int, id : int) : Array
		{
			var arr : Array = [];
			var noteX : int = _xList[id];
			var noteY : int = _yList[id];
			while (noteX != startX || noteY != startY)
			{
				arr.unshift([noteX, noteY]);
				id = _parentList[id];
				noteX = _xList[id];
				noteY = _yList[id];
			}
			arr.unshift([startX, startY]);
			return arr;
		}

		/**
		 * 获取某ID节点在开放列表中的索引(从1开始)
		 * @param id
		 * @return
		 *
		 */
		private function getIndex(id : int) : int
		{
			var i : int = 1;
			for each (var tmp_id : int in _openList)
			{
				if (tmp_id == id)
				{
					return i;
				}
				i++;
			}
			return -1;
		}

		/**
		 * 获取某节点的路径评分
		 * @param index 节点在开启列表中的索引(从1开始)
		 * @return
		 *
		 */
		private function getScore(index : int) : int
		{
			return _pathScoreList[_openList[index - 1]];
		}

		/**
		 * 清除
		 *
		 */
		private function clear() : void
		{
			_openList.length = 0;
			_xList.length = 0;
			_yList.length = 0;
			_pathScoreList.length = 0;
			_movementCostList.length = 0;
			_parentList.length = 0;
			_nodeMap.length = 0;
		}
	}
}