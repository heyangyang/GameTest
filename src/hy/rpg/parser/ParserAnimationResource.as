package hy.rpg.parser
{
	import flash.geom.Point;
	
	import hy.game.animation.SAnimationDescription;
	import hy.game.core.interfaces.IBitmapData;
	import hy.game.manager.SReferenceManager;
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