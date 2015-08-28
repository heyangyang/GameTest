package hy.rpg.parser
{
	import flash.utils.ByteArray;
	
	import hy.game.core.SCall;
	import hy.game.core.SReference;
	import hy.game.manager.SReferenceManager;
	import hy.game.resources.SResource;
	import hy.rpg.enum.EnumLoadPriority;

	/**
	 * 资源解析器
	 *
	 */
	public class ParserResource extends SReference
	{
		private var mId : String;
		private var mVersion : String;
		private var mPriority : int;
		private var mIsCompleted : Boolean;
		private var mIsLoading : Boolean;

		private var mIoErrorCall : SCall;
		private var mCompleteCall : SCall;

		public var cc : String;

		/**
		 * 创建一个资源解析器
		 * @param id
		 * @param version 版本
		 * @param priority 优先级
		 *
		 */
		public function ParserResource(id : String, version : String = null, priority : int = EnumLoadPriority.MIN)
		{
			super();
			mId = id;
			mVersion = version;
			mPriority = priority;
			mIoErrorCall = new SCall(this);
			mCompleteCall = new SCall(this);
		}

		/**
		 * 开始加载
		 *
		 */
		public function load() : void
		{
			var mResource : SResource = SReferenceManager.getInstance().createResource(mId, mVersion);

			//已经加载并且处理完毕
			if (mIsCompleted)
			{
				mCompleteCall.excute();
				mCompleteCall.clear();
			}
			//资源加载完毕，需要解析
			else if (mResource.isLoaded)
			{
				mIsLoading = true;
				parseLoaderData(null);
			}
			else if (!mResource.isLoading)
			{
				mIsLoading = true;
				mIsCompleted = false;
				mResource.addNotifyCompleted(onResourceLoaded).addNotifyIOError(onResourceIOError).setPriority(mPriority).load();
			}
		}

		/**
		 * 加载完成,开始解析
		 * @param res
		 *
		 */
		private function onResourceLoaded(res : SResource) : void
		{
			parseLoaderData(res.getBinary());
		}

		/**
		 * 加载失败
		 * @param res
		 *
		 */
		private function onResourceIOError(res : SResource) : void
		{
			mIsLoading = false;
			mIsCompleted = false;
			mIoErrorCall.excute();
			mIoErrorCall.clear();
		}

		public function onIOError(fun : Function) : ParserResource
		{
			mIoErrorCall.push(fun);
			return this;
		}

		public function onComplete(fun : Function) : ParserResource
		{
			mCompleteCall.push(fun);
			return this;
		}

		/**
		 * 加载完成后解析数据
		 * @param bytes
		 *
		 */
		protected function parseLoaderData(bytes : ByteArray) : void
		{
			
		}


		/**
		 * 解析完成后
		 *
		 */
		protected function parseLoaderCompleted() : void
		{
			mIsLoading = false;
			mIsCompleted = true;
			mCompleteCall.excute();
		}

		/**
		 * 加载id
		 * @return
		 *
		 */
		public function get id() : String
		{
			return mId;
		}

		public function get version() : String
		{
			return mVersion;
		}

		public function get priority() : int
		{
			return mPriority;
		}

		/**
		 * 加载并且解析完成
		 * @return
		 *
		 */
		public function get isComplete() : Boolean
		{
			return mIsCompleted;
		}

		/**
		 * 正在加载
		 * @return
		 *
		 */
		public function get isLoading() : Boolean
		{
			return mIsLoading;
		}

		override protected function dispose() : void
		{
			if (mIoErrorCall)
			{
				mIoErrorCall.dispose();
				mIoErrorCall = null;
			}
			if (mCompleteCall)
			{
				mCompleteCall.dispose();
				mCompleteCall = null;
			}
			super.dispose();
		}
	}
}