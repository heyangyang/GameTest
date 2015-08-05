package hy.rpg.components
{
	import hy.game.components.SRenderComponent;
	import hy.game.data.STransform;
	import hy.game.manager.SReferenceManager;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.enum.EnumRenderLayer;
	import hy.rpg.render.SNameParser;

	/**
	 * 名字组件
	 * @author wait
	 *
	 */
	public class ComponentName extends SRenderComponent
	{
		private var m_data : DataComponent;
		private var m_parser : SNameParser;
		private var m_isMouseOver : Boolean;
		private var isUpdatable : Boolean;

		public function ComponentName(type : * = null)
		{
			super(type);
		}

		override protected function onStart() : void
		{
			super.onStart();
			m_data = m_owner.getComponentByType(DataComponent) as DataComponent;
			m_isMouseOver = m_data.isMe;
			!m_isMouseOver && removeRender(m_render);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			m_render.layer = EnumRenderLayer.NAME;
			m_offsetY = 20;
		}

		override public function notifyRemoved() : void
		{
			super.notifyRemoved();
			m_data = null;
			parser = null;
		}

		override public function update() : void
		{
			if (!m_data.isMe && m_isMouseOver != m_transform.isMouseOver)
			{
				isUpdatable = m_isMouseOver = m_transform.isMouseOver;
				m_isMouseOver ? addRender(m_render) : removeRender(m_render);
			}
			if (!m_isMouseOver)
				return;
			if (m_data.updateName)
				updateRender();
			if (isUpdatable || m_transform.isChangeFiled(STransform.C_XYZ) || m_transform.isChangeFiled(STransform.C_WH))
				m_render.y = -m_transform.height - m_offsetY - m_transform.z + m_transform.centerOffsetY;
		}

		private function updateRender() : void
		{
			parser = SReferenceManager.getInstance().createRoleName(m_data.name + "[" + m_data.level + "级]");
			m_render.bitmapData = m_parser.bitmapData;
			m_render.x = -m_parser.bitmapData.width * .5;
			m_data.updateName = false;
		}

		public function set parser(value : SNameParser) : void
		{
			m_parser && m_parser.release();
			m_parser = value;
		}

		override public function set offsetY(value : int) : void
		{
			m_offsetY = value;
		}
	}
}