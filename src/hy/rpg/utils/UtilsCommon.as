package hy.rpg.utils
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import hy.game.cfg.Config;
	import hy.rpg.enum.EnumDirection;
	import hy.rpg.enum.EnumGrid;

	/**
	 *  常用工具
	 *
	 */
	public class UtilsCommon
	{
		/**
		 * 将坐标点x,y以一个int表示
		 * @param x 不能超过short
		 * @param y 不能超过short
		 * @return
		 */
		public static function xyToInt(x : int, y : int) : int
		{
			return (x << 16) | y;
		}

		/**
		 * 坐标点以一个int表示, 获取其中的x坐标
		 * @param value
		 * @return
		 */
		public static function getXFromInt(value : int) : int
		{
			return value >> 16;
		}

		/**
		 * 坐标点以一个int表示, 获取其中的y坐标
		 * @param value
		 * @return
		 */
		public static function getYFromInt(value : int) : int
		{
			return value & 0xffff;
		}

		public static function bytesToString(bytes : int) : String
		{
			if (bytes < 1024)
				return bytes + "b";
			else if (bytes < 10240)
				return (bytes / 1024).toFixed(2) + "kb";
			else if (bytes < 102400)
				return (bytes / 1024).toFixed(1) + "kb";
			else if (bytes < 1048576)
				return (bytes >> 10) + "kb";
			else if (bytes < 10485760)
				return (bytes / 1048576).toFixed(2) + "mb";
			else if (bytes < 104857600)
				return (bytes / 1048576).toFixed(1) + "mb";
			else
				return String(bytes >> 20) + "mb";
		}

		/**
		 * 格子从0开始
		 * @param gridX
		 * @return
		 *
		 */
		public static function getPixelXByGrid(gridX : int) : int
		{
			//if (gridX >= 0)
			return gridX * Config.GRID_WIDTH + Config.GRID_WIDTH / 2;
			//SDebug.errorPrint(gridX, "格子数不能为负数！");
			//return 0;
		}

		/**
		 * 格子从0开始
		 * @param gridY
		 * @return
		 *
		 */
		public static function getPixelYByGrid(gridY : int) : int
		{
			//if (gridY >= 0)
			return gridY * Config.GRID_HEIGHT + Config.GRID_HEIGHT / 2;
			//SDebug.errorPrint(gridY, "格子数不能为负数！");
			return 0;
		}

		public static function getGridXByPixel(pixelX : int) : int
		{
			return int(pixelX / Config.GRID_WIDTH);
		}

		public static function getGridYByPixel(pixelY : int) : int
		{
			return int(pixelY / Config.GRID_HEIGHT);
		}

		public static function getGridStepTimeBySpeed(speed : Number) : int
		{
			return int(Config.GRID_WIDTH / speed);
		}

		/**
		 * 每毫秒所走的像素
		 * @param stepTime
		 * @return
		 *
		 */
		public static function getSpeedByGridStepTime(stepTime : int) : Number
		{
			if (stepTime == 0)
				return 0;
			return Number((Config.GRID_WIDTH / stepTime).toFixed(3));
		}

		public static function getAttackRange(grids : int) : int
		{
			return grids * Config.GRID_WIDTH;
		}

		/**
		 * 根据网格坐标取得象素坐标
		 * @param tileWidth
		 * @param tileHeight
		 * @param tx
		 * @param ty
		 * @return
		 *
		 */
		public static function getPixelPointByGrid(gridType : int, gridWidth : int, gridHeight : int, gridX : int, gridY : int) : Point
		{
			var xPixel : int = 0;
			var yPixel : int = 0;
			if (gridType == EnumGrid.RECTANGLE)
			{
				// x象素
				xPixel = gridX * gridWidth + gridWidth / 2;
				// y象素
				yPixel = gridY * gridHeight + gridHeight / 2;
			}
			else if (gridType == EnumGrid.DIAMOND)
			{
				//偶数行tile中心
				var tileCenter : int = (gridX * gridWidth) + gridWidth / 2;
				// x象素  如果为奇数行加半个宽
				xPixel = tileCenter + (gridY & 1) * gridWidth / 2;
				// y象素
				yPixel = (gridY + 1) * gridHeight / 2;
			}
			return new Point(xPixel, yPixel);
		}

		//根据屏幕象素坐标取得网格的坐标
		public static function getCellPoint(tileWidth : int, tileHeight : int, px : int, py : int) : Point
		{
			var xtile : int = 0; //网格的x坐标
			var ytile : int = 0; //网格的y坐标

			var cx : int, cy : int, rx : int, ry : int;
			cx = int(px / tileWidth) * tileWidth + tileWidth / 2; //计算出当前X所在的以tileWidth为宽的矩形的中心的X坐标
			cy = int(py / tileHeight) * tileHeight + tileHeight / 2; //计算出当前Y所在的以tileHeight为高的矩形的中心的Y坐标

			rx = (px - cx) * tileHeight / 2;
			ry = (py - cy) * tileWidth / 2;

			if (Math.abs(rx) + Math.abs(ry) <= tileWidth * tileHeight / 4)
			{
				//xtile = int(pixelPoint.x / tileWidth) * 2;
				xtile = int(px / tileWidth);
				ytile = int(py / tileHeight) * 2;
			}
			else
			{
				px = px - tileWidth / 2;
				//xtile = int(pixelPoint.x / tileWidth) * 2 + 1;
				xtile = int(px / tileWidth) + 1;

				py = py - tileHeight / 2;
				ytile = int(py / tileHeight) * 2 + 1;
			}

			return new Point(xtile - (ytile & 1), ytile);
		}

		public static function changeTextDataValueID(fields : Array, values : Dictionary, orgId : int, id : int) : void
		{
			for each (var field : String in fields)
			{
				var valueMap : Dictionary = values[field];
				if (valueMap)
				{
					if (valueMap.hasOwnProperty(orgId))
					{
						var value : String = valueMap[orgId];
						delete valueMap[orgId];
						valueMap[id] = value;
					}
				}
			}
		}

		/**
		 * 根据角度获取方向
		 * @param rotation
		 * @return
		 */
		public static function getDirection(rotation : int) : uint
		{
			if (rotation < 0)
				rotation = 360 + rotation;
			if (rotation <= 22 || rotation >= 338)
				return EnumDirection.EAST;
			else if (rotation >= 23 && rotation <= 67)
				return EnumDirection.EAST_SOUTH;
			else if (rotation >= 68 && rotation <= 112)
				return EnumDirection.SOUTH;
			else if (rotation >= 113 && rotation <= 157)
				return EnumDirection.WEST_SOUTH;
			else if (rotation >= 158 && rotation <= 202)
				return EnumDirection.WEST;
			else if (rotation >= 203 && rotation <= 247)
				return EnumDirection.WEST_NORTH;
			else if (rotation >= 248 && rotation <= 292)
				return EnumDirection.NORTH;
			else if (rotation >= 293 && rotation <= 337)
				return EnumDirection.EAST_NORTH;
			return 0;
		}

		public static function getAngleByDir(dir : int) : int
		{
			if (dir == EnumDirection.SOUTH)
			{
				return 90;
			}
			else if (dir == EnumDirection.WEST)
			{
				return 180;
			}
			else if (dir == EnumDirection.EAST)
			{
				return 0;
			}
			else if (dir == EnumDirection.NORTH)
			{
				return 270;
			}
			else if (dir == EnumDirection.WEST_SOUTH)
			{
				return 135;
			}
			else if (dir == EnumDirection.EAST_SOUTH)
			{
				return 45;
			}
			else if (dir == EnumDirection.WEST_NORTH)
			{
				return 225;
			}
			else if (dir == EnumDirection.EAST_NORTH)
			{
				return 315;
			}
			return 0;
		}

		public static function getDirectionByAngle(angle : int) : uint
		{
			if (angle <= 20 && angle >= -20)
			{ //0
				return EnumDirection.EAST;
			}
			else if (angle >= 25 && angle <= 65)
			{ //45
				return EnumDirection.EAST_SOUTH;
			}
			else if (angle >= 70 && angle <= 110)
			{ //90
				return EnumDirection.SOUTH;
			}
			else if (angle >= 115 && angle <= 155)
			{ //135
				return EnumDirection.WEST_SOUTH;
			}
			else if (angle >= 160 || angle <= -160)
			{ //180
				return EnumDirection.WEST;
			}
			else if (angle >= -155 && angle <= -115)
			{ //-150
				return EnumDirection.WEST_NORTH;
			}
			else if (angle >= -110 && angle <= -70)
			{ //-90
				return EnumDirection.NORTH;
			}
			else if (angle >= -65 && angle <= -25)
			{ //-45
				return EnumDirection.EAST_NORTH;
			}
			return EnumDirection.NONE;
		}

		/**
		 * 取得一个方向的反向
		 * @param dir
		 * @return
		 *
		 */
		public static function getReverseDirByDir(dir : int) : int
		{
			switch (dir)
			{
				case EnumDirection.EAST:
					return EnumDirection.WEST;
				case EnumDirection.EAST_SOUTH:
					return EnumDirection.WEST_NORTH;
				case EnumDirection.SOUTH:
					return EnumDirection.NORTH;
				case EnumDirection.EAST_NORTH:
					return EnumDirection.WEST_SOUTH;
				case EnumDirection.NORTH:
					return EnumDirection.SOUTH;
				case EnumDirection.WEST:
					return EnumDirection.EAST;
				case EnumDirection.WEST_NORTH:
					return EnumDirection.EAST_SOUTH;
				case EnumDirection.WEST_SOUTH:
					return EnumDirection.EAST_NORTH;
					break;
			}
			return -1;
		}

		/**
		 * 计算两点之间的角度
		 * @param Ax	A点x坐标
		 * @param Ay	A点y坐标
		 * @param Bx	B点x坐标
		 * @param By	B点y坐标
		 */
		public static function getAngle(Ax : int, Ay : int, Bx : int, By : int) : int
		{
			var tempXDistance : int = Bx - Ax;
			var tempYDistance : int = By - Ay;

			var rotation : int = Math.round(Math.atan2(tempYDistance, tempXDistance) * 57.33); //弧度化角度
			rotation = (rotation + 360) % 360;

			return rotation;
		}

		/**
		 * 计算两点之间 的弧度
		 * @param Ax
		 * @param Ay
		 * @param Bx
		 * @param By
		 * @return
		 *
		 */
		public static function getRotate(Ax : int, Ay : int, Bx : int, By : int) : Number
		{
			var tempXDistance : int = Bx - Ax;
			var tempYDistance : int = By - Ay;
			return Math.atan2(tempYDistance, tempXDistance);
		}

		/**
		 * 根据角度得出弧度
		 * @param angle
		 * @return
		 *
		 */
		public static function getRotateByAngle(angle : int) : Number
		{
			return angle * Math.PI / 180;
		}

		/**
		 * 根据弧度得到角度
		 * @param rotate
		 * @return
		 */
		public static function getAngleByRotate(rotate : Number) : int
		{
			return Math.round(rotate * 180 / Math.PI);
		}

		/**
		 * 检查方向是否斜向
		 * @param dir
		 * @return
		 *
		 */
		public static function checkIsInclination(dir : int) : Boolean
		{
			switch (dir)
			{
				case EnumDirection.EAST:
				case EnumDirection.SOUTH:
				case EnumDirection.NORTH:
				case EnumDirection.WEST:
					return false;
				case EnumDirection.EAST_SOUTH:
				case EnumDirection.EAST_NORTH:
				case EnumDirection.WEST_NORTH:
				case EnumDirection.WEST_SOUTH:
					return true;
			}
			return false;
		}

		/**
		 * 计算两点距离
		 * @param ax	A点x坐标
		 * @param ay	A点y坐标
		 * @param bx	B点x坐标
		 * @param by	B点y坐标
		 */
		public static function getDistance(ax : Number, ay : Number, bx : Number, by : Number) : Number
		{
			return (Math.sqrt(((ax - bx) * (ax - bx)) + ((ay - by) * (ay - by))));
		}

		/**
		 * 判断点在有向直线的左侧还是右侧.
		 * @param ptStart
		 * @param ptEnd
		 * @param ptTest
		 * @return -1: 点在线段左侧; 0: 点在线段上; 1: 点在线段右侧
		 *
		 */
		public static function pointAtLineLeftRight(ptStartX : int, ptStartY : int, ptEndX : int, ptEndY : int, ptTestX : int, ptTestY : int) : int
		{
			ptStartX -= ptTestX;
			ptStartY -= ptTestY;
			ptEndX -= ptTestX;
			ptEndY -= ptTestY;

			var nRet : int = ptStartX * ptEndY - ptStartY * ptEndX;

			if (nRet == 0)
				return 0;
			else if (nRet > 0)
				return 1;
			else if (nRet < 0)
				return -1;
			return 0;
		}

		/**
		 * 判断两条线段是否相交
		 * @param ptLine1Start
		 * @param ptLine1End
		 * @param ptLine2Start
		 * @param ptLine2End
		 * @return
		 *
		 */
		public static function isTwoLineIntersect(ptLine1StartX : int, ptLine1StartY : int, ptLine1EndX : int, ptLine1EndY : int, ptLine2StartX : int, ptLine2StartY : int, ptLine2EndX : int, ptLine2EndY : int) : Boolean
		{
			var nLine1Start : int = pointAtLineLeftRight(ptLine2StartX, ptLine2StartY, ptLine2EndX, ptLine2EndY, ptLine1StartX, ptLine1StartY);
			var nLine1End : int = pointAtLineLeftRight(ptLine2StartX, ptLine2StartY, ptLine2EndX, ptLine2EndY, ptLine1EndX, ptLine1EndY);
			if (nLine1Start * nLine1End > 0)
				return false;

			var nLine2Start : int = pointAtLineLeftRight(ptLine1StartX, ptLine1StartY, ptLine1EndX, ptLine1EndY, ptLine2StartX, ptLine2StartY);
			var nLine2End : int = pointAtLineLeftRight(ptLine1StartX, ptLine1StartY, ptLine1EndX, ptLine1EndY, ptLine2EndX, ptLine2EndY);

			if (nLine2Start * nLine2End > 0)
				return false;

			return true;
		}

		private static var ptStart : Point = new Point(0, 0);
		private static var ptEnd : Point = new Point(0, 0);

		/**
		 * 判断线段是否与矩形相交
		 * @param ptStart
		 * @param ptEnd
		 * @param rect
		 * @return
		 *
		 */
		public static function isLineIntersectRect(ptStartX : int, ptStartY : int, ptEndX : int, ptEndY : int, rect : Rectangle) : Boolean
		{
			ptStart.x = ptStartX;
			ptStart.y = ptStartY;

			ptEnd.x = ptEndX;
			ptEnd.y = ptEndY;

			// 如果有一个点在矩形内
			if (rect.containsPoint(ptStart) || rect.containsPoint(ptEnd))
			{
				return true;
			}

			// 两个点都不在矩形内
			if (isTwoLineIntersect(ptStartX, ptStartY, ptEndX, ptEndY, rect.topLeft.x, rect.topLeft.y, rect.topLeft.x, rect.topLeft.y + rect.height))
				return true;
			if (isTwoLineIntersect(ptStartX, ptStartY, ptEndX, ptEndY, rect.topLeft.x, rect.topLeft.y + rect.height, rect.bottomRight.x, rect.bottomRight.y))
				return true;
			if (isTwoLineIntersect(ptStartX, ptStartY, ptEndX, ptEndY, rect.bottomRight.x, rect.bottomRight.y, rect.topLeft.x + rect.width, rect.topLeft.y))
				return true;
			if (isTwoLineIntersect(ptStartX, ptStartY, ptEndX, ptEndY, rect.topLeft.x, rect.topLeft.y, rect.topLeft.x + rect.width, rect.topLeft.y))
				return true;

			return false;
		}

		/**
		 * 判断多边形是否与矩形相交
		 * @param fencePnts
		 * @param rect
		 * @return
		 *
		 */
		public static function isFenceIntersectRect(fencePnts : Array, rect : Rectangle) : Boolean
		{
			for (var i : int = 0; i < fencePnts.length; i++)
			{
				if (i == fencePnts.length - 1)
				{
					if (isLineIntersectRect(fencePnts[i].x, fencePnts[i].y, fencePnts[0].x, fencePnts[0].y, rect))
					{
						return true;
					}
				}
				else
				{
					if (isLineIntersectRect(fencePnts[i].x, fencePnts[i].y, fencePnts[i + 1].x, fencePnts[i + 1].y, rect))
					{
						return true;
					}
				}
			}
			return false;
		}

		/**
		 * 判断点是否在多边形内
		 * @param pnt1
		 * @param fencePnts
		 * @return
		 *
		 */
		public static function isPointInFence(pnt1 : Object, fencePnts : Array) : Boolean
		{
			var j : int = 0;
			var cnt : int = 0;

			for (var i : int = 0; i < fencePnts.length; i++)
			{
				j = (i == fencePnts.length - 1) ? 0 : j + 1;
				if ((fencePnts[i].y != fencePnts[j].y) && (((pnt1.y >= fencePnts[i].y) && (pnt1.y < fencePnts[j].y)) || ((pnt1.y >= fencePnts[j].y) && (pnt1.y < fencePnts[i].y))) && (pnt1.x < (fencePnts[j].x - fencePnts[i].x) * (pnt1.y - fencePnts[i].y) / (fencePnts[j].y - fencePnts[i].y) + fencePnts[i].x))
					cnt++;
			}
			if (cnt % 2 > 0)
			{
				return true;
			}
			else
			{
				return false;
			}
		}

		public static function angleToRadian(angle : Number) : Number
		{
			return angle * (Math.PI / 180);
		}

		/**
		 * 弧度转换为角度
		 * @param radian
		 * @return
		 *
		 */
		public static function radianToAngle(radian : Number) : Number
		{
			return fixAngle(radian * (180 / Math.PI));
		}

		/**
		 * 修正角度在360度以内
		 */
		public static function fixAngle(angle : Number) : Number
		{
			return (angle + 360) % 360;
		}

		/**
		 * 以角度为单位计算三角函数值
		 * @param angle
		 * @return
		 *
		 */
		public static function sind(angle : Number) : Number
		{
			return Math.sin(angleToRadian(angle));
		}

		public static function cosd(angle : Number) : Number
		{
			return Math.cos(angleToRadian(angle));
		}

		public static function tand(angle : Number) : Number
		{
			return Math.tan(angleToRadian(angle));
		}

		/**
		 * 返回的值是以角度为单位
		 * @param radian
		 * @return
		 *
		 */
		public static function asind(radian : Number) : Number
		{
			return radianToAngle(Math.acos(radian));
		}

		public static function acosd(radian : Number) : Number
		{
			return radianToAngle(Math.acos(radian));
		}

		public static function atand(radian : Number) : Number
		{
			return radianToAngle(Math.acos(radian));
		}

		public static function atan2d(y : Number, x : Number) : Number
		{
			return radianToAngle(Math.atan2(y, x));
		}

		//返回两个角度的差值
		public static function getDegree1(a : Number, b : Number) : Number
		{
			if ((a > 0 && b > 0) || (a < 0 && b < 0))
			{
				return Math.abs(a - b);
			}
			else
			{
				var c : Number = Math.abs(a);
				var d : Number = Math.abs(b);
				if ((c + d) > 180)
				{
					return (360 - c - d);
				}
				else
				{
					return c + d;
				}
			}
		}

		/**
		 * 由一堆的顺时针方向得到路径
		 * @param dirs
		 * @return
		 *
		 */
		public static function getPathsByDirs(x : int, y : int, dirs : Array) : Array
		{
			var paths : Array = [];
			for (var i : int = 0; i < dirs.length; i++)
			{
				var dir : uint = dirs[i];

				switch (dir)
				{
					case EnumDirection.CW_NORTH:
						y--;
						break;
					case EnumDirection.CW_EAST_NORTH:
						x++;
						y--;
						break;
					case EnumDirection.CW_EAST:
						x++;
						break;
					case EnumDirection.CW_EAST_SOUTH:
						x++;
						y++;
						break;
					case EnumDirection.CW_SOUTH:
						y++;
						break;
					case EnumDirection.CW_WEST_SOUTH:
						x--;
						y++;
						break;
					case EnumDirection.CW_WEST:
						x--;
						break;
					case EnumDirection.CW_WEST_NORTH:
						x--;
						y--;
						break;
				}

				paths.push([x, y]);
			}
			return paths;
		}

		/**
		 * 由一堆的路径得到顺时针方向
		 * @param dirs
		 * @return
		 *
		 */
		public static function getDirsByPaths(x : int, y : int, paths : Array) : Array
		{
			var pathsLen : int = paths.length;
			var dirs : Array = [];
			for (var i : int = 0; i < pathsLen; i++)
			{
				var path : Array = paths[i];
				var toX : int = path[0];
				var toY : int = path[1];
				var dir : int = 0;

				if (toX - x == 1 && toY - y == 1)
					dir = EnumDirection.CW_EAST_SOUTH;
				else if (toX - x == 1 && toY - y == -1)
					dir = EnumDirection.CW_EAST_NORTH;
				else if (toX - x == -1 && toY - y == 1)
					dir = EnumDirection.CW_WEST_SOUTH;
				else if (toX - x == -1 && toY - y == -1)
					dir = EnumDirection.CW_WEST_NORTH;
				else if (toX - x == 1 && toY - y == 0)
					dir = EnumDirection.CW_EAST;
				else if (toX - x == -1 && toY - y == 0)
					dir |= EnumDirection.CW_WEST;
				else if (toY - y == 1 && toX - x == 0)
					dir |= EnumDirection.CW_SOUTH;
				else if (toY - y == -1 && toX - x == 0)
					dir |= EnumDirection.CW_NORTH;
//				else
//					SDebug.errorPrint(paths, "路径方向异常脱节！");

				if (dir)
					dirs.push(dir);
				x = toX;
				y = toY;
			}
			return dirs;
		}

		public static function getDxByAngle(value : Number, angle : Number) : Number
		{
			return UtilsCommon.cosd(angle) * value;
		}

		public static function getDyByAngle(value : Number, angle : Number) : Number
		{
			return UtilsCommon.sind(angle) * value;
		}

		/**
		 * 跳转地址
		 */
		public static function gotoURL(url : String, window : String = null) : void
		{
			navigateToURL(new URLRequest(url), window);
		}

		/**
		 * 获取字符串中的超链接内容
		 * @param str
		 * @return
		 */
		public static function getHref(str : String) : String
		{
			var reg : RegExp = /<[aA][^>]+>(.+?)<\/[aA]>/g;
			var array : Array = str.match(reg);
			return array.length > 0 ? array[0] : "";
		}

		public static function cloneByteArray(input : ByteArray) : ByteArray
		{
			var bytes : ByteArray = new ByteArray();
			input.position = 0;
			bytes.writeBytes(input, 0, input.length);
			return bytes;
		}

		public static function validParameter(value : String) : Boolean
		{
			return (value && value != "null" && value != "undefined");
		}

		/**
		 * a-b之间的随机数
		 * @param a
		 * @param b
		 * @return
		 *
		 */
		public static function random(a : int, b : int) : int
		{
			return a + (b - a) * Math.random();
		}

		/**
		 * 根据起始点，角度以及斜边算出目标点
		 * @param start
		 * @param rotation
		 * @param len
		 * @return 目标点
		 *
		 */
		public static function getPointByPointAndRotation(start : Point, rotation : Number, len : int) : Point
		{
			var result : Point = new Point();
			var newTotation : Number = fixAngle(rotation);
			var x : Number = Math.cos(getRotateByAngle(rotation)) * len;
			var y : Number = Math.sin(getRotateByAngle(rotation)) * len;
			result.x = x + start.x;
			result.y = y + start.y;
			return result;
		}

		public static function arrayIsEqual(array1 : Object, array2 : Object) : Boolean
		{
			if (array1.length != array2.length)
				return false;
			for (var i : int = 0; i < array1.length; i++)
			{
				if (array1[i] != array2[i])
					return false;
			}
			return true;
		}
	}
}