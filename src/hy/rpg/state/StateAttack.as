package hy.rpg.state
{
	import hy.game.avatar.SActionType;
	import hy.game.core.GameObject;
	import hy.game.state.SBaseState;
	import hy.game.state.StateComponent;
	
	public class StateAttack extends SBaseState
	{
		public function StateAttack(gameObject:GameObject, stateMgr:StateComponent)
		{
			super(gameObject, stateMgr);
			mAction = SActionType.ATTACK;
			mId = EnumState.ATTACK;
		}
	}
}