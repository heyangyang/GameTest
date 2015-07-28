package hy.rpg.parser
{
	import flash.utils.ByteArray;
	
	import hy.game.core.SReference;
	import hy.game.manager.SReferenceManager;
	import hy.game.resources.SResource;
	import hy.rpg.enmu.SLoadPriorityType;

	/**
	 * 资源解析器
	 *
	 */
	public class SResourceParser extends SReference
	{
		private var m_id : String;
		private var m_version : String;
		private var m_priority : int;
		protected var m_resource : SResource;

		private var m_ioErrorFuns : Vector.<Function>;
		private var m_completeFuns : Vector.<Function>;

		/**
		 * 创建一个资源解析器
		 * @param id
		 * @param version 版本
		 * @param priority 优先级
		 *
		 */
		public function SResourceParser(id : String, version : String = null, priority : int = SLoadPriorityType.MAX)
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
			if (m_resource)
				return;

			m_resource = SReferenceManager.getInstance().createResource(m_id, m_version);

			if (m_resource.isLoaded)
			{
				onResourceLoaded(m_resource);
			}
			else if (!m_resource.isLoading)
			{
				m_resource.addNotifyCompleted(onResourceLoaded).addNotifyIOError(onResourceIOError).priority(m_priority).load();
			}
		}

		/**
		 * 加载完成
		 * @param res
		 *
		 */
		private function onResourceLoaded(res : SResource) : void
		{
			if (m_resource)
			{
				parse(m_resource.getBinary());
			}
		}

		/**
		 * 加载失败
		 * @param res
		 *
		 */
		private function onResourceIOError(res : SResource) : void
		{
			invokeNotifyByArray(m_ioErrorFuns);
		}

		public function onIOError(fun : Function) : SResourceParser
		{
			if (!m_ioErrorFuns)
				m_ioErrorFuns = new Vector.<Function>();
			if (m_ioErrorFuns && m_ioErrorFuns.indexOf(fun) == -1)
				m_ioErrorFuns.push(fun);
			return this;
		}

		public function onComplete(fun : Function) : SResourceParser
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
		protected function parse(bytes : ByteArray) : void
		{
		}


		/**
		 * 解析完成后
		 *
		 */
		protected function parseCompleted() : void
		{
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
			if (m_resource)
				return m_resource.isLoaded;
			return false;
		}


		/**
		 * 正在加载
		 * @return
		 *
		 */
		public function get isLoading() : Boolean
		{
			if (m_resource)
				return m_resource.isLoading;
			return false;
		}

		override protected function destroy() : void
		{
			if (m_resource)
			{
				m_resource.release();
				m_resource = null;
			}
			cleanNotify();
			super.destroy();
		}
	}
}