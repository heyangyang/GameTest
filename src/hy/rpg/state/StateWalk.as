package hy.rpg.state
{
	import hy.game.avatar.SActionType;
	import hy.game.core.GameObject;
	import hy.game.core.STime;
	import hy.game.namespaces.name_part;
	import hy.game.state.SBaseState;
	import hy.game.state.StateComponent;
	import hy.rpg.seek.SRoadSeeker;
	import hy.rpg.utils.UtilsCommon;
	use namespace name_part;

	public class StateWalk extends SBaseState
	{
		protected var m_seekRoad : SRoadSeeker;
		private var m_paths : Array;
		private var m_step : int;
		private var m_stepEnd : int;
		private var m_lastTargetGridX : int;
		private var m_lastTargetGridY : int;
		private var m_targetDistance : int;
		private var m_targetAnagle : int;
		private var m_moveSpeed : Number;

		public function StateWalk(gameObject : GameObject, stateMgr : StateComponent)
		{
			super(gameObject, stateMgr);
			m_action = SActionType.RUN;
			m_id = EnumState.WALK;
			m_seekRoad = SRoadSeeker.getInstance();
		}

		/**
		 * 尝试是否可以转换该状态
		 * @return
		 *
		 */
		override public function tryChangeState() : Boolean
		{
			if (m_seekRoad.isBlock(m_data.targetGridX, m_data.targetGridY))
				return false;
			m_paths = m_seekRoad.find(UtilsCommon.getGridXByPixel(m_transform.x), UtilsCommon.getGridXByPixel(m_transform.x), m_data.targetGridX, m_data.targetGridY);
			if (!m_paths || m_paths.length == 0)
				return false;
			return true;
		}

		/**
		 * 进入当前动作处理
		 *
		 */
		override public function enterState() : void
		{
			m_lastTargetGridX = m_data.targetGridX;
			m_lastTargetGridY = m_data.targetGridY;
			m_stepEnd = m_paths.length;
			m_step = 0;
		}

		/**
		 * 更新动作
		 * @param delay
		 *
		 */
		override public function update() : void
		{
			super.update();
			if (m_lastTargetGridX != m_data.targetGridX || m_lastTargetGridY != m_data.targetGridY)
			{
				if (!tryChangeState())
				{
					onStand();
					return;
				}
				enterState();
			}

			m_targetDistance = UtilsCommon.getDistance(m_transform.x, m_transform.y, m_data.targetX, m_data.targetY);
			m_moveSpeed = m_data.speed * STime.deltaTime;
			m_targetAnagle = UtilsCommon.getAngle(m_transform.x, m_transform.y, m_data.targetX, m_data.targetY);

			//距离小于速度,达到这格格子末尾
			if (m_targetDistance <= Math.ceil(m_moveSpeed))
			{
				onStand();
			}
			else
			{
				m_transform.dir = UtilsCommon.getDirection(m_targetAnagle);
				m_transform.mx = UtilsCommon.cosd(m_targetAnagle) * m_moveSpeed;
				m_transform.my = UtilsCommon.sind(m_targetAnagle) * m_moveSpeed;
				m_transform.x += m_transform.mx;
				m_transform.y += m_transform.my;
			}
		}

		private function onStand() : void
		{
			changeStateId(EnumState.STAND);
		}
	}
}