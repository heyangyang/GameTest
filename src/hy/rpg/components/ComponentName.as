package hy.rpg.components
{
	import hy.game.components.SRenderComponent;
	import hy.game.manager.SLayerManager;
	import hy.game.manager.SReferenceManager;
	import hy.game.render.SRender;
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
		private var mData : DataComponent;
		private var mParser : SNameParser;
		private var mIsMouseOver : Boolean;
		private var mIsUpdatable : Boolean;

		public function ComponentName(type : * = null)
		{
			super(type);
		}

		override protected function onStart() : void
		{
			super.onStart();
			mData = m_owner.getComponentByType(DataComponent) as DataComponent;
			mTransform.addPositionChange(updatePosition);
			mTransform.addSizeChange(updatePosition);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			mRender.layer = EnumRenderLayer.NAME;
			mOffsetY = 20;
		}

		override public function notifyRemoved() : void
		{
			super.notifyRemoved();
			mData = null;
			parser = null;
		}

		override public function update() : void
		{
			if (mIsMouseOver != mTransform.isMouseOver)
			{
				mIsUpdatable = mIsMouseOver = mTransform.isMouseOver;
				updateRenderVisible();
			}
			if (mData.updateName)
				updateRender();
			if (mIsUpdatable)
			{
				mIsUpdatable = false;
				updatePosition();
			}
		}

		private function updateRender() : void
		{
			parser = SReferenceManager.getInstance().createRoleName(mData.name + "[" + mData.level + "级]");
			mRender.bitmapData = mParser.bitmapData;
			mData.updateName = false;
		}

		protected function updatePosition() : void
		{
			mRender.x = mTransform.screenX + -mParser.bitmapData.width * .5;
			mRender.y = mTransform.screenY + -mTransform.height - mOffsetY - mTransform.z + mTransform.centerOffsetY;
		}

		public function set parser(value : SNameParser) : void
		{
			mParser && mParser.release();
			mParser = value;
		}

		/**
		 * 不添加到父类，直接添加到name层
		 * @param render
		 *
		 */
		protected override function addRender(render : SRender) : void
		{
			SLayerManager.getInstance().addRenderByType(SLayerManager.LAYER_NAME, render);
		}

		protected override function removeRender(render : SRender) : void
		{
			SLayerManager.getInstance().removeRenderByType(SLayerManager.LAYER_NAME, render);
		}

		override protected function updateRenderVisible() : void
		{
			if (mIsVisible || mIsMouseOver)
			{
				mIsUpdatable = true;
				addRender(mRender)
				return;
			}
			mIsUpdatable = false;
			removeRender(mRender);
		}
	}
}