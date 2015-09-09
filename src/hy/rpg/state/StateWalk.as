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
		private var mStepTargetX : int;
		private var mStepTargetY : int;
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
			var tPaths : Array = mSeekRoad.find(UtilsCommon.getGridXByPixel(mTransform.x), UtilsCommon.getGridXByPixel(mTransform.y), mData.targetGridX, mData.targetGridY);
			if (!tPaths || tPaths.length <= 1)
				return false;
			mPaths = tPaths;
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
			mStepTargetX = mStepTargetY = -1
			mStep = 1;
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
				if (tryChangeState())
				{
					enterState();
				}
			}

			if (mStepTargetX == -1 || mStepTargetY == -1)
			{
				mStepTargetX = UtilsCommon.getPixelXByGrid(mPaths[mStep][0]);
				mStepTargetY = UtilsCommon.getPixelYByGrid(mPaths[mStep][1]);
				updateAnagle();
			}

			mTargetDistance = UtilsCommon.getDistance(mTransform.x, mTransform.y, mStepTargetX, mStepTargetY);
			mMoveSpeed = mData.speed * STime.deltaTime;


			//距离小于速度,达到这格格子末尾
			if (mTargetDistance <= Math.ceil(mMoveSpeed))
			{
				if (++mStep >= mStepEnd)
				{
					mTransform.x = mData.targetX;
					mTransform.y = mData.targetY;
					onStand();
					return;
				}
				mStepTargetX = mStepTargetY = -1
			}
			mTransform.x += UtilsCommon.cosd(mTargetAnagle) * mMoveSpeed;
			mTransform.y += UtilsCommon.sind(mTargetAnagle) * mMoveSpeed;
//			if (!mData.isMe && !SCameraObject.isInScreen(mTransform))
//				ManagerGameObject.getInstance().deleteGameObject(mOwner);
		}

		private function updateAnagle() : void
		{
			mTargetAnagle = UtilsCommon.getAngle(mTransform.x, mTransform.y, mStepTargetX, mStepTargetY);
			mTransform.dir = UtilsCommon.getDirection(mTargetAnagle);
		}

		private function onStand() : void
		{
			changeStateId(EnumState.STAND);
		}
	}
}