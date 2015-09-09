package hy.rpg.components
{
	import flash.events.MouseEvent;

	import hy.game.cfg.Config;
	import hy.game.core.FrameComponent;
	import hy.game.core.SCameraObject;
	import hy.game.core.STime;
	import hy.game.state.StateComponent;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.manager.ManagerGameCreate;
	import hy.rpg.seek.SRoadSeeker;
	import hy.rpg.state.EnumState;
	import hy.rpg.utils.UtilsCommon;

	/**
	 * 鼠标操作组件
	 * 只能创建一个
	 * @author wait
	 *
	 */
	public class ComponentMouse extends FrameComponent
	{
		/**
		 * 每次点击响应的间隔
		 */
		private const mInterval : int = 100;

		private var mSeekRoad : SRoadSeeker;
		private var mData : DataComponent;
		private var mState : StateComponent;
		private var mDelay : int;
		private var mClickCount : int;

		public function ComponentMouse(type : * = null)
		{
			super(type);
		}

		override protected function onStart() : void
		{
			mSeekRoad = SRoadSeeker.getInstance();
			mState = mOwner.getComponentByType(StateComponent) as StateComponent;
			mData = mOwner.getComponentByType(DataComponent) as DataComponent;
			Config.stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		override public function notifyRemoved() : void
		{
			mState = null;
			mData = null;
			Config.stage.removeEventListener(MouseEvent.CLICK, onClick);
		}

		protected function onClick(evt : MouseEvent) : void
		{
			if (STime.getTimer - mDelay < mInterval)
				return;
			mDelay = STime.getTimer;
			var clickGridX : int = UtilsCommon.getGridXByPixel(SCameraObject.sceneX + evt.stageX);
			var clickGridY : int = UtilsCommon.getGridYByPixel(SCameraObject.sceneY + evt.stageY);
			if (mSeekRoad.isBlock(clickGridX, clickGridY))
				return;
			mData.targetGridX = clickGridX;
			mData.targetGridY = clickGridY;
			mData.targetX = UtilsCommon.getPixelXByGrid(clickGridX);
			mData.targetY = UtilsCommon.getPixelYByGrid(clickGridY);
			ManagerGameCreate.getInstance().createSceneEffect("clickRoad", (mClickCount++).toString(), mData.targetX, mData.targetY, 1);
			mState.changeStateById(EnumState.WALK);
		}
	}
}