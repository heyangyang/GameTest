package hy.rpg.state
{
	import hy.game.avatar.SActionType;
	import hy.game.core.GameObject;
	import hy.game.state.SBaseState;
	import hy.game.state.StateComponent;

	public class StateStand extends SBaseState
	{

		public function StateStand(gameObject : GameObject, stateMgr : StateComponent)
		{
			super(gameObject, stateMgr);
			m_action = SActionType.IDLE;
			m_id = EnumState.STAND;
		}

		/**
		 * 进入当前动作处理
		 *
		 */
		override public function enterState() : void
		{
		}
	}
}