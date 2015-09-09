package hy.rpg.components
{
	import hy.game.avatar.SActionType;
	import hy.game.components.SAvatarComponent;
	import hy.rpg.enum.EnumDirection;
	import hy.rpg.enum.EnumLoadPriority;
	import hy.rpg.enum.EnumRenderLayer;

	public class ComponentWing extends SAvatarComponent
	{
		public function ComponentWing(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			mResource.priority = EnumLoadPriority.WING;
		}

		override protected function onStart() : void
		{
			super.onStart();
			setAvatarId(mData.wingId);
		}

		/**
		 * 转换动作的一些操作
		 *
		 */
		override protected function changeAvatarAction() : void
		{
			mAvatar.gotoDirection(mTransform.dir);
			mRender.layer = EnumDirection.isBackDirection(mTransform.dir) ? EnumRenderLayer.WING_BACK : EnumRenderLayer.WING;
			mUpdateRectangle = true;
		}

		/**
		 * 加载完毕
		 *
		 */
		override protected function onLoadAvatarComplete() : void
		{
			mAvatar.gotoAnimation(SActionType.IDLE, mTransform.dir, 0, 0);
			changeAvatarAction();
		}
	}
}