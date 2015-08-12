package hy.rpg.parser
{
	import flash.geom.Point;
	import flash.utils.ByteArray;

	import hy.game.animation.SAnimationDescription;
	import hy.game.cfg.Config;
	import hy.game.core.interfaces.IBitmapData;
	import hy.game.manager.SReferenceManager;
	import hy.game.resources.SResource;
	import hy.rpg.enum.EnumLoadPriority;


	/**
	 *  动画资源解析器
	 *
	 */
	public class ParserAnimationResource extends ParserPakResource
	{
		protected var action_name : String;

		public function ParserAnimationResource(desc : SAnimationDescription, priority : int = EnumLoadPriority.EFFECT)
		{
			super(desc.url, desc.version, priority);
		}

		override public function load() : void
		{
			var cur_id : String = id;
			if (Config.supportDirectX)
			{
				var tmp : Array = id.split("/");
				tmp.pop();
				tmp[0] = "avatar_atf";
				tmp.push(tmp[1] + ".xtf");
				cur_id = tmp.join("/");
			}

			var m_resource : SResource = SReferenceManager.getInstance().createResource(id, version);

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
				m_resource.addNotifyCompleted(onResourceLoaded).addNotifyIOError(onResourceIOError).setPriority(m_priority).load();
			}
		}

		override protected function startParseLoader(bytes : ByteArray) : void
		{
			var cur_id : String = id;
			if (Config.supportDirectX)
			{
				var tmp : Array = id.split("/");
				tmp[0] = "avatar_atf";
				tmp.push(tmp.pop().split(".")[0] + ".xtf");
				cur_id = tmp.join("/");
			}
			if (action_name == null)
				action_name = id.split("/").pop().split(".").shift();
			decoder = SReferenceManager.getInstance().createDirectAnimationDeocder(cur_id);
			_decoder.addNotify(onParseCompleted);
			if (Config.supportDirectX)
				_decoder.startXtfLoad(version, priority);
			else
				_decoder.decode(bytes, false);
		}


		override protected function loadThreadResource() : void
		{
			var cur_id : String = id;
//			if (_isDirect)
//			{
//				var tmp : Array = id.split("/");
//				tmp.pop();
//				tmp[0] = "avatar_atf";
//				tmp.push(tmp[1] + ".xtf");
//				cur_id = tmp.join("/");
//			}
			if (action_name == null)
				action_name = id.split("/").pop().split(".").shift();
			decoder = SReferenceManager.getInstance().createDirectAnimationDeocder(cur_id);
			if (!_decoder.isCompleted)
				_decoder.addNotify(parseComplete);
			else
				parseComplete(_decoder);
			if (!_decoder.isSend)
			{
				_decoder.isSend = true;

				//直接用使用atf加载，不经过多线程
//				if (_isDirect)
//				{
//					_decoder.startXtfLoad(version, priority);
//					return;
//				}

				if (load_list.length > COUNT)
				{
					need_send_list.push([id, version, priority]);
					isSort = true;
				}
				else
				{
					var send_arr : Array = [id, version, priority];
					load_list.push(send_arr);
//					SThreadEvent.dispatchEvent(SThreadEvent.LOAD_SEND, send_arr);
				}
			}
		}

		public function getBitmapDataByDir(frame : int, dir : String) : IBitmapData
		{
			if (_decoder)
				return _decoder.getDirResult(action_name, frame - 1, dir);
			return null;
		}

		override public function getOffset(index : int, dir : String) : Point
		{
			if (_decoder)
				return _decoder.getDirOffest(action_name, index, dir);
			return null;
		}
	}
}