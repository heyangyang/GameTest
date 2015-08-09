package hy.rpg.components
{
	import hy.game.core.FrameComponent;
	import hy.game.core.SCameraObject;
	import hy.game.core.STime;
	import hy.game.data.SPoint;
	import hy.game.state.StateComponent;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.seek.SRoadSeeker;
	import hy.rpg.state.EnumState;
	import hy.rpg.utils.UtilsCommon;

	public class ComponentAi extends FrameComponent
	{
		private var m_data : DataComponent;
		private var m_state : StateComponent;
		/**
		 * 更新间隔
		 */
		private const m_frameInterval : uint = 2000;
		/**
		 * 记录当前持续时间
		 */
		protected var m_frameElapsedTime : uint = 0;

		public function ComponentAi(type : * = null)
		{
			super(type);
		}

		/**
		 * 添加到容器的时候调用
		 * 一般参数设置，写这里
		 *
		 */
		override public function notifyAdded() : void
		{

		}

		/**
		 * 第一次更新前创调用
		 * 一般引用，写这里
		 */
		override protected function onStart() : void
		{
			m_data = m_owner.getComponentByType(DataComponent) as DataComponent;
			m_state = m_owner.getComponentByType(StateComponent) as StateComponent;
		}

		override public function update() : void
		{
			m_frameElapsedTime += STime.deltaTime;
			if (m_frameElapsedTime < m_frameInterval)
				return;
			m_frameElapsedTime -= m_frameInterval;
			//20%几率产生移动
			if (Math.random() > 0.2)
				return;
			runAnyWay();
		}

		private function runAnyWay() : void
		{
			var point : SPoint = SCameraObject.getVisualPoint();
			var gridX : int = UtilsCommon.getGridXByPixel(point.x);
			var gridY : int = UtilsCommon.getGridYByPixel(point.y);
			if (SRoadSeeker.getInstance().isBlock(gridX, gridY))
			{
				runAnyWay();
				return;
			}
			m_data.targetX = UtilsCommon.getPixelXByGrid(gridX);
			m_data.targetY = UtilsCommon.getPixelYByGrid(gridY);
			m_data.targetGridX = gridX;
			m_data.targetGridY = gridY;
			m_state.changeStateById(EnumState.WALK);
		}
	}
}