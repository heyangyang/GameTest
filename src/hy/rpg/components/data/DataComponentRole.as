package hy.rpg.components.data
{
	import hy.game.components.data.SComponentData;

	public class DataComponentRole extends SComponentData
	{
		private var m_name : String;
		private var m_updateName : Boolean;
		public var speed : int;
		public var hp_max : int = 200;
		public var hp_cur : int = 200;
		public var level : int = 99;
		public var avatarId : String;
		public var weaponId : String;
		public var action : int;

		public function DataComponentRole(type : * = null)
		{
			super(type);
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