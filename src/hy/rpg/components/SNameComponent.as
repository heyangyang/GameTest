package hy.rpg.components
{
	import hy.game.components.SRenderComponent;
	import hy.game.manager.SReferenceManager;
	import hy.rpg.render.SNameParser;
	
	/**
	 * 名字组件 
	 * @author wait
	 * 
	 */
	public class SNameComponent extends  SRenderComponent
	{
		private var m_roleData:SRoleComponentData;
		private var m_parser:SNameParser;
		private var m_oldHeight:int;
		public function SNameComponent(type:*=null)
		{
			super(type);
		}
		
		override public function notifyAdded() : void
		{
			super.notifyAdded();
			m_offsetY=20;
			m_roleData=m_owner.getComponentByType(SRoleComponentData) as SRoleComponentData;
			updateRender();
		}
		
		override public function update():void
		{
			if(m_roleData.updateName)
				updateRender();
			if(m_transform.height>0 && m_transform.height!=m_oldHeight)
			{
				m_oldHeight=m_transform.height;
				m_render.y=-m_oldHeight-m_offsetY;
			}
		}
		
		private function updateRender():void
		{
			parser=SReferenceManager.getInstance().createRoleName(m_roleData.name+"["+m_roleData.level+"级]");
			m_render.bitmapData=m_parser.bitmapData;
			m_render.x=-m_parser.bitmapData.width*.5;
			m_roleData.updateName=true;
		}

		public function set parser(value:SNameParser):void
		{
			m_parser&& m_parser.release();
			m_parser = value;
		}

		override public function set offsetY(value:int):void
		{
			m_offsetY = value;
			m_oldHeight=0;
		}
		
		override public function destroy():void
		{
			super.destroy();
			m_roleData=null;
			parser=null;
		}
			
			
	}
}