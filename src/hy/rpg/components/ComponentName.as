package hy.rpg.components
{
	import hy.game.components.SRenderComponent;
	import hy.game.data.STransform;
	import hy.game.manager.SReferenceManager;
	import hy.rpg.enum.EnumRenderLayer;
	import hy.rpg.render.SNameParser;
	import hy.rpg.components.data.DataComponentRole;

	/**
	 * 名字组件
	 * @author wait
	 *
	 */
	public class ComponentName extends SRenderComponent
	{
		private var m_roleData : DataComponentRole;
		private var m_parser : SNameParser;

		public function ComponentName(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			m_render.layer = EnumRenderLayer.NAME;
			m_roleData = m_owner.getComponentByType(DataComponentRole) as DataComponentRole;
			m_offsetY = 20;
			updateRender();
		}

		override public function update() : void
		{
			if (m_roleData.updateName)
				updateRender();
			if (m_transform.isChangeFiled(STransform.C_XYZ) || m_transform.isChangeFiled(STransform.C_WH))
				m_render.y = -m_transform.height - m_transform.z - m_offsetY;
		}

		private function updateRender() : void
		{
			parser = SReferenceManager.getInstance().createRoleName(m_roleData.name + "[" + m_roleData.level + "级]");
			m_render.bitmapData = m_parser.bitmapData;
			m_render.x = -m_parser.bitmapData.width * .5;
			m_roleData.updateName = true;
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

		override public function destroy() : void
		{
			super.destroy();
			m_roleData = null;
			parser = null;
		}


	}
}