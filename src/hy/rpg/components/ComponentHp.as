package hy.rpg.components
{
	import hy.game.components.SRenderComponent;
	import hy.game.data.STransform;
	import hy.game.manager.SLayerManager;
	import hy.game.render.SRender;
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
				m_render.x = m_transform.screenX - 30;
				m_render.y = m_transform.screenY - m_transform.height - m_offsetY - m_transform.z + m_transform.centerOffsetY;
			}
		}

		/**
		 * 不添加到父类，直接添加到name层
		 * @param render
		 *
		 */
		protected override function addRender(render : SRender) : void
		{
			SLayerManager.getInstance().addRenderByType(SLayerManager.LAYER_HP, render);
		}

		protected override function removeRender(render : SRender) : void
		{
			SLayerManager.getInstance().removeRenderByType(SLayerManager.LAYER_HP, render);
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