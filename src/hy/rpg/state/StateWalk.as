package hy.rpg.state
{
	import hy.game.avatar.SActionType;
	import hy.game.core.GameObject;
	import hy.game.core.SCameraObject;
	import hy.game.core.STime;
	import hy.game.namespaces.name_part;
	import hy.game.state.SBaseState;
	import hy.game.state.StateComponent;
	import hy.rpg.manager.ManagerGameObject;
	import hy.rpg.seek.SRoadSeeker;
	import hy.rpg.utils.UtilsCommon;

	use namespace name_part;

	public class StateWalk extends SBaseState
	{
		protected var mSeekRoad : SRoadSeeker;
		private var mPaths : Array;
		private var mStep : int;
		private var mStepEnd : int;
		private var mLastTargetGridX : int;
		private var mLastTargetGridY : int;
		private var mTargetDistance : int;
		private var mTargetAnagle : int;
		private var mMoveSpeed : Number;

		public function StateWalk(gameObject : GameObject, stateMgr : StateComponent)
		{
			super(gameObject, stateMgr);
			mAction = SActionType.RUN;
			mId = EnumState.WALK;
			mSeekRoad = SRoadSeeker.getInstance();
		}

		/**
		 * 尝试是否可以转换该状态
		 * @return
		 *
		 */
		override public function tryChangeState() : Boolean
		{
			if (mSeekRoad.isBlock(mData.targetGridX, mData.targetGridY))
				return false;
			mPaths = mSeekRoad.find(UtilsCommon.getGridXByPixel(mTransform.x), UtilsCommon.getGridXByPixel(mTransform.y), mData.targetGridX, mData.targetGridY);
			if (!mPaths || mPaths.length == 0)
				return false;
			return true;
		}

		/**
		 * 进入当前动作处理
		 *
		 */
		override public function enterState() : void
		{
			mLastTargetGridX = mData.targetGridX;
			mLastTargetGridY = mData.targetGridY;
			mStepEnd = mPaths.length;
			mStep = 0;
		}

		/**
		 * 更新动作
		 * @param delay
		 *
		 */
		override public function update() : void
		{
			super.update();
			if (mLastTargetGridX != mData.targetGridX || mLastTargetGridY != mData.targetGridY)
			{
				if (!tryChangeState())
				{
					onStand();
					return;
				}
				enterState();
			}

			mTargetDistance = UtilsCommon.getDistance(mTransform.x, mTransform.y, mData.targetX, mData.targetY);
			mMoveSpeed = mData.speed * STime.deltaTime;
			mTargetAnagle = UtilsCommon.getAngle(mTransform.x, mTransform.y, mData.targetX, mData.targetY);

			//距离小于速度,达到这格格子末尾
			if (mTargetDistance <= Math.ceil(mMoveSpeed))
			{
				onStand();
			}
			else
			{
				mTransform.dir = UtilsCommon.getDirection(mTargetAnagle);
				mTransform.mAddX = UtilsCommon.cosd(mTargetAnagle) * mMoveSpeed;
				mTransform.mAddY = UtilsCommon.sind(mTargetAnagle) * mMoveSpeed;
				mTransform.x += mTransform.mAddX;
				mTransform.y += mTransform.mAddY;
				if (!mData.isMe && !SCameraObject.isInScreen(mTransform))
					ManagerGameObject.getInstance().deleteGameObject(mOwner);
			}
		}

		private function onStand() : void
		{
			changeStateId(EnumState.STAND);
		}
	}
}