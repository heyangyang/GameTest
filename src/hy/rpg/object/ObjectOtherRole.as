package hy.rpg.object
{
	import hy.game.core.GameObject;
	import hy.game.core.SCameraObject;
	import hy.game.data.STransform;

	public class ObjectOtherRole extends GameObject
	{
		public function ObjectOtherRole()
		{
			super();
		}

		public override function set transform(value : STransform) : void
		{
			super.transform = value;
			SCameraObject.moveNotify(updatePosition);
		}

//		protected override function updatePosition() : void
//		{
//			transform.x = transform.x;
//			transform.y = transform.y;
//		}
	}
}