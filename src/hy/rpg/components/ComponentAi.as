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
		private var mData : DataComponent;
		private var mState : StateComponent;
		/**
		 * 更新间隔
		 */
		private const mFrameInterval : uint = 2000;
		/**
		 * 记录当前持续时间
		 */
		protected var mFrameElapsedTime : uint = 0;

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
			mData = mOwner.getComponentByType(DataComponent) as DataComponent;
			mState = mOwner.getComponentByType(StateComponent) as StateComponent;
		}

		override public function update() : void
		{
			mFrameElapsedTime += STime.deltaTime;
			if (mFrameElapsedTime < mFrameInterval)
				return;
			mFrameElapsedTime -= mFrameInterval;
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
			mData.targetX = UtilsCommon.getPixelXByGrid(gridX);
			mData.targetY = UtilsCommon.getPixelYByGrid(gridY);
			mData.targetGridX = gridX;
			mData.targetGridY = gridY;
			mState.changeStateById(EnumState.WALK);
		}
	}
}