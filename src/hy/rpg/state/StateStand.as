package hy.rpg.state
{
	import hy.game.core.GameObject;
	import hy.game.state.SBaseState;
	import hy.game.state.StateComponent;
	
	public class StateStand extends SBaseState
	{
		public function StateStand(gameObject:GameObject, stateMgr:StateComponent)
		{
			super(gameObject, stateMgr);
		}
	}
}