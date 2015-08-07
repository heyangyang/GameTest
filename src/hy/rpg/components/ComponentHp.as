package hy.rpg.components
{
	import hy.game.components.SRenderComponent;
	import hy.game.data.STransform;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.enum.EnumRenderLayer;
	import hy.rpg.utils.UtilsHpBar;

	/**
	 * 血条组件
	 * @author wait
	 *
	 */
	public class ComponentHp extends SRenderComponent
	{
		private var m_lastHp : int;
		private var m_isMouseOver : Boolean;
		private var m_data : DataComponent;
		private var m_isUpdatable : Boolean;

		public function ComponentHp(type : * = null)
		{
			super(type);
		}

		override protected function onStart() : void
		{
			super.onStart();
			m_data = m_owner.getComponentByType(DataComponent) as DataComponent;
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			m_render.x = -30;
			m_render.layer = EnumRenderLayer.HP;
			m_lastHp = -1;
		}

		override public function notifyRemoved() : void
		{
			super.notifyRemoved();
			m_data = null;
		}

		override public function update() : void
		{
			if (m_isMouseOver != m_transform.isMouseOver)
			{
				m_isMouseOver = m_transform.isMouseOver;
				updateRenderVisible();
			}
			if (m_lastHp != m_data.hp_cur)
			{
				m_lastHp = m_data.hp_cur;
				m_render.bitmapData = UtilsHpBar.getHp(m_data.hp_cur / m_data.hp_max * 100);
			}
			if (m_isUpdatable || m_transform.isChangeFiled(STransform.C_XYZ) || m_transform.isChangeFiled(STransform.C_WH))
			{
				m_isUpdatable = false;
				m_render.y = -m_transform.height - m_offsetY - m_transform.z + m_transform.centerOffsetY;
			}
		}

		override protected function updateRenderVisible() : void
		{
			if (m_isVisible || m_isMouseOver)
			{
				m_isUpdatable = true;
				addRender(m_render)
				return;
			}
			m_isUpdatable = false;
			removeRender(m_render);
		}
	}
}