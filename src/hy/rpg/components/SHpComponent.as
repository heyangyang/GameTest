package hy.rpg.components
{
	import hy.game.components.SRenderComponent;
	import hy.rpg.enmu.SRenderLayerType;
	import hy.rpg.utils.SHpBarUtils;

	/**
	 * 血条组件
	 * @author wait
	 *
	 */
	public class SHpComponent extends SRenderComponent
	{
		private var m_lastHp : int;
		private var m_oldHeight : int;
		private var m_roleData : SRoleComponentData;

		public function SHpComponent(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			m_roleData = m_owner.getComponentByType(SRoleComponentData) as SRoleComponentData;
			m_render.x = -30;
			m_render.layer=SRenderLayerType.HP;
			m_oldHeight=m_lastHp=-1;
		}

		override public function update() : void
		{
			if (m_lastHp != m_roleData.hp_cur)
			{
				m_lastHp = m_roleData.hp_cur;
				m_render.bitmapData = SHpBarUtils.getHp(m_roleData.hp_cur / m_roleData.hp_max * 100);
			}
			if (m_transform.height > 0 && m_transform.height != m_oldHeight)
			{
				m_oldHeight = m_transform.height;
				m_render.y = -m_oldHeight - m_offsetY;
			}
		}
	}
}