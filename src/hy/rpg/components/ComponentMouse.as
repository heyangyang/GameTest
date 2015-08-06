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
		private const m_Interval : int = 100;

		private var m_data : DataComponent;
		private var m_state : StateComponent;
		private var m_delay : int;
		private var m_clickCount : int;

		public function ComponentMouse(type : * = null)
		{
			super(type);
		}

		override protected function onStart() : void
		{
			m_state = m_owner.getComponentByType(StateComponent) as StateComponent;
			m_data = m_owner.getComponentByType(DataComponent) as DataComponent;
			Config.stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		override public function notifyRemoved() : void
		{
			m_state = null;
			m_data = null;
			Config.stage.removeEventListener(MouseEvent.CLICK, onClick);
		}

		protected function onClick(evt : MouseEvent) : void
		{
			if (STime.getTimer - m_delay < m_Interval)
				return;
			m_delay = STime.getTimer;
			m_data.targetX = SCameraObject.sceneX + evt.stageX;
			m_data.targetY = SCameraObject.sceneY + evt.stageY;
			m_data.targetGridX = UtilsCommon.getGridXByPixel(m_data.targetX);
			m_data.targetGridY = UtilsCommon.getGridYByPixel(m_data.targetY);
			ManagerGameCreate.getInstance().createSceneEffect("clickRoad", (m_clickCount++).toString(), m_data.targetX, m_data.targetY, 1);
			m_state.changeStateById(EnumState.WALK);
		}
	}
}