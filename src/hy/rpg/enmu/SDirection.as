package  hy.rpg.enmu
{
	import hy.game.utils.SDebug;
	import hy.rpg.utils.SCommonUtil;

	/**
	 *
	 * <p>
	 * SunnyGame的一个方向枚举
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
	public final class SDirection
	{
		/**
		 * 方向模式，横向一方向
		 */
		public static const DIR_MODE_HOR_ONE : uint = 1;
		public static const DIR_MODE_TWO : uint = 2;
		/**
		 * 方向模式，五方向
		 */
		public static const DIR_MODE_FIVE : uint = 3;
		public static const EIGHT_DIR : uint = 4;
		/**
		 * 方向模式，Diagonal 斜向两方向
		 */
		public static const DIR_MODE_DIA_TWO : uint = 5;
		/**
		 * 方向模式，Vertical 垂直一方向
		 */
		public static const DIR_MODE_VER_ONE : uint = 6;
		/**
		 * 方向模式，北方向
		 */
		public static const DIR_MODE_NORTH : uint = 7;
		/**
		 * 方向模式，南方向
		 */
		public static const DIR_MODE_SOUTH : uint = 8;

		/**
		 * 以左边3向为准向右翻转
		 */
		public static const MIRROR_REVERSE_LEFT : uint = 1;
		/**
		 * 以右边3向为准向左翻转
		 */
		public static const MIRROR_REVERSE_RIGHT : uint = 2;
		/**
		 * 反转模式
		 */
		public static const mirrorReverseMode : uint = MIRROR_REVERSE_RIGHT;

		/**
		 * 左边五向
		 */
		public static const leftFiveDirs : Array = [SDirection.WEST, SDirection.WEST_NORTH, SDirection.WEST_SOUTH, SDirection.SOUTH, SDirection.NORTH];
		/**
		 * 右边五向
		 */
		public static const rightFiveDirs : Array = [SDirection.EAST, SDirection.EAST_NORTH, SDirection.EAST_SOUTH, SDirection.SOUTH, SDirection.NORTH];
		/**
		 * 左边一向
		 */
		public static const leftOneDirs : Array = [SDirection.WEST];
		/**
		 * 右边一向
		 */
		public static const rightOneDirs : Array = [SDirection.EAST];
		/**
		 * 横两向
		 */
		public static const twoHorDirs : Array = [SDirection.EAST, SDirection.WEST];
		/**
		 * 纵一向
		 */
		public static const twoVerDirs : Array = [SDirection.NORTH, SDirection.SOUTH];
		/**
		 * 斜两向
		 */
		public static const twoDiaDirs : Array = [SDirection.EAST_NORTH, SDirection.EAST_SOUTH, SDirection.WEST_NORTH, SDirection.WEST_SOUTH];
		/**
		 * 八向
		 */
		public static const eightDirs : Array = [SDirection.EAST, SDirection.NORTH, SDirection.SOUTH, SDirection.WEST, SDirection.EAST_NORTH, SDirection.WEST_NORTH, SDirection.EAST_SOUTH, SDirection.WEST_SOUTH];

		/**
		 * 以左边3向为镜像向右翻转
		 */
		public static const leftReverseDirs : Array = [SDirection.EAST, SDirection.EAST_NORTH, SDirection.EAST_SOUTH];
		/**
		 * 以右边3向为镜像向左翻转
		 */
		public static const rightReverseDirs : Array = [SDirection.WEST, SDirection.WEST_NORTH, SDirection.WEST_SOUTH];

		/**
		 * 无方向
		 */
		public static const NONE : uint = 0;

		/**
		 * 东
		 */
		public static const EAST : uint = 1;
		/**
		 * 西
		 */
		public static const WEST : uint = 2;
		/**
		 * 南
		 */
		public static const SOUTH : uint = 3;
		/**
		 * 北
		 */
		public static const NORTH : uint = 4;
		/**
		 * 东南
		 */
		public static const EAST_SOUTH : uint = 5;
		/**
		 * 东北
		 */
		public static const EAST_NORTH : uint = 6;
		/**
		 * 西南
		 */
		public static const WEST_SOUTH : uint = 7;
		/**
		 * 西北
		 */
		public static const WEST_NORTH : uint = 8;

		public static const DIRECTION_TYPE_MAP : Array = [EAST, WEST, SOUTH, NORTH, EAST_SOUTH, EAST_NORTH, WEST_SOUTH, WEST_NORTH];
		public static const DIRECTION_NAME_MAP : Array = ["east", "west", "south", "north", "east_south", "east_north", "west_south", "west_north"];
		public static const DIRECTION_CHINESE_NAME_MAP : Array = ["东", "西", "南", "北", "东南", "东北", "西南", "西北"];

		/**
		 * 顺时针北clockwise (C.W.)
		 */
		public static const CW_NORTH : uint = 1;
		/**
		 * 顺时针东北
		 */
		public static const CW_EAST_NORTH : uint = 2;
		/**
		 * 顺时针东
		 */
		public static const CW_EAST : uint = 3;
		/**
		 * 顺时针东南
		 */
		public static const CW_EAST_SOUTH : uint = 4;
		/**
		 * 顺时针南
		 */
		public static const CW_SOUTH : uint = 5;
		/**
		 * 顺时针西南
		 */
		public static const CW_WEST_SOUTH : uint = 6;
		/**
		 * 顺时针西
		 */
		public static const CW_WEST : uint = 7;
		/**
		 * 顺时针西北
		 */
		public static const CW_WEST_NORTH : uint = 8;


		/**
		 * 东
		 */
		public static const BIT_E : int = 1;
		/**
		 * 西
		 */
		public static const BIT_W : int = 2;
		/**
		 * 南
		 */
		public static const BIT_S : int = 4;
		/**
		 * 北
		 */
		public static const BIT_N : int = 8;
		/**
		 * 东南
		 */
		public static const BIT_SE : int = BIT_S | BIT_E;
		/**
		 * 东北
		 */
		public static const BIT_NE : int = BIT_N | BIT_E;
		/**
		 * 西南
		 */
		public static const BIT_SW : int = BIT_S | BIT_W;
		/**
		 * 西北
		 */
		public static const BIT_NW : int = BIT_N | BIT_W;

		public static function getCWDirectionByDirection(direction : uint) : uint
		{
			switch (direction)
			{
				case EAST:
					return CW_EAST;
				case WEST:
					return CW_WEST;
				case SOUTH:
					return CW_SOUTH;
				case NORTH:
					return CW_NORTH;
				case EAST_SOUTH:
					return CW_EAST_SOUTH;
				case EAST_NORTH:
					return CW_EAST_NORTH;
				case WEST_SOUTH:
					return CW_WEST_SOUTH;
				case WEST_NORTH:
					return CW_WEST_NORTH;
			}
			return 0;
		}

		public static function getDirectionByCWDirection(direction : uint) : uint
		{
			switch (direction)
			{
				case CW_EAST:
					return EAST;
				case CW_WEST:
					return WEST;
				case CW_SOUTH:
					return SOUTH;
				case CW_NORTH:
					return NORTH;
				case CW_EAST_SOUTH:
					return EAST_SOUTH;
				case CW_EAST_NORTH:
					return EAST_NORTH;
				case CW_WEST_SOUTH:
					return WEST_SOUTH;
				case CW_WEST_NORTH:
					return WEST_NORTH;
			}
			return 0;
		}

		public static const STR_N : String = 'north';
		public static const STR_S : String = 'south';
		public static const STR_W : String = 'west';
		public static const STR_E : String = 'east';
		public static const STR_NW : String = 'northWest';
		public static const STR_NE : String = 'northEast';
		public static const STR_SW : String = 'southWest';
		public static const STR_SE : String = 'southEast';

		public static const ANGLE_E : Number = 0;
		public static const ANGLE_SE : Number = 45;
		public static const ANGLE_S : Number = 90;
		public static const ANGLE_SW : Number = 135;
		public static const ANGLE_W : Number = 180;
		public static const ANGLE_NW : Number = 225;
		public static const ANGLE_N : Number = 270;
		public static const ANGLE_NE : Number = 315;

		public static const SIN_E : Number = 0;
		public static const SIN_SE : Number = 0.7071067811865475;
		public static const SIN_S : Number = 1;
		public static const SIN_SW : Number = 0.7071067811865475;
		public static const SIN_W : Number = 0;
		public static const SIN_NW : Number = -0.7071067811865475;
		public static const SIN_N : Number = -1;
		public static const SIN_NE : Number = -0.7071067811865475;

		public static const COS_E : Number = 1;
		public static const COS_SE : Number = 0.7071067811865475;
		public static const COS_S : Number = 0;
		public static const COS_SW : Number = -0.7071067811865475;
		public static const COS_W : Number = -1;
		public static const COS_NW : Number = -0.7071067811865475;
		public static const COS_N : Number = 0;
		public static const COS_NE : Number = 0.7071067811865475;

		public static const STR_DIR : Array = [];
		public static const ANGLE_DIR : Array = [];
		public static const SIN_DIR : Array = [];
		public static const COS_DIR : Array = [];
		public static const REVERSE_DIR : Array = [];
		public static const BIT_DIR : Array = [];

		public static const X_SPEED_DIR : Array = [];
		public static const Y_SPEED_DIR : Array = [];

		ANGLE_DIR[NORTH] = ANGLE_N;
		ANGLE_DIR[SOUTH] = ANGLE_S;
		ANGLE_DIR[WEST] = ANGLE_W;
		ANGLE_DIR[EAST] = ANGLE_E;
		ANGLE_DIR[WEST_NORTH] = ANGLE_NW;
		ANGLE_DIR[EAST_NORTH] = ANGLE_NE;
		ANGLE_DIR[WEST_SOUTH] = ANGLE_SW;
		ANGLE_DIR[EAST_SOUTH] = ANGLE_SE;

		STR_DIR[NORTH] = STR_N;
		STR_DIR[SOUTH] = STR_S;
		STR_DIR[WEST] = STR_W;
		STR_DIR[EAST] = STR_E;
		STR_DIR[WEST_NORTH] = STR_NW;
		STR_DIR[EAST_NORTH] = STR_NE;
		STR_DIR[WEST_SOUTH] = STR_SW;
		STR_DIR[EAST_SOUTH] = STR_SE;

		SIN_DIR[NORTH] = SIN_N;
		SIN_DIR[SOUTH] = SIN_S;
		SIN_DIR[WEST] = SIN_W;
		SIN_DIR[EAST] = SIN_E;
		SIN_DIR[WEST_NORTH] = SIN_NW;
		SIN_DIR[EAST_NORTH] = SIN_NE;
		SIN_DIR[WEST_SOUTH] = SIN_SW;
		SIN_DIR[EAST_SOUTH] = SIN_SE;

		COS_DIR[NORTH] = COS_N;
		COS_DIR[SOUTH] = COS_S;
		COS_DIR[WEST] = COS_W;
		COS_DIR[EAST] = COS_E;
		COS_DIR[WEST_NORTH] = COS_NW;
		COS_DIR[EAST_NORTH] = COS_NE;
		COS_DIR[WEST_SOUTH] = COS_SW;
		COS_DIR[EAST_SOUTH] = COS_SE;

		REVERSE_DIR[NORTH] = SOUTH;
		REVERSE_DIR[SOUTH] = NORTH;
		REVERSE_DIR[WEST] = EAST;
		REVERSE_DIR[EAST] = WEST;
		REVERSE_DIR[WEST_NORTH] = EAST_SOUTH;
		REVERSE_DIR[EAST_NORTH] = WEST_SOUTH;
		REVERSE_DIR[WEST_SOUTH] = EAST_NORTH;
		REVERSE_DIR[EAST_SOUTH] = WEST_NORTH;

		BIT_DIR[NORTH] = BIT_N;
		BIT_DIR[SOUTH] = BIT_S;
		BIT_DIR[WEST] = BIT_W;
		BIT_DIR[EAST] = BIT_E;
		BIT_DIR[WEST_NORTH] = BIT_NW;
		BIT_DIR[EAST_NORTH] = BIT_NE;
		BIT_DIR[WEST_SOUTH] = BIT_SW;
		BIT_DIR[EAST_SOUTH] = BIT_SE;

		X_SPEED_DIR[NORTH] = 0;
		X_SPEED_DIR[SOUTH] = 0;
		X_SPEED_DIR[WEST] = -4.472135;
		X_SPEED_DIR[EAST] = 4.472135;
		X_SPEED_DIR[WEST_NORTH] = -4;
		X_SPEED_DIR[EAST_NORTH] = 4
		X_SPEED_DIR[WEST_SOUTH] = -4
		X_SPEED_DIR[EAST_SOUTH] = 4;

		/*		X_SPEED_DIR[N]  = 0;
		   X_SPEED_DIR[S]  = 0;
		   X_SPEED_DIR[W]  = -5.68;
		   X_SPEED_DIR[E]  = 5.68;
		   X_SPEED_DIR[NW] = -5;
		   X_SPEED_DIR[NE] = 5
		   X_SPEED_DIR[SW] = -5
		 X_SPEED_DIR[SE] = 5;*/

		Y_SPEED_DIR[NORTH] = -4.472135;
		Y_SPEED_DIR[SOUTH] = 4.472135;
		Y_SPEED_DIR[WEST] = 0;
		Y_SPEED_DIR[EAST] = 0;
		Y_SPEED_DIR[WEST_NORTH] = -2;
		Y_SPEED_DIR[EAST_NORTH] = -2;
		Y_SPEED_DIR[WEST_SOUTH] = 2;
		Y_SPEED_DIR[EAST_SOUTH] = 2;

		/*		Y_SPEED_DIR[N]  = -5.68;
		   Y_SPEED_DIR[S]  = 5.68;
		   Y_SPEED_DIR[W]  = 0;
		   Y_SPEED_DIR[E]  = 0;
		   Y_SPEED_DIR[NW] = -2.5;
		   Y_SPEED_DIR[NE] = -2.5;
		   Y_SPEED_DIR[SW] = 2.5;
		 Y_SPEED_DIR[SE] = 2.5;*/

		/**
		 * 将值转换成中文方向
		 * @param value
		 * @return
		 */
		public static function getChineseByDirection(value : uint) : String
		{
			var index : int = DIRECTION_TYPE_MAP.indexOf(value);
			if (index != -1)
				return DIRECTION_CHINESE_NAME_MAP[index];
			return null;
		}

		/**
		 * 将中文方向转换成值
		 * @param value
		 * @return
		 */
		public static function getDirectionByChinese(value : String) : uint
		{
			var index : int = DIRECTION_CHINESE_NAME_MAP.indexOf(value);
			if (index != -1)
				return DIRECTION_TYPE_MAP[index];
			return 0;
		}

		/**
		 * 中文方向转换为英文
		 * @param value
		 * @return
		 *
		 */
		public static function directionToEnglish(value : String) : String
		{
			if (value == "东")
				return "East";
			else if (value == "西")
				return "West";
			else if (value == "南")
				return "South";
			else if (value == "北")
				return "North";
			else if (value == "东南")
				return "EastSouth";
			else if (value == "东北")
				return "EastNorth";
			else if (value == "西南")
				return "WestSouth";
			else if (value == "西北")
				return "WestNorth";
			return "";
		}

		public static function getDirectionNameByType(type : uint) : String
		{
			var index : int = DIRECTION_TYPE_MAP.indexOf(type);
			if (index != -1)
				return DIRECTION_NAME_MAP[index];
			if (SDebug.OPEN_WARNING_TRACE)
				SDebug.warningPrint(type, "没有方向为%s的方向名称！", type);
			return null;
		}

		public static function getDirectionByName(name : String) : uint
		{
			var index : int = DIRECTION_NAME_MAP.indexOf(name.toLowerCase());
			if (index != -1)
				return DIRECTION_TYPE_MAP[index];
			if (SDebug.OPEN_WARNING_TRACE)
				SDebug.warningPrint(name, "没有方向名称为%s的方向！", name);
			return 0;
		}

		/**
		 * 矫正东西方向，南北方向采用保留东西方向的方案
		 * @param dir
		 * @return
		 *
		 */
		public static function getCorrectHorizontalDir(dir : uint) : uint
		{
			if (dir == EAST_NORTH || dir == EAST_SOUTH)
				return EAST;
			else if (dir == WEST_NORTH || dir == WEST_SOUTH)
				return WEST;
			return dir;
		}

		public static function getCorrectDiagonalDir(lastDir : uint, dir : uint) : uint
		{
			if (dir == EAST)
			{
				if (lastDir == WEST_SOUTH)
					return EAST_SOUTH;
				else if (lastDir == WEST_NORTH)
					return EAST_NORTH;
				return EAST_SOUTH;
			}
			else if (dir == WEST)
			{
				if (lastDir == EAST_SOUTH)
					return WEST_SOUTH;
				else if (lastDir == EAST_NORTH)
					return WEST_NORTH;
				return WEST_SOUTH;
			}
			else if (dir == NORTH)
			{
				if (lastDir == EAST_SOUTH)
					return EAST_NORTH;
				else if (lastDir == WEST_SOUTH)
					return WEST_NORTH;
				return EAST_NORTH;
			}
			else if (dir == SOUTH)
			{
				if (lastDir == EAST_NORTH)
					return EAST_SOUTH;
				else if (lastDir == WEST_NORTH)
					return WEST_SOUTH;
				return EAST_SOUTH;
			}
			return dir;
		}

		public static function getCorrectVerticalDir(dir : uint) : uint
		{
			if (dir == EAST_NORTH || dir == WEST_NORTH)
				return NORTH;
			else if (dir == EAST_SOUTH || dir == WEST_SOUTH)
				return SOUTH;
			return dir;
		}

		public static function getCorrectNorthDir(dir : uint) : uint
		{
			return NORTH;
		}

		public static function getCorrectSouthDir(dir : uint) : uint
		{
			return SOUTH;
		}

		/**
		 * 矫正后的方向
		 * @return
		 *
		 */
		public static function correctDirection(dirMode : uint, lastDir : uint, dir : uint) : uint
		{
			var result : uint = lastDir;
			var correctDir : uint = 0;
			if (dirMode == DIR_MODE_HOR_ONE)
				correctDir = getCorrectHorizontalDir(dir);
			else if (dirMode == DIR_MODE_DIA_TWO)
				correctDir = getCorrectDiagonalDir(lastDir, dir);
			else if (dirMode == DIR_MODE_VER_ONE)
				correctDir = getCorrectVerticalDir(dir);
			else if (dirMode == DIR_MODE_NORTH)
				correctDir = getCorrectNorthDir(dir);
			else if (dirMode == DIR_MODE_SOUTH)
				correctDir = getCorrectSouthDir(dir);
			else if (dirMode == DIR_MODE_FIVE)
				correctDir = dir;
			if (isAvaliableDir(dirMode, correctDir))
				result = correctDir;
			return result;
		}

		public static function equalsDirection(sourceDirMode : uint, sourceDir : uint, sourceLastDir : uint, targetDir : uint) : Boolean
		{
			var sourceCorrectDir : uint = correctDirection(sourceDirMode, sourceLastDir, sourceDir);
			var targetCorrectDir : uint = correctDirection(sourceDirMode, sourceLastDir, targetDir);
			return sourceCorrectDir == targetCorrectDir;
		}

		/**
		 * 检查是否符合5向或1向反转条件
		 * @param dirs
		 * @param reverseMode
		 * @return
		 */
		public static function checkDirsReversable(dirMode : uint, dirs : Array, reverseMode : int) : Boolean
		{
			var dirCount : int = 0;
			if (dirMode == DIR_MODE_HOR_ONE)
				dirCount = 1;
			else if (dirMode == DIR_MODE_FIVE)
				dirCount = 5;

			if (dirs.length < dirCount)
				return false;
			if (reverseMode == MIRROR_REVERSE_LEFT)
			{
				for each (var dir : int in leftFiveDirs)
				{
					if (dirs.indexOf(dir) == -1)
						return false;
				}
			}
			else
			{
				for each (dir in rightFiveDirs)
				{
					if (dirs.indexOf(dir) == -1)
						return false;
				}
			}
			return true;
		}

		/**
		 * 检查方向模式
		 * @param dirs
		 * @return
		 *
		 */
		public static function checkDirsDirMode(dirs : Array) : uint
		{
			if (dirs.length == 1)
			{
				if (dirs.indexOf(NORTH) != -1)
					return DIR_MODE_NORTH;
				else if (dirs.indexOf(SOUTH) != -1)
					return DIR_MODE_SOUTH;
				else
					return DIR_MODE_HOR_ONE;
			}
			else if (dirs.length == 2)
			{
				if (dirs.indexOf(WEST_NORTH) != -1 || dirs.indexOf(WEST_SOUTH) != -1 || dirs.indexOf(EAST_NORTH) != -1 || dirs.indexOf(EAST_SOUTH) != -1)
					return DIR_MODE_DIA_TWO;
				else if (dirs.indexOf(NORTH) != -1 || dirs.indexOf(SOUTH) != -1)
					return DIR_MODE_VER_ONE;
			}
			else if (dirs.length == 3)
			{
				return DIR_MODE_FIVE;
			}
			else if (dirs.length == 5)
			{
				return DIR_MODE_FIVE;
			}
			return 0;
		}

		/**
		 * 获取一个方向的反向
		 * @param dir
		 */
		public static function getMirrorReversal(direction : uint) : uint
		{
			if (mirrorReverseMode == MIRROR_REVERSE_RIGHT)
			{
				switch (direction)
				{
					case SDirection.WEST:
						return SDirection.EAST;
					case SDirection.WEST_SOUTH:
						return SDirection.EAST_SOUTH;
					case SDirection.WEST_NORTH:
						return SDirection.EAST_NORTH;
					case SDirection.EAST_NORTH:
						return SDirection.EAST_NORTH;
					case SDirection.NORTH:
						return SDirection.NORTH;
					case SDirection.SOUTH:
						return SDirection.SOUTH;
					case SDirection.EAST:
						return SDirection.EAST;
					case SDirection.EAST_SOUTH:
						return SDirection.EAST_SOUTH;
				}
			}
			else
			{
				switch (direction)
				{
					case SDirection.EAST:
						return SDirection.WEST;
					case SDirection.EAST_NORTH:
						return SDirection.WEST_NORTH;
					case SDirection.EAST_SOUTH:
						return SDirection.WEST_SOUTH;
					case SDirection.WEST:
						return SDirection.WEST;
					case SDirection.NORTH:
						return SDirection.NORTH;
					case SDirection.SOUTH:
						return SDirection.SOUTH;
					case SDirection.WEST_NORTH:
						return SDirection.WEST_NORTH;
					case SDirection.WEST_SOUTH:
						return SDirection.WEST_SOUTH;
				}
			}
			return 0;
		}

		/**
		 * 反转坐标
		 * @param dir
		 * @return
		 *
		 */
		public static function reverseDirection(dir : int) : int
		{
			switch (dir)
			{
				case SDirection.WEST:
					return SDirection.EAST;
				case SDirection.WEST_SOUTH:
					return SDirection.EAST_NORTH;
				case SDirection.WEST_NORTH:
					return SDirection.EAST_SOUTH;
				case SDirection.EAST_NORTH:
					return SDirection.WEST_SOUTH;
				case SDirection.NORTH:
					return SDirection.SOUTH;
				case SDirection.SOUTH:
					return SDirection.NORTH;
				case SDirection.EAST:
					return SDirection.WEST;
				case SDirection.EAST_SOUTH:
					return SDirection.WEST_NORTH;
					break;
			}
			return -1;
		}

		/**
		 * 是否背对方向
		 * @param dir
		 * @return
		 *
		 */
		public static function isBackDirection(dir : int) : Boolean
		{
			switch (dir)
			{
				case SDirection.WEST_NORTH:
					return true;
				case SDirection.EAST_NORTH:
					return true;
				case SDirection.NORTH:
					return true;
			}
			return false;
		}

		/**
		 * 是否有效方向
		 * @param dir
		 * @return
		 *
		 */
		public static function isAvaliableDir(dirMode : uint, dir : uint) : Boolean
		{
			if (dirMode == DIR_MODE_HOR_ONE)
			{
				if (twoHorDirs.indexOf(dir) == -1)
					return false;
			}
			else if (dirMode == DIR_MODE_VER_ONE)
			{
				if (twoVerDirs.indexOf(dir) == -1)
					return false;
			}
			else if (dirMode == DIR_MODE_NORTH)
			{
				if (dir != NORTH)
					return false;
			}
			else if (dirMode == DIR_MODE_SOUTH)
			{
				if (dir != SOUTH)
					return false;
			}
			else if (dirMode == DIR_MODE_DIA_TWO)
			{
				if (twoDiaDirs.indexOf(dir) == -1)
					return false;
			}
			else if (dirMode == DIR_MODE_FIVE)
			{
				if (eightDirs.indexOf(dir) == -1)
					return false;
			}
			return true;
		}

		/**
		 * 确定是否dir是需要通过反转的方向
		 * @param dir
		 * @return
		 */
		public static function needMirrorReversal(dir : int) : Boolean
		{
			if (mirrorReverseMode == MIRROR_REVERSE_LEFT)
			{
				return leftReverseDirs.indexOf(dir) != -1;
			}
			else
			{
				return rightReverseDirs.indexOf(dir) != -1;
			}
			return false;
		}

		/**
		 * 把反向的也全部计算进入数组
		 * @param dirs
		 * @return
		 */
		public static function getReversalDirs(dirs : Array) : Array
		{
			var result : Array = dirs.slice();
			for (var i : int = dirs.length - 1; i >= 0; i--)
			{
				var revesalDir : int = SCommonUtil.getReverseDirByDir(dirs[i]); //取反向
				if (needMirrorReversal(revesalDir))
				{ //是在需要通过反转的方向 
					if (dirs.indexOf(revesalDir) == -1)
						result.push(revesalDir);
				}
			}
			return result;
		}

		/**
		 * 根据方向取X方向正负
		 * @param dir
		 * @return
		 *
		 */
		public static function getXPlusMinusByDir(dir : uint, lastDir : uint = 0) : int
		{
			var plusMinus : int = 1;
			switch (dir)
			{
				case SDirection.EAST:
				case SDirection.EAST_SOUTH:
				case SDirection.EAST_NORTH:
					break;
				case SDirection.SOUTH:
				case SDirection.NORTH:
					if (lastDir == SDirection.WEST || lastDir == SDirection.WEST_NORTH || lastDir == SDirection.WEST_SOUTH)
						plusMinus = -1;
					break;
				case SDirection.WEST:
				case SDirection.WEST_SOUTH:
				case SDirection.WEST_NORTH:
					plusMinus = -1;
					break;
			}
			return plusMinus;
		}

		/**
		 * 根据方向取Y方向正负
		 * @param dir
		 * @return
		 *
		 */
		public static function getYPlusMinusByDir(dir : uint, lastDir : uint = 0) : int
		{
			var plusMinus : int = 1;
			switch (dir)
			{
				case SDirection.EAST:
				case SDirection.WEST:
				case SDirection.SOUTH:
					break;
				case SDirection.EAST_SOUTH:
				case SDirection.WEST_SOUTH:
					if (lastDir == SDirection.NORTH || lastDir == SDirection.EAST_NORTH || lastDir == SDirection.WEST_NORTH)
						plusMinus = -1;
					break;
				case SDirection.NORTH:
				case SDirection.EAST_NORTH:
				case SDirection.WEST_NORTH:
					plusMinus = -1;
					break;
			}
			return plusMinus;
		}
	}
}