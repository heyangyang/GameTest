package hy.rpg.components.data
{
	import hy.game.components.data.SComponentData;
	import hy.game.data.STransform;

	public class DataComponent extends SComponentData
	{
		public var id : int;
		private var m_name : String;
		private var m_updateName : Boolean;
		public var speed : Number = 0.25;
		public var hp_max : int = 200;
		public var hp_cur : int = 200;
		public var level : int = 99;
		public var avatarId : String;
		public var weaponId : String;
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
			return m_name;
		}

		public function set name(value : String) : void
		{
			if (m_name == value)
				return;
			m_name = value;
			m_updateName = true;
		}

		/**
		 * 名字是否需要更新
		 * @return
		 *
		 */
		public function get updateName() : Boolean
		{
			return m_updateName;
		}

		public function set updateName(value : Boolean) : void
		{
			m_updateName = value;
		}

	}
}