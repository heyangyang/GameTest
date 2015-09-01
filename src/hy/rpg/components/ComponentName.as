package hy.rpg.components
{
	import hy.game.components.SRenderComponent;
	import hy.game.manager.SLayerManager;
	import hy.game.manager.SReferenceManager;
	import hy.rpg.components.data.DataComponent;
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
			mData = mOwner.getComponentByType(DataComponent) as DataComponent;
			mTransform.addPositionChange(updatePosition);
			mTransform.addSizeChange(updatePosition);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			mLayerType = SLayerManager.LAYER_NAME;
//			mRender.layer = EnumRenderLayer.NAME;
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
			mRender.depth = mTransform.screenY;
		}

		public function set parser(value : SNameParser) : void
		{
			mParser && mParser.release();
			mParser = value;
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