package hy.rpg.components
{
	import hy.game.components.SRenderComponent;
	import hy.game.data.STransform;
	import hy.rpg.enum.EnumRenderLayer;
	import hy.rpg.utils.UtilsHpBar;
	import hy.rpg.components.data.DataComponent;

	/**
	 * 血条组件
	 * @author wait
	 *
	 */
	public class ComponentHp extends SRenderComponent
	{
		private var m_lastHp : int;
		private var m_data : DataComponent;

		public function ComponentHp(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			m_data = m_owner.getComponentByType(DataComponent) as DataComponent;
			m_render.x = -30;
			m_render.layer = EnumRenderLayer.HP;
			m_lastHp = -1;
		}

		override public function update() : void
		{
			if (m_lastHp != m_data.hp_cur)
			{
				m_lastHp = m_data.hp_cur;
				m_render.bitmapData = UtilsHpBar.getHp(m_data.hp_cur / m_data.hp_max * 100);
			}
			if (m_transform.isChangeFiled(STransform.C_XYZ) || m_transform.isChangeFiled(STransform.C_WH))
			{
				m_render.y = -m_transform.height - m_offsetY - m_transform.z + m_transform.centerOffsetY;
			}
		}

		override public function destroy() : void
		{
			super.destroy();
			m_data = null;
		}
	}
}