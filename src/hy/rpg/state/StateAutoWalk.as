package hy.rpg.state
{
	import hy.game.avatar.SActionType;
	import hy.game.core.GameObject;
	import hy.game.state.SBaseState;
	import hy.game.state.StateComponent;

	public class StateAutoWalk extends SBaseState
	{
		public function StateAutoWalk(gameObject : GameObject, stateMgr : StateComponent)
		{
			super(gameObject, stateMgr);
			mAction = SActionType.WALK;
			mId = EnumState.AUTO_WALK;
		}
	}
}