package hy.rpg.state
{
	import hy.game.core.GameObject;
	import hy.game.state.SBaseState;
	import hy.game.state.StateComponent;
	
	public class StateWalk extends SBaseState
	{
		public function StateWalk(gameObject:GameObject, stateMgr:StateComponent)
		{
			super(gameObject, stateMgr);
		}
	}
}