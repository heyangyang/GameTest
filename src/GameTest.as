package
{
	import flash.display.Sprite;
	import flash.events.Event;

	import hy.game.GameFrameStart;
	import hy.game.core.interfaces.IRender;


	public class GameTest extends Sprite
	{
		public function GameTest()
		{
			stage ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(evt : Event = null) : void
		{
			for (var i : int = 0; i <53; i++)
			{
				mChilds.push(int(Math.random() * 1000));
			}
			mChilds.sort(Array.NUMERIC);
			mNumChildren = mChilds.length;
			trace(mChilds)
			sort2Push(666);
//			trace(sStartSortIndex , sEndSortIndex)
//			trace(sSortPushIndex)
			//	new GameFrameStart(stage, new GameStarter());
		}

		private static var sSortIndex : int;
		private static var sStartSortIndex : int;
		private static var sEndSortIndex : int;
		private static var mNumChildren : int;
		private static var mChilds : Array = [];

		//[1,2,3,4,5,7,8,9]
		//6
		public function sort2Push(child : int) : void
		{
			//中间开始查找
			sStartSortIndex = 0;
			sEndSortIndex = mNumChildren - 1;
			var index : int = 1;
			var add : int = sSortIndex = Math.ceil(mNumChildren - 1 >> index);
			while (add > 0)
			{
				add = Math.ceil(mNumChildren - 1 >> ++index);
				//向后查找
				if (child > mChilds[sSortIndex])
				{
					sStartSortIndex = sSortIndex;
					sSortIndex += add;
				}
				//向前查找
				else
				{
					sEndSortIndex = sSortIndex;
					sSortIndex -= add;
				}
				if (index > 10)
					break;
			}
			for (var i : int = sStartSortIndex; i <= sEndSortIndex; i++)
			{
				if (child < mChilds[i])
				{
					break;
				}
			}
			mChilds.splice(i, 0, child);
			trace(mChilds);
			trace(index - 1, sStartSortIndex, sEndSortIndex);
		}
	}
}