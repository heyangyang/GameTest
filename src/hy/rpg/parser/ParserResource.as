package hy.rpg.parser
{
	import flash.utils.ByteArray;
	
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
		protected var mPriority : int;
		protected var mIsLoaded : Boolean;
		protected var mIsLoading : Boolean;

		protected var mIoErrorFuns : Vector.<Function>;
		protected var mCompleteFuns : Vector.<Function>;

		public var cc:String;
		/**
		 * 创建一个资源解析器
		 * @param id
		 * @param version 版本
		 * @param priority 优先级
		 *
		 */
		public function ParserResource(id : String, version : String = null, priority : int = EnumLoadPriority.MAX)
		{
			super();
			mId = id;
			mVersion = version;
			mPriority = priority;
		}

		/**
		 * 开始加载
		 *
		 */
		public function load() : void
		{
			var mResource : SResource = SReferenceManager.getInstance().createResource(mId, mVersion);

			if (mIsLoaded)
			{
				invokeNotifyByArray(mCompleteFuns);
			}
			else if (mResource.isLoaded)
			{
				mIsLoading = true;
				startParseLoader(null);
			}
			else if (!mResource.isLoading)
			{
				mIsLoading = true;
				mIsLoaded = false;
				mResource.addNotifyCompleted(onResourceLoaded).addNotifyIOError(onResourceIOError).setPriority(mPriority).load();
			}
		}

		/**
		 * 加载完成,开始解析
		 * @param res
		 *
		 */
		protected function onResourceLoaded(res : SResource) : void
		{
			startParseLoader(res.getBinary());
		}

		/**
		 * 加载失败
		 * @param res
		 *
		 */
		protected function onResourceIOError(res : SResource) : void
		{
			mIsLoading = false;
			mIsLoaded = false;
			invokeNotifyByArray(mIoErrorFuns);
		}

		public function onIOError(fun : Function) : ParserResource
		{
			if (!mIoErrorFuns)
				mIoErrorFuns = new Vector.<Function>();
			if (mIoErrorFuns && mIoErrorFuns.indexOf(fun) == -1)
				mIoErrorFuns.push(fun);
			return this;
		}

		public function onComplete(fun : Function) : ParserResource
		{
			if (!mCompleteFuns)
				mCompleteFuns = new Vector.<Function>();
			if (mCompleteFuns && mCompleteFuns.indexOf(fun) == -1)
				mCompleteFuns.push(fun);
			return this;
		}

		/**
		 * 加载完成后解析数据
		 * @param bytes
		 *
		 */
		protected function startParseLoader(bytes : ByteArray) : void
		{
		}


		/**
		 * 解析完成后
		 *
		 */
		protected function parseCompleted() : void
		{
			mIsLoading = false;
			mIsLoaded = true;
			invokeNotifyByArray(mCompleteFuns);
		}

		private function cleanNotify() : void
		{
			if (mIoErrorFuns)
			{
				mIoErrorFuns.length = 0;
				mIoErrorFuns = null;
			}
			if (mCompleteFuns)
			{
				mCompleteFuns.length = 0;
				mCompleteFuns = null;
			}
		}

		protected function invokeNotifyByArray(functions : Vector.<Function>) : void
		{
			if (!functions)
				return;
			for each (var notify : Function in functions)
			{
				notify(this);
			}
			functions.length = 0;
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
		 * 加载完成
		 * @return
		 *
		 */
		public function get isLoaded() : Boolean
		{
			return mIsLoaded;
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

		override protected function destroy() : void
		{
			cleanNotify();
			super.destroy();
		}
	}
}