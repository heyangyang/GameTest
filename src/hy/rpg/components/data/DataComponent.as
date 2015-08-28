package hy.rpg.components.data
{
	import hy.game.components.data.SComponentData;
	import hy.game.data.STransform;

	public class DataComponent extends SComponentData
	{
		public var id : int;
		public var isMe : Boolean;
		private var mName : String;
		private var mUpdateName : Boolean;
		public var speed : Number = 0.25;
		public var hp_max : int = 200;
		public var hp_cur : int = 200;
		public var level : int = 99;
		public var avatarId : String;
		public var weaponId : String;
		public var wingId : String;
		public var mountId : String;
		public var action : int;
		public var targetX : int;
		public var targetY : int;
		public var targetGridX : int;
		public var targetGridY : int;
		public var isRide : Boolean;
		public var transform : STransform;

		public function DataComponent(type : * = null)
		{
			super(type);
			transform = new STransform();
		}

		override public function notifyAdded() : void
		{
			updateName = true;
		}

		public function get name() : String
		{
			return mName;
		}

		public function set name(value : String) : void
		{
			if (mName == value)
				return;
			mName = value;
			mUpdateName = true;
		}

		/**
		 * 名字是否需要更新
		 * @return
		 *
		 */
		public function get updateName() : Boolean
		{
			return mUpdateName;
		}

		public function set updateName(value : Boolean) : void
		{
			mUpdateName = value;
		}

		/**
		 * 暂时不要销毁
		 *
		 */
		override public function dispose() : void
		{

		}

	}
}