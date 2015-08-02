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
		private var m_id : String;
		private var m_version : String;
		private var m_priority : int;
		private var m_isLoaded : Boolean;
		private var m_isLoading : Boolean;

		private var m_ioErrorFuns : Vector.<Function>;
		private var m_completeFuns : Vector.<Function>;

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
			m_id = id;
			m_version = version;
			m_priority = priority;
		}

		/**
		 * 开始加载
		 *
		 */
		public function load() : void
		{
			var m_resource : SResource = SReferenceManager.getInstance().createResource(m_id, m_version);

			if (m_isLoaded)
			{
				invokeNotifyByArray(m_completeFuns);
			}
			else if (m_resource.isLoaded)
			{
				m_isLoading = true;
				startParseLoader(null);
			}
			else if (!m_resource.isLoading)
			{
				m_isLoading = true;
				m_isLoaded = false;
				m_resource.addNotifyCompleted(onResourceLoaded).addNotifyIOError(onResourceIOError).priority(m_priority).load();
			}
		}

		/**
		 * 加载完成,开始解析
		 * @param res
		 *
		 */
		private function onResourceLoaded(res : SResource) : void
		{
			startParseLoader(res.getBinary());
		}

		/**
		 * 加载失败
		 * @param res
		 *
		 */
		private function onResourceIOError(res : SResource) : void
		{
			m_isLoading = false;
			m_isLoaded = false;
			invokeNotifyByArray(m_ioErrorFuns);
		}

		public function onIOError(fun : Function) : ParserResource
		{
			if (!m_ioErrorFuns)
				m_ioErrorFuns = new Vector.<Function>();
			if (m_ioErrorFuns && m_ioErrorFuns.indexOf(fun) == -1)
				m_ioErrorFuns.push(fun);
			return this;
		}

		public function onComplete(fun : Function) : ParserResource
		{
			if (!m_completeFuns)
				m_completeFuns = new Vector.<Function>();
			if (m_completeFuns && m_completeFuns.indexOf(fun) == -1)
				m_completeFuns.push(fun);
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
			m_isLoading = false;
			m_isLoaded = true;
			invokeNotifyByArray(m_completeFuns);
		}

		private function cleanNotify() : void
		{
			if (m_ioErrorFuns)
			{
				m_ioErrorFuns.length = 0;
				m_ioErrorFuns = null;
			}
			if (m_completeFuns)
			{
				m_completeFuns.length = 0;
				m_completeFuns = null;
			}
		}

		private function invokeNotifyByArray(functions : Vector.<Function>) : void
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
			return m_id;
		}

		public function get version() : String
		{
			return m_version;
		}

		public function get priority() : int
		{
			return m_priority;
		}

		/**
		 * 加载完成
		 * @return
		 *
		 */
		public function get isLoaded() : Boolean
		{
			return m_isLoaded;
		}


		/**
		 * 正在加载
		 * @return
		 *
		 */
		public function get isLoading() : Boolean
		{
			return m_isLoading;
		}

		override protected function destroy() : void
		{
			cleanNotify();
			super.destroy();
		}
	}
}