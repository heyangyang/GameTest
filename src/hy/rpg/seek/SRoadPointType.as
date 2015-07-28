package hy.rpg.seek
{

	/**
	 *
	 *  路点类型
	 *
	 */
	public class SRoadPointType
	{
		/**
		 * 可行走区域
		 */
		public static const WALKABLE_VALUE : int = 127;
		/**
		 * 遮罩区域
		 */
		public static const MASKABLE_VALUE : int = 63;
		/**
		 * 不可行走区域
		 */
		public static const UNWALKABLE_VALUE : int = 0;
		/**
		 * PK区域
		 */
		public static const SAFE_VALUE : int = 31;
		/**
		 * PK区域并且遮罩区域
		 */
		public static const SAFE_MASKABLE_VALUE : int = 93;
		/**
		 * 跳跃区域
		 */
		public static const JUMP_VALUE : int = 7;

		public function SRoadPointType()
		{
		}
	}
}